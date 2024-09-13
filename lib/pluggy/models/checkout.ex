defmodule Pluggy.Checkout do
  alias Pluggy.Order

  # Function to get the current order for a user
  def get_current_order(user_id) do
    query = """
    SELECT * FROM orders WHERE user_id = $1
    """

    # Execute the query
    result = Postgrex.query!(DB, query, [user_id]).rows

    # Check if the result is empty, return an empty list if true
    if Enum.empty?(result) do
      []
    else
      result
      |> Order.parse_data()
      |> get_pizza_name()
    end
  end

    def get_pizza_name(order) do
      order_map = Enum.at(order, 0, %{})  # Default to an empty map if nil
      pizza_id = Enum.at(order_map.order, 0, %{}) |> Map.get(:pizza_id, nil)

      if pizza_id do
        query = """
        SELECT name FROM pizzas WHERE id = $1
        """
        pizza_name = Postgrex.query!(DB, query, [pizza_id]).rows
        [Map.put(order_map, :pizza_name, Enum.at(Enum.at(pizza_name, 0), 0))]
      else
        [order_map]
      end
    end

  # Function to finalize an order
  def finalize_order(order_id) do
    query = """
    UPDATE orders SET state = 'Registered' WHERE id = $1
    """
    Postgrex.query!(DB, query, [order_id])
  end

  # Function to remove a pizza from an order
  def remove_pizza(order_id, pizza_id) do
    query = """
    DELETE FROM order_items WHERE order_id = $1 AND pizza_id = $2
    """
    Postgrex.query!(DB, query, [order_id, pizza_id])
  end
end
