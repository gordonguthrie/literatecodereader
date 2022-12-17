# This escript generates markdown - this is a heading
It supports the native comment structure of whatever the programming language is
These include `@moduledoc` and `@doc`
this is a module comment - level 1 in this formatter
this is a document comment - level 2 in this formatter
This is a multiline module comment
         In this Elixir formatter module comments am a level 1 comment

This is a multiline document comment
         In this Elixir formatter document comments are a level 2 comment

```
elixir
```

The first two `##` are stripped off and the rest of the text
is turned into markdown.

Note that single `#` comments (in Elixir) are not processed
```
elixir
# (This comment won't be turned into markdown or html)
```

## Second Heading
### Third Heading
#### Fourth Heading
##### Fifth Heading
###### Sixth Heading
All other markdown constructs are supported.

lists
* item 1
* item 2

numbered lists
1. item 1
2. item

and also **bold** and *italic* etc
and any code in the file will be wrapped in a `pre` tag
```
elixir
def parse_args(args) do
    acc = %LiterateCompiler.Args{}
    parse_args(args, acc)
end```
