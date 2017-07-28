FROM elixir:1.5.0

ENV DEBIAN_FRONTEND=noninteractive

RUN mix local.hex --force

RUN mix local.rebar --force

ADD . /app

WORKDIR /app

RUN mix deps.get
