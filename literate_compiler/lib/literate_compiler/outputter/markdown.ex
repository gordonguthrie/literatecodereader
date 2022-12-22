defmodule LiterateCompiler.Outputter.Markdown do

### Purpose

## This is the outputter for markdown
## It marks up the code with a langauge prefix for code highlighting

## The fixed API could have been enforced as a [behaviour](https://hexdocs.pm/elixir/1.4.5/behaviours.html)
## but that's a bit over the top

#### Public API

	def format({:markdown, level}, print_type, contents, _language) when level <= print_type do
		Enum.join([contents, "\n"])
	end
	def format({:markdown, _}, _print_type, contents, _language) do
		css_extension = ""
		format_as_code(contents, css_extension)
	end
	def format({:code, _}, _print_type, contents, language) do
		css_extension = Kernel.apply(language, :get_css_ext, [])
		format_as_code(contents, css_extension)
	end

	def wrap(contents), do: contents

#### Private Funs

	def format_as_code(contents, ext) do
		trim = String.trim(contents)
		case trim do
			"" -> "\n"
			_  ->
				  Enum.join(["```", ext, "\n", contents, "\n```\n"])
		end
	end

end