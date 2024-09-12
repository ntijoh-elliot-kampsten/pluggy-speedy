defmodule Pluggy.UserController do
  # import Pluggy.Template, only: [render: 2] #det här exemplet renderar inga templates
  import Plug.Conn, only: [send_resp: 3]
  alias Pluggy.User

  def login(conn, params) do
    user_name = params["username"]
    password = params["pwd"]

    user = User.get_user(user_name)

    cond do
      # no user with that username
      user.num_rows == 0 ->
        redirect(conn, "/login")
      # user with that username exists
      true ->
        [id, password_hash] = user

        # make sure password is correct
        if Bcrypt.verify_pass(password, password_hash) do
          Plug.Conn.put_session(conn, :user_id, id)
          |> redirect("/main") #skicka vidare modifierad conn
        else
          redirect(conn, "/login")
        end
    end
  end

  def logout(conn) do
    Plug.Conn.configure_session(conn, drop: true) #tömmer sessionen
    |> redirect("/main")
  end

  def signUp(conn, params) do
    user_name = params["username"]
    hashed_password = Bcrypt.hash_pwd_salt(params["pwd"])
    number = Integer.parse(params["number"])
    mail = params["mail"]

    case User.user_exist(user_name) do
      # no user with that username
      false ->
        Postgrex.query!(DB, "INSERT INTO users(name, password, number, mail, is_admin) VALUES($1, $2, $3, $4, $5)", [user_name, hashed_password, number, mail, false], pool: DBConnection.ConnectionPool)
        redirect(conn, "/main")
      true -> redirect(conn, "/login")
      _ -> redirect(conn, "/login")
    end
  end

  defp redirect(conn, url),
    do: Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")


end
