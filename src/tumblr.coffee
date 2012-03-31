VERSION     = '0.0.1'

http        = require('http')
querystring = require('querystring')
oauth       = require('oauth')
utils       = require('./utils')
keys        = require('./keys')

class Tumblr

  @VERSION = VERSION

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
    @options = utils.merge(defaults, options, keys.urls)
    @oauth    = new oauth.OAuth(
      @options.requestTokenUrl,
      @options.accessTokenUrl,
      @options.consumerKey,
     @options.consumerSecret,
      '1.0', null, 'HMAC-SHA1', null, defaults.headers
    )
    ###
    _createClient = @oauth._createClient
    # Needs to treat binary data a bit differently that others
    @oauth._createClient = ( port, hostname, method, path, headers, sshEnabled )=>
      requestModel = _createClient(port, hostname, method, path, headers, sshEnabled)
      _write = requestModel.write
      
      requestModel.write = (postBody)->
        
        param   = 'data%5B0%5D=%FF%D8%FF%E0%00%10JFIF%00%01%01%01%00H%00H%00%00%FF%DB%00C%00%06%04%04%04%05%04%06%05%05%06%09%06%05%06%09%0B%08%06%06%08%0B%0C%0A%0A%0B%0A%0A%0C%10%0C%0C%0C%0C%0C%0C%10%0C%0E%0F%10%0F%0E%0C%13%13%14%14%13%13%1C%1B%1B%1B%1C++++++++++%FF%DB%00C%01%07%07%07%0D%0C%0D%18%10%10%18%1A%15%11%15%1A+++++++++++++++++++++++++++++++++++++++++++++++++%FF%C0%00%11%08%00%02%00%02%03%01%11%00%02%11%01%03%11%01%FF%C4%00%14%00%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%08%FF%C4%00%14%10%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%C4%00%14%01%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%C4%00%14%11%01%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%FF%DA%00%0C%03%01%00%02%11%03%11%00%3F%00T%83%FF%D9&type=photo'
        good     = param.replace('&type=photo', '').replace('data%5B0%5D=', '')
        returned = postBody.replace('type=photo&state=draft&data%5B0%5D=', '')
      requestModel.write = (chunk, encoding) ->
        chunk = chunk.replace(/data%3A/, "").replace(/%2B/g, "+").replace(/%25/g, "%")
        @_implicitHeader()  unless @_header
        unless @_hasBody
          console.error "This type of response MUST NOT have a body. " + "Ignoring write() calls."
          return true
        throw new TypeError("first argument must be a string or Buffer")  if typeof chunk isnt "string" and not Buffer.isBuffer(chunk)
        return false  if chunk.length is 0
        len = undefined
        ret = undefined
        if @chunkedEncoding
          if typeof (chunk) is "string"
            len = Buffer.byteLength(chunk, encoding)
            chunk = len.toString(16) + CRLF + chunk + CRLF
            ret = @_send(chunk, encoding)
          else
            len = chunk.length
            @_send len.toString(16) + CRLF
            @_send chunk
            ret = @_send(CRLF)
        else
          ret = @_send(chunk, encoding)
        ret
      requestModel
      ###


  get: (url)->
    @oauth.get url,
      @options.accessTokenKey,
      @options.accessTokenSecret,
      (error, data, response)->
        console.log data

  post: (content, contentType = "application/x-www-form-urlencoded")->
    @oauth.post "http://api.tumblr.com/v2/blog/square.mnmly.com/post",
      @options.accessTokenKey,
      @options.accessTokenSecret,
      content, contentType
      (error, data, response)->
        console.log data

    
  getInfo: ->
    @get("http://api.tumblr.com/v2/blog/square.mnmly.com/info")
  
  
module.exports = Tumblr
