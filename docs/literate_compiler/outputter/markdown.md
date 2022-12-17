```elixir
defmodule LiterateCompiler.Outputter.Markdown do

	def format(:markdown, contents, _language) do
		IO.inspect(contents, label: "contents - markdown")
		contents
	end
	def format(:code, contents, language) do
		IO.inspect(contents, label: "contents - pre")
		js_extension = Kernel.apply(language, :get_js_ext, [])
		Enum.join(["```", js_extension, "\n", contents, "\n```\n"])
	end

	def wrap(contents), do: contents

end
```
