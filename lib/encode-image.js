(function() {
  var fs, qs, _hexSlice, _toHex;

  fs = require('fs');

  qs = require('querystring');

  _toHex = function(n) {
    if (n < 16) return "0" + n.toString(16);
    return n.toString(16);
  };

  _hexSlice = function(buffer, start, end) {
    var b, deci, i, len, out;
    len = buffer.length;
    if (!start || start < 0) start = 0;
    if (!end || end < 0 || end > len) end = len;
    out = "";
    i = start;
    while (i < end) {
      b = _toHex(buffer[i]);
      deci = parseInt("0x" + b);
      if ((32 < deci && deci < 126)) {
        b = String.fromCharCode(deci);
      } else {
        b = "0x" + b;
      }
      out += b.toUpperCase();
      i++;
    }
    return out;
  };

  module.exports.encodeToHex = function(buffer) {
    return "data:" + _hexSlice(buffer);
  };

  module.exports.replaceAfterEncode = function(str) {
    return str.replace(/data%3A([%\w]+)/g, function(a, g) {
      return g.replace(/0X/g, "%").replace(/%20/g, "+");
    });
  };

}).call(this);
