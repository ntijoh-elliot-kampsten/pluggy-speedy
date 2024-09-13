defmodule Pluggy.Layout do
  alias Pluggy.Order

  def get_basket_amount(user_name) do
    cond do
      Enum.count(Order.get_user_unsubmitted_order(user_name)) == 0 -> 0
      true -> count_basket_amount(Enum.at(Order.get_user_unsubmitted_order_parsed(user_name), 0).order)
    end
  end

  defp count_basket_amount(_, amount \\ 0)
  defp count_basket_amount([], amount), do: amount
  defp count_basket_amount([head | tail], amount), do: count_basket_amount(tail, amount + head.amount)
end
