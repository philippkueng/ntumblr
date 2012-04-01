http    = require('http')
fs      = require('fs')
config = JSON.parse( fs.readFileSync('config.json', 'utf-8') )

express = require("express")

Tumblr  = require('./src/tumblr')

encodeImage = require('./src/encode-image')

OAuth = require("oauth").OAuth

config =
  consumer_key: config.consumerKey
  secret_key: config.secretKey
  oauth_access_token: config.accessToken
  oauth_access_token_secret: config.accessTokenSecret
  session_secret: "someRandomLetters"

app = express()

app.configure ->
  app.use express.bodyParser()
  app.use express.cookieParser('secrecy')
  app.use express.session(secret: config.session_secret)

oa = new OAuth("http://www.tumblr.com/oauth/request_token", "http://www.tumblr.com/oauth/access_token", config.consumer_key, config.secret_key, "1.0A", "http://localhost:3000/callback", "HMAC-SHA1")

app.get "/callback", (req, res) ->
  oauth_token = req.query.oauth_token
  oauth_verifier = req.query.oauth_verifier
  hasVerifier = !!(oauth_verifier)
  if hasVerifier
    getOAuthAccessToken req, res, oauth_verifier
  else
    getOAuthRequestToken req, res

app.get "/dashb", (req, res) ->
  res.send "ok"

app.get "/dashb/fetch", (req, res) ->
  oa.getProtectedResource "http://api.tumblr.com/v2/blog/square.mnmly.com/info", "GET", req.session.oauth.access_token, req.session.oauth.access_token_secret, (err, data, response) ->
    if err
      res.send err, 500
      return
    res.contentType "json"
    res.send data

getOAuthAccessToken = (req, res, oauth_verifier) ->
  oa.getOAuthAccessToken req.session.oauth.oauth_token, req.session.oauth.oauth_token_secret, oauth_verifier, (err, oauth_access_token, oauth_access_token_secret, results) ->
    if err
      res.send err, 500
      return
    req.session.oauth =
      access_token: oauth_access_token
      access_token_secret: oauth_access_token_secret
    
    tumblr = new Tumblr
      consumerKey: config.consumer_key
      consumerSecret: config.secret_key
      accessTokenKey: oauth_access_token
      accessTokenSecret: oauth_access_token_secret

    img = fs.readFileSync('photo.jpg')
    body =
      'data[0]': encodeImage(img)
      type: 'photo'

    tumblr.post body

    #tumblr.post body, "multipart/form-data; boundary=#{boundary}"
    

    res.redirect "/dashb"

getOAuthRequestToken = (req, res) ->
  oa.getOAuthRequestToken (err, oauth_token, oauth_token_secret, results) ->
    if err
      res.send err, 500
      return
    req.session.oauth =
      oauth_token: oauth_token
      oauth_token_secret: oauth_token_secret
      request_token_results: results
    
    res.redirect "http://www.tumblr.com/oauth/authorize?oauth_token=" + oauth_token

http.createServer( app ).listen 3000

console.log "listening on port 3000"



tumblr = new Tumblr
  consumerKey: config.consumer_key
  consumerSecret: config.secret_key
  accessTokenKey: config.oauth_access_token
  accessTokenSecret: config.oauth_access_token_secret
  host: 'square.mnmly.com'

postImage = ->
  img = fs.readFileSync('photo.jpg')

  body =
    data: [ img, img ]
    type: 'photo'

  ###
  body =
    type: 'text'
    status: 'draft'
    body: 'testing'
  ###
  console.log body
  tumblr.post body, (err, data)->
    console.log('post ', data)
  ###
  tumblr.get 'info', (err, data, response)->
    throw new Error(err) if err?
    blogInfoData = JSON.parse( data ).response.blog
    { title,
      post,
      name,
      url,
      updated,
      description,
      ask,
      ask_anon,
      likes } = blogInfoData
    console.log title, post, name, url, updated
    
  tumblr.get 'posts', type:'photo', (err, data, response)->
    postObj =
      type: 'text'
      title: 'Demo Post'
      body: 'Having a nice day :D'
      status: 'draft'

    tumblr.post postObj, (err, data, response)->
      {
        meta,
        response
      } = JSON.parse(data)

      if meta.status is 201 then console.log meta.msg is 'Created'
      newPostId = response.id
      console.log newPostId

  tumblr.get 'posts', type: 'text', (err, data, response)->
    console.log 'get post:text', JSON.stringify( JSON.parse( data ), null, 2 )
  
  tumblr.get 'posts', limit: 1, (err, data, response)->
    console.log 'get post limited to 1', JSON.stringify( JSON.parse( data ), null, 2 )
  
  tumblr.get 'posts', type: 'draft', (err, data, response)->
    console.log 'get draft post', JSON.stringify( JSON.parse( data ), null, 2 )
  tumblr.get 'user/info', (err, data, response)->
    console.log 'get user info', JSON.stringify( JSON.parse( data ), null, 2 )
  ###
postImage()
