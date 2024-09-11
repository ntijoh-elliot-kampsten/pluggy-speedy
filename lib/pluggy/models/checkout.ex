defmodule Pluggy.Checkout do
  # Function to get the current order for a user
  def get_current_order(user_id) do
    query = """
    SELECT * FROM orders WHERE user_id = $1
    """
    Postgrex.query!(DB, query, [user_id]).rows
  end

  # Function to finalize an order
  def finalize_order(order_id) do
    query = """
    UPDATE orders SET state = 'Registered' WHERE id = $1
    """
    Postgrex.query!(DB, query, [order_id])
  end
end
