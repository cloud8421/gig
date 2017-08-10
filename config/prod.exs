use Mix.Config

config :gig,
  server_port: System.get_env("PORT"),
  metrics_adapter: Metrics.Adapter.Statsd

config :graphiter,
  writers: [heroku: [host: 'carbon.hostedgraphite.com',
                     port: 2003,
                     prefix: System.get_env("HOSTEDGRAPHITE_APIKEY"),
                     send_timeout: 5000]]

config :ex_statsd,
       host: "localhost",
       port: 8125,
       namespace: "gig",
       tags: ["env:#{Mix.env}"]
