defmodule LiterateCompiler.CLI do

  alias LiterateCompiler.Args

  def main(args) do
    parsedargs = Args.parse_args(args)
    run(parsedargs)
  end

  defp run(parsedargs) when parsedargs.help do
      print_help()
    end
  defp run(parsedargs) when parsedargs.errors != [] do
      print_errors(parsedargs)
      IO.puts("run ./literate_compiler -h for help")
  end
  defp run(parsedargs) do
      IO.inspect(parsedargs, label: "in run")
      :ok = walk_directories(parsedargs.inputdir, parsedargs.outputdir)
  end

  defp walk_directories(inputdir, outputdir) do
    wildcard = Path.join(inputdir, "*")
    IO.inspect(wildcard, label: "wildcard")
    entries = Path.wildcard(wildcard)
    IO.inspect(entries, label: "entries")
    :ok
  end

  defp print_help() do
    lines = [
      "Help",
      "",
      "literate compiler is a script that converts code into beautiful webpages to read",
      "",
      "Options:",
      "-h --help       prints this message",
      "",
      "-i --inputdir   the root directory of the code",
      "                defaults to the current directory",
      "",
      "-o --outputdir  the directory to output the html",
      "                defaults to the current directory",
      "",
      "All options (except help) take exactly one argument",
      "",
      "Either the inputdir or the outputdir must be set explicitly",
      "",
      "Examples:",
      "./literate_compiler -o /some/dir/for/output",
      "./literate_compiler --outputdir /some/dir/for/output",
      "./literate_compiler -i /some/dir/for/output -o /some/dir/for/output",
      "./literate_compiler --help",
      ""
    ]
    for x <- lines, do: IO.puts(x)
  end

  defp print_errors(parsedargs) do
    IO.puts("script did not run because of the following errors:")
    for x <- parsedargs.errors, do: IO.puts(x)
    IO.puts("")
  end

end
