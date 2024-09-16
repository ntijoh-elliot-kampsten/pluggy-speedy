defmodule Pluggy.OrderController do
  require IEx

  alias Pluggy.Pizza
  alias Pluggy.Order
  alias Pluggy.User
  import Pluggy.Template, only: [render: 4, render: 3]
  import Plug.Conn, only: [send_resp: 3]

  # def index(conn) do
  #   # get user if logged in
  #   session_user = conn.private.plug_session["user_id"]

  #   current_user =
  #     case session_user do
  #       nil -> nil
  #       _ -> User.get(session_user)
  #     end
  #   send_resp(conn, 200, render("pizzas/index", pizzas: Pizza.all(), user: current_user))
  # end

  def show_orders(conn) do
    # get user if logged in
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    if current_user == nil do
      send_resp(conn, 200, render(conn, "pizzas/index", pizzas: Pizza.all(), user: current_user))
    else
      if(current_user.is_admin?) do
        send_resp(conn, 200, render(conn, "admin/show_orders", [orders: Order.all(), user: current_user], false))
      else
        send_resp(conn, 200, render(conn, "pizzas/index", pizzas: Pizza.all(), user: current_user))
      end
    end
  end

  def handleSearchInput(conn, params) do
    result = Order.get_search_result(params)

    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    send_resp(conn, 200, render(conn, "admin/show_orders", [orders: result, user: current_user], false))

    # Send a JSON response back to the client
    #send_resp(conn, 200, Jason.encode!(%{message: result}))
  end

  #render använder eex
  # def new(conn), do: send_resp(conn, 200, render("pizzas/new", []))
  # def show(conn, id), do: send_resp(conn, 200, render("pizzas/show", pizza: Pizza.get(id)))
  # def edit(conn, id), do: send_resp(conn, 200, render("pizzas/edit", pizza: Pizza.get(id)))
  # def customize(conn, id), do: send_resp(conn, 200, render("/pizzas/customize", pizza: Pizza.get(id)))

  def remove_order(conn, params) do
    Order.remove_order(conn, params)
    redirect(conn, "/orders")
  end

  def remove_order_part(conn, params) do
    Order.remove_order_part(conn, params)
    redirect(conn, "/orders")
  end

  def change_state(conn, params) do
    Order.change_state(conn, params)
    redirect(conn, "/orders")
  end

  def create(conn, params) do
    Order.create(conn, params)
    redirect(conn, "/main")
  end

  def update(conn, id, params) do
    Order.update(id, params)
    redirect(conn, "/main")
  end

  def destroy(conn, id) do
    Order.delete(id)
    redirect(conn, "/main")
  end

  defp redirect(conn, url) do
    Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
  end
end
