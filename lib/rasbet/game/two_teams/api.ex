defmodule Rasbet.Game.TwoTeams.Api do
  use HTTPoison.Base

  alias Rasbet.Game.TwoTeams.Info
  alias Rasbet.Repo

  require Logger

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
        Logger.debug("Saving games...")

        for game <- games do
          case Repo.get_by(Info, api_id: game.api_id) do
            nil -> %Info{api_id: game.api_id}
            g -> g
          end
          |> Info.changeset(game)
          |> Repo.insert_or_update()
        end

        Logger.debug("Games saved.")

      {:error, reason} ->
        Logger.error("Failed to fetch games", reason: reason)
    end
  end

  @spec games :: {:error, any} | {:ok, list}
  def games() do
    case get("/games") do
      {:ok, %{body: {:ok, body}}} -> {:ok, Enum.map(body, &cast_game/1)}
      {:ok, %{body: {:error, reason}}} -> {:error, reason}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec create_game(:invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_game(attrs \\ %{}) do
    %Info{}
    |> Info.changeset(attrs)
    |> Repo.insert()
  end

  def delete_game(%Info{} = game_info) do
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
