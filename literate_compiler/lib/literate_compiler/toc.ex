	defmodule LiterateCompiler.TOC do

	@empty_accumulator []

	def make_toc(files, parsedargs) do
		split = split(files, @empty_accumulator)
		sorted = Enum.sort(split, &sorter/2)
		toc = build_tree(sorted, @empty_accumulator)
		# the toc starts with a line 'toc:' and a title and subfolder
		header = ["    subfolderitems:",
				  "  - title: Contents",
				  "toc:"]
		# we start indenting at 2 because the header has an indent in it
		file = indent(toc, header)
		fileandpath = Path.join([parsedargs.outputdir, "_data/contents.yml"])
		write_dir = Path.dirname(fileandpath)
		:ok = File.mkdir_p(write_dir)
		File.write(fileandpath, Enum.join(file, "\n"))
	end

	defp indent([], acc), do: Enum.reverse(acc)
	defp indent([{{:url, _n}, line} | t], acc) do
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

	defp build_tree([], acc) do
		Enum.reverse(acc)
	end
	defp build_tree([{path, file} | t], acc) do
		{page, url} = get_components(path ++ [file])
		len = length(path)
	  	newacc = [{{:url, len}, url}, {:page, page}]
	  	build_tree(t, newacc ++ acc)
	end

	defp get_components(path) do

		# do some setup
		rev = Enum.reverse(path)
		[file | rest] = rev
		newp = Enum.join(Enum.reverse(rest), "/")
		fileroot = Path.rootname(file)

		# make the page
		page = Enum.join(["- page: ", newp, " - MODULE ",fileroot])

		# make the URL
		filename = Enum.join([fileroot, ".html"])
		urlpath = Enum.reverse([filename | rest])
		url = Enum.join(urlpath, "/")
		urlline = Enum.join(["url:  ", url])

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

	## if two paths are the same length sort on path
	## if two paths are identical sort on file
	## if one path is longer
	## * check if the short has the longer as a prefix
	defp sorter({path1, file1}, {path2, file2}) do
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

end