#!/bin/bash
mix escript.build && ./literate_compiler -i ./lib/ -o ../docs/ -t 2