(function() {
  var Tumblr, VERSION, encodeData, keys, oauth, querystring, replaceAfterEncode, utils, _ref;

  VERSION = '0.0.1';

  oauth = require('oauth');

  querystring = require('querystring');

  utils = require('./utils');

  keys = require('./keys');

  _ref = require('./encode-image'), encodeData = _ref.encodeData, replaceAfterEncode = _ref.replaceAfterEncode;

  Tumblr = (function() {
    var BASE, defaults, _isFunction;

    Tumblr.VERSION = VERSION;

    BASE = "http://api.tumblr.com/v2/";

    _isFunction = function(fn) {
      var getType;
      getType = {};
      return fn && getType.toString.call(fn) === "[object Function]";
    };

    defaults = {
      consumerKey: null,
      consumerSecret: null,
      accessTokenKey: null,
      accessTokenSecret: null,
      headers: {
        'Accept-Encoding': 'identity'
      },
      secure: false,
      cookie: 'tbauth',
      cookieOptions: {},
      cookieSecret: null
    };

    function Tumblr(options) {
      this.options = utils.merge(defaults, options, keys.urls);
      this.host = this.options.host;
      this.baseBlog = "" + BASE + "blog/" + this.host + "/";
      this.oauth = new oauth.OAuth(this.options.requestTokenUrl, this.options.accessTokenUrl, this.options.consumerKey, this.options.consumerSecret, '1.0', null, 'HMAC-SHA1', null, this.options.headers);
      this.modifyOAuthMethods();
    }

    Tumblr.prototype.modifyOAuthMethods = function() {
      var _createClient,
        _this = this;
      _createClient = this.oauth._createClient.bind(this.oauth);
      this.oauth._encodeData = function(toEncode) {
        var result;
        if (!(!(toEncode != null) || toEncode === "")) {
          result = encodeURIComponent(toEncode);
          if (typeof toEncode === "string" && toEncode.search(/data%3A/) > -1) {
            result = replaceAfterEncode(result);
          }
          return result.replace(/\!/g, "%21").replace(/\'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29").replace(/\*/g, "%2A");
        }
      };
      return this.oauth._createClient = function(port, hostname, method, path, headers, sshEnabled) {
        var request, _write;
        request = _createClient(port, hostname, method, path, headers, sshEnabled);
        _write = request.write.bind(request);
        request.write = function(chunk, encoding) {
          var contentLength;
          if (chunk.search(/data%3A/) > -1) chunk = replaceAfterEncode(chunk);
          contentLength = 0;
          if (Buffer.isBuffer(chunk) != null) {
            contentLength = chunk.length;
          } else {
            contentLength = Buffer.byteLength(chunk);
          }
          this.setHeader("Content-Length", contentLength);
          return _write(chunk, encoding);
        };
        return request;
      };
    };

    Tumblr.prototype.get = function(action, options, callback) {
      var method;
      if ((!(callback != null)) && _isFunction(options)) callback = options;
      method = /user/.test(action) ? 'post' : 'get';
      return this.oauth[method](this.getUrlFor(action, options), this.options.accessTokenKey, this.options.accessTokenSecret, callback);
    };

    Tumblr.prototype.post = function(content, callback) {
      var d, i, _len, _ref2;
      if (content.data != null) {
        if (Array.isArray(content.data)) {
          _ref2 = content.data;
          for (i = 0, _len = _ref2.length; i < _len; i++) {
            d = _ref2[i];
            content["data[" + i + "]"] = encodeData(d);
          }
          delete content.data;
        } else {
          content.data = encodeData(content.data);
        }
      }
      return this.oauth.post(this.getUrlFor('post'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype.edit = function(content, callback) {
      return this.oauth.post(this.getUrlFor('post/edit'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype["delete"] = function(postId, callback) {
      return this.oauth.post(this.getUrlFor('post/delete'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype.getUrlFor = function(action, options) {
      var isUser, query, _ref2, _url;
      if (/post(?!s)/.test(action)) {
        return "" + this.baseBlog + action;
      } else {
        isUser = /user/.test(action);
        _url = "" + (isUser ? BASE : this.baseBlog);
        _url += "" + action + "/";
        if (!(((_ref2 = (options != null ? options.type : void 0) != null) === 'draft' || _ref2 === 'queue' || _ref2 === 'submission') || isUser)) {
          _url += "?api_key=" + this.options.consumerKey;
        }
        if (options != null) {
          query = querystring.stringify(options);
          if (query !== '') _url += "&" + query;
        }
        return _url;
      }
    };

    return Tumblr;

  })();

  module.exports = Tumblr;

}).call(this);
