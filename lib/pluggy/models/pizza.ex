defmodule Pluggy.Pizza do
  defstruct(id: nil, name: "", ingredients: [], price: nil, img: "")

  alias Pluggy.Pizza

  def all do
    Postgrex.query!(DB, "SELECT * FROM pizzas", []).rows
    |> to_struct_list
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM pizzas WHERE id = $1 LIMIT 1", [String.to_integer(id)]
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

  def to_struct([[id, name, ingredients, price, img]]) do
    %Pizza{
      id: id,
      name: name,
      ingredients: parse_ingredients(ingredients),
      price: price,
      img: img
    }
  end

  def to_struct_list(rows) do
    for [id, name, ingredients, price, img] <- rows do
      %Pizza{
        id: id,
        name: name,
        ingredients: parse_ingredients(ingredients),
        price: price,
        img: img
      }
    end
  end

  defp parse_ingredients(ingredients) when is_binary(ingredients) do
    {list, _} = Code.eval_string(ingredients)
    Enum.map(list, &List.to_string/1)
  end
end
