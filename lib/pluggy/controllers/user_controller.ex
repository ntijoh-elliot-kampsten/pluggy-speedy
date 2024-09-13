defmodule Pluggy.UserController do
  import Plug.Conn
  alias Pluggy.User
  require Logger

  # Renders the login form with a link to signup
  def show_login_form(conn) do
    send_resp(
      conn,
      200,
      Pluggy.Template.render("pizzas/login", [], false)
    )
  end

def login(conn, %{"username" => username, "pwd" => pwd}) do
  case User.get_user(username) do
    nil ->
      redirect(conn, "/login")

    %Pluggy.User{id: id, password_hash: password_hash} ->
      if Bcrypt.verify_pass(pwd, password_hash) do
        conn
        |> put_session(:user_id, id)
        |> redirect("/main")
      else
        redirect(conn, "/login")
      end

    _ ->
      redirect(conn, "/login")
  end
end


  # Renders the signup form with a link to login
  def show_signup_form(conn) do
    send_resp(
      conn,
      200,
      Pluggy.Template.render("pizzas/signup", [], false)
    )
  end

  # Handles user signup
  def sign_up(conn, %{"username" => username, "pwd" => pwd, "number" => num, "mail" => mail}) do
    hashed_password = Bcrypt.hash_pwd_salt(pwd)

    Logger.info("Sign-up attempt for username: #{username}")

    if User.user_exist(username) do
      Logger.warning("Username already exists: #{username}")
      redirect(conn, "/login")
    else
      case User.insert_user(username, hashed_password, num, mail) do
        {:ok, _result} ->
          Logger.info("User successfully created: #{username}")
          redirect(conn, "/login")

        {:error, reason} ->
          Logger.error("Failed to insert user: #{reason}")
          send_resp(conn, 500, "Internal Server Error")
      end
    end
  end

  # Logs out the user
  def logout(conn) do
    conn
    |> configure_session(drop: true)
    |> redirect("/main")
  end

  # Helper function to handle redirects
  defp redirect(conn, url) do
    conn
    |> put_resp_header("location", url)
    |> send_resp(303, "")
  end
end
