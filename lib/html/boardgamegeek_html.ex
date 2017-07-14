defmodule BoardGameGeekHTML.HTTPClient do
  @moduledoc """
  BoardGameGeek.com HTML Scraper

  Use this in clients to scrape BoardGameGeek's HTML pages.

  ## Examples

  defmodule MyClient do
    require BoardGameGeek

    def search_games(game) do
      BoardGameGeekHTML.get("geeksearch.php?action=search&objecttype=boardgame&q=" <> game).body
    end
  end
  """

  use HTTPotion.Base

  def process_url(url) do
    "https://www.boardgamegeek.com/" <> url
  end

  def process_request_headers(headers) do
    Map.put(headers, :"Content-Type", "text/html")
  end

  def process_response_body(body) do
    body
    |> IO.iodata_to_binary
  end
end

