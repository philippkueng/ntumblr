
/*
  Merge objects into the first one
*/

(function() {

  exports.merge = function(defaults) {
    var i, key, obj, val, _len;
    for (i = 0, _len = arguments.length; i < _len; i++) {
      obj = arguments[i];
      if (i === 0) continue;
      for (key in obj) {
        val = obj[key];
        defaults[key] = val;
      }
    }
    return defaults;
  };

}).call(this);