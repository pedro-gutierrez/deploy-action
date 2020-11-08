FROM pedrogutierrez/elixir:1.11
RUN mkdir /action
COPY lib /action/lib
COPY mix.exs mix.lock /action/
RUN mix deps.get; mix compile
COPY entrypoint.sh /action/entrypoint.sh
RUN chmod +x /action/entrypoint.sh 
ENTRYPOINT ["/action/entrypoint.sh"]
