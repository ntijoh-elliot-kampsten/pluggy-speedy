defmodule Pluggy.Order do
  defstruct pizza_id: nil, add: [], sub: [], price: 0, pizza_count: 0, size: 1

  alias Pluggy.Order

  def all do
    temp = Postgrex.query!(DB, "SELECT * FROM orders", []).rows
    # |> parse_data

    IO.inspect(temp)

    #temp
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

  def delete(id) do
    Postgrex.query!(DB, "DELETE FROM orders WHERE id = $1", [String.to_integer(id)])
  end

  def to_struct([[id, add, sub, price, pizza_count, size]]) do
    %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end

  def parse_data(rows) do
    #sIO.inspect(Enum.each(rows, &(Enum.at(&1, 3))))

    Enum.each(rows, &(Enum.at(&1, 0)))
    |> IO.inspect

  end

  def to_struct_list(rows) do
    for [id, add, sub, price, pizza_count, size] <- rows, do: %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
    #"%Order{order: [%{pizza_id: 1, add: ['Svamp'], sub: ['Tomatsås'], size: 1, amount: 2, price: 130}, %{pizza_id: 3, add: ['Basilika'], sub: ['Skinka', 'Svamp'], size: 2, amount: 1, price: 230}]}"

    # [
    #   [1, 1, "Carl Svensson",
    #    "%Order{order: [%{pizza_id: 1, add: ['Svamp'], sub: ['Tomatsås'], size: 1, amount: 2, price: 130}]}",
    #    "Making"],
    #   [2, -1, "Abdi Svensson",
    #    "%Order{order: [%{pizza_id: 1, add: ['Svamp'], sub: ['Tomatsås'], size: 1, amount: 2, price: 130}, %{pizza_id: 3, add: ['Basilika'], sub: ['Skinka', 'Svamp'], size: 2, amount: 1, price: 230}]}",
    #    "Done"]
    # ]
  end
end
