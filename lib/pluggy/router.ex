defmodule Pluggy.Router do
  use Plug.Router
  use Plug.Debugger

  alias Pluggy.Order
  alias Pluggy.OrderController
  alias Pluggy.PizzaController
  alias Pluggy.UserController
  alias Pluggy.CheckoutController
  alias Pluggy.LayoutController

  plug(Plug.Static, at: "/", from: :pluggy)
  plug(:put_secret_key_base)

  plug(Plug.Session,
  store: :cookie,
  key: "_my_app_session",
  encryption_salt: "cookie store encryption salt",
  signing_salt: "cookie store signing salt",
  log: :debug
)

  plug(:fetch_session)
  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])
  plug(:match)
  plug(:dispatch)

  get("/", do: PizzaController.index(conn))
  get("/main", do: PizzaController.index(conn))

  get("/orders", do: OrderController.show_orders(conn))
  post("/order/add", do: OrderController.create(conn, conn.body_params))

  get("/customize/:id", do: PizzaController.customize(conn, id))

  get("/checkout", do: CheckoutController.index(conn))
  post("/checkout/finalize", do: CheckoutController.finalize(conn, conn.body_params))
  get("/order_confirmation", do: CheckoutController.confirmation(conn))
    # get("/fruits", do: FruitController.index(conn))
  # get("/fruits/new", do: FruitController.new(conn))
  # get("/fruits/:id", do: FruitController.show(conn, id))
  # get("/fruits/:id/edit", do: FruitController.edit(conn, id))

  # post("/fruits", do: FruitController.create(conn, conn.body_params))

  # # should be put /fruits/:id, but put/patch/delete are not supported without hidden inputs
  # post("/fruits/:id/edit", do: FruitController.update(conn, id, conn.body_params))

  # # should be delete /fruits/:id, but put/patch/delete are not supported without hidden inputs
  # post("/fruits/:id/destroy", do: FruitController.destroy(conn, id))

  # User management routes
  get("/login", do: UserController.show_login_form(conn))
  post("/users/login", do: UserController.login(conn, conn.body_params))
  get("/signup", do: UserController.show_signup_form(conn))
  post("/users/signup", do: UserController.sign_up(conn, conn.body_params))
  post("/users/logout", do: UserController.logout(conn))

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp put_secret_key_base(conn, _) do
    put_in(
      conn.secret_key_base,
      "-- LONG STRING WITH AT LEAST 64 BYTES LONG STRING WITH AT LEAST 64 BYTES --"
    )
  end


end
