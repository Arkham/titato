require Logger

defmodule Titato.Players.Computer do
  use GenServer

  alias Titato.Board

  defmodule State do
    defstruct server: nil, value: nil
  end

  def start_link(server, value \\ :O) do
    GenServer.start_link(__MODULE__, {server, value})
  end

  def init({server, value}) do
    {:ok, %State{server: server, value: value}}
  end

  def handle_info({:play, board}, %{server: server, value: value} = state) do
    position = Board.available_moves(board) |> Enum.random()
    Titato.Server.put(server, value, position)
    {:noreply, state}
  end
  def handle_info(message, state) do
    Logger.debug("#{inspect self()} Received message #{inspect message}")
    {:noreply, state}
  end
end
