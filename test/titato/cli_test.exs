defmodule Titato.CliTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  defmodule FakeIO do
    def start_link() do
      Agent.start_link(fn -> {[], 0} end, name: __MODULE__)
    end

    def set_inputs(inputs) do
      Agent.update(__MODULE__, fn _ ->
        {inputs, 0}
      end)
    end

    def gets(_prompt) do
      Agent.get_and_update(__MODULE__, fn {inputs, counter} ->
        {Enum.at(inputs, counter), {inputs, counter + 1}}
      end)
    end
  end

  setup do
    FakeIO.start_link()
    Application.put_env(:titato, :cli_io, FakeIO)
  end

  test "it plays a normal game of titato" do
    FakeIO.set_inputs(~w{4 8 1 5 6})

    assert capture_io(fn ->
      Titato.Cli.start_game()
    end) =~ "Game Over, it's a tie!"
  end
end
