defmodule Pluggy.Router do
  use Plug.Router
  use Plug.Debugger

  alias Pluggy.Order
  alias Pluggy.OrderController
  alias Pluggy.PizzaController
  alias Pluggy.UserController
  alias Pluggy.CheckoutController
  alias Pluggy.PortalController

  plug(Plug.Static, at: "/", from: :pluggy)
  plug(:put_secret_key_base)

  # plug(Plug.Session,
  #   store: :cookie,
  #   key: "_pluggy_session",
  #   encryption_salt: "cookie store encryption salt",
  #   signing_salt: "cookie store signing salt",
  #   key_length: 64,
  #   log: :debug,
  #   secret_key_base: "-- LONG STRING WITH AT LEAST 64 BYTES -- LONG STRING WITH AT LEAST 64 BYTES --"
  # )

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

  get("/", do: PortalController.index(conn, fn conn -> PizzaController.index(conn) end))
  get("/main", do: PortalController.index(conn, fn conn -> PizzaController.index(conn) end))


  get("/orders", do: PortalController.index(conn, fn conn -> OrderController.show_orders(conn) end))
  get("/order/update", do: PortalController.index(conn, fn conn -> Order.update_order("Carl Svensson") end))
  post("/order/add", do: PortalController.index(conn, fn conn -> OrderController.create(conn, conn.body_params) end))
  post("/order/searchbar", do: OrderController.handleSearchInput(conn, conn.body_params))
  post("/order/change-state", do: PortalController.index(conn, fn conn -> OrderController.change_state(conn, conn.body_params) end))
  post("/order/remove-order", do: PortalController.index(conn, fn conn -> OrderController.remove_order(conn, conn.body_params) end))
  post("/order/remove-order-part", do: PortalController.index(conn, fn conn -> OrderController.remove_order_part(conn, conn.body_params) end))

  get("/customize/:id", do: PortalController.index(conn, fn conn -> PizzaController.customize(conn, id) end))

  get("/checkout", do: PortalController.index(conn, fn conn -> CheckoutController.index(conn) end))
  post("/checkout/finalize", do: PortalController.index(conn, fn conn -> CheckoutController.finalize(conn, conn.body_params) end))
  get("/order_confirmation/:id", do: PortalController.index(conn, fn conn -> CheckoutController.confirmation(conn, id) end))
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
get("/login", do: UserController.login_form(conn))
get("/signup", do: UserController.signup_form(conn))
get("/change_password", do: PortalController.index(conn, fn conn -> UserController.change_password_form(conn) end))
post("/users/login", do: UserController.login(conn, conn.body_params))
post("/users/logout", do: UserController.logout(conn)) # This is correct
post("/users/signup", do: UserController.signup(conn, conn.body_params))
post("/users/change_password", do: UserController.change_password(conn, conn.body_params))



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
