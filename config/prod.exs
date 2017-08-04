use Mix.Config

config :gig,
  server_port: System.get_env("PORT"),
  metrics_adapter: Metrics.Adapter.Graphite

config :graphiter,
  writers: [heroku: [host: 'carbon.hostedgraphite.com',
                     port: 2003,
                     prefix: System.get_env("HOSTEDGRAPHITE_APIKEY"),
                     send_timeout: 5000]]
