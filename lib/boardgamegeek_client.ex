defmodule BoardGameGeekClient do
  @boardgamegeek_api Application.get_env(:boardgamegeek_client, :boardgamegeek_api)

  @moduledoc """
  Client for interacting with the BoardGameGeek XML API (v2).
  """

  @doc """
  Search BoardGameGeek for any board games containing the query string.
  Returns a list of maps containing the names (plus year) and BoardGameGeek ID.

  ## Examples
      iex> BoardGameGeekClient.search_games("Scythe")
      [%{id: 169786, name: "Scythe (2016)"}, %{id: 199727, name: "Scythe: Invaders from Afar (2016)"}]
  """
  def search_games(query) do
    doc = "search?query=#{query}&type=boardgame"
    |> get_response

    Exml.get(doc, "//items/@total")
    |> String.to_integer
    |> search_games(doc)
  end
  defp search_games(0, _), do: []
  defp search_games(_, doc) do
    ids = Exml.get(doc, "//items/item/@id")
    names = Exml.get(doc, "//items/item/name/@value")
    years = Exml.get(doc, "//items/item/yearpublished/@value")
    games = Enum.zip(names, years)
    Enum.zip(ids, games) |> Enum.map(fn {id, {name, year}} -> %{id: String.to_integer(id), name: "#{name} (#{year})"} end)
  end

  @doc """
  Request a user's collection of board games from BoardGameGeek.
  Returns a list of Game structs contains the BoardGameGeek ID, name, thumbnail, minimum players, and maximum players

  ## Examples
      iex> BoardGameGeekClient.get_game_collection("Serneum")
      [%Game{bgg_id: 207830, name: "5-Minute Dungeon", image: "https://cf.geekdo-images.com/images/pic3213622_t.png", min_players: 2, max_players: 5},
       %Game{bgg_id: 141932, name: "The Agents", image: "https://cf.geekdo-images.com/images/pic1714861_t.png", min_players: 2, max_players: 5}]
  """
  def get_game_collection(username) do
    game_ids =
      "collection?username=#{username}&own=1&subtype=boardgame"
      |> get_response
      |> Exml.get("//items/item/@objectid")
    get_games_info(game_ids)
  end

  @doc """
  Request information about a specific board game from BoardGameGeek.
  Returns a list of Game structs contains the BoardGameGeek ID, name, thumbnail, minimum players, and maximum players

  ## Examples
      iex> BoardGameGeekClient.get_games_info([207830, 141932])
      [%Game{bgg_id: 207830, name: "5-Minute Dungeon", image: "https://cf.geekdo-images.com/images/pic3213622_t.png", min_players: 2, max_players: 5},
       %Game{bgg_id: 141932, name: "The Agents", image: "https://cf.geekdo-images.com/images/pic1714861_t.png", min_players: 2, max_players: 5}]

      iex> BoardGameGeekClient.get_games_info([207830])
      [%Game{bgg_id: 207830, name: "5-Minute Dungeon", image: "https://cf.geekdo-images.com/images/pic3213622_t.png", min_players: 2, max_players: 5}]
  """
  def get_games_info(game_ids) when is_list(game_ids) do
    doc = "thing?id=#{Enum.join(game_ids, ",")}"
    |> get_response(30_000)

    case games_from_xml(doc) do
      {:ok, games} ->
        games
      {:error, msg} ->
        raise msg
    end
  end
  def get_games_info(_), do: []

  defp games_from_xml(doc) do
    bgg_ids = Exml.get(doc, "//items/item/@id")
    names = Exml.get(doc, "//items/item/name[@type='primary']/@value")
    images = Exml.get(doc, "//items/item/thumbnail")
    min_players = Exml.get(doc, "//items/item/minplayers/@value")
    max_players = Exml.get(doc, "//items/item/maxplayers/@value")
    game_from_xml(bgg_ids, names, images, min_players, max_players, [])
  end

  # This is somewhat poorly named. The game is from the XML but we've already parsed it into a series of lists
  # This specific method is only used in the case where we only look up a single game
  defp game_from_xml(bgg_id, name, image, min_players, max_players, _) when not is_list(bgg_id) do
    {:ok, [create_game(bgg_id, name, image, min_players, max_players)]}
  end
  defp game_from_xml([bgg_id|ids], [name|names], [image|images], [min_players|mins], [max_players|maxes], result) do
    game = create_game(bgg_id, name, image, min_players, max_players)
    game_from_xml(ids, names, images, mins, maxes, [game | result])
  end
  defp game_from_xml([], [], [], [], [], result) do
    {:ok, Enum.reverse(result)}
  end
  defp game_from_xml(_, _, _, _, _, _) do
    {:error, "Invalid data was parsed from BGG. All data lists should be the same length."}
  end

  defp create_game(bgg_id, name, image, min_players, max_players) do
    %Game{
       bgg_id: String.to_integer(bgg_id),
       name: name,
       image: image,
       min_players: String.to_integer(min_players),
       max_players: String.to_integer(max_players)
    }
  end

  defp get_response(url, timeout \\ 5_000) do
    @boardgamegeek_api.get(url, [timeout: timeout]).body
    |> Exml.parse
  end
end
