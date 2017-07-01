use Mix.Config

config :boardgamegeek_client, :boardgamegeek_api, BoardGameGeek.InMemory
config :boardgamegeek_client, :boardgamegeek_html, BoardGameGeekHTML.InMemory

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
