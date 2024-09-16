defmodule Pluggy.User do
  defstruct(id: nil, username: "", is_admin?: false)

  alias Pluggy.User
  alias Pluggy.Helper

  def get(id) do
    Postgrex.query!(DB, "SELECT id, name, is_admin FROM users WHERE id = $1 LIMIT 1", [Helper.safe_string_to_integer(id)],
      pool: DBConnection.ConnectionPool
    ).rows
    |> to_struct
  end

  def to_struct([[id, username, is_admin?]]) do
    %User{id: id, username: username, is_admin?: is_admin?}
  end
end
