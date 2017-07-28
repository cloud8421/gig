.PHONY: test iex deps.get

test:
	docker-compose run gig mix test

iex:
	docker-compose run gig iex -S mix

deps.get:
	docker-compose run gig mix deps.get
