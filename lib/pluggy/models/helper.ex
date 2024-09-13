defmodule Pluggy.Helper do
  #####
  ##### Made for functionns that will be used al over the project and does not have a home
  #####

  def safe_string_to_integer(val) when is_binary(val) do
    case Integer.parse(val) do
      {int, _} -> int
      :error -> ""
    end
  end
  def safe_string_to_integer(val) when is_integer(val), do: val
  def safe_string_to_integer(_), do: ""

  def safe_integer_to_string(val) when is_integer(val), do: Integer.to_string(val)
  def safe_integer_to_string(val) when is_binary(val), do: val
  def safe_integer_to_string(_), do: ""
end
