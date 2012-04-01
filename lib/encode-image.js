(function() {
  var encodeImage, fs, qs, toHex, _hexSlice;

  fs = require('fs');

  qs = require('querystring');

  toHex = function(n) {
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
      b = toHex(buffer[i]);
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

  module.exports = encodeImage = function(buffer) {
    return "data:" + _hexSlice(buffer);
  };

  /*
  encoded = 'data%5B0%5D=' + encodeURIComponent( _hexSlice( fs.readFileSync('photo.jpg') ) ).replace(/0x/gi, '%').replace(/%20/gi, '+') + '&type=photo'
  #console.log decodeURIComponent(encoded)
  param   = 'data%5B0%5D=%FF%D8%FF%E0%00%10JFIF%00%01%01%01%00H%00H%00%00%FF%DB%00C%00%06%04%04%04%05%04%06%05%05%06%09%06%05%06%09%0B%08%06%06%08%0B%0C%0A%0A%0B%0A%0A%0C%10%0C%0C%0C%0C%0C%0C%10%0C%0E%0F%10%0F%0E%0C%13%13%14%14%13%13%1C%1B%1B%1B%1C++++++++++%FF%DB%00C%01%07%07%07%0D%0C%0D%18%10%10%18%1A%15%11%15%1A+++++++++++++++++++++++++++++++++++++++++++++++++%FF%C0%00%11%08%00%02%00%02%03%01%11%00%02%11%01%03%11%01%FF%C4%00%14%00%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%08%FF%C4%00%14%10%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%C4%00%14%01%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%C4%00%14%11%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%DA%00%0C%03%01%00%02%11%03%11%00%3F%00T%83%FF%D9&type=photo'
  console.log encoded is param
  console.log encoded.substr(100, 400)
  console.log param.substr(100, 400)
  */

}).call(this);
