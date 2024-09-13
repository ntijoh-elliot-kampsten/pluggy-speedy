defmodule Pluggy.Layout do
  alias Pluggy.Order

  def get_basket_amount(user_name), do: count_basket(Enum.at(Order.get_user_unsubmitted_order(user_name), 0).order)
  defp count_basket(_, count \\ 0)
  defp count_basket([], count), do: count
  defp count_basket([_head|tail], count), do: count_basket(tail, count + 1)
end
