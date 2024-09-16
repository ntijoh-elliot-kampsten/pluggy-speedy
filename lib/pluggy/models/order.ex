defmodule Pluggy.Order do
  defstruct [:pizza_id, :add, :sub, :size, :pizza_count, :price]

  alias Pluggy.Order
  alias Pluggy.Pizza
  alias Pluggy.Helper

  @states %{"Registered" => "Making", "Making" => "Done"}

  def all do
    Postgrex.query!(DB, "SELECT * FROM orders ORDER BY id", []).rows
    |> parse_data
    #|> IO.inspect
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM orders WHERE id = $1 LIMIT 1", [Helper.safe_string_to_integer(id)]
    ).rows
    |> parse_data
  end

  def update_order(conn, params) do
    case pizza_in_order_exist(
      Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order,
      Helper.safe_string_to_integer(params["pizzaId"]),
      get_size(Helper.safe_string_to_integer(params["size"])),
      if params["add"] && params["add"] != "" do
      String.split(params["add"], "&&&&")
    else
      []
    end,
    if params["sub"] && params["sub"] != "" do
      String.split(params["sub"], "&&&&")
    else
      []
    end) do
      false ->
        Postgrex.query!(
          DB,
          "UPDATE orders SET \"current_order\" = $1 WHERE user_name = $2 AND state = ''",
          [build_updated_order_string(
            Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order,
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
          ), conn.private.plug_session["user_name"]]
        )
      true ->
        update_amount(conn, params)
    end
  end

  def update_amount(conn, params) do
    Postgrex.query!(
      DB,
      "UPDATE orders SET \"current_order\" = $1 WHERE user_name = $2 AND state = ''",
      [build_updated_order_count_string(
        Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order,
        Enum.count(Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order),
        Helper.safe_string_to_integer(params["pizzaId"]),
        Helper.safe_string_to_integer(params["size"]),
        if params["add"] && params["add"] != "" do
          String.split(params["add"], "&&&&")
        else
          []
        end,
        if params["sub"] && params["sub"] != "" do
          String.split(params["sub"], "&&&&")
        else
          []
        end,
        Helper.safe_string_to_integer(params["amount"])
      ), conn.private.plug_session["user_name"]]
    )
  end

  def get_search_result(params) do
    %{"search_bar" => search_result} = params

    query = """
    SELECT * FROM orders WHERE user_name ILIKE $1 AND state != $2;
    """

    Postgrex.query!(DB, query, ["%#{search_result}%", ""]).rows
    |> parse_data()
  end

  def change_state(_conn, params) do
    query = """
    UPDATE orders SET \"state\" = $1 WHERE id = $2
    """

    Postgrex.query!(
      DB,
      query,
      [params["new_state"], String.to_integer(params["order_id"])]
    )
  end

  def remove_order(_conn, params) do
    query = """
    DELETE FROM orders WHERE id = $1
    """
    Postgrex.query!(
      DB,
      query,
      [String.to_integer(params["order_id"])]
    )
  end

  def remove_order_part(conn, params) do
    case user_unsubmitted_order_exist(conn.private.plug_session["user_name"]) do
      false -> nil
      true ->
        case pizza_in_order_exist(
          orders_size_name_to_id(Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order),
          Helper.safe_string_to_integer(params["pizzaId"]),
          get_size_id(Helper.safe_string_to_integer(params["size"])),
          if params["add"] && params["add"] != "" do
            String.split(params["add"], "&&&&")
          else
            []
          end,
          if params["sub"] && params["sub"] != "" do
            String.split(params["sub"], "&&&&")
          else
            []
          end) do
          false -> nil
          true ->
            case Enum.count(Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order) > 1 do
              false ->
                Postgrex.query!(
                  DB,
                  "DELETE FROM orders WHERE user_name = $1 and state = ''",
                  [conn.private.plug_session["user_name"]]
                )
              true ->
                Postgrex.query!(
                  DB,
                  "UPDATE orders SET \"current_order\" = $1 WHERE user_name = $2 AND state = ''",
                  [build_updated_order_remove_part_string(
                    orders_size_name_to_id(Enum.at(get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"]), 0).order),
                    Helper.safe_string_to_integer(params["pizzaId"]),
                    get_size_id(Helper.safe_string_to_integer(params["size"])),
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
                  ), conn.private.plug_session["user_name"]]
                )
            end
        end
    end
  end

  def create(conn, params) do
    case user_unsubmitted_order_exist(conn.private.plug_session["user_name"]) do
      true -> update_order(conn, params)
      false ->
        # Insert the order into the database
        Postgrex.query!(
          DB,
          "INSERT INTO orders (user_id, user_name, current_order, state) VALUES ($1, $2, $3, $4)",
          [conn.private.plug_session["user_id"], conn.private.plug_session["user_name"], build_new_order_string(
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

  def parse_data([]), do: []
  def parse_data(rows) do
    # Gets orders and parses it
    order_list = Enum.map(rows, &(Enum.at(&1, 3)))
    |> Enum.map(&(convert_string_to_list(&1)))

    orders = Enum.map(0..length(rows)-1, fn(index) ->
      %{order_id: get_full_order_data(rows, index, 0), user_id: get_full_order_data(rows, index, 1), user_name: get_full_order_data(rows, index, 2), order: get_order_data(order_list, index), state: get_full_order_data(rows, index, 4), total_price: get_total_price(order_list, index)}
    end)

    orders
  end

  def get_total_price(order_input, index, map_index \\ 0, map_length \\ 1, total_price \\ 0)
  def get_total_price(_order_input, _index, map_index, map_length, total_price) when map_index >= map_length, do: total_price
  def get_total_price(order_input, index, map_index, _map_length, total_price) do
    order_list = Enum.at(order_input, index)
    order_map = Enum.at(order_list, map_index)
    get_total_price(order_input, index, map_index + 1, length(order_list) , total_price + Pizza.calculate_price(order_map.pizza_id, order_map.amount))

    # Enum.reduce(0.0, fn pizza, acc ->
    #   acc + ((pizza.amount || 0) * (pizza.price || 0.0)) # Default to 0 if nil
    # end)
  end

  def get_total_price2(order, price \\ 0)
  def get_total_price2([], price), do: price
  def get_total_price2([head | tail], price), do: get_total_price2(tail, price + head.price)

  def get_size(size) do
    case size do
      1 ->
        "Liten"
      2 ->
        "Stor"
      3 ->
        "Familjepizza"
      _ ->
        "Storlek hittades ej"
    end
  end

  def get_size_id(size_name) do
    case size_name do
      "Liten" ->
        1
      "Stor" ->
        2
      "Familjepizza" ->
        3
      _ ->
        1
    end
  end

  def get_new_state(currentState) do
    Map.get(@states, currentState, "Undefined")
  end

  def get_full_order_data(rows, index, map_pos) do
    Enum.at(Enum.map(rows, &(Enum.at(&1, map_pos))), index)
  end

  def get_order_data(order_list, index) do
    order_map = Enum.at(order_list, index)

    return_value = Enum.map(0..length(order_map)-1, fn(k) ->
      orders = Enum.at(order_map, k)
      new_map = %{orders | size: get_size(orders.size)}
      pizza_id = orders.pizza_id

      query = """
      SELECT name FROM pizzas WHERE id = $1
      """

      pizza_name = Postgrex.query!(DB, query, [pizza_id]).rows
      Map.put(new_map, :pizza_name, Enum.at(Enum.at(pizza_name, 0), 0))
    end)

    return_value
  end

  def to_struct_list(rows) do
    for [id, add, sub, price, pizza_count, size] <- rows, do: %Order{pizza_id: id, add: add, sub: sub, price: price, pizza_count: pizza_count, size: size}
  end

  def pizza_in_order_exist(order, pizza_id, size, add \\ [], sub \\ [])
  def pizza_in_order_exist([], _pizza_id, _size, _add, _sub), do: false
  def pizza_in_order_exist([head | _tail], pizza_id, size, add, sub) when head.pizza_id == pizza_id and head.size == size and head.add == add and head.sub == sub, do: true
  def pizza_in_order_exist([_head | tail], pizza_id, size, add, sub), do: pizza_in_order_exist(tail, pizza_id, size, add, sub)

  def order_match(order, pizza_id, size, add \\ [], sub \\ [])
  def order_match(order, pizza_id, size, add, sub) when order.pizza_id == pizza_id and order.size == size and order.add == add and order.sub == sub, do: true
  def order_match(order, pizza_id, size, add, sub) do
    false
  end

  # needs to exist
  def get_order_match_index(order, pizza_id, size, add \\ [], sub \\ [], acc \\ 0)
  def get_order_match_index([head | _tail], pizza_id, size, add, sub, acc) when head.pizza_id == pizza_id and head.size == size and head.add == add and head.sub == sub, do: acc
  def get_order_match_index([_head | tail], pizza_id, size, add, sub, acc), do: get_order_match_index(tail, pizza_id, size, add, sub, acc + 1)

  def get_user_unsubmitted_order_parsed(user_name), do: get_user_unsubmitted_order(user_name) |> parse_data
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

  def build_updated_order_remove_part(current_order, pizza_id, size, add \\ [], sub \\ [])
  def build_updated_order_remove_part(current_order, pizza_id, size, add, sub), do: List.delete_at(current_order, get_order_match_index(current_order, pizza_id, size, add, sub))

  def build_updated_order_remove_part_string(current_order, pizza_id, size, add \\ [], sub \\ [])
  def build_updated_order_remove_part_string(current_order, pizza_id, size, add, sub), do: build_updated_order_remove_part(current_order, pizza_id, size, add, sub) |> convert_list_to_string()

  def build_updated_order_count(order, order_length, pizza_id, size, add \\ [], sub \\ [], amount \\ 1, index \\ 0)
  def build_updated_order_count(order, order_length, _pizza_id, _size, _add, _sub, _amount, index) when order_length == index - 1, do: order
  def build_updated_order_count(order, order_length, pizza_id, size, add, sub, amount, index) do
    case order_match(Enum.at(order, index), pizza_id, get_size(size), add, sub) do
      true ->
        List.update_at(
          List.update_at(order, index, fn item ->
            %{item | amount: item.amount + amount}
          end),
          index, fn item ->
            %{item | price: Pizza.calculate_price(item.pizza_id, item.add, item.amount)}
          end)
      false -> build_updated_order_count(order, order_length, pizza_id, size, add, sub, amount, index + 1)
    end
  end

  def build_updated_order_count_string(order, order_length, pizza_id, size, add \\ [], sub \\ [], amount \\ 1, index \\ 0)
  def build_updated_order_count_string(order, order_length, pizza_id, size, add, sub, amount, index), do: build_updated_order_count(order, order_length, pizza_id, size, add, sub, amount, index) |> orders_size_name_to_id() |> convert_list_to_string()

  def orders_size_name_to_id(orders, new_orders \\ [])
  def orders_size_name_to_id([], new_orders), do: Enum.reverse(new_orders)
  def orders_size_name_to_id([head|tail], new_orders), do: orders_size_name_to_id(tail, [%{head | size: get_size_id(head.size)}|new_orders])
end
