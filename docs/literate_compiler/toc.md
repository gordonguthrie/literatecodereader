```elixir	defmodule LiterateCompiler.TOC do

	@empty_accumulator []

	def make_toc(files, _parsedargs) do
		split = split(files, @empty_accumulator)
		sorted = Enum.sort(split, &sorter/2)
		toc = build_tree(sorted, @empty_accumulator)
		for x <- toc, do: IO.puts(x)
	end

	defp build_tree([{path, file} | []], acc) do
		line = get_line(path ++ [file])
		Enum.reverse([line | acc])
	end
	defp build_tree([{path1, file1}, {path2, _file2} = h2 | t], acc) do
		len1 = length(path1)
		len2 = length(path2)
		line = get_line(path1 ++ [file1])
		case len1 do
		  ^len2 -> build_tree([h2 | t], [line | acc])
		  _     -> build_tree([h2 | t], [line | acc])
		end
	end

	defp get_line(path) do
		rev = Enum.reverse(path)
		[file | rest] = rev
		newp = Enum.join(Enum.reverse(rest), " - ")
		filename = Path.rootname(file)
		line = Enum.join(["-page: ", newp, " - ",filename])
		length = length(path)
		pad(line, length)
	end

	defp pad(line, n) do
		pad =  String.duplicate(" ", (n + 1) * 2)
		Enum.join([pad, line])
	end

	defp split([], acc), do: acc
	defp split([h | t], acc) do
		[file | rev] = Enum.reverse(h)
		newacc = [{Enum.reverse(rev), file} | acc]
		split(t, newacc)
	end
```

if two paths are the same length sort on path
if two paths are identical sort on file
if one path is longer
* check if the short has the longer as a prefix
```elixir	defp sorter({path1, file1}, {path2, file2}) do
		len1 = length(path1)
		len2 = length(path2)
		len1plus = len1 + 1
		len2plus = len2 + 1
		cond do
			path1 == path2 ->
				file1 <= file2
			len1  == len2 ->
				path1 <= path2
			len1plus == len2 ->
				fname = Path.rootname(file1)
				case path1 ++ fname do
					^path2 -> true
					_      -> path1 <= path2
				end
			len1 == len2plus ->
				fname = Path.rootname(file2)
				case path2 ++ [fname] do
					^path1 -> false
					_      -> path1 <= path2
				end
			len1  <  len2 ->
				fname = Path.rootname(file1)
				case prefix(path1 ++ [fname], path2) do
					true  -> true
					false -> path1 ++ [fname] <= path2
				end
			len1  >  len2 ->
				fname = Path.rootname(file2)
				case prefix(path2 ++ [fname], path1) do
					true  -> false
					false -> path1 <= path2 ++ [fname]
				end
		end
 	end

 	defp prefix([], _),             do: true
 	defp prefix([h | t1], [h |t2]), do: prefix(t1, t2)
 	defp prefix(_, _),              do: false

end```
