defmodule Pluggy.CheckoutController do
  require IEx

  alias Pluggy.Checkout
  alias Pluggy.User
  alias Pluggy.Order
  import Pluggy.Template, only: [render: 4, render: 3]
  import Plug.Conn, only: [send_resp: 3]

  def index(conn) do
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    # Ensure orders is always a list
    orders = Order.get_user_unsubmitted_order_parsed(current_user) || []

    # Calculate the total amount safely
    total_amount =
      orders
      |> Enum.flat_map(&(&1.order || [])) # Ensure `order` is not nil
      |> Enum.reduce(0.0, fn pizza, acc ->
        acc + ((pizza.amount || 0) * (pizza.price || 0.0)) # Default to 0 if nil
      end)

    send_resp(conn, 200, render(conn, "pizzas/checkout", user: current_user, orders: orders, total_amount: total_amount))
  end


  def finalize(conn, %{"order_id" => order_id}) do
    IO.inspect(order_id, label: "Received Order ID")

    case Integer.parse(order_id) do
      {order_id_int, _} ->
        Checkout.finalize_order(order_id_int)
        redirect(conn, "/order_confirmation")

      :error ->
        IO.puts("Invalid order ID received: #{order_id}")
        send_resp(conn, 400, "Invalid order ID")
    end
  end

  def confirmation(conn) do
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    orders = Pluggy.Checkout.get_current_order(1)

    IO.inspect(orders, label: "Orders Data")
    total_amount =
      if is_list(orders) do
        orders
        |> Enum.flat_map(& &1.order)
        |> Enum.reduce(0.0, fn pizza, acc ->
          acc + pizza.amount * pizza.price
        end)
      else
        0.0
      end

    IO.inspect(total_amount, label: "Total Amount")

    send_resp(
      conn,
      200,
      Pluggy.Template.render(conn, "pizzas/confirmation", user: current_user, orders: orders, total_amount: total_amount)
    )
  end

  def remove_pizza(conn, %{"order_id" => order_id, "pizza_id" => pizza_id}) do
    IO.inspect({order_id, pizza_id}, label: "Remove Pizza")

    case {Integer.parse(order_id), Integer.parse(pizza_id)} do
      {{order_id_int, _}, {pizza_id_int, _}} ->
        Checkout.remove_pizza(order_id_int, pizza_id_int)
        redirect(conn, "/checkout")

      _ ->
        IO.puts("Invalid order ID or pizza ID")
        send_resp(conn, 400, "Invalid request")
    end
  end

  defp redirect(conn, url) do
    Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
  end
end
