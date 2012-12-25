# Renderer
renderer = require './renderer'

# Arguments
argv = (require 'optimist').argv

# Error
error = require './error'

# Single file passed
if argv.file.length > 0
    renderer.documentFile argv.file, argv.out, argv.templates
