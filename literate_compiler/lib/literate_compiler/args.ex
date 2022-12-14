defmodule LiterateCompiler.Args do
   defstruct [
      inputdir:   :nil,
      outputdir:  :nil,
      help:       false, 
      errors:     []
   ]

   def parse_args(args) do
      acc = %LiterateCompiler.Args{}
      parse_args(args, acc)
   end

   defp parse_args([],                     args), do: validate(args)
   defp parse_args(["-h"             | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:      true})
   defp parse_args(["--help"         | t], args), do: parse_args(t, %LiterateCompiler.Args{args | help:      true})
   defp parse_args(["-i"         , i | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:  i})
   defp parse_args(["--inputdir" , i | t], args), do: parse_args(t, %LiterateCompiler.Args{args | inputdir:  i})
   defp parse_args(["-o"         , o | t], args), do: parse_args(t, %LiterateCompiler.Args{args | outputdir: o})
   defp parse_args(["--outputdir", o | t], args), do: parse_args(t, %LiterateCompiler.Args{args | outputdir: o})
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
      |> validate_paths
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
end