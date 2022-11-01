#!/usr/bin/env sh

yes | mix deps.get

cd assets ; npm install ; cd ..

mix ecto.create
mix ecto.migrate

mix phx.server
