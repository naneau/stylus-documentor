# Jade
jade = require 'jade'

# File system
fs   = require 'fs'
path = require 'path'

# Parser
parse = require './parser'

# Default templates dir
defaultTemplatedir = path.join (path.dirname (fs.realpathSync __filename)), '../templates'

# Document a file
documentFile = (stylusFile, outputDir = null, templateDir = null) ->

    # Output
    outputDir = (do process.cwd) if not outputDir?

    # Dir of templates
    templateDir = defaultTemplatedir if not templateDir?

    # Make sure file exists
    error "\"#{stylusFile}\" does not exist" if not fs.existsSync stylusFile

    # Parse it
    tree = parse stylusFile

    # Render the tree
    renderFileTree stylusFile, tree, templateDir, outputDir


# Render a file's tree
renderFileTree = (fileName, tree, templateDir, outputDir) ->

    # Template file
    template = (templateDir + '/file.jade')

    # Options
    options =
        fileName : fileName
        tree     : tree
        pretty   : true

    # Render
    jade.renderFile template, options, (err, str) ->

        # Exit on error
        process.exit 1 if err?

        writeOutput str, outputDir, fileName

# Write to disk
writeOutput = (html, outputDir, stylusFile) ->

    outFile = outputDir + '/' + (path.basename stylusFile) + '.html'
    console.log outFile

    fs.writeFileSync outFile, html

# Exports
module.exports = {documentFile}
