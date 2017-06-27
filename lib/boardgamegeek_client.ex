defmodule BoardGameGeekClient do
  @moduledoc """
  Client for interacting with BoardGameGeek.
  """

  require BoardGameGeek

  def search_games(query) do
    url = "search?query=#{query}&type=boardgame"
    doc = get_response(url)
    ids = Exml.get(doc, "//items/item/@id")
    names = Exml.get(doc, "//items/item/name/@value")
    years = Exml.get(doc, "//items/item/yearpublished/@value")
    games = Enum.zip(names, years)
    Enum.zip(ids, games) |> Enum.map(fn {id, {name, year}} -> %{id: id, name: "#{name} (#{year})"} end)
  end

  def get_game_collection(username) do
    game_ids =
      "collection?username=#{username}&own=1&subtype=boardgame"
      |> get_response
      |> Exml.get("//items/item/@objectid")
    get_games_info(game_ids)
  end

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
    bgg_ids = Exml.get doc, "//items/item/@id"
    names = Exml.get doc, "//items/item/name[@type='primary']/@value"
    images = Exml.get doc, "//items/item/thumbnail"
    min_players = Exml.get doc, "//items/item/minplayers/@value"
    max_players = Exml.get doc, "//items/item/maxplayers/@value"
    game_from_xml(bgg_ids, names, images, min_players, max_players, [])
  end

  # This is somewhat poorly named. The game is from the XML but we've already parsed it into a series of lists
  defp game_from_xml([bgg_id|ids], [name|names], [image|images], [min_players|mins], [max_players|maxes], result) do
    game = %Game{
             bgg_id: bgg_id,
             name: name,
             image: image,
             min_players: String.to_integer(min_players),
             max_players: String.to_integer(max_players)
           }
    game_from_xml(ids, names, images, mins, maxes, [game | result])
  end
  defp game_from_xml([], [], [], [], [], result) do
    {:ok, Enum.reverse(result)}
  end
  defp game_from_xml(_, _, _, _, _, _) do
    {:error, "Invalid data was parsed from BGG. All data lists should be the same length."}
  end

  defp get_response(url, timeout \\ 5_000) do
    BoardGameGeek.get(url, [timeout: timeout]).body
    |> Exml.parse
  end
end
