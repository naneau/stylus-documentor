# Renderer
renderer = require './renderer'

# Arguments
argv = (require 'optimist').argv

# Error
error = require './error'

glob = require 'glob'

# Single file passed
if argv.file? and argv.file.length > 0
    renderer.documentFile argv.file, argv.out, argv.templates

# Glob passed
else if argv.glob? and argv.glob.length > 0
    console.log "Parsing #{argv.glob}"

    glob argv.glob, (err, files) ->

        # Error out on failure
        error "Can not glob \"#{arg.glob}\", because: \n\n#{err}" if err?

        for file in files
            do (file) ->
                renderer.documentFile file, argv.out, argv.templates
