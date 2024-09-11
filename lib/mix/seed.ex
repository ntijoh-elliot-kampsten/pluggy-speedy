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
    Postgrex.query!(DB, "Create TABLE pizzas (id SERIAL, name VARCHAR(255) NOT NULL, ingredients_id VARCHAR(255), price INTEGER, image_url VARCHAR(255))", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE orders (id SERIAL, user_id INTEGER, user_name VARCHAR(255) NOT NULL, current_order VARCHAR(255), state VARCHAR(255) NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE ingredients (name VARCHAR(255) NOT NULL UNIQUE, price INTEGER NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE users (id SERIAL, name VARCHAR(255) NOT NULL, number INTEGER, mail VARCHAR(255), is_admin BOOLEAN DEFAULT false)", [], pool: DBConnection.ConnectionPool)
  end

  defp seed_data() do
    IO.puts("Seeding data")
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Margherita", "[\"Tomatsås\", \"Mozzarella\", \"Basilika\"]", 110, "/uploads/pizzas/margherita.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Marinara", "[\"Tomatsås\"]", 110, "/uploads/pizzas/marinara.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Prosciutto e funghi", "[\"Tomatsås\", \"Mozzarella\", \"Skinka\", \"Svamp\"]", 120, "/uploads/pizzas/prosciutto-e-funghi.svg"], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Tomatsås", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Mozzarella", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Basilika", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Skinka", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Svamp", 10], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO users(name, number, mail, is_admin) VALUES($1, $2, $3, $4)", ["Carl Svensson", 0123456789, "", false], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO orders(user_id, user_name, current_order, state) VALUES($1, $2, $3, $4)", [1, "Carl Svensson", "[%Order{pizza_id: 1, add: ['Svamp'], sub: ['Tomatsås'], size: 1, amount: 2, price: 130}]", "Making"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO orders(user_id, user_name, current_order, state) VALUES($1, $2, $3, $4)", [-1, "Abdi Svensson", "[%Order{pizza_id: 1, add: ['Svamp'], sub: ['Tomatsås'], size: 1, amount: 2, price: 130}], [%Order{pizza_id: 3, add: ['Basilika'], sub: ['Skinka', 'Svamp'], size: 2, amount: 1, price: 230}]", "Done"], pool: DBConnection.ConnectionPool)
  end

end
