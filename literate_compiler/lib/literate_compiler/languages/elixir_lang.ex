defmodule LiterateCompiler.Languages.Elixir_lang do

	def is_comment(line) do
		{newt, newl} = is_c(String.trim(line))
		case newt do
			{:code, :code} -> {newt, expand(line)}
			_              -> {newt, newl}
		end
	end

	def comment_level({:code,    _}),  do: 0
	def comment_level({:comment, _}), do: 0
	def comment_level({:module,  _}), do: 1
	def comment_level({:fn,      _}), do: 2

	def get_js_ext, do: "elixir"

	defp is_c(<<"@moduledoc \"\"\"", r::binary>>), do: {{:module,  :open},   r}
	defp is_c(<<"@moduledoc ",       r::binary>>), do: {{:module,  :line},   r}
	defp is_c(<<"@doc \"\"\"",       r::binary>>), do: {{:fn,      :open},   r}
	defp is_c(<<"@doc ",             r::binary>>), do: {{:fn,      :line},   r}
	defp is_c(<<"##", 				 r::binary>>), do: {{:comment, :line},   String.trim(r)}
	defp is_c(<<"#jekyll", 		     r::binary>>), do: {{:code,    :jekyll}, r}
	defp is_c(<<"\"\"\"", 			 r::binary>>), do: {{:comment, :close},  r}
	defp is_c(c),                                  do: {{:code,    :code},   c}

	defp expand(c) do
		newc = String.replace(c, "{{", "{ {", [global: true])
		case Regex.match?(~r/{{/, newc) do
			true -> expand(newc)
			false -> newc
		end
	end

end