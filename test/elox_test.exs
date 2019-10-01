defmodule EloxTest do
  use ExUnit.Case
  doctest Elox

  test "greets the world" do
    assert Elox.hello() == :world
  end
end
