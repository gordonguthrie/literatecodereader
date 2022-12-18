```elixir
defmodule LiterateCompiler.Outputter.Markdown do

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
