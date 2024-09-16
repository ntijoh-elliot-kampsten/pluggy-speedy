defmodule Pluggy.PortalController do
  require IEx

  alias Pluggy.User
  import Plug.Conn, only: [send_resp: 3]

  def index(conn, function) do
    # Get user if logged in
    session_user = conn.private.plug_session["user_id"]

    case session_user do
      nil ->
        redirect(conn, "/login")
      _ ->
        case User.exist(session_user) do
          false ->
            redirect(conn, "/login")
          true ->
            case conn.private.plug_session["is_admin"] do
              true ->
                case conn.request_path == "/orders" do
                  false -> redirect(conn, "/orders")
                  true -> function.(conn)
                end
              false ->
                # User is logged in, execute the passed function
                function.(conn)
            end
        end
    end
  end

  defp redirect(conn, url) do
    Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
  end
end
