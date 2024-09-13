defmodule Pluggy.Template do
  # def srender(file, data \\ [], layout \\ true) do
  #   {:ok, template} = File.read("templates/#{file}.slime")

  #   case layout do
  #     true ->
  #       {:ok, layout} = File.read("templates/layout.slime")
  #       Slime.render(layout, template: Slime.render(template, data))

  #     false ->
  #       Slime.render(template, data)
  #   end
  # end

  alias Pluggy.Layout
  alias Pluggy.Checkout

  def render(conn, file, data \\ [], layout \\ true) do
    session_user = conn.private.plug_session["user_id"]

    cond do
      session_user == nil && file != "pizzas/signup" -> EEx.eval_file("templates/pizzas/login.eex", data)
      true ->
        case layout do
          true ->
            EEx.eval_file("templates/layout.eex",
              template: EEx.eval_file("templates/#{file}.eex", data),
              basket_amount: Layout.get_basket_amount("Carl Svensson"),
              user_name: "Carl Svensson",
              orders: Checkout.get_current_order(1)
            )

          false ->
            EEx.eval_file("templates/#{file}.eex", data)
        end
    end
  end
end
