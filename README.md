[![Coverage Status](https://coveralls.io/repos/github/treebee/battleship/badge.svg?branch=main)](https://coveralls.io/github/treebee/battleship?branch=main)

# Battleship

A Phoenix LiveView implementation of the [battleship game](<https://en.wikipedia.org/wiki/Battleship_(game)>)

Check out the [live demo](https://battleship.gigalixirapp.com/)

## Development

Sadly there's no one-click development setup yet. You get started, you need
a running Postgres database, running on `localhost:5432` and superuser credentials `postgres:pg-secret`.

For example with Docker you can spin it up like this:

```
docker run -d --name battleship-db -p 5432:5432 -e POSTGRES_PASSWORD=pg-secret postgres:13
```

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
