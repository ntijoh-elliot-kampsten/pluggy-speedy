defmodule Pluggy.PizzaController do
  require IEx

  alias Pluggy.Ingredient
  alias Pluggy.Pizza
  alias Pluggy.Order
  alias Pluggy.User
  import Pluggy.Template, only: [render: 4, render: 3]
  import Plug.Conn, only: [send_resp: 3]

  def index(conn) do
    # get user if logged in
    session_user = conn.private.plug_session["user_id"]

    current_user =
      case session_user do
        nil -> nil
        _ -> User.get(session_user)
      end
    send_resp(conn, 200, render(conn, "pizzas/index", pizzas: Pizza.all(), user: current_user))
  end

  #render använder eex

  def new(conn), do: send_resp(conn, 200, render(conn, "pizzas/new", []))
  def show(conn, id), do: send_resp(conn, 200, render(conn, "pizzas/show", pizza: Pizza.get(id)))
  def edit(conn, id), do: send_resp(conn, 200, render(conn, "pizzas/edit", pizza: Pizza.get(id)))
  def customize(conn, id), do: send_resp(conn, 200, render(conn, "/pizzas/customize", pizza: Pizza.get(id), all_ingredients: Ingredient.all()))


  def create(conn, params) do
    Pizzas.create(params)
    case params["file"] do
      nil -> IO.puts("No file uploaded")  #do nothing
        # move uploaded file from tmp-folder
      _  -> File.rename(params["file"].path, "priv/static/uploads/pizzas/#{params["file"].filename}")
    end
    redirect(conn, "/main")
  end

  def update(conn, id, params) do
    Fruit.update(id, params)
    redirect(conn, "/main")
  end

  def destroy(conn, id) do
    Fruit.delete(id)
    redirect(conn, "/main")
  end

  defp redirect(conn, url) do
    Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
  end
end
