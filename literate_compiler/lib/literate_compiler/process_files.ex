defmodule LiterateCompiler.ProcessFiles do

	@moduledoc """
	This is the ProcessFiles module for the Literate Compiler
	"""

	@empty_accumulator []

	alias LiterateCompiler.Extensions

	@doc """
	`list_file` is a function that just prints all the files that
	will be processed. It checks the file extension and if that sort of
	file is processed it will be printed - if not it won't.
	"""
	def list_file(file) do
	  ext = Path.extname(file)
	  langmodule = Extensions.get_lang_module(ext)
	  case langmodule do
	  	:none -> :ok
	  	_     -> IO.inspect(file)
	  end
	end

	@doc """
	`make_contents` is a function that generates the table of contents for jekyll.
	"""
	def make_jekyll_contents(file) do
		String.split(file, "/")
	end

	@doc """
	`process_file` is a function that just actually process all the source code files and
	generates the outcome that is specified in the command line options.
	"""
	def process_file(file) do
	 	ext = Path.extname(file)
	 	langmodule = Extensions.get_lang_module(ext)
	 	process(file, langmodule)
	end

	defp process(_file, :none), do: []
	defp process(file, langmodule) do
		{:ok, bin} = File.read(file)
		lines = String.split(bin, "\n")
		f = process_lines(lines, langmodule, :none, @empty_accumulator, @empty_accumulator)
		{file, List.flatten(f)}
	end

	defp process_lines([], _, _type, [], acc) do
		Enum.reverse(acc)
	end
	defp process_lines([], langmodule, _type, partialacc, acc) do
		partial = Enum.reverse(partialacc)
		frag = make_frag(partial, langmodule)
	 	Enum.reverse([frag | acc])
	end
	# the open multiline comment line is already on the partial accumulator
	# so we steal it back
	defp process_lines(lines, langmodule, {ty, :open}, [{_, steal} | partialacc], acc) do
		{glob, rest} = gobble([steal | lines], ty, langmodule, [])
		newfrag1 = make_frag(glob, langmodule)
		newfrag2 = make_frag(partialacc, langmodule)
		process_lines(rest, langmodule, :none, [], [newfrag2, newfrag1 | acc])
	end
	defp process_lines([h | t], langmodule, type, partialacc, acc) do
		{newt, newl} = process_line(langmodule, h)
		{newpartial, newacc} = accumulate(newl, newt, type, langmodule, partialacc, acc)
		process_lines(t, langmodule, newt, newpartial, newacc)
	end

	defp process_line(langmodule, line) do
		Kernel.apply(langmodule, :is_comment, [line])
	end

	defp accumulate(line, type, type, _, partial, acc) do
		{[{type, line} | partial], acc}
	end
	defp accumulate(line, {_, :open} = newt, _type, _, [], acc) do
		{[{newt, line}], acc}
	end
	defp accumulate(line, type, _, langmodule, partial, acc) do
		newfrag = make_frag(Enum.reverse(partial), langmodule)
		{[{type, line}], [newfrag |acc]}
	end

	defp gobble([], ty, _langmodule, acc) do
		{{{ty, :block}, Enum.reverse(acc)}, []}
	end
	defp gobble([h | t], ty, langmodule, acc) do
		{newt, newl} = process_line(langmodule, h)
		case {newt, newl} do
			{{_, :close}, _} ->
				comments = {{ty, :block}, Enum.reverse([{newt, newl} | acc])}
				{comments, t}
			_ ->
			 	newacc = [{newt, newl} | acc]
				gobble(t, ty, langmodule, newacc)
		end
	end

	defp make_frag({{_type, :block} = ty, lines}, langmodule) do
		make_tag(ty, gather_lines(lines), langmodule)
	end
	defp make_frag(lines, langmodule) do
		tag = get_tag(lines)
		make_tag(tag, gather_lines(lines), langmodule)
	end

	defp gather_lines(lines) do
		stripped = for {_t, x} <- lines, do: x
		Enum.join(stripped, "\n")
	end

	defp get_tag([]),              do: :none
	defp get_tag([{tag, _} | _t]), do: tag

	defp make_tag(_,     <<"">>, _langmodule), do: []
	defp make_tag(:none, _lines, _langmodule), do: []
	defp make_tag({:code, _} = c,  lines,  langmodule) do
		level = Kernel.apply(langmodule, :comment_level, [c])
	 	{:code, level, lines}
	end
	defp make_tag(type, lines, langmodule) do
		level = Kernel.apply(langmodule, :comment_level, [type])
	 	{:markdown, level, lines}
	end

end