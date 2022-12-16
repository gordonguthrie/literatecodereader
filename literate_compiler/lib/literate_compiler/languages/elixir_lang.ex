defmodule LiterateCompiler.Languages.Elixir_lang do

	def is_comment(line) do
		{newt, newl} = is_c(String.trim(line))
		case newt do
			:code -> {newt, line}
			_     -> {newt, newl}
		end
	end

	defp is_c(<<"@moduledoc \"\"\"", r::binary>>), do: {{:module,  :open},  r}
	defp is_c(<<"@moduledoc ",       r::binary>>), do: {{:module,  :line},  r}
	defp is_c(<<"@doc \"\"\"",       r::binary>>), do: {{:fn,      :open},  r}
	defp is_c(<<"@doc ",             r::binary>>), do: {{:fn,      :line},  r}
	defp is_c(<<"##", 				 r::binary>>), do: {{:comment, :line},  r}
	defp is_c(<<"\"\"\"", 			 r::binary>>), do: {{:comment, :close}, r}
	defp is_c(c),                                  do: {:code,              c}

end