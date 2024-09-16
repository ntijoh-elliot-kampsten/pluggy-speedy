defmodule Pluggy.CheckoutController do
  require IEx

  alias Pluggy.Helper
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


    unless Order.get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]) == [] do
      order = Order.get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"])
      send_resp(conn, 200, render(conn, "pizzas/checkout", user: current_user, orders: order, total_amount: Order.get_total_price2(Enum.at(order, 0).order)))
    end
    send_resp(conn, 200, render(conn, "pizzas/checkout", user: current_user, orders: [], total_amount: 0))


  end


  def finalize(conn, %{"order_id" => order_id}) do
    IO.inspect(order_id, label: "Received Order ID")

    case Integer.parse(order_id) do
      {order_id_int, _} ->
        Checkout.finalize_order(order_id_int)
        redirect(conn, "/order_confirmation/#{order_id}")

      :error ->
        IO.puts("Invalid order ID received: #{order_id}")
        send_resp(conn, 400, "Invalid order ID")
    end
  end

  def confirmation(conn, id) do
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    order = Enum.at(Order.get(Helper.safe_string_to_integer(id)), 0).order |> Order.orders_size_name_to_id()

    send_resp(
      conn,
      200,
      Pluggy.Template.render(conn, "pizzas/confirmation", user: current_user, order_number: id, order: order, total_amount: Order.get_total_price2(order))
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
