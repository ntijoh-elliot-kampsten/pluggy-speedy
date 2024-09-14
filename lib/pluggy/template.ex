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

  alias Pluggy.Order
  alias Pluggy.Layout

  def render(conn, file, data \\ [], layout \\ true) do
    cond do
      conn.private.plug_session["user_id"] == nil && file != "pizzas/signup" -> EEx.eval_file("templates/pizzas/login.eex", data)
      true ->
        case layout do
          true ->
            EEx.eval_file("templates/layout.eex",
              template: EEx.eval_file("templates/#{file}.eex", data),
              basket_amount: Layout.get_basket_amount(conn.private.plug_session["user_name"]),
              user_name: conn.private.plug_session["user_name"],
              orders: Order.get_user_unsubmitted_order_parsed(conn.private.plug_session["user_name"])
            )

          false ->
            EEx.eval_file("templates/#{file}.eex", data)
        end
    end
  end
end
