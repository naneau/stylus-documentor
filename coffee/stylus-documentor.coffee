# Parser
parse = require './parser'

# Arguments
argv = (require 'optimist').argv

# File system
fs = require 'fs'

# Error out
error = (message) ->
    console.error message
    process.exit 1

# Single file passed
if argv.file.length > 0

    # Make sure file exists
    error "\"#{argv.file}\" does not exist" if not fs.existsSync argv.file

    # Parse it
    tree = parse argv.file
