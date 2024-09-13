defmodule Pluggy.Order do
  defstruct [:pizza_id, :add, :sub, :size, :pizza_count, :price]

  alias Pluggy.Order
  alias Pluggy.Pizza
  alias Pluggy.Helper

  def all do
    Postgrex.query!(DB, "SELECT * FROM orders", []).rows
    |> parse_data
    #|> IO.inspect
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM orders WHERE id = $1 LIMIT 1", [Helper.safe_string_to_integer(id)]
    ).rows
    |> to_struct
  end

  def update_order(conn, params) do
    user_name = "Carl Svensson"

    # Insert the new updated order into the database
    Postgrex.query!(
      DB,
      "UPDATE orders SET \"current_order\" = $1 WHERE user_name = $2 AND state = ''",
      [build_updated_order_string(
        Enum.at(get_user_unsubmitted_order_parsed(user_name), 0).order,
        Helper.safe_string_to_integer(params["pizzaId"]),
        Helper.safe_string_to_integer(params["size"]),
        Helper.safe_string_to_integer(params["amount"]),
        if params["add"] && params["add"] != "" do
          String.split(params["add"], "&&&&")
        else
          []
        end,
        if params["sub"] && params["sub"] != "" do
          String.split(params["sub"], "&&&&")
        else
          []
        end
      ), user_name]
    )
  end

  def update_state() do

  end

  def create(conn, params) do
    user_id = 1
    user_name = "Carl Svensson"

    cond do
      user_unsubmitted_order_exist(user_name) ->
        update_order(conn, params)
      true ->
        # Insert the order into the database
        Postgrex.query!(
          DB,
          "INSERT INTO orders (user_id, user_name, current_order, state) VALUES ($1, $2, $3, $4)",
          [user_id, user_name, build_new_order_string(
            Helper.safe_string_to_integer(params["pizzaId"]),
            Helper.safe_string_to_integer(params["size"]),
            Helper.safe_string_to_integer(params["amount"]),
            if params["add"] && params["add"] != "" do
              String.split(params["add"], "&&&&")
            else
              []
            end,
            if params["sub"] && params["sub"] != "" do
              String.split(params["sub"], "&&&&")
            else
              []
            end
          ), ""]
        )
    end
  end


  @spec delete(binary()) :: Postgrex.Result.t()
  def delete(id) do
    Postgrex.query!(DB, "DELETE FROM orders WHERE id = $1", [Helper.safe_string_to_integer(id)])
  end

  def convert_string_to_list(string) do
    # Convert the string to a list of structs
    {list, _bindings} = Code.eval_string(string)

    Enum.map(list, &(&1))
  end

  def convert_list_to_string(list) do
    # Convert the list of maps/structs to a string that matches PostgreSQL's format
    inspect(list, charlists: :as_lists)
  end

  def to_struct([id, add, sub, price, pizza_count, size]) do
    %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end

  def parse_data(rows) do
    # Gets orders and parses it
    order_list = Enum.map(rows, &(Enum.at(&1, 3)))
    |> Enum.map(&(convert_string_to_list(&1)))

    orders = Enum.map(0..length(rows)-1, fn(index) ->
      %{order_id: get_full_order_data(rows, index, 0), user_id: get_full_order_data(rows, index, 1), user_name: get_full_order_data(rows, index, 2), order: get_order_data(order_list, index), state: get_full_order_data(rows, index, 4)}
    end)

    orders
  end

  def get_full_order_data(rows, index, map_pos) do
    Enum.at(Enum.map(rows, &(Enum.at(&1, map_pos))), index)
  end

  def get_order_data(order_list, index) do
    order_map = Enum.at(order_list, index)

    return_value = Enum.map(0..length(order_map)-1, fn(k) ->
      orders = Enum.at(order_map, k)
      pizza_id = orders.pizza_id

      query = """
      SELECT name FROM pizzas WHERE id = $1
      """

      pizza_name = Postgrex.query!(DB, query, [pizza_id]).rows
      Map.put(orders, :pizza_name, Enum.at(Enum.at(pizza_name, 0), 0))
    end)

    return_value
  end

  def to_struct_list(rows) do
    for [id, add, sub, price, pizza_count, size] <- rows, do: %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end

  def get_user_unsubmitted_order_parsed(user_name), do: Postgrex.query!(DB, "SELECT * FROM orders WHERE user_name = $1 and state = '' LIMIT 1", [user_name]).rows |> parse_data
  def get_user_unsubmitted_order(user_name), do: Postgrex.query!(DB, "SELECT * FROM orders WHERE user_name = $1 and state = '' LIMIT 1", [user_name]).rows

  def user_unsubmitted_order_exist(user_name), do: Postgrex.query!(DB, "SELECT * FROM orders WHERE user_name = $1 and state = '' LIMIT 1", [user_name]).num_rows != 0

  def build_new_order(pizza_id, size, amount \\ 1, add \\ [], sub \\ [])
  def build_new_order(pizza_id, size, amount, add, sub) do
    %{
      pizza_id: pizza_id,
      size: size,
      amount: amount,
      add: add,
      sub: sub,
      price: Pizza.calculate_price(pizza_id, add, amount)
    }
  end

  def build_new_order_string(pizza_id, size, amount \\ 1, add \\ [], sub \\ [])
  def build_new_order_string(pizza_id, size, amount, add, sub), do: [build_new_order(pizza_id, size, amount, add, sub)] |> convert_list_to_string()

  def build_updated_order(current_order, pizza_id, size, amount \\ 1, add \\ [], sub \\ [])
  def build_updated_order(current_order, pizza_id, size, amount, add, sub), do: [build_new_order(pizza_id, size, amount, add, sub) | current_order]

  def build_updated_order_string(current_order, pizza_id, size, amount \\ 1, add \\ [], sub \\ [])
  def build_updated_order_string(current_order, pizza_id, size, amount, add, sub), do: build_updated_order(current_order, pizza_id, size, amount, add, sub) |> convert_list_to_string()

end
