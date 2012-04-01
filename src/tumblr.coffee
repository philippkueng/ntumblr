VERSION     = '0.0.1'

oauth       = require('oauth')
querystring = require('querystring')
utils       = require('./utils')
keys        = require('./keys')

{ encodeData,
  replaceAfterEncode } = require('./encode-image')

class Tumblr

  @VERSION = VERSION
  BASE     = "http://api.tumblr.com/v2/"
  
  _isFunction = (fn)->
    getType = {}
    fn and getType.toString.call(fn) is "[object Function]"
  
  defaults =
    consumerKey: null
    consumerSecret: null
    accessTokenKey: null
    accessTokenSecret: null
    headers:
      'Accept-Encoding': 'identity'
    secure: no
    cookie: 'tbauth'
    cookieOptions: {}
    cookieSecret: null

  constructor: (options)->

    @options  = utils.merge(defaults, options, keys.urls)
    @host     = @options.host
    @baseBlog = "#{BASE}blog/#{@host}/"

    @oauth    = new oauth.OAuth(
      @options.requestTokenUrl,
      @options.accessTokenUrl,
      @options.consumerKey,
      @options.consumerSecret,
      '1.0', null, 'HMAC-SHA1', null, @options.headers
    )
    
    @modifyOAuthMethods()

  # As Tumblr only accepts url-encoded binary data,
  # we need to modify some of the oauth encoding methods
  modifyOAuthMethods: ->

    _createClient = @oauth._createClient.bind(@oauth)
    
    # Fix encodeData
    @oauth._encodeData = (toEncode) ->
      unless not toEncode? or toEncode is ""
        result = encodeURIComponent(toEncode)
        if typeof toEncode is "string" and toEncode.search(/data%3A/) > -1
          result = replaceAfterEncode(result)
        result.replace(/\!/g, "%21").replace(/\'/g, "%27").replace(/\(/g, "%28").replace(/\)/g, "%29").replace /\*/g, "%2A"
    
    # Needs to treat binary data a bit differently that others
    @oauth._createClient = ( port, hostname, method, path, headers, sshEnabled )=>

      request = _createClient(port, hostname, method, path, headers, sshEnabled)
      _write  = request.write.bind(request)
      # Need to format binary data
      request.write = (chunk, encoding) ->
        if chunk.search(/data%3A/) > -1
          chunk = replaceAfterEncode(chunk)

        # Content-Length should be changed as we replaced some bits of chunk
        contentLength = 0
        if Buffer.isBuffer(chunk)?
          contentLength = chunk.length
        else
          contentLength = Buffer.byteLength(chunk)
        @setHeader "Content-Length", contentLength
        _write(chunk, encoding)
      request
  
  get: (action, options, callback)->
    if ( not callback? ) and _isFunction( options )
      callback = options
    # user info can be retrieved via POST
    method = if /user/.test(action) then 'post' else 'get'
    @oauth[method] @getUrlFor(action, options),
      @options.accessTokenKey,
      @options.accessTokenSecret,
      callback
  
  post: (content, callback)->
    if content.data?
      if Array.isArray( content.data )
        for d, i in content.data
          content["data[#{i}]"] = encodeData(d)
        delete content.data
      else
        content.data = encodeData(content.data)
    @oauth.post @getUrlFor('post'),
      @options.accessTokenKey,
      @options.accessTokenSecret,
      content, "application/x-www-form-urlencoded",
      callback
  
  edit: (content, callback)->
    @oauth.post @getUrlFor('post/edit'),
      @options.accessTokenKey,
      @options.accessTokenSecret,
      content, "application/x-www-form-urlencoded",
      callback
  
  delete: (postId, callback)->
    @oauth.post @getUrlFor('post/delete'),
      @options.accessTokenKey,
      @options.accessTokenSecret,
      content, "application/x-www-form-urlencoded",
      callback

  getUrlFor: (action, options)->
    if /post(?!s)/.test(action)
      return "#{@baseBlog}#{action}"
    else
      isUser = /user/.test(action)
      _url   = "#{if isUser then BASE else @baseBlog}"
      _url  += "#{action}/"

      # If Oauth is not required, add the API key
      unless ( options?.type? in ['draft', 'queue', 'submission'] or isUser )
        _url += "?api_key=#{@options.consumerKey}"

      if options?
        query = querystring.stringify(options)
        if query isnt ''
          _url += "&#{ query }"
      _url

module.exports = Tumblr
