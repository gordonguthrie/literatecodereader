```elixirdefmodule LiterateCompiler.CLI do

  alias LiterateCompiler.Args
  alias LiterateCompiler.Outputter
  alias LiterateCompiler.ProcessFiles
  alias LiterateCompiler.Tree

  def main(args) do
    parsedargs = Args.parse_args(args)
    run(parsedargs)
  end

  defp run(parsedargs) when parsedargs.help do
      Args.print_help()
    end
  defp run(parsedargs) when parsedargs.errors != [] do
      Args.print_errors(parsedargs)
      IO.puts("run ./literate_compiler -h for help")
  end
  defp run(parsedargs) when parsedargs.print_files do
      IO.inspect(parsedargs, label: "in run")
      IO.puts("The following files will be processed:")
      Tree.walk_tree([parsedargs.inputdir], &ProcessFiles.list_file/1)
    end
  defp run(parsedargs) do
      IO.inspect(parsedargs, label: "in run")
      files = Tree.walk_tree([parsedargs.inputdir], &ProcessFiles.process_file/1)
      :ok = Outputter.write_output(files, parsedargs)
  end

end
```
