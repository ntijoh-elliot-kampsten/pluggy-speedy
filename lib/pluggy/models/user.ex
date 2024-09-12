defmodule Pluggy.User do
  defstruct(id: nil, username: "")

  alias Pluggy.User

  def get(id) do
    Postgrex.query!(DB, "SELECT id, username FROM users WHERE id = $1 LIMIT 1", [id],
      pool: DBConnection.ConnectionPool
    ).rows
    |> to_struct
  end

  def user_exist(user_name), do: Postgrex.query!(DB, "SELECT id FROM users WHERE user_name = $1", [user_name], pool: DBConnection.ConnectionPool).num_rows != 0

  def get_user(user_name), do: Postgrex.query!(DB, "SELECT id, password_hash FROM users WHERE user_name = $1", [user_name], pool: DBConnection.ConnectionPool).first_row

  def to_struct([[id, username]]) do
    %User{id: id, username: username}
  end
end
