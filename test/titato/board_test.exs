defmodule Titato.BoardTest do
  use ExUnit.Case
  alias Titato.Board

  test "it creates an empty board" do
    board = %Board{}
    assert Board.empty?(board) == true
  end

  test "it allows to fill the board" do
    {:ok, board} = %Board{} |> Board.put(:X, 0)
    assert Board.empty?(board) == false
  end

  test "it returns error when using it wrong" do
    board = %Board{}
    assert Board.put(board, :X, 100) == :error
  end

  test "it returns error when trying to modify an existing tile" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :O, :O,
      :X, :X, :X
    ]}

    assert Board.put(board, :X, 0) == :error
  end

  test "it returns error when putting an illegal value" do
    board = %Board{}
    assert Board.put(board, :hi, 0) == :error

    board = %Board{pieces: [:hi, :ho]}
    assert Board.put(board, :hi, 0) != :error
  end

  test "it tells when the board is full" do
    board = %Board{data: (for _ <- 1..9, do: :X)}
    assert Board.full?(board) == true
  end

  test "it tells an empty board is not winning" do
    board = %Board{}
    assert Board.winner(board) == :not_found
  end

  test "it recognizes a horizontal winning position" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :O, :O,
      :X, :X, :X
    ]}

    assert Board.winner(board) == {:ok, :X}
    assert Board.victory?(board) == true
  end

  test "it recognizes a vertical winning position" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :O, :X,
      :O, :X, :X
    ]}

    assert Board.winner(board) == {:ok, :X}
    assert Board.victory?(board) == true
  end

  test "it recognizes a diagonal winning position" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :X, :O,
      :X, :O, :X
    ]}

    assert Board.winner(board) == {:ok, :X}
    assert Board.victory?(board) == true
  end

  test "it recognizes when there is no winner" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :X, :O,
      :O, :O, :X
    ]}

    assert Board.winner(board) == :not_found
    assert Board.victory?(board) == false
  end

  test "it recognizes when the board is tied" do
    board = %Board{data: [
      :O, :O, :X,
      :X, :X, :O,
      :O, :O, Board.empty
    ]}
    assert Board.tie?(board) == false

    board = %Board{data: [
      :O, :O, :X,
      :X, :X, :O,
      :O, :O, :X
    ]}
    assert Board.tie?(board) == true
  end

  test "it knows when the game is over" do
    board = %Board{data: [
      :X, :O, :X,
      :X, :X, :O,
      :O, :O, :X
    ]}
    assert Board.game_over?(board) == true

    board = %Board{data: [
      :O, :O, :X,
      :X, :X, :O,
      :O, :O, :X
    ]}
    assert Board.game_over?(board) == true

    e = Board.empty()
    board = %Board{data: [
       e, :O, :X,
      :X, :X, :O,
      :O, :O, :X
    ]}
    assert Board.game_over?(board) == false
  end

  test "it returns the available moves" do
    e = Board.empty()

    board = %Board{data: [
      :O, :O,  e,
      :X,  e, :O,
      :O, :O,  e
    ]}

    assert Board.available_moves(board) == [2, 4, 8]
  end

  test "it returns the string representation of the board" do
    board = %Board{}

    assert Board.to_string(board) ==
      """
      -------
       0 1 2
      -------
       3 4 5
      -------
       6 7 8
      -------
      """

    {:ok, board} = Board.put(board, :X, 0)

    assert Board.to_string(board) ==
      """
      -------
       X 1 2
      -------
       3 4 5
      -------
       6 7 8
      -------
      """
  end
end
