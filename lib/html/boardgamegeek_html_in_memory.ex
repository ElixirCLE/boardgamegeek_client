defmodule BoardGameGeekHTML.InMemory do
  def get("geeksearch.php?action=search&objecttype=boardgame&q=Scythe", _) do
    body = File.read!("test/fixtures/html/search_games_fixture.html")
    %HTTPotion.Response{body: body}
  end

  def get("geeksearch.php?action=search&objecttype=boardgame&q=Sushi+Go+Party", _) do
    body = File.read!("test/fixtures/html/search_games_single_result_fixture.html")
    %HTTPotion.Response{body: body}
  end
end

