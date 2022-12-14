defmodule LiterateCompilerTest do
  use ExUnit.Case
  doctest LiterateCompiler

  test "greets the world" do
    assert LiterateCompiler.hello() == :world
  end
end
