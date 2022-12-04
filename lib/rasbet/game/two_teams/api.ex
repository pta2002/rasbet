defmodule Rasbet.Game.TwoTeams.Api do
  use HTTPoison.Base

  alias Rasbet.Game.TwoTeams.Game
  alias Rasbet.Game.Bets
  alias Rasbet.Game.Bets.Bet
  alias Rasbet.Repo
  alias Rasbet.Wallet.Transaction
  alias Rasbet.Wallet

  alias Ecto.Multi

  require Logger
  import Ecto.Query

  @moduledoc """
  # Functions for interfacing with the provided API
  """

  @endpoint Application.fetch_env!(:rasbet, :endpoint)

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    Poison.decode(body)
  end

  def update_games() do
    case games() do
      {:ok, games} ->
        for game <- games do
          Multi.new()
          |> Multi.one(:game, from(i in Game, where: i.api_id == ^game.api_id))
          |> Multi.insert_or_update(:new_game, fn %{game: db_game} ->
            Game.changeset(db_game || %Game{api_id: game.api_id}, game)
          end)
          |> Multi.run(:completed_bets, fn repo, %{game: game, new_game: new_game} ->
            if game != nil and new_game.completed and not game.completed do
              {:ok,
               game
               |> repo.preload(bets: [entries: :game])
               |> Map.get(:bets)
               |> Enum.filter(&(Bets.bet_status(&1) != :in_progress))
               |> Enum.map(&Bets.assign_winnings/1)}
            else
              {:ok, []}
            end
          end)
          |> Multi.run(:winning_transactions, fn repo, %{completed_bets: bets} ->
            {:ok,
             bets
             |> Enum.filter(&Money.positive?(&1.final_gains))
             |> Enum.map(fn bet ->
               {bet,
                %Transaction{
                  type: :bet_winnings,
                  value: bet.final_gains,
                  description: "Recompensa aposta",
                  bet_id: bet.id,
                  user_id: bet.user_id,
                  inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
                  updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
                }}
             end)
             |> Enum.map(fn {bet, tx} ->
               Wallet.apply_transaction(tx)
               |> Multi.update_all(
                 :bet,
                 fn _ ->
                   from(b in Bet, where: b.id == ^bet.id, update: [set: [completed: true]])
                 end,
                 []
               )
             end)
             |> Enum.map(&repo.transaction/1)}
          end)
          |> Multi.inspect(only: :winning_transactions)
          |> Repo.transaction()
        end

        Logger.debug("Games saved.")

      {:error, reason} ->
        Logger.error("Failed to fetch games", reason: reason)
    end
  end

  @spec games :: {:error, any} | {:ok, list}
  def games() do
    case get("/games", [], timeout: 50_000, recv_timeout: 50_000) do
      {:ok, %{body: {:ok, body}}} -> {:ok, Enum.map(body, &cast_game/1)}
      {:ok, %{body: {:error, reason}}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec create_game(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def delete_game(%Game{} = game_info) do
    Repo.delete(game_info)
  end

  defp cast_game(
         %{
           "id" => id,
           "awayTeam" => away_team,
           "homeTeam" => home_team,
           "commenceTime" => start_time,
           "completed" => completed,
           "scores" => score,
           "bookmakers" => bookmakers
         } = _game
       ) do
    time =
      case DateTime.from_iso8601(start_time) do
        {:ok, t, _} -> t
        {:error, err} -> raise err
      end

    [home_score, away_score] =
      if score do
        score
        |> String.split("x")
        |> Enum.map(&String.to_integer/1)
      else
        [nil, nil]
      end

    # TODO: Ir buscar as odds de uma forma melhor...
    odds =
      case bookmakers do
        [%{"markets" => [%{"key" => "h2h", "outcomes" => outcomes} | _]} | _] ->
          Enum.reduce(outcomes, Map.new(), fn outcome, acc ->
            Map.put(acc, outcome["name"], trunc(outcome["price"] * 100))
          end)

        _ ->
          %{}
      end

    %{
      api_id: id,
      game_source: "ucras",
      home_team: home_team,
      away_team: away_team,
      start_time: time,
      completed: completed,
      home_score: home_score,
      away_score: away_score,
      odds: odds,
      sport: :football
    }
  end
end
