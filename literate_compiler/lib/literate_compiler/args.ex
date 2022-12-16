defmodule LiterateCompiler.Args do
   defstruct [
      inputdir:    :nil,
      outputdir:   :nil,
      print_files: false,
      help:        false,
      format:      "markdown",
      print_type:  0,
      errors:      []
   ]

   def parse_args(args) do
      acc = %LiterateCompiler.Args{}
      parse_args(args, acc)
   end

   def print_help() do
    lines = [
      "Help",
      "",
      "literate compiler is a script that converts code into beautiful webpages to read",
      "either directly as HTML or as markdown for github to convert to GitHub pages",
      "",
      "Options:",
      "-h --help       prints this message",
      "                (optional)",
      "-f --format     specify what the script should output [markdown | html]",
      "                if you are intending to publish on github pages",
      "                set to markdown",
      "                (optional - default markdown)",
      "",
      "-i --inputdir   the root directory of the code",
      "                defaults to the current directory",
      "",
      "-l --list       doesn't process the files, just prints them",
      "                (optional)",
      "",
      "-o --outputdir  the directory to output the html",
      "                defaults to the current directory",
      "",
      "-t --type       the type of output - usually 0, 1 or 2",
      "                optional - defaults to 0",
      "                0 is all comments shown",
      "                1 is some comments surpressed",
      "                2 is maximum comments supressed",
      "                (but see the documentation of a particular language",
      "                extension for details)",
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
      "./literate_compiler -i /some/dir/for/output -l",
      ""
    ]
    for x <- lines, do: IO.puts(x)
   end

   def print_errors(parsedargs) do
    IO.puts("script did not run because of the following errors:")
    for x <- parsedargs.errors, do: IO.puts(x)
    IO.puts("")
   end

   defp parse_args([],                     args), do: validate(args)
   defp parse_args(["-h"              | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:        true})
   defp parse_args(["--help"          | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:        true})
   defp parse_args(["-f"         , f  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | format:      f})
   defp parse_args(["--format"   , f  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | format:      f})
   defp parse_args(["-i"         , i  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:    i})
   defp parse_args(["--inputdir" , i  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:    i})
   defp parse_args(["-l"              | t], args), do: parse_args(t, %LiterateCompiler.Args{args | print_files: true})
   defp parse_args(["--list"          | t], args), do: parse_args(t, %LiterateCompiler.Args{args | print_files: true})
   defp parse_args(["-o"         , o  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | outputdir:   o})
   defp parse_args(["--outputdir", o  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | outputdir:   o})
   defp parse_args(["-t"         , ty | t], args), do: parse_args(t, %LiterateCompiler.Args{args | print_type:  ty})
   defp parse_args(["--type"     , ty | t], args), do: parse_args(t, %LiterateCompiler.Args{args | print_type:  ty})
   defp parse_args([h | t], args) do
      error = case h do
          <<"-", _rest::binary>> -> "unknown option #{h}"
          _                      -> "unknown action #{h}"
       end
      newerrors = args.errors ++ [error]
      parse_args(t, %LiterateCompiler.Args{args | errors: newerrors})
   end

   defp validate(args) do
      args
      |> validate_usage
      |> validate_formats
      |> validate_paths
      |> validate_print_type
   end

   defp validate_usage(args) do
      case {args.inputdir, args.outputdir} do
         {:nil, :nil} -> newerrors = ["both inputdir and outputdir can't be unspecified" | args.errors]
                         %{args | errors:   newerrors}
         {:nil, _}    -> %{args | inputdir:  "./"}
         {_,    :nil} -> %{args | outputdir: "./"}
         {_,    _}    ->   args
      end
   end

   defp validate_formats(%{format: "markdown"} = args), do: args
   defp validate_formats(%{format: "html"} = args), do: args
   defp validate_formats(%{format: other, errors: e} = args) do
      error = "invalid output format, must be html or markdown: #{other}"
      %{args | errors: [error | e]}
   end

   defp validate_paths(%{errors: []} = args) do
      inputDirIsDir  = File.dir?(args.inputdir)
      outputDirIsDir = File.dir?(args.outputdir)
      case {inputDirIsDir, outputDirIsDir} do
         {true,  true}  -> args
         {true,  false} -> newerrors = ["output dir is not a directory" | args.errors]
                           %{args | errors:   newerrors}
         {false, true}  -> newerrors = ["input dir is not a directory" | args.errors]
                           %{args | errors:   newerrors}
         {false, false} -> newerrors = ["neither input dir our output dir is a directory" | args.errors]
                           %{args | errors:   newerrors}
      end
   end
   defp validate_paths(args), do: args

   defp validate_print_type(%{print_type:  p} = args) do
      case Integer.parse(p) do
         {n, ""} -> %{args | print_type: n}
         {n, _}  -> %{args | errors: "print level must be an integer #{p}"}
         err     -> %{args | errors: "print level must be an integer #{err}"}
      end
   end

end