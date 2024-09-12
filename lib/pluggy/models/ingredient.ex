defmodule Pluggy.Ingredient do
  defstruct(id: nil, name: "", price: nil)

  alias Pluggy.Ingredient

  def all do
    Postgrex.query!(DB, "SELECT * FROM ingredients", []).rows
    |> to_struct_list
  end

  def get(id) do
    Postgrex.query!(DB, "SELECT * FROM ingredients WHERE id = $1 LIMIT 1", [String.to_integer(id)]
    ).rows
    |> to_struct
  end

  def get_by_name(name) do
    Postgrex.query!(DB, "SELECT * FROM ingredients WHERE name = $1 LIMIT 1", [name]
    ).rows
    |> to_struct
  end

  # def update(id, params) do
  #   name = params["name"]
  #   ingredients = params["ingredients"]
  #   price = String.to_integer(params["price"])
  #   id = String.to_integer(id)

  #   Postgrex.query!(
  #     DB,
  #     "UPDATE pizzas SET name = $1, ingredients = $2, price = $3 WHERE id = $4",
  #     [name, ingredients, price, id]
  #   )
  # end

  # def create(params) do
  #   name = params["name"]
  #   ingredients = params["ingredients"]
  #   price = String.to_integer(params["price"])

  #   Postgrex.query!(DB, "INSERT INTO pizzas (name, ingredients, price) VALUES ($1, $2, $3)", [name, ingredients, price])
  # end

  def delete(id) do
    Postgrex.query!(DB, "DELETE FROM ingredients WHERE id = $1", [String.to_integer(id)])
  end

  def to_struct([[id, name, price]]) do
    %Ingredient{
      id: id,
      name: name,
      price: price
    }
  end

  def to_struct_list(rows) do
    for [id, name, price] <- rows do
      %Ingredient{
        id: id,
        name: name,
        price: price,
      }
    end
  end
end
