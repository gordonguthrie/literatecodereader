```elixir
defmodule LiterateCompiler.Outputter do

```

# Purpose

writes the output for html and markdown, invoking the specific
formatting functions from the appropriate submodules

```elixir

	alias LiterateCompiler.Extensions

```

## Public API

```elixir

	def write_output([], _args), do: :ok
	# the tree walker will return a null list if it sees a file
	# with a type that it isn't processing, so we skip that
	def write_output([[] | t], args), do: write_output(t, args)
	def write_output([{oldfilename, body} | t], args) do
		indir = args.inputdir
		outdir = args.outputdir
		newext = args.format
		oldext = Path.extname(oldfilename)
		print_type = args.print_type
		outputter = Extensions.get_formatter_module(newext)
		language = Extensions.get_lang_module(oldext)
		transformed = transform(body, print_type, outputter, language)
		write_file = make_write_file(oldfilename, indir, outdir, newext)
		write_dir = Path.dirname(write_file)
		:ok = File.mkdir_p(write_dir)
		:ok = File.write(write_file, transformed)
		write_output(t, args)
	end

```

## Private Fns

```elixir

	defp make_write_file(oldfilename, inputdir, outputdir, ext) do
		relative = Path.relative_to(Path.absname(oldfilename), Path.absname(inputdir))
		old = Path.join([outputdir, relative])
		root = Path.rootname(old)
		Enum.join([root, ".", ext])
	end

	defp transform(body, print_type, outputter, language)  do
		lines = for {type, level, contents} <- body do
			Kernel.apply(outputter, :format, [{type, level}, print_type, contents, language])
		end
		newbody = Enum.join(lines, "\n")
		Kernel.apply(outputter, :wrap, [newbody])
	end



end
```
