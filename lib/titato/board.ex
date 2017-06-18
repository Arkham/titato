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

  def available_moves(%__MODULE__{data: data}) do
    data
    |> Enum.with_index
    |> Enum.reject(fn {value, _index} -> value != @empty end)
    |> Enum.map(fn {_value, index} -> index end)
  end

  def put(%__MODULE__{data: data} = board, value, index) when index in 0..8 do
    case Enum.at(data, index) do
      :empty ->
        new_data = List.update_at(data, index, fn(_) -> value end)
        {:ok, %{board | data: new_data}}

      _ -> :error
    end
  end
  def put(_board, _value, _index), do: :error

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

  def to_string(%__MODULE__{data: data}) do
    v = fn(index) ->
      case Enum.at(data, index) do
        @empty -> index
        value -> value
      end
    end

    separator = for _ <- 1..7, do: "-"

    """
    #{separator}
     #{v.(0)} #{v.(1)} #{v.(2)}
    #{separator}
     #{v.(3)} #{v.(4)} #{v.(5)}
    #{separator}
     #{v.(6)} #{v.(7)} #{v.(8)}
    #{separator}
    """
  end
end
