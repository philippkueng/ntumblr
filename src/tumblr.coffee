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
      '1.0A', null, 'HMAC-SHA1'
    )

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
