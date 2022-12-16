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
	def list_file(file, _args) do
	  ext = Path.extname(file)
	  langmodule = Extensions.get_lang_module(ext)
	  case langmodule do
	  	:none -> :ok
	  	_     -> IO.inspect(file)
	  end
	end

	@doc """
	`process_file` is a function that just actually process all the source code files and
	generates the outcome that is specified in the command line options.
	"""
	def process_file(file, args) do
	  ext = Path.extname(file)
	  langmodule = Extensions.get_lang_module(ext)
	  process(file, langmodule, args)
	end

	defp process(_file, :none, _args), do: []
	defp process(file, langmodule, args) do
		{:ok, bin} = File.read(file)
		lines = String.split(bin, "\n")
		process_lines(lines, langmodule, args, :none, @empty_accumulator, @empty_accumulator)
	end

	defp process_lines([], _, _args, _type, [], acc) do
		Enum.reverse(acc)
	end
	defp process_lines([], _,  args, _type, partialacc, acc) do
		partial = Enum.reverse(partialacc)
		frag = make_frag(partial, args)
	 	Enum.reverse([frag | acc])
	end
	# the open multiline comment line is already on the partial accumulator
	# so we steal it back
	defp process_lines(lines, langmodule, args, {ty, :open}, [{_, steal} | partialacc], acc) do
		{glob, rest} = gobble([steal | lines], ty, langmodule, args, [])
		newfrag1 = make_frag(glob, args)
		newfrag2 = make_frag(partialacc, args)
		process_lines(rest, langmodule, args, :none, [], [newfrag2, newfrag1 | acc])
	end
	defp process_lines([h | t], langmodule, args, type, partialacc, acc) do
		{newt, newl} = process_line(langmodule, h, args)
		{newpartial, newacc} = accumulate(newl, newt, type, args, partialacc, acc)
		process_lines(t, langmodule, args, newt, newpartial, newacc)
	end

	defp process_line(typefn, line, _args) do
		Kernel.apply(typefn, :is_comment, [line])
	end

	defp accumulate(line, type, type, _args, partial, acc) do
		{[{type, line} | partial], acc}
	end
	defp accumulate(line, {_, :open} = newt, _type, _args, [], acc) do
		{[{newt, line}], acc}
	end
	defp accumulate(line, type, _, args, partial, acc) do
		newfrag = make_frag(partial, args)
		{[{type, line}], [newfrag |acc]}
	end

	defp gobble([], ty, _langmodule, _args, acc) do
		{{{ty, :block}, Enum.reverse(acc)}, []}
	end
	defp gobble([h | t], ty, langmodule, args, acc) do
		{newt, newl} = process_line(langmodule, h, args)
		case {newt, newl} do
			{{_, :close}, _} ->
				comments = {{ty, :block}, Enum.reverse([{newt, newl} | acc])}
				{comments, t}
			_ ->
			 	newacc = [{newt, newl} | acc]
				gobble(t, ty, langmodule, args, newacc)
		end
	end

	defp make_frag({{type, :block}, lines}, args) do
		make_tag(type, gather_lines(lines), args)
	end
	defp make_frag(lines, args) do
		tag = get_tag(lines)
		make_tag(tag, gather_lines(lines), args)
	end

	defp gather_lines(lines) do
		stripped = for {_t, x} <- lines, do: x
		Enum.join(stripped, "\n")
	end

	defp get_tag([]),              do: :none
	defp get_tag([{tag, _} | _t]), do: tag

	defp make_tag(_,     <<"">>, _args), do: []
	defp make_tag(:none, _lines, _args), do: []
	defp make_tag(:code,  lines, _args), do: {:code, lines}
	defp make_tag(_,      lines, _args), do: {:markdown, lines}

end