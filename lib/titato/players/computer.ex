require Logger

defmodule Titato.Players.Computer do
  use GenServer

  alias Titato.Board

  defmodule State do
    defstruct server: nil, piece: nil
  end

  def start_link(server, piece \\ :O) do
    GenServer.start_link(__MODULE__, {server, piece})
  end

  def init({server, piece}) do
    {:ok, %State{server: server, piece: piece}}
  end

  def handle_info({:play, board}, %{server: server, piece: piece} = state) do
    position = best_move(board, piece)
    Titato.Server.put(server, piece, position)
    {:noreply, state}
  end
  def handle_info(message, state) do
    Logger.debug("#{inspect self()} Received message #{inspect message}")
    {:noreply, state}
  end

  def best_move(board, piece) do
    {position, _} = minmax(board, piece, piece)
    position
  end

  def minmax(board, current_piece, original_piece) do
    scores =
      board
      |> Board.available_moves()
      |> Enum.map(fn position ->
        {:ok, board} = Board.put(board, current_piece, position)

        case Board.game_over?(board) do
          true -> {position, score(board, original_piece)}
          false ->
            {_, score} = minmax(board, toggle_piece(board, current_piece), original_piece)
            {position, score}
        end
      end)

    best_score(scores, original_piece, current_piece)
  end

  def best_score(scores, original_piece, current_piece)
  when original_piece == current_piece do
    scores
    |> Enum.max_by(fn {_, score} -> score end)
  end
  def best_score(scores, _original_piece, _current_piece) do
    scores
    |> Enum.min_by(fn {_, score} -> score end)
  end

  def score(board, piece) do
    cond do
      Board.winner(board) == {:ok, piece} -> 1
      Board.winner(board) == {:ok, toggle_piece(board, piece)} -> -1
      true -> 0
    end
  end

  def toggle_piece(board, piece) do
    {:ok, other} = Board.toggle_piece(board, piece)
    other
  end
end
