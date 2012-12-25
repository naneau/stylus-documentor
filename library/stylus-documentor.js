// Generated by CoffeeScript 1.4.0
(function() {
  var argv, error, glob, renderer;

  renderer = require('./renderer');

  argv = (require('optimist')).argv;

  error = require('./error');

  glob = require('glob');

  if ((argv.file != null) && argv.file.length > 0) {
    renderer.documentFile(argv.file, argv.out, argv.templates);
  } else if ((argv.glob != null) && argv.glob.length > 0) {
    console.log("Parsing " + argv.glob);
    glob(argv.glob, function(err, files) {
      var file, _i, _len, _results;
      if (err != null) {
        error("Can not glob \"" + arg.glob + "\", because: \n\n" + err);
      }
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        _results.push((function(file) {
          return renderer.documentFile(file, argv.out, argv.templates);
        })(file));
      }
      return _results;
    });
  }

}).call(this);
