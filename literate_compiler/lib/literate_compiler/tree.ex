defmodule LiterateCompiler.Tree do

### Purpose

## This is a generic tree walking function
## given a root directory it walks over all the sub directories

## The first arguement of the public api is the root directory
## and the second is a function of arity 1 which is called when a file is found

	@empty_accumulator []

#### Public API

  def walk_tree(directorylist, excludelist, fun), do: walk_tree(directorylist, excludelist, fun, @empty_accumulator)

#### Private Fns

  defp walk_tree([], _excludelist, _fun, acc), do: acc
  defp walk_tree([h | t], excludelist, fun, acc) do
    newacc = case File.dir?(h) do
      true  ->
        wildcard = Path.join(h, "*")
        case Enum.member?(excludelist, wildcard) do
          true  ->
            acc
          false ->
            entries = Path.wildcard(wildcard)
            Enum.flat_map(entries, fn x -> walk_tree([x], excludelist, fun, acc) end)
          end
      false -> file = fun.(h)
               [file | acc]
    end
    walk_tree(t, excludelist, fun, newacc)
  end

end