defmodule Titato.Cli do
  alias Titato.{Server,Players}

  def start_game() do
    {:ok, pid} = Server.start_link()
    {:ok, human} = Players.CliHuman.start_link(pid, self())
    {:ok, computer} = Players.Computer.start_link(pid)
    Server.start_game(pid, {human, computer})
    loop(human)
  end

  def loop(human) do
    receive do
      {ref, :play, board} ->
        IO.puts Titato.Board.to_string(board)
        move = read_move()
        send human, {ref, :move, move}
        loop(human)

      {:game_over, :victory, board} ->
        IO.puts Titato.Board.to_string(board)
        IO.puts "Game Over, you won!"

      {:game_over, :loss, board} ->
        IO.puts Titato.Board.to_string(board)
        IO.puts "Game Over, you lost!"

      {:game_over, :tie, board} ->
        IO.puts Titato.Board.to_string(board)
        IO.puts "Game Over, it's a tie!"
    end
  end

  defp read_move() do
    input = IO.gets("Choose your move [0-8]: ")
    IO.puts ""

    case Integer.parse(input) do
      {num, _} when num in 0..8 ->
        num

      _ ->
        IO.puts("Invalid move, please try again.")
        read_move()
    end
  end
end
