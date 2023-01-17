defmodule Rasbet.Game.Bets do
  alias Ecto.Multi

  alias Rasbet.Game.TwoTeams.Game
  alias Rasbet.Game.Bets.Entry
  alias Rasbet.Game.Bets.Bet
  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet
  alias Rasbet.Games

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
           Game
           |> where([i], i.id == ^entry.game_id)
           |> repo.one()

         %{
           odds: info.odds[entry.outcome],
           outcome: entry.outcome,
           game_id: entry.game_id,
           bet_id: bet.id,
           inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
           updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
         }
       end)}
    end)
    |> Multi.insert_all(:insert_entries, Entry, & &1.entries)
    |> Multi.run(:notify, fn repo, %{bet: %{user_id: user_id}, entries: entries} ->
      {:ok,
       Enum.map(
         entries,
         &Rasbet.Accounts.User.subscribe_event(repo, user_id, &1.game_id, [
           :started,
           :odds_changed,
           :ended
         ])
       )}
    end)
  end

  def assign_odds(%{entries: entries, amount: amount, promo: promo} = bet) do
    final_odds =
      entries
      |> Enum.reduce(Decimal.new(1), fn %{odds: odds}, acc ->
        Decimal.mult(acc, Decimal.new(1, odds, -2))
      end)

    gains =
      Money.multiply(amount || Money.new(0), final_odds)
      |> then(
        &if promo do
          Rasbet.Promotions.calculate_promotion(&1, promo)
        else
          &1
        end
      )

    %{bet | final_odds: final_odds, possible_gains: gains}
  end

  def assign_entry_odds(%Entry{game: %Game{odds: odds}, outcome: outcome} = entry) do
    Map.put(entry, :odds, Map.get(odds, outcome))
  end

  def assign_winnings(%Bet{} = bet) do
    %{possible_gains: possible_gains} = bet = bet |> assign_odds()

    case bet |> bet_status() do
      :won -> %{bet | final_gains: possible_gains, completed: true}
      :lost -> %{bet | final_gains: Money.new(0), completed: true}
    end
  end

  def entry_status(%Entry{game: game, outcome: outcome}) do
    if game.completed do
      case Games.get_outcome(game) == outcome do
        true -> :won
        false -> :lost
      end
    else
      :in_progress
    end
  end

  def bet_status(%Bet{entries: entries}) do
    Enum.reduce(entries, :won, fn entry, acc ->
      case acc do
        :won -> entry_status(entry)
        a -> a
      end
    end)
  end
end
