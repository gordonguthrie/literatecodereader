defmodule LiterateCompiler.Outputter.Markdown do

	def format(:markdown, contents, _language) do
		contents
	end
	def format(:code, contents, language) do
		js_extension = Kernel.apply(language, :get_js_ext, [])
		Enum.join(["```", js_extension, contents, "```\n"])
	end

end