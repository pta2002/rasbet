FROM elixir:alpine

WORKDIR /app

RUN apk add --no-cache make g++ nodejs inotify-tools && \
    mix local.hex --force && \
    mix archive.install hex phx_new --force && \
    mix local.rebar --force

COPY mix.exs .
COPY mix.lock .

CMD /app/scripts/run.sh
