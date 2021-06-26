defmodule SclTransClientTest do
  use ExUnit.Case
  doctest SclTransClient

  test "greets the world" do
    assert SclTransClient.hello() == :world
  end
end
