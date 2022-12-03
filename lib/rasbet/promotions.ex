defmodule Rasbet.Promotions do
  alias Rasbet.Promotions.Promo
  alias Rasbet.Accounts.User
  alias Rasbet.Repo

  import Ecto.Query

  def applicable_promotions(_user \\ %User{}) do
    # TODO: Filtrar contas novas, filtrar promoções gastas

    from(p in Promo, where: p.active == true) |> Repo.all()
  end

  def is_applicable(promo, bet) do
    Money.cmp(bet.amount, promo.minimum) != :lt
  end

  def calculate_promotion(amount, promo) do
    if promo.discount do
      Money.add(amount, Money.multiply(amount, promo.discount / 100))
    else
      Money.add(amount, promo.free_credits)
    end
  end
end
