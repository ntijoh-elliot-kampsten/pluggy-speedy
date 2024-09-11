defmodule Pluggy.Order do
  defstruct [:pizza_id, :add, :sub, :size, :pizza_count, :price]

  alias Pluggy.Order

  def all do
    Postgrex.query!(DB, "SELECT * FROM orders", []).rows
    |> parse_data
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM orders WHERE id = $1 LIMIT 1", [String.to_integer(id)]
    ).rows
    |> to_struct
  end

  def update(id, params) do
    state = params["state"]
    id = String.to_integer(id)

    Postgrex.query!(
      DB,
      "UPDATE orders SET state = $1, WHERE id = $2",
      [state, id]
    )
  end

  def create(params) do
    user_id = params["user_id"]
    user_name = params["user_name"]
    current_order = params["current_order"]
    state = "Making"

    Postgrex.query!(DB, "INSERT INTO orders (user_id, user_name, current_order, state) VALUES ($1, $2, $3, $4)", [user_id, user_name, current_order, state])
  end

  @spec delete(binary()) :: Postgrex.Result.t()
  def delete(id) do
    Postgrex.query!(DB, "DELETE FROM orders WHERE id = $1", [String.to_integer(id)])
  end

  def convert_string_to_list(string) do
    # Convert the string to a list of structs
    {list, _bindings} = Code.eval_string(string)

    Enum.map(list, &(&1))
  end

  def to_struct([[id, add, sub, price, pizza_count, size]]) do
    %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end

  def parse_data(rows) do
    # Gets orders and parses it
    order_list = Enum.map(rows, &(Enum.at(&1, 3)))
    |> Enum.map(&(convert_string_to_list(&1)))

    orders = []

    orders = Enum.map(0..length(rows)-1, fn(index) ->
      order_map = %{order_id: get_full_order_data(rows, index, 0), user_id: get_full_order_data(rows, index, 1), user_name: get_full_order_data(rows, index, 2), order: get_order_data(order_list, index), state: get_full_order_data(rows, index, 4)}
    end)

    orders
  end

  def get_full_order_data(rows, index, map_pos) do
    Enum.at(Enum.map(rows, &(Enum.at(&1, map_pos))), index)
  end

  def get_order_data(order_list, index) do
    Enum.at(order_list, index)
  end

  def to_struct_list(rows) do
    for [id, add, sub, price, pizza_count, size] <- rows, do: %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end
end
