require Logger

defmodule Titato.Players.CliHuman do
  use GenServer

  defmodule State do
    defstruct piece: nil, cli: nil, server: nil
  end

  def start_link(server, cli, piece \\ :X) do
    GenServer.start_link(__MODULE__, {server, cli, piece})
  end

  def init({server, cli, piece}) do
    {:ok, %State{server: server, cli: cli, piece: piece}}
  end

  def handle_info({:play, board}, %{piece: piece, cli: cli, server: server} = state) do
    ref = make_ref()
    send cli, {ref, :play, board}

    receive do
      {^ref, :move, position} ->
        case Titato.Server.put(server, piece, position) do
          :ok -> :ok
          :retry -> send(self(), {:play, board})
        end
    end

    {:noreply, state}
  end
  def handle_info({:game_over, result, board}, %{cli: cli} = state)
  when result in [:victory, :loss, :tie] do
    send cli, {:game_over, result, board}
    {:noreply, state}
  end
  def handle_info(message, state) do
    Logger.debug("#{inspect self()} Received message #{inspect message}")
    {:noreply, state}
  end
end
