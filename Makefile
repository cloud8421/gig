.PHONY: compile test iex deps.get

compile:
	docker-compose run gig mix compile

test:
	docker-compose run gig mix test

iex:
	docker-compose run gig iex -S mix

deps.get:
	docker-compose run gig mix deps.get

docs:
	docker-compose run gig mix docs
