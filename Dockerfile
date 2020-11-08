FROM pedrogutierrez/elixir:1.11
WORKDIR /action
COPY lib /action/lib
COPY mix.exs mix.lock /action/
RUN mix deps.get; mix compile
ENTRYPOINT ["mix", "run", "lib/deploy.exs"]
