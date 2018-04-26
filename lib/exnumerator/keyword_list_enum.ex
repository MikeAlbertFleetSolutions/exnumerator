defmodule Exnumerator.KeywordListEnum do
  def cast(values, term) do
    with atom_term = atom_term(term), true <- Keyword.has_key?(values, atom_term) do
      {:ok, atom_term}
    else
      _ -> find_value(values, term)
    end
  end

  def load(values, term), do: find_value(values, term)

  def dump(values, term) do
    with nil <- Keyword.get(values, atom_term(term)),
         {:ok, key} <- find_value(values, term) do
      {:ok, Keyword.get(values, key)}
    else
      :error -> :error
      value -> {:ok, value}
    end
  end

  # when a string key, convert to atom
  defp atom_term(term)
      when is_binary(term),
      do: String.to_atom(term)

  # when an atom key, return
  defp atom_term(term) when is_atom(term), do: term

  # all others are invalid and should be omitted / made nil
  defp atom_term(_term), do: nil

  defp find_value(values, term) do
    with {key, _value} <- key_by_value(values, term), do: {:ok, key}
  end

  defp key_by_value(values, term) do
    if is_binary(term) and is_integer_string?(term) and all_integers?(values) do
      Enum.find(values, :error, &matching(String.to_integer(term), &1))
    else
      Enum.find(values, :error, &matching(term, &1))
    end
  end

  defp matching(term, {_key, term}), do: true
  defp matching(_term, _tuple), do: false

  defp all_integers?(values) do
    values
    |> Keyword.values
    |> Enum.all?(fn(x) -> is_integer(x) end)
  end

  defp is_integer_string?(term) do
    case Integer.parse(term) do
      {_num, ""} -> true
      _ -> false
    end
  end
end
