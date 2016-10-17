defmodule BoardGameGeekClient do
  @moduledoc """
  Client for interacting with BoardGameGeek.
  """

  require BoardGameGeek

  def get_game_collection(username, wait \\ 500) do
    url = "collection?username=#{username}&own=1&subtype=boardgame"
    doc = get_response(url, wait)
    game_ids = Exml.get doc, "//items/item/@objectid"
    Process.sleep(wait)
    get_games_info(game_ids)
  end

  def get_games_info(game_ids, wait \\ 500) when is_list(game_ids), do: get_games_info(game_ids, wait, [])
  defp get_games_info([], _wait, acc), do: acc
  defp get_games_info([head|tail], wait, acc) do
    url = "thing?id=#{head}"
    response = BoardGameGeek.post(url)
    case response.status_code do
      202 ->
        Process.sleep(wait)
        # Results not ready, append to end of games list so that it retries
        get_games_info(tail ++ [head], wait, acc)
      200 ->
        Process.sleep(wait)
        get_games_info(tail, wait, [game_from_response(response) | acc])
      true -> raise "unknown status code: #{response.status_code}"
    end
  end

  defp game_from_response(response) do
    response.body
    |> Exml.parse
    |> game_from_xml
  end

  defp game_from_xml(doc) do
    name = Exml.get doc, "//items/item/name[@type='primary']/@value"
    min_players = Exml.get doc, "//items/item/minplayers/@value"
    max_players = Exml.get doc, "//items/item/maxplayers/@value"
    %Game{name: name,
          min_players: String.to_integer(min_players),
          max_players: String.to_integer(max_players)}
  end

  defp get_response(url, wait) do
    response = BoardGameGeek.post(url)
    get_response(url, wait, response, response.status_code)
  end

  defp get_response(url, wait, _response, 202) do
    Process.sleep(wait)
    response = BoardGameGeek.post(url)
    get_response(url, wait, response, response.status_code)
  end

  defp get_response(_url, _wait, response, _status_code) do
    response.body
    |> Exml.parse
  end
end
