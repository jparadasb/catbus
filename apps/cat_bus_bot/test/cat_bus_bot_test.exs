defmodule CatBusBotTest do
  use ExUnit.Case
  doctest CatBusBot

  test "greets the world" do
    assert CatBusBot.hello() == :world
  end
end
