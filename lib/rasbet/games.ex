defmodule Rasbet.Games do
  use Phoenix.HTML

  alias Rasbet.Game.TwoTeams.Game
  alias Rasbet.Game.Bets
  alias Rasbet.Game.Bets.Bet
  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet
  alias Ecto.Multi
  alias Rasbet.Accounts.Subscription
  alias Rasbet.Accounts.Notification

  import Ecto.Query

  require Logger

  def get_name(%Game{home_team: home, away_team: away}) do
    raw("#{home} &ndash; #{away}")
  end

  def get_outcome(%Game{
        home_team: home_team,
        home_score: home_score,
        away_team: away_team,
        away_score: away_score
      }) do
    cond do
      away_score == home_score -> "Draw"
      home_score > away_score -> home_team
      away_score > home_score -> away_team
    end
  end

  @doc """
  Takes in a query to find the game. The second argument is what the new state
  of the game _should_ be.
  """
  def update_game(query, default, game) do
    multi =
      Multi.new()
      |> Multi.one(:game, query)
      |> Multi.insert_or_update(:new_game, fn %{game: db_game} ->
        Game.changeset(db_game || default, game)
      end)
      |> Multi.run(:events, fn _, %{game: game, new_game: new_game} ->
        # Find out what events happened, in order to send notifications
        if game != nil do
          completed = new_game.completed and not game.completed
          started = new_game.home_score != nil and game.home_score == nil
          odds = new_game.odds != game.odds

          {:ok,
           [
             if completed do
               {:ended, %{}}
             end,
             if started do
               {:started, %{}}
             end,
             if odds do
               {:odds_changed, %{odds: new_game.odds}}
             end
           ]
           |> Enum.filter(fn a -> a != nil end)}
        else
          {:ok, []}
        end
      end)
      |> Multi.run(:subscriptions, fn repo, %{events: events, new_game: game} ->
        subscriptions =
          Enum.map(events, fn {event, extra} ->
            {event, extra,
             from(s in Subscription, where: s.game_id == ^game.id and ^event in s.events)
             |> repo.all()}
          end)

        {:ok, subscriptions}
      end)
      |> Multi.run(:notifications, fn _, %{subscriptions: subscriptions, new_game: game} ->
        IO.inspect(subscriptions)

        {:ok,
         Enum.flat_map(subscriptions, fn {event, extra, subs} ->
           Enum.map(subs, fn subscription ->
             %Notification{
               game_id: game.id,
               extra_data: extra,
               event: event,
               user_id: subscription.user_id
             }
           end)
         end)}
      end)
      |> Multi.run(:update_bets, fn repo, %{new_game: game, events: events} ->
        {:ok,
         game
         |> repo.preload(bets: [entries: :game])
         |> Map.get(:bets)
         |> Bets.update_game(repo, events |> Enum.map(fn {e, _} -> e end))}
      end)

    res = multi |> Rasbet.Repo.transaction()

    case res do
      {:ok, %{notifications: ns}} ->
        Rasbet.Accounts.Notifications.send_notifications(ns)
        Logger.debug("Games saved.")

      {:error, _} ->
        Logger.error("Error updating game")
    end
  end
end
