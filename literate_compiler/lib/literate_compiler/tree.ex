defmodule LiterateCompiler.Tree do

	@empty_accumulator []

  def walk_tree(directorylist, fun, fnargs), do: walk_tree(directorylist, fun, fnargs, @empty_accumulator)

  defp walk_tree([], _fun, _fnargs, acc), do: acc
  defp walk_tree([h | t], fun, fnargs, acc) do
    newacc = case File.dir?(h) do
      true  -> wildcard = Path.join(h, "*")
               entries = Path.wildcard(wildcard)
               Enum.flat_map(entries, fn x -> walk_tree([x], fun, fnargs, acc) end)
      false -> file = fun.(h, fnargs)
               [file | acc]
    end
    walk_tree(t, fun, fnargs, newacc)
  end

end