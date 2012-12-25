# Jade
jade = require 'jade'

# File system
fs   = require 'fs'
path = require 'path'

# Wrench
wrench = require 'wrench'

# Parser
parse = require './parser'

# Error
error = require './error'

# Default templates dir
defaultInputDir = path.join (path.dirname (fs.realpathSync __filename)), '../output/html'

# Document a file
documentFile = (stylusFile, outputDir = null, inputDir = null) ->

    # Output
    outputDir = (do process.cwd) if not outputDir?

    # Dir of templates
    inputDir = defaultInputDir if not inputDir?

    # Make sure file exists
    error "\"#{stylusFile}\" does not exist" if not fs.existsSync stylusFile

    # Parse it
    tree = parse stylusFile

    # Render the tree
    renderFileTree stylusFile, tree, inputDir, outputDir

# Render a file's tree
renderFileTree = (fileName, tree, inputDir, outputDir) ->

    # Template file
    template = (inputDir + '/templates/file.jade')

    error "\"#{template}\" template file does not exist " if not fs.existsSync template

    # Options
    options =
        fileName     : fileName
        fileBaseName : path.basename fileName
        tree         : tree
        pretty       : true
        markdown     : (require 'markdown-js').parse

    # Render
    jade.renderFile template, options, (err, str) ->

        # Exit on error
        if err?
            error "Could not render jade template \"#{template}\", because: \n\n#{err}"

        # Copy assets
        copyAssets inputDir, outputDir

        # Write the output
        writeOutput str, outputDir, fileName

# Write to disk
writeOutput = (html, outputDir, stylusFile) ->

    outFile = outputDir + '/' + (path.basename stylusFile) + '.html'

    console.log "Writing docs for #{stylusFile} to #{outFile}"

    fs.writeFileSync outFile, html

# Copy assets
copyAssets = (inputDir, outputDir) ->
    console.log "Copying assets from #{inputDir}/assets to #{outputDir}"

    wrench.copyDirSyncRecursive "#{inputDir}/assets", "#{outputDir}/assets"

# Exports
module.exports = {documentFile}
