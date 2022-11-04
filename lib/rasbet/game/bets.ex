defmodule Rasbet.Game.Bets do
  alias Ecto.Multi

  alias Rasbet.Game.TwoTeams.Info
  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet

  import Ecto.Query

  def place_bet(changeset, entries) do
    transaction = %Transaction{
      type: :bet,
      value: Money.neg(changeset.changes.amount),
      description: "Place bet"
    }

    # TODO: Validate the bet's entries
    Multi.new()
    |> Multi.insert(:bet, changeset)
    |> Multi.merge(fn %{bet: %{user_id: user_id, id: bet_id}} ->
      Wallet.apply_transaction(%{transaction | user_id: user_id, bet_id: bet_id})
    end)
    |> Multi.run(:entries, fn repo, %{bet: bet} ->
      {:ok,
       entries
       |> Enum.map(fn entry ->
         # TODO: Error if this is nil
         info =
           Info
           |> where([i], i.id == ^entry.id)
           |> repo.one()

         %{
           odds: info.odds[entry.outcome],
           outcome: entry.outcome,
           game_id: entry.id,
           bet_id: bet.id,
           inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
           updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
         }
       end)}
    end)
    |> Multi.insert_all(:insert_entries, Entry, & &1.entries)
  end
end
