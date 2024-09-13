defmodule Pluggy.Pizza do
  defstruct(id: nil, name: "", ingredients: [], price: nil, image_url: "")

  alias Pluggy.Pizza
  alias Pluggy.Ingredient
  alias Pluggy.Helper

  def all do
    Postgrex.query!(DB, "SELECT * FROM pizzas", []).rows
    |> to_struct_list
  end


  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM pizzas WHERE id = $1 LIMIT 1", [Helper.safe_string_to_integer(id)]
    ).rows
    |> to_struct
  end

  def update(id, params) do
    name = params["name"]
    ingredients = params["ingredients"]
    price = String.to_integer(params["price"])
    id = String.to_integer(id)

    Postgrex.query!(
      DB,
      "UPDATE pizzas SET name = $1, ingredients = $2, price = $3 WHERE id = $4",
      [name, ingredients, price, id]
    )
  end

  def create(params) do
    name = params["name"]
    ingredients = params["ingredients"]
    price = String.to_integer(params["price"])

    Postgrex.query!(DB, "INSERT INTO pizzas (name, ingredients, price) VALUES ($1, $2, $3)", [name, ingredients, price])
  end

  def delete(id) do
    Postgrex.query!(DB, "DELETE FROM pizzas WHERE id = $1", [String.to_integer(id)])
  end

  def calculate_price(id, add \\ [], amount), do: (get(id).price + calculate_ingredients_price(add)) * amount

  def calculate_ingredients_price(_, price \\ 0)
  def calculate_ingredients_price([], price), do: price
  def calculate_ingredients_price([head|tail], price), do: calculate_ingredients_price(tail, price + (Ingredient.get_by_name(head).price || 0))

  def to_struct([[id, name, ingredients, price, image_url]]) do
    %Pizza{
      id: id,
      name: name,
      ingredients: parse_ingredients(ingredients),
      price: price,
      image_url: image_url
    }
  end

  def to_struct_list(rows) do
    for [id, name, ingredients, price, image_url] <- rows do
      %Pizza{
        id: id,
        name: name,
        ingredients: parse_ingredients(ingredients),
        price: price,
        image_url: image_url
      }
    end

  end

  defp parse_ingredients(ingredients) when is_binary(ingredients), do: elem(Code.eval_string(ingredients), 0)
end
