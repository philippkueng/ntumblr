// Generated by CoffeeScript 1.3.1
(function() {
  var CustomOAuth, Tumblr, VERSION, encodeToHex, keys, querystring, utils;

  VERSION = '0.0.2';

  querystring = require('querystring');

  CustomOAuth = require('./custom-oauth');

  utils = require('./utils');

  keys = require('./keys');

  encodeToHex = require('./encode-image').encodeToHex;

  Tumblr = (function() {
    var BASE, defaults, _isFunction;

    Tumblr.name = 'Tumblr';

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
      this.oauth = new CustomOAuth(this.options.requestTokenUrl, this.options.accessTokenUrl, this.options.consumerKey, this.options.consumerSecret, '1.0', null, 'HMAC-SHA1', null, this.options.headers);
    }

    Tumblr.prototype.get = function(action, options, callback) {
      var method;
      if ((!(callback != null)) && _isFunction(options)) {
        callback = options;
      }
      method = /user/.test(action) ? 'post' : 'get';
      return this.oauth[method](this.getUrlFor(action, options), this.options.accessTokenKey, this.options.accessTokenSecret, callback);
    };

    Tumblr.prototype.post = function(content, callback) {
      var d, i, _i, _len, _ref;
      if (content.data != null) {
        this.oauth.originalBody = {};
        if (Array.isArray(content.data)) {
          _ref = content.data;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            d = _ref[i];
            content["data[" + i + "]"] = encodeToHex(d);
            this.oauth.originalBody["data[" + i + "]"] = encodeToHex(d);
          }
          delete content.data;
        } else {
          content['data[0]'] = encodeToHex(content.data);
          this.oauth.originalBody["data[0]"] = encodeToHex(content.data);
          delete content.data;
        }
      }
      return this.oauth.post(this.getUrlFor('post'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype.edit = function(content, callback) {
      return this.oauth.post(this.getUrlFor('post/edit'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype["delete"] = function(postId, callback) {
      var content;
      if (postId.id != null) {
        postId = postId.id;
      }
      content = {
        "id": postId
      };
      return this.oauth.post(this.getUrlFor('post/delete'), this.options.accessTokenKey, this.options.accessTokenSecret, content, "application/x-www-form-urlencoded", callback);
    };

    Tumblr.prototype.getUrlFor = function(action, options) {
      var isUser, query, _ref, _url;
      if (/post(?!s)/.test(action)) {
        return "" + this.baseBlog + action;
      } else {
        isUser = /user/.test(action);
        _url = "" + (isUser ? BASE : this.baseBlog);
        _url += "" + action + "/";
        if (!(((_ref = (options != null ? options.type : void 0) != null) === 'draft' || _ref === 'queue' || _ref === 'submission') || isUser)) {
          _url += "?api_key=" + this.options.consumerKey;
        }
        if (options != null) {
          query = querystring.stringify(options);
          if (query !== '') {
            _url += "&" + query;
          }
        }
        return _url;
      }
    };

    return Tumblr;

  })();

  module.exports = Tumblr;

}).call(this);
