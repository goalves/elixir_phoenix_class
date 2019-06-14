# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir_phoenix_class,
  namespace: EPClass,
  ecto_repos: [EPClass.Repo]

# Configures the endpoint
config :elixir_phoenix_class, EPClassWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "L87E9eS9jK8uh4ZABRM66Qs8XRtuvT0SdkzRmv/225elAOoUG6bHmq0Zlio1iy9F",
  render_errors: [view: EPClassWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: EPClass.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
