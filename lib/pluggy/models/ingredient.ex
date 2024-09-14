defmodule Pluggy.Ingredient do
  defstruct( name: "", price: nil)

  alias Pluggy.Ingredient

  def all do
    Postgrex.query!(DB, "SELECT * FROM ingredients", []).rows
    |> to_struct_list
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

  def delete(name) do
    Postgrex.query!(DB, "DELETE FROM ingredients WHERE name = $1", [name])
  end

  def to_struct([[ name, price]]) do
    %Ingredient{
      name: name,
      price: price
    }
  end

  def to_struct_list(rows) do
    for [ name, price] <- rows do
      %Ingredient{
        name: name,
        price: price,
      }
    end
  end
end
