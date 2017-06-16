defmodule Titato.Board do

  @empty :empty
  @initial (for _ <- 1..9, do: @empty)
  @winning_lines_indexes [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], # horizontal
    [0, 3, 6], [1, 4, 7], [2, 5, 8], # vertical
    [0, 4, 8], [2, 4, 6]             # diagonal
  ]

  defstruct data: @initial

  def empty, do: @empty

  def empty?(%__MODULE__{data: data}) do
    data |> Enum.all?(& &1 == @empty)
  end

  def full?(%__MODULE__{data: data}) do
    data |> Enum.all?(& &1 != @empty)
  end

  def update_at(%__MODULE__{data: data} = board, index, value) do
    %{board | data: List.update_at(data, index, fn(_) -> value end)}
  end

  def winner(%__MODULE__{data: data})  do
    @winning_lines_indexes
    |> Enum.reduce_while(:not_found, fn indexes, _acc ->
      result =
        indexes
        |> Enum.map(&(Enum.at(data, &1)))
        |> Enum.uniq

      case length(result) do
        1 -> {:halt, {:ok, List.first(result)}}
        _ -> {:cont, :not_found}
      end
    end)
  end

  def victory?(board) do
    case winner(board) do
      :not_found -> false
      _ -> true
    end
  end

  def tie?(board) do
    !victory?(board) && full?(board)
  end

  def game_over?(board) do
    victory?(board) || full?(board)
  end
end
