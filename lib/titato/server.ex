defmodule Titato.Server do
  use GenServer

  alias Titato.Board

  defmodule State do
    defstruct board: nil, players: nil, current_player: nil
  end

  # Public API
  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def start_game(pid, players, board \\ %Board{}) do
    GenServer.call(pid, {:start_game, players, board})
  end

  def put(pid, piece, position) do
    GenServer.call(pid, {:put, piece, position})
  end

  # Callbacks
  def init(:ok) do
    {:ok, %State{}}
  end

  def handle_call({:start_game, {first, _} = players, board}, _from, state) do
    notify_player(first, {:play, board})
    {:reply, :ok, %{state | board: board, players: players, current_player: first}}
  end
  def handle_call({:put, piece, position}, {current, _}, %{current_player: current} = state) do
    opponent = toggle_player(current, state.players)

    case Board.put(state.board, piece, position) do
      {:ok, board} ->
        cond do
          Board.winner(board) == {:ok, piece} ->
            notify_player(current, {:game_over, :victory, board})
            notify_player(opponent, {:game_over, :loss, board})
          Board.tie?(board) ->
            notify_player(current, {:game_over, :tie, board})
            notify_player(opponent, {:game_over, :tie, board})
          true ->
            notify_player(opponent, {:play, board})
        end

        {:reply, :ok, %{state | board: board, current_player: opponent}}
      :error ->
        {:reply, :retry, state}
    end
  end

  # Internals
  defp notify_player(player, message), do: send player, message

  defp toggle_player(first, {first, second}), do: second
  defp toggle_player(second, {first, second}), do: first
end
