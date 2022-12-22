defmodule LiterateCompiler.Languages.Elixir_lang do

### Purpose

## Processes Elixir files
## The atom `Elixir` is already used in the `Elixir` language - hence the module name

#### Public API

## The fixed API could have been enforced as a [behaviour](https://hexdocs.pm/elixir/1.4.5/behaviours.html)
## but that's a bit over the top

	def is_comment(line) do
		{newt, newl} = is_c(String.trim(line))
		case newt do
			{:code, :code} -> {newt, expand(line)}
			_              -> {newt, newl}
		end
	end

	def comment_level({:code,    _}), do: 0
	def comment_level({:comment, _}), do: 0
	def comment_level({:module,  _}), do: 1
	def comment_level({:fn,      _}), do: 2

	def get_css_ext, do: "elixir"

#### Private API

## in the private function `is_c` take special notice of the doubled handling of
## comments
##
## * in the first we strip the leading space, this is for non-headers in markdown
## * and in the second we don't - this enables continuous headers

	defp is_c(<<"@moduledoc \"\"\"", r::binary>>), do: {{:module,  :open},  r}
	defp is_c(<<"@moduledoc ",       r::binary>>), do: {{:module,  :line},  r}
	defp is_c(<<"@doc \"\"\"",       r::binary>>), do: {{:fn,      :open},  r}
	defp is_c(<<"@doc ",             r::binary>>), do: {{:fn,      :line},  r}
	defp is_c(<<"## ",               r::binary>>), do: {{:comment, :line},  r}
	defp is_c(<<"##",                r::binary>>), do: {{:comment, :line},  r}
	defp is_c(<<"#jekyll",           r::binary>>), do: {{:comment, :line},  r}
	defp is_c(<<"\"\"\"",            r::binary>>), do: {{:comment, :close}, r}
	defp is_c(c),                                  do: {{:code,    :code},  c}

	defp expand(c) do
		newc = String.replace(c, "{{", "{ {", [global: true])
		case Regex.match?(~r/{{/, newc) do
			true -> expand(newc)
			false -> newc
		end
	end

end