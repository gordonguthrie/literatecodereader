defmodule LiterateCompiler.CLI do

### Purpose

## This module is the actual CLI for the escript

## It does 3 things:

## * prints the help
## * displays the errors when the command is wrongly invoked
## * runs the script
## ^

## It uses the Elixir Standard `Args` library to process the arguments

  alias LiterateCompiler.Args
  alias LiterateCompiler.Outputter
  alias LiterateCompiler.ProcessFiles
  alias LiterateCompiler.Tree
  alias LiterateCompiler.TOC

#### Public API

  def main(args) do
    parsedargs = Args.parse_args(args)
    run(parsedargs)
  end

#### Private Fns

  defp run(parsedargs) when parsedargs.help do
      Args.print_help()
    end
  defp run(parsedargs) when parsedargs.errors != [] do
      Args.print_errors(parsedargs)
      IO.puts("run ./literate_compiler -h for help")
  end
  defp run(parsedargs) when parsedargs.print_files do
      Tree.walk_tree([parsedargs.inputdir], parsedargs.excludes, &ProcessFiles.list_file/1)
    end
  defp run(parsedargs) do
      files = Tree.walk_tree([parsedargs.inputdir], parsedargs.excludes, &ProcessFiles.process_file/1)
      :ok = Outputter.write_output(files, parsedargs)
      case parsedargs.make_jekyll do
        true  -> jekyll = Tree.walk_tree([parsedargs.inputdir], parsedargs.excludes, &ProcessFiles.make_jekyll_contents/1)
                 TOC.make_toc(jekyll, parsedargs)
        false -> :ok
      end
      :ok
  end

end
