defmodule Titato.Players.ComputerTest do
  use ExUnit.Case
  alias Titato.Board
  alias Titato.Players.Computer

  test "it wins immediately if it can" do
    e = Board.empty()
    board = %Board{data: [
      :X, :X, e,
      :O, :O, e,
      :X,  e, e,
    ]}

    assert Computer.best_move(board, :O) == 5
  end

  test "it stops opponent from winning immediately" do
    e = Board.empty()
    board = %Board{data: [
      :X, :X, e,
      :O,  e, e,
       e,  e, e,
    ]}

    assert Computer.best_move(board, :O) == 2
  end

  test "it stops opponent from winning in following turns" do
    e = Board.empty()
    board = %Board{data: [
     :X, :O, e,
     :X,  e, e,
     :O, :X, e,
    ]}

    assert Computer.best_move(board, :O) == 4
  end
end
