defmodule Pluggy.UserController do
  # import Pluggy.Template, only: [render: 2] #det här exemplet renderar inga templates
  import Plug.Conn, only: [send_resp: 3]

  def login(conn, params) do
    username = params["username"]
    password = params["pwd"]

     #Bör antagligen flytta SQL-anropet till user-model (t.ex User.find)
    result =
      Postgrex.query!(DB, "SELECT id, password FROM users WHERE name = $1", [username],
        pool: DBConnection.ConnectionPool
      )

    case result.num_rows do
      # no user with that username
      0 ->
        redirect(conn, "/login")
      # user with that username exists
      _ ->
        [[id, password_hash]] = result.rows

        # make sure password is correct
        if Bcrypt.verify_pass(password, password_hash) do
          Plug.Conn.put_session(conn, :user_id, id)
          |> Plug.Conn.put_session(:user_name, username)
          |> redirect("/main") #skicka vidare modifierad conn
        else
          redirect(conn, "/login")
        end
    end
  end

  def login_form(conn) do
    send_resp(
      conn,
      200,
      Pluggy.Template.render(conn, "pizzas/login", [], false)
    )
  end

  def logout(conn) do
    conn
    |> Plug.Conn.configure_session(drop: true) # Drops the session to log out the user
    |> redirect("/login") # Redirects to the login page after logout
  end

  # def create(conn, params) do
  # 	#pseudocode
  # 	# in db table users with password_hash CHAR(60)
  # 	# hashed_password = Bcrypt.hash_pwd_salt(params["password"])
  #  	# Postgrex.query!(DB, "INSERT INTO users (username, password_hash) VALUES ($1, $2)", [params["username"], hashed_password], [pool: DBConnection.ConnectionPool])
  #  	# redirect(conn, "/fruits")
  # end

  def signup(conn, %{"username" => username, "pwd" => password, "number" => number, "mail" => mail}) do
    hashed_password = Bcrypt.hash_pwd_salt(password)

    Postgrex.query!(DB,
      "INSERT INTO users (name, password, number, mail) VALUES ($1, $2, $3, $4)",
      [username, hashed_password, number, mail],
      pool: DBConnection.ConnectionPool
    )

    redirect(conn, "/login")
  end

  def signup_form(conn) do
    send_resp(
      conn,
      200,
      Pluggy.Template.render(conn, "pizzas/signup", [], false)
    )
  end

  def change_password(conn, %{"user" => %{"current_password" => current_password, "new_password" => new_password}}) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    result = Postgrex.query!(DB, "SELECT password FROM users WHERE id = $1", [user_id], pool: DBConnection.ConnectionPool)

    [[password]] = result.rows

    if Bcrypt.verify_pass(current_password, password) do
      new_hashed_password = Bcrypt.hash_pwd_salt(new_password)

      Postgrex.query!(DB,
        "UPDATE users SET password = $1 WHERE id = $2",
        [new_hashed_password, user_id],
        pool: DBConnection.ConnectionPool
      )

      redirect(conn, "/main")
    else
      redirect(conn, "/change_password")
    end
  end

  def change_password_form(conn) do
    send_resp(
      conn,
      200,
      Pluggy.Template.render(conn, "pizzas/change_password", [], false)
    )
  end



  defp redirect(conn, url),
    do: Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
end
