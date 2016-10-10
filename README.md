# BoardGameGeekClient

[![Build Status](https://travis-ci.org/ElixirCLE/boardgamegeek_client.svg?branch=master)](https://travis-ci.org/ElixirCLE/boardgamegeek_client)

An Elixir wrapper around the [BoardGameGeek API](http://boardgamegeek.com/wiki/page/BGG_XML_API2)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `boardgamegeek_client` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:boardgamegeek_client, "~> 0.1.0"}]
    end
    ```

  2. Ensure `boardgamegeek_client` is started before your application:

    ```elixir
    def application do
      [applications: [:boardgamegeek_client]]
    end
    ```

