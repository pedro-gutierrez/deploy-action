FROM pedrogutierrez/elixir:1.11
WORKDIR /action
COPY lib /action/lib
COPY mix.exs mix.lock /action/
COPY entrypoint.sh /action
RUN chmod +x /action/entrypoint.sh 
RUN mix deps.get; mix compile
ENTRYPOINT ["/action/entrypoint.sh"]
