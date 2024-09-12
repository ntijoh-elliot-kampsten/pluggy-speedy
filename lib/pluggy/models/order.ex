defmodule Pluggy.Order do
  defstruct [:pizza_id, :add, :sub, :size, :pizza_count, :price]

  alias Pluggy.Order
  alias Pluggy.Pizza

  def all do
    Postgrex.query!(DB, "SELECT * FROM orders", []).rows
    |> parse_data
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM orders WHERE id = $1 LIMIT 1", [String.to_integer(id)]
    ).rows
    |> to_struct
  end

  def update_order(conn, params) do
    user_name = "Carl Svensson"
    IO.puts(user_name)

    current_order = Enum.at(get_user_unsubmitted_order(user_name), 0).order

    IO.inspect(current_order)

    order = %{
      pizza_id: String.to_integer(params["pizzaId"]),
      size: String.to_integer(params["size"]),
      amount: String.to_integer(params["amount"]),
      add: if params["add"] && params["add"] != "" do
        String.split(params["add"], "&&&&")
      else
        []
      end,
      sub: if params["sub"] && params["sub"] != "" do
        String.split(params["sub"], "&&&&")
      else
        []
      end,
      price: Pizza.calculate_price(params["pizzaId"], if params["add"] && params["add"] != "" do
        String.split(params["add"], "&&&&")
      else
        []
      end)
    }

    new_order = [order | current_order]

    IO.inspect(convert_list_to_string(new_order))

    # Insert the new updated order into the database
    Postgrex.query!(
      DB,
      "UPDATE orders SET \"current_order\" = $1 WHERE user_name = $2 AND state = ''",
      [convert_list_to_string(new_order), user_name]
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
        # Create the order map and handle empty "add" and "sub" fields using atoms instead of strings
        order = %{
          pizza_id: String.to_integer(params["pizzaId"]),
          size: String.to_integer(params["size"]),
          amount: String.to_integer(params["amount"]),
          add: if params["add"] && params["add"] != "" do
            String.split(params["add"], "&&&&")
          else
            []
          end,
          sub: if params["sub"] && params["sub"] != "" do
            String.split(params["sub"], "&&&&")
          else
            []
          end,
          price: Pizza.calculate_price(params["pizzaId"], if params["add"] && params["add"] != "" do
            String.split(params["add"], "&&&&")
          else
            []
          end)
        }

        state = ""

        # Insert the order into the database
        Postgrex.query!(
          DB,
          "INSERT INTO orders (user_id, user_name, current_order, state) VALUES ($1, $2, $3, $4)",
          [user_id, user_name, convert_list_to_string([order]), state]
        )
    end
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

  def get_user_unsubmitted_order(user_name), do: Postgrex.query!(DB, "SELECT * FROM orders WHERE user_name = $1 and state = '' LIMIT 1", [user_name]).rows |> parse_data

  def user_unsubmitted_order_exist(user_name), do: Postgrex.query!(DB, "SELECT * FROM orders WHERE user_name = $1 and state = '' LIMIT 1", [user_name]).num_rows != 0
end
