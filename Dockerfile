FROM pedrogutierrez/elixir:1.11
RUN mkdir /action
COPY lib /action/lib
COPY mix.exs mix.lock /action/
COPY entrypoint.sh /action/entrypoint.sh
RUN chmod +x /action/entrypoint.sh 
RUN cd /action; mix deps.get; mix compile
ENTRYPOINT ["/action/entrypoint.sh"]
