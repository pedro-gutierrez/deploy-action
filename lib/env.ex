defmodule Env do
  def ensure(env) do
    value = System.get_env(env)

    if value == nil || value == "" do
      raise "Missing env variable #{env}"
    end

    value
  end

  def ensure(env, default) do
    System.get_env(env, default)
  end
end
