# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bookish,
  ecto_repos: [Bookish.Repo]

# Configures the endpoint
config :bookish, Bookish.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TyAH0vNLqCorWMAhS27b7TqObyRDp0NoqJ4SYCQNOiTT4atnVIc8KjZPw3pZaa3Y",
  render_errors: [view: Bookish.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bookish.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
