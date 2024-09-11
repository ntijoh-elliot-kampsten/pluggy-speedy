defmodule Pluggy.CheckoutController do
  require IEx

  alias Pluggy.Checkout
  alias Pluggy.User
  import Pluggy.Template, only: [render: 2]
  import Plug.Conn, only: [send_resp: 3]

  def index(conn) do
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end

    orders = Checkout.get_current_order(session_user)

    send_resp(conn, 200, render("pizzas/checkout", user: current_user, orders: orders))
  end

  def create(conn, params) do
    Checkout.create(params)
    case params["file"] do
      nil -> IO.puts("No file uploaded")
      _ -> File.rename(params["file"].path, "priv/static/uploads/pizzas/#{params["file"].filename}")
    end
    redirect(conn, "/main")
  end

  def finalize(conn, %{"order_id" => order_id}) do
    Checkout.finalize_order(order_id)
    redirect(conn, "/order_confirmation")
  end

  defp redirect(conn, url) do
    Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
  end
end
