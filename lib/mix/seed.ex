defmodule Mix.Tasks.Seed do
  use Mix.Task

  @shortdoc "Resets & seeds the DB."
  def run(_) do
    Mix.Task.run "app.start"
    drop_tables()
    create_tables()
    seed_data()
  end

  defp drop_tables() do
    IO.puts("Dropping tables")
    Postgrex.query!(DB, "DROP TABLE IF EXISTS pizzas", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "DROP TABLE IF EXISTS orders", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "DROP TABLE IF EXISTS ingredients", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "DROP TABLE IF EXISTS users", [], pool: DBConnection.ConnectionPool)
  end

  defp create_tables() do
    IO.puts("Creating tables")
    Postgrex.query!(DB, "Create TABLE pizzas (id SERIAL, name VARCHAR(255) NOT NULL, ingredients_id VARCHAR(255))", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE orders (id SERIAL, user_id INTEGER, user_name VARCHAR(255) NOT NULL, order VARCHAR(255), state VARCHAR(255) NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE ingredients (id SERIAL, name VARCHAR(255) NOT NULL, price INTEGER NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE users (id SERIAL, name VARCHAR(255) NOT NULL, number INTEGER, mail VARCHAR(255), is_admin BOOLEAN DEFAULT false)", [], pool: DBConnection.ConnectionPool)
  end

  defp seed_data() do
    IO.puts("Seeding data")
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients, price) VALUES($1, $2, $3)", ["Margherita", "[1, 2, 3]", 110], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients, price) VALUES($1, $2, $3)", ["Marinara", "[1]", 110], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients, price) VALUES($1, $2, $3)", ["Prosciutto e funghi", "[1, 2, 4, 5]", 120], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Tomatsås", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Mozzarella", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Basilika", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Skinka", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Svamp", 10], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO users(name, number, mail, is_admin?) VALUES($1, $2, $3, $4)", ["Carl Svensson", 0123456789, Null, false], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO orders(user_id, user_name, order, state) VALUES($1, $2, $3, $4)", [1, "Carl Svensson", "[%{pizza_id: 1, add: [5], sub: [1], size: 1, amount: 2, price: 130}]", "Making"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO orders(user_id, user_name, order, state) VALUES($1, $2, $3, $4)", [Null, "Abdi Svensson", "[%{pizza_id: 1, add: [5], sub: [1], size: 1, amount: 2, price: 130}, %{pizza_id: 3, add: [3], sub: [4, 5], size: 2, amount: 1, price: 230}]", "Done"], pool: DBConnection.ConnectionPool)
  end

end
