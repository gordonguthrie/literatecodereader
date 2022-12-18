```elixir
defmodule LiterateCompiler.Outputter.Markdown do

```

# Purpose

This is the outputter for markdown
It marks up the code with a langauge prefix for code highlighting

The fixed API could have been enforced as a [behaviour](https://hexdocs.pm/elixir/1.4.5/behaviours.html)
but that's a bit over the top

## Public API

```elixir

	def format(:markdown, contents, _language) do
		Enum.join([contents, "\n"])
	end
	def format(:code, contents, language) do
		trim = String.trim(contents)
		case trim do
			"" -> "\n"
			_  -> js_extension = Kernel.apply(language, :get_js_ext, [])
				  Enum.join(["```", js_extension, "\n", contents, "\n```\n"])
		end
	end

	def wrap(contents), do: contents

end
```
