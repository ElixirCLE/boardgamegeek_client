defmodule BoardGameGeek.InMemory do
  def get("search?query=Scythe&type=boardgame", _) do
    body = File.read!("test/fixtures/search_games_fixture.xml")
    %HTTPotion.Response{body: body}
  end

  def get("search?query=Sushi+Go+Party&type=boardgame", _) do
    body = File.read!("test/fixtures/search_games_single_result_fixture.xml")
    %HTTPotion.Response{body: body}
  end

  def get("collection?username=Serneum&own=1&subtype=boardgame", _) do
    body = File.read!("test/fixtures/get_collection_fixture.xml")
    %HTTPotion.Response{body: body}
  end

  def get("thing?id=207830", _) do
    body = File.read!("test/fixtures/get_games_info_single_fixture.xml")
    %HTTPotion.Response{body: body}
  end

  def get("thing?id=207830,141932", _) do
    body = File.read!("test/fixtures/get_games_info_fixture.xml")
    %HTTPotion.Response{body: body}
  end
end
