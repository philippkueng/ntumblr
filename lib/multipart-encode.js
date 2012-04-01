(function() {
  var _flatten;

  _flatten = function(q) {
    var list;
    list = [];
    Object.keys(q).forEach(function(k) {
      var v;
      v = q[k];
      if (k[0] === "$") {
        k = k.slice(1);
        if (k[0] !== "$") v = JSON.stringify(v);
      }
      return [].concat(v).forEach(function(v) {
        return list.push([k, v]);
      });
    });
    return list;
  };

  exports.multipartEncode = function(data) {
    var buffer, push, q, segno;
    buffer = new Buffer(0);
    push = function(l) {
      var newBuffer, prevBuffer;
      prevBuffer = buffer;
      newBuffer = (l instanceof Buffer ? l : new Buffer("" + l));
      buffer = new Buffer(prevBuffer.length + newBuffer.length + 2);
      prevBuffer.copy(buffer);
      newBuffer.copy(buffer, prevBuffer.length);
      return buffer.write("\r\n", buffer.length - 2);
    };
    q = function(s) {
      return "\"" + s.replace(/"|"/g, "%22").replace(/\r\n|\r|\n/g, " ") + "\"";
    };
    segno = "" + Math.round(Math.random() * 1e16) + Math.round(Math.random() * 1e16);
    _flatten(data).forEach(function(kv) {
      var file;
      push("--" + segno);
      if ({}.hasOwnProperty.call(kv[1], "data")) {
        file = kv[1];
        push("Content-Disposition: form-data; name=" + q(kv[0]) + "; filename=" + q(file.name || "blob"));
        push("Content-Type: " + (file.type || "application/octet-stream"));
        push("");
        return push(file.data);
      } else {
        push("Content-Disposition: form-data; name=" + q(kv[0]));
        push("");
        return push(kv[1]);
      }
    });
    push("--" + segno + "--");
    return {
      buffer: buffer,
      boundary: segno
    };
  };

}).call(this);
