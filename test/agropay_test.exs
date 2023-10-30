defmodule acmeTest do
  use ExUnit.Case
  doctest acme

  test "greets the world" do
    assert acme.hello() == :world
  end
end
