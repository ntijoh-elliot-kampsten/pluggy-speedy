defmodule Pluggy.User do
  defstruct(id: nil, username: "", password_hash: "")

  def get_user(username) do
    query = "SELECT id, password FROM users WHERE name = $1"
    result = Postgrex.query!(DB, query, [username], pool: DBConnection.ConnectionPool)
    case result.rows do
      [[id, password_hash]] -> %Pluggy.User{id: id, username: username, password_hash: password_hash}
      _ -> nil
    end
  end

  def user_exist(username) do
    query = "SELECT 1 FROM users WHERE name = $1"
    result = Postgrex.query!(DB, query, [username], pool: DBConnection.ConnectionPool)
    result.num_rows > 0
  end

   # Inserts a new user into the database
   def insert_user(username, password_hash, number, mail) do
    query = "INSERT INTO users(name, password, number, mail) VALUES($1, $2, $3, $4)"

    try do
      Postgrex.query!(DB, query, [username, password_hash, String.to_integer(number), mail], pool: DBConnection.ConnectionPool)
      {:ok, :inserted}
    rescue
      e ->
        IO.inspect(e, label: "Insert User Error")
        {:error, e}
    end
  end

  def update_password(username, new_password_hash) do
    query = "UPDATE users SET password = $1 WHERE name = $2"
    Postgrex.query!(DB, query, [new_password_hash, username], pool: DBConnection.ConnectionPool)
  end
  
end
