# Renderer
renderer = require './renderer'

# Arguments
argv = (require 'optimist').argv

# Error out
error = (message) ->
    console.error message
    process.exit 1

# Single file passed
if argv.file.length > 0
    renderer.documentFile argv.file, argv.out, argv.templates
