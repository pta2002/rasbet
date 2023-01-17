defmodule Rasbet.APIs.UCRas do
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

  def update() do
    case games() do
      {:ok, games} ->
        {:ok,
         Enum.map(games, fn game ->
           {from(g in Game, where: g.api_id == ^game.api_id and g.game_source == "ucras"),
            %Game{api_id: game.api_id}, game}
         end)}

      {:error, reason} ->
        {:error, reason}
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
      api_info: %{},
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
