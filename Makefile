.PHONY: test iex

test:
	docker-compose run gig mix test

iex:
	docker-compose run gig iex -S mix
