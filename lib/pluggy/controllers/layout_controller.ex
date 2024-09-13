defmodule Pluggy.LayoutController do
  import Plug.Conn

  alias Pluggy.Layout

  def init(default), do: default

  # kanske ej fungerer
  def get_values(conn) do
    user_name = "Carl Svensson"
    basket_amount = Layout.get_basket_amount(user_name)

    response_text = "#{user_name}|#{basket_amount}"

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, response_text)
  end
end
