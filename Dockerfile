FROM bitwalker/alpine-elixir-phoenix:latest

ARG USER_ID
ARG GROUP_ID


RUN addgroup -g $GROUP_ID user
RUN adduser -D -g '' -G user -u $USER_ID user

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mkdir assets && mkdir deps

COPY assets/package.json assets
COPY assets/package-lock.json assets

RUN mix deps.get && mix deps.compile && MIX_ENV=test mix deps.compile

RUN cd assets && npm install && cd .. \
  && chown -R $USER_ID:$GROUP_ID /app /opt/app

USER user
