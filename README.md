# Gig

With Gig you can monitor gigs near your location, accessing more data about your favourite artists.

## Development/Test

- Initial setup can be done with `mix deps.get`
- Run tests with `mix test`
- Run dialyzer with `mix dialyzer`
- Run credo with `mix credo`
- Build docs with `mix docs`

Running the iex console requires an environment variable called `SONGKICK_API_TOKEN`.

E.g.

`SONGKICK_API_TOKEN=<my-token> iex -S mix`

## Docker support

- copy the `.env.example` file to `.env`
- replace the relevant values in the config (e.g. a working Songkick api token)
- run all commands via Docker compose. For some examples, check the contents of `Makefile`
