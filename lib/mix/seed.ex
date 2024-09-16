defmodule Mix.Tasks.Seed do
  use Mix.Task

  @shortdoc "Resets & seeds the DB."
  def run(_) do
    Mix.Task.run "app.start"
    drop_tables()
    create_tables()
    seed_data()
    add_orders(1000)
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
    Postgrex.query!(DB, "Create TABLE orders (id SERIAL, user_id INTEGER, user_name VARCHAR(255) NOT NULL, current_order VARCHAR(2000000), state VARCHAR(255) NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE ingredients (name VARCHAR(255) NOT NULL UNIQUE, price INTEGER NOT NULL)", [], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "Create TABLE users (id SERIAL, password VARCHAR(255), name VARCHAR(255) NOT NULL, number VARCHAR(255), mail VARCHAR(255), is_admin BOOLEAN DEFAULT false)", [], pool: DBConnection.ConnectionPool)
  end

  defp seed_data() do
    IO.puts("Seeding data")
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Margherita", "[\"Tomatsås\", \"Mozzarella\", \"Basilika\", \"Gluten\"]", 110, "/uploads/pizzas/margherita.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Marinara", "[\"Tomatsås\", \"Gluten\"]", 110, "/uploads/pizzas/marinara.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Prosciutto e funghi", "[\"Tomatsås\", \"Mozzarella\", \"Skinka\", \"Svamp\", \"Gluten\"]", 120, "/uploads/pizzas/prosciutto-e-funghi.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Quattro stagioni", "[\"Tomatsås\", \"Mozzarella\", \"Skinka\", \"Svamp\", \"Kronärtskocka\", \"Oliver\", \"Gluten\"]", 120, "/uploads/pizzas/quattro-stagioni.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Capricciosa", "[\"Tomatsås\", \"Mozzarella\", \"Skinka\", \"Svamp\", \"Kronärtskocka\", \"Gluten\"]", 120, "/uploads/pizzas/capricciosa.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Quattro formaggi", "[\"Tomatsås\", \"Mozzarella\", \"Parmesan\", \"Pecorino\", \"Gorgonzola\", \"Gluten\"]", 120, "/uploads/pizzas/quattro-formaggi.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Ortolana", "[\"Tomatsås\", \"Mozzarella\", \"Paprika\", \"Aubergine\", \"Zucchini\", \"Gluten\"]", 120, "/uploads/pizzas/otrolana.svg"], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO pizzas(name, ingredients_id, price, image_url) VALUES($1, $2, $3, $4)", ["Diavola", "[\"Tomatsås\", \"Mozzarella\", \"Salami\", \"Paprika\", \"Chili\", \"Gluten\"]", 120, "/uploads/pizzas/diavola.svg"], pool: DBConnection.ConnectionPool)

    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Tomatsås", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Mozzarella", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Basilika", 5], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Skinka", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Svamp", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Kronärtskocka", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Parmesan", 15], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Pecorino", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Gorgonzola", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Paprika", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Aubergine", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Zucchini", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Oliver", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Salami", 15], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Chili", 10], pool: DBConnection.ConnectionPool)
    Postgrex.query!(DB, "INSERT INTO ingredients(name, price) VALUES($1, $2)", ["Gluten", 0], pool: DBConnection.ConnectionPool)

    # Password is "123"
    Postgrex.query!(DB, "INSERT INTO users(name, password, number, mail, is_admin) VALUES($1, $2, $3, $4, $5)", ["Admin", "$2b$12$4Co1TinijJo1Xq8a0f0LHevgrHTCB6BCPN5i1xmJ53cqNJ2EMPBeS", "", "", true], pool: DBConnection.ConnectionPool)
  end

  defp add_orders(amount_orders) do
    first_names = ["Carl", "Sven", "Gustav", "Johan", "Siri", "Wilma", "Hannah", "Solveig", "Göran", "Elliot", "Filip", "Phillip", "Christer", "Tilde", "Jonas", "Leon", "Karina", "Linnea", "Andreas", "Abdi", "Muhammed", "Mohammed", "Elton", "David", "Julia", "Alva", "Nellie", "Solin", "Sirin", "Sonia", "Rita", "Gunilla", "Bashar", "Yazan"]
    last_names = [
      "Johansson", "Andersson", "Karlsson", "Nilsson", "Eriksson", "Larsson",
      "Olsson", "Persson", "Svensson", "Gustafsson", "Pettersson", "Jonsson",
      "Jansson", "Hansson", "Bengtsson", "Carlsson", "Jönsson", "Petersson",
      "Lindberg", "Magnusson", "Gustavsson", "Olofsson", "Lindgren",
      "Lindström", "Axelsson", "Lundberg", "Lundgren", "Berg", "Jakobsson",
      "Bergström", "Berglund", "Fredriksson", "Sandberg", "Mattsson",
      "Henriksson", "Forsberg", "Lindqvist", "Danielsson", "Eklund", "Lundin",
      "Lind", "Sjöberg", "Gunnarsson", "Holm", "Engström", "Håkansson",
      "Bergman", "Samuelsson", "Fransson", "Johnsson", "Holmberg", "Lundqvist",
      "Arvidsson", "Wallin", "Nyberg", "Isaksson", "Nyström", "Söderberg",
      "Björk", "Eliasson", "Mårtensson", "Berggren", "Nordström", "Lundström",
      "Nordin", "Hermansson", "Holmgren", "Björklund", "Sundberg", "Hedlund",
      "Sandström", "Ström", "Martinsson", "Åberg", "Ekström", "Dahlberg",
      "Abrahamsson", "Sjögren", "Blom", "Lindholm", "Blomqvist", "Norberg",
      "Ek", "Jonasson", "Månsson", "Ivarsson", "Andreasson", "Hellström",
      "Öberg", "Falk", "Nyman", "Strömberg", "Åkesson", "Ali", "Dahl",
      "Sundström", "Bergqvist", "Lund", "Åström", "Hallberg", "Josefsson",
      "Palm", "Löfgren", "Göransson", "Söderström", "Englund", "Borg",
      "Davidsson", "Ottosson", "Jensen", "Ekman", "Lindblom", "Adolfsson",
      "Lindahl", "Hansen", "Nygren", "Stenberg", "Skoglund", "Hedberg",
      "Strand", "Friberg", "Möller", "Boström", "Börjesson", "Söderlund",
      "Strandberg", "Sjöström", "Erlandsson", "Ericsson", "Holmström",
      "Bäckström", "Höglund", "Rosén", "Claesson", "Johannesson", "Edlund",
      "Malm", "Aronsson", "Haglund", "Björkman", "Nielsen", "Dahlgren",
      "Knutsson", "Moberg", "Melin", "Viklund", "Roos", "Sundqvist",
      "Wikström", "Lilja", "Holmqvist", "Blomberg", "Ohlsson", "Ahmed",
      "Lindén", "Vikström", "Östlund", "Alm", "Norén", "Olausson", "Sundin",
      "Franzén", "Hedman", "Lindell", "Lundmark", "Oskarsson", "Pålsson",
      "Dahlström", "Jacobsson", "Högberg", "Wiklund", "Öhman", "Paulsson",
      "Nord", "Ljungberg", "Lindblad", "Boman", "Molin", "Sjödin", "Linder",
      "Ljung", "Hedström", "Malmberg", "Ekberg", "Sköld", "Hellberg", "Norman",
      "Hagström", "Pedersen", "Ståhl", "Lindh", "Svärd", "Berntsson",
      "Hjalmarsson", "Näslund", "Ågren", "Forslund", "Augustsson", "Lindkvist",
      "Asplund", "Brandt", "Lundkvist", "Mohamed", "Dahlin"]

    Enum.each(0..amount_orders, fn(x) ->

      state = case :rand.uniform(3) do
        1 -> "Registered"
        2 -> "Making"
        3 -> "Done"
        _ -> "oops"
      end

      add_list = "[]"
      sub_list = "[]"

      order_map = case :rand.uniform(3) do
        1 -> "[%{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}]"
        2 -> "[%{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}, %{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}]"
        3 -> "[%{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}, %{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}, %{pizza_id: #{:rand.uniform(8)}, add: #{add_list}, sub: #{sub_list}, size: #{:rand.uniform(3)}, amount: #{:rand.uniform(10)}, price: 0}]"
      end

      user_id = :rand.uniform(9999)

      name = Enum.at(first_names, :rand.uniform(length(first_names) - 1)) <> " " <> Enum.at(last_names, :rand.uniform(length(last_names) - 1))

      Postgrex.query!(DB, "INSERT INTO orders(user_id, user_name, current_order, state) VALUES($1, $2, $3, $4)", [user_id, name, order_map, state], pool: DBConnection.ConnectionPool)
    end)
  end
end
