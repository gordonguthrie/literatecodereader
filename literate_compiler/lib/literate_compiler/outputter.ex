defmodule LiterateCompiler.Outputter do

### Purpose

## writes the output for html and markdown, invoking the specific
## formatting functions from the appropriate submodules

	alias LiterateCompiler.Extensions

#### Public API

	def write_output([], _args), do: :ok
	# the tree walker will return a null list if it sees a file
	# with a type that it isn't processing, so we skip that
	def write_output([[] | t], args), do: write_output(t, args)
	def write_output([{oldfilename, body} | t], args) do
		case Enum.member?(args.excludes, oldfilename) do
			true  ->
				:ok
			false ->
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
		end
		write_output(t, args)
	end

## the function `make_write_file/4` is also used by the `toc` module

	def make_write_file(oldfilename, inputdir, outputdir, ext) do
		relative = Path.relative_to(Path.absname(oldfilename), Path.absname(inputdir))
		old = Path.join([outputdir, relative])
		root = Path.rootname(old)
		Enum.join([root, ".", ext])
	end

#### Private Fns

	defp transform(body, print_type, outputter, language)  do
		lines = for {type, level, contents} <- body do
			Kernel.apply(outputter, :format, [{type, level}, print_type, contents, language])
		end
		newbody = Enum.join(lines, "\n")
		Kernel.apply(outputter, :wrap, [newbody])
	end

end