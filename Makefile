.PHONY: up compile test iex deps.get docs curl.monitor

up:
	docker-compose up

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

curl.monitor:
	curl http://localhost:4000/monitor/51.50809/-0.1291379 | jq .

load_test:
	locust -f load_test.py --host=http://localhost:4000
