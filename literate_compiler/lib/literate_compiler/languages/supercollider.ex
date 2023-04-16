defmodule LiterateCompiler.Languages.SuperCollider do

### Purpose

## Processes SuperCollider files as input

# Super Collider is a repl-based application for building music synthesisers

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

	def comment_level({:code,     _}),       do: 0
	def comment_level({:module,   _}),       do: 0
	def comment_level({:comment,  :jekyll}), do: 0
	def comment_level({:comment,  _}),       do: 1

	def get_css_ext, do: "supercollider"

#### Private API

## in the private function `is_c` take special notice of the doubled handling of
## comments

	defp is_c(<<"/* ",     r::binary>>) do
		case  Regex.match?(~r/\*\/$/, r) do
			true  -> newline = Regex.replace(~r/\*\/$/, r, "")
					 {{:comment,  :line},  newline}
			false -> {{:comment,  :open},  r}
		end
	end
	defp is_c(<<"/\*",     r::binary>>), do: {{:module, :open},   r}
	defp is_c(<<"\*/",     r::binary>>), do: {{:module, :close},  r}
	defp is_c(<<"// ",     r::binary>>), do: {{:comment, :line},   r}
	defp is_c(<<"//",      r::binary>>), do: {{:comment, :line},   r}
	defp is_c(<<"/jekyll", r::binary>>), do: {{:comment, :jekyll}, r}
	defp is_c(c),                        do: {{:code,    :code},   c}

	defp expand(c) do
		newc = String.replace(c, "{{", "{ {", [global: true])
		case Regex.match?(~r/{{/, newc) do
			true  -> expand(newc)
			false -> newc
		end
	end

end