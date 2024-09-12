defmodule Pluggy.Checkout do
  alias Pluggy.Order

  # Function to get the current order for a user
  def get_current_order(user_id) do
    query = """
    SELECT * FROM orders WHERE user_id = $1
    """
    Postgrex.query!(DB, query, [user_id]).rows
    |> Order.parse_data
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
