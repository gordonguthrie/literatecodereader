```elixir
defmodule LiterateCompiler.TOC do

```

# Purpose

This generates a table of contents in yaml for Jekyll

```elixir

	@empty_accumulator []

	alias LiterateCompiler.Outputter

```

## Public API

```elixir

	def make_toc(files, args) do
		split = split(files, @empty_accumulator)
		sorted = Enum.sort(split, &sorter/2)
		toc = build_tree(sorted, args, @empty_accumulator)
		# the toc starts with a line 'toc:' and a title and subfolder
		header = ["    subfolderitems:",
				  "  - title: Contents",
				  "toc:"]
		# we start indenting at 2 because the header has an indent in it
		file = indent(toc, header)
		fileandpath = Path.join([args.outputdir, "_data/contents.yml"])
		write_dir = Path.dirname(fileandpath)
		:ok = File.mkdir_p(write_dir)
		File.write(fileandpath, Enum.join(file, "\n"))
	end

```

## Private Fns

yaml is a pain in the arse, white space matters language
so you have to write an indenter

```elixir

	defp indent([], acc), do: Enum.reverse(acc)
	defp indent([{ {:url, _n}, line} | t], acc) do
		newacc = pad(line, 4)
		indent(t, [newacc | acc])
	end
	defp indent([{:title, line} | t], acc) do
		newacc = pad(line, 1)
		indent(t, [newacc | acc])
	end
	defp indent([{:sub, line} | t], acc) do
		newacc = pad(line, 2)
		indent(t, [newacc | acc])
	end
	defp indent([{:page, line} | t], acc) do
		newacc = pad(line, 3)
		indent(t, [newacc | acc])
	end

	defp build_tree([], _args, acc) do
		Enum.reverse(acc)
	end
	defp build_tree([{path, file} | t], args, acc) do
		case Enum.member?(args.excludes, Path.join(path ++ [file])) do
			true ->
				build_tree(t, args, acc)
			false ->
				{page, url} = get_components(path ++ [file], args)
				len = length(path)
				newacc = [{ {:url, len}, url}, {:page, page}]
				build_tree(t, args, newacc ++ acc)
			end
	end

	defp get_components(path, args) do

		oldext = Path.extname(path)
		oldfile = Path.join(path)
		newfile = Outputter.make_write_file(oldfile, args.inputdir, args.outputdir, "html")
		newpath = String.split(newfile, "/")

		# do some setup
		rev = Enum.reverse(newpath)
		[file | rest] = rev
		fileroot = Path.rootname(file)

		# make the URL
		relpath = Enum.reverse(rest)
		[_, _ | trimmedrelpath] = relpath
		root = Path.rootname(file)
		file = Enum.join([root, ".", "html"])
		url  = Path.join(["."] ++ trimmedrelpath ++ [file])

		# make the lines for the toc
		urlline = Enum.join(["url:  ", url])
		page = case trimmedrelpath do
			[] -> Enum.join(["- page: ", fileroot, oldext])
		    _  -> pagepath = Path.join(trimmedrelpath)
				Enum.join(["- page: ", pagepath, " - ", fileroot, oldext])
		end

		# return them
		{page, urlline}
	end

	defp pad(line, n) do
		pad =  String.duplicate(" ", n * 2)
		Enum.join([pad, line])
	end

	defp split([], acc), do: acc
	defp split([h | t], acc) do
		[file | rev] = Enum.reverse(h)
		newacc = [{Enum.reverse(rev), file} | acc]
		split(t, newacc)
	end

```

The sorter is the hardest bit of code in the whole programme :-)

```elixir

	defp sorter({path1, file1}, {path2, file2}) do
		len1 = length(path1)
		len2 = length(path2)
		len1plus = len1 + 1
		len2plus = len2 + 1
		cond do

```

same path, sort by filename

```elixir
			path1 == path2 ->
				file1 <= file2

```

paths the same length, sort by path

```elixir
			len1  == len2 ->
				path1 <= path2

```

path exactly one longer than the other
check if the <short path plus filename> is the same as the long
if it is, the short sorts first
if it isn't sort on path

```elixir
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

```

otherwise see if the <short plus filename> is a prefix of the long
if it is sort short first
if it isn't sort on <short plus filename> vs <long>

```elixir
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

end
```
