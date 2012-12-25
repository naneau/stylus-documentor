// Generated by CoffeeScript 1.4.0
(function() {
  var copyAssets, defaultInputDir, documentFile, error, fs, jade, parse, path, renderFileTree, wrench, writeOutput;

  jade = require('jade');

  fs = require('fs');

  path = require('path');

  wrench = require('wrench');

  parse = require('./parser');

  error = require('./error');

  defaultInputDir = path.join(path.dirname(fs.realpathSync(__filename)), '../output/html');

  documentFile = function(stylusFile, outputDir, inputDir) {
    var tree;
    if (outputDir == null) {
      outputDir = null;
    }
    if (inputDir == null) {
      inputDir = null;
    }
    if (!(outputDir != null)) {
      outputDir = process.cwd();
    }
    if (!(inputDir != null)) {
      inputDir = defaultInputDir;
    }
    if (!fs.existsSync(stylusFile)) {
      error("\"" + stylusFile + "\" does not exist");
    }
    tree = parse(stylusFile);
    return renderFileTree(stylusFile, tree, inputDir, outputDir);
  };

  renderFileTree = function(fileName, tree, inputDir, outputDir) {
    var options, template;
    template = inputDir + '/templates/file.jade';
    if (!fs.existsSync(template)) {
      error("\"" + template + "\" template file does not exist ");
    }
    options = {
      fileName: fileName,
      fileBaseName: path.basename(fileName),
      tree: tree,
      pretty: true
    };
    return jade.renderFile(template, options, function(err, str) {
      if (err != null) {
        error("Could not render jade template \"" + template + "\", because: \n\n" + err);
      }
      copyAssets(inputDir, outputDir);
      return writeOutput(str, outputDir, fileName);
    });
  };

  writeOutput = function(html, outputDir, stylusFile) {
    var outFile;
    outFile = outputDir + '/' + (path.basename(stylusFile)) + '.html';
    console.log("Writing docs for " + stylusFile + " to " + outFile);
    return fs.writeFileSync(outFile, html);
  };

  copyAssets = function(inputDir, outputDir) {
    console.log("Copying assets from " + inputDir + "/assets to " + outputDir);
    return wrench.copyDirSyncRecursive("" + inputDir + "/assets", "" + outputDir + "/assets");
  };

  module.exports = {
    documentFile: documentFile
  };

}).call(this);
