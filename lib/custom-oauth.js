(function() {
  var CustomOAuth, OAuth, replaceAfterEncode,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  OAuth = require('oauth').OAuth;

  replaceAfterEncode = require('./encode-image').replaceAfterEncode;

  CustomOAuth = (function(_super) {

    __extends(CustomOAuth, _super);

    function CustomOAuth() {
      CustomOAuth.__super__.constructor.apply(this, arguments);
    }

    CustomOAuth.prototype._encodeData = function(toEncode) {
      var result;
      result = CustomOAuth.__super__._encodeData.call(this, toEncode);
      if (/data%3A/g.test(result)) result = replaceAfterEncode(result);
      return result;
    };

    CustomOAuth.prototype._createClient = function() {
      var client, _write;
      client = CustomOAuth.__super__._createClient.apply(this, arguments);
      _write = client.write.bind(client);
      client.write = function(chunk, encoding) {
        var contentLength;
        if (/data%3A/g.test(chunk)) chunk = replaceAfterEncode(chunk);
        contentLength = 0;
        if (Buffer.isBuffer(chunk) != null) {
          contentLength = chunk.length;
        } else {
          contentLength = Buffer.byteLength(chunk);
        }
        this.setHeader("Content-Length", contentLength);
        return _write(chunk, encoding);
      };
      return client;
    };

    return CustomOAuth;

  })(OAuth);

  module.exports = CustomOAuth;

}).call(this);
