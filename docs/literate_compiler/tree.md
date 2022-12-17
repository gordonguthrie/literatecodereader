```
elixirdefmodule LiterateCompiler.Tree do

	@empty_accumulator []

  def walk_tree(directorylist, fun), do: walk_tree(directorylist, fun, @empty_accumulator)

  defp walk_tree([], _fun, acc), do: acc
  defp walk_tree([h | t], fun, acc) do
    newacc = case File.dir?(h) do
      true  -> wildcard = Path.join(h, "*")
               entries = Path.wildcard(wildcard)
               Enum.flat_map(entries, fn x -> walk_tree([x], fun, acc) end)
      false -> file = fun.(h)
               [file | acc]
    end
    walk_tree(t, fun, newacc)
  end

end```
