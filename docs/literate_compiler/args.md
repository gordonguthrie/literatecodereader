<!-- DO NOT EDIT - this file generated by the literate code reader -->
<!-- https://gordonguthrie.github.io/literatecodereader/ -->
```elixir
defmodule LiterateCompiler.Args do

```

# Purpose



A standard Elixir library has collected and marshalled all the arguments.
This module verifies them and ensures that the set of arguments passed
are coherent.



# Data Structures



This arguments structure is populated when the CLI is called and
is then passed around the various arguments



When the inputs are validated, any errors are written to the `errors` key
The consumer of this argument struct checks if it is error free

```elixir

   defstruct [
      inputdir:    :nil,
      outputdir:   :nil,
      excludes:    :nil,
      print_files: false,
      help:        false,
      make_jekyll: false,
      format:      "markdown",
      print_type:  0,
      errors:      []
   ]

```

## Public API



Three simple self-explanatory functions.

```elixir

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
      "-h --help       takes no argument",
      "                prints this message",
      "                (optional)",
      "",
      "-e --exclude    takes 1 argument",
      "                which path to and name of an exclude file",
      "                which contains a list of modules to exclude",
      "                one per line, path relative to the directory this script runs in",
      "                exclude files can be generated with the -l --list option.",
      "                This supports simple directory wildcards of the form 'path/to/a/dir/*",
      "                (optional - default .literate_compiler.exclude in the current directory)",
      "",
      "-f --format     takes 1 argument, one of: [markdown | html]",
      "                specify what the script should output",
      "                if you are intending to publish on github pages",
      "                set to markdown",
      "                (optional - default markdown)",
      "",
      "-i --inputdir   takes 1 argument",
      "                the root directory of the code",
      "                defaults to the current directory",
      "",
      "-j --jekyll     takes no arguments",
      "                generates the contents metadata for jekyll",
      "                (Jekyll is the site generator for Github Pages)",
      "                (optional - defaults to off)",
      "",
      "-l --list       takes no arguments",
      "                doesn't process the files, just prints them",
      "                (optional)",
      "",
      "-o --outputdir  takes 1 argument",
      "                the directory to output the html",
      "                defaults to the current directory",
      "",
      "-t --type       takes 1 argument",
      "                the type of output - usually 0, 1 or 2",
      "                optional - defaults to 0",
      "                0 is all comments shown",
      "                1 is some comments surpressed",
      "                2 is maximum comments supressed",
      "                (but see the documentation of a particular language",
      "                extension for details)",
      "",
      "Either the inputdir or the outputdir must be set explicitly",
      "",
      "Examples:",
      "./literate_compiler -o /some/dir/for/output",
      "./literate_compiler --outputdir /some/dir/for/output",
      "./literate_compiler -i /some/dir/for/input -o /some/dir/for/output",
      "./literate_compiler --help",
      "./literate_compiler -i /some/dir/for/input -l",
      ""
    ]
    for x <- lines, do: IO.puts(x)
   end

   def print_errors(parsedargs) do
    IO.puts("script did not run because of the following errors:")
    for x <- parsedargs.errors, do: IO.puts(x)
    IO.puts("")
   end

```

## Private Functions



`parse_args` places the inputs into the data structure
when the arguments have been consumed it calles `validate` on the data structure

```elixir

   defp parse_args([],                      args), do: validate(args)
   defp parse_args(["-h"              | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:        true})
   defp parse_args(["--help"          | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:        true})
   defp parse_args(["-e"         , e  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | excludes:    e})
   defp parse_args(["--exclude"  , e  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | excludes:    e})
   defp parse_args(["-f"         , f  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | format:      f})
   defp parse_args(["--format"   , f  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | format:      f})
   defp parse_args(["-i"         , i  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:    i})
   defp parse_args(["--inputdir" , i  | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:    i})
   defp parse_args(["-j"              | t], args), do: parse_args(t, %LiterateCompiler.Args{args | make_jekyll: true})
   defp parse_args(["--jekyll"        | t], args), do: parse_args(t, %LiterateCompiler.Args{args | make_jekyll: true})
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

```

The validate pipeline places all and any errors on the `errors` key
The reason for this is to avoid the irritating **fix and run again** problem
If the user makes multiple mistakes in their invocation they should be told
all of them and not just the first

```elixir

   defp validate(args) do
      args
      |> validate_usage
      |> validate_formats
      |> validate_paths
      |> validate_print_type
      |> validate_excludes
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

   defp validate_formats(%{format: "markdown"}       = args), do: %{args | format: "md"}
   defp validate_formats(%{format: "html"}           = args), do: args
   defp validate_formats(%{format: other, errors: e} = args) do
      error = "invalid output format, must be html or markdown: #{other}"
      %{args | errors: [error | e]}
   end

   defp validate_paths(%{errors: []} = args) do
      inputDirIsDir  = File.dir?(args.inputdir)
      outputDirIsDir = File.dir?(args.outputdir)
      case {inputDirIsDir, outputDirIsDir} do
         {true,  true}  -> args
         {true,  false} -> newerrors = ["output dir #{args.outputdir} is not a directory" | args.errors]
                           %{args | errors:   newerrors}
         {false, true}  -> newerrors = ["input dir #{args.inputdir} is not a directory" | args.errors]
                           %{args | errors:   newerrors}
         {false, false} -> newerrors = ["neither input dir#{args.inputdir} nor output dir #{args.outputdir} is a directory" | args.errors]
                           %{args | errors:   newerrors}
      end
   end
   defp validate_paths(args), do: args

   defp validate_print_type(%{print_type: n} = args) when is_integer(n), do: args
   defp validate_print_type(%{print_type: p} = args) do
      case Integer.parse(p) do
         {n, ""} -> %{args | print_type: n}
         {_, _}  -> %{args | errors: "print level must be an integer: #{p}"}
         err     -> %{args | errors: "print level must be an integer: #{err}"}
      end
   end

   defp validate_excludes(%{excludes: e} = args) when e == :nil do
      case File.exists?("./.literate_compiler.exclude") do
         true  -> excludes = read_excludes("./.literate_compiler.exclude")
                  %{args | excludes: excludes}
         false -> %{args | excludes: []}
      end
   end
   defp validate_excludes(%{excludes: e, errors: errs} = args) do
      case File.exists?(e) do
         true  -> excludes = read_excludes(e)
                  %{args | excludes: excludes}
         false -> newerrs = ["exclude file doesn't exist: #{e}" | errs]
                  %{args | errors: newerrs}
      end
   end

   defp read_excludes(file) do
      {:ok, contents} = File.read(file)
      String.split(contents, "\n")
   end

end
```
