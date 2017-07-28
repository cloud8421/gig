defmodule GigTest do
  use ExUnit.Case
  doctest Gig

  test "greets the world" do
    assert Gig.hello() == :world
  end
end
