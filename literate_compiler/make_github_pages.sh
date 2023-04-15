#!/bin/bash
set -o pipefail
mix escript.build && ./literate_compiler --inputdir ./lib/ --outputdir ../docs/ --type 2 --jekyll