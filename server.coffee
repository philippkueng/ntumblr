http    = require('http')
fs      = require('fs')
Iconv   = require('iconv').Iconv
config = JSON.parse( fs.readFileSync('config.json', 'utf-8') )
express = require("express")
Tumblr  = require('./src/tumblr')
multipartEncode = require('./src/multipart-encode')
console.log multipartEncode
OAuth = require("oauth").OAuth

config =
  consumer_key: config.consumerKey
  secret_key: config.secretKey
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
    console.log
      consumerKey: config.consumer_key
      consumerSecret: config.secret_key
      accessTokenKey: oauth_access_token
      accessTokenSecret: oauth_access_token_secret

    img = fs.readFileSync('photo.jpg', 'utf-8')
    #iconv = new Iconv('UTF-8', 'ISO-8859-1')
    #buffer = iconv.convert(img).toString()
    boundary = 'myboundary'
    body = ''
    body += "--#{boundary}\r\n"
    body += "Content-Disposition: form-data; name=\"type\"\r\n"
    body += "\r\n"
    body += "photo\r\n"
    body += "--#{boundary}\r\n"
    body += "Content-Disposition: form-data; name=\"state\"\r\n"
    body += "\r\n"
    body += "draft\r\n"
    body += "--#{boundary}\r\n"
    body += "Content-Disposition: form-data; name=\"data[0]\"; filename=\"photo\"\r\n"
    body += "Content-Type: application/octet-stream\r\n"
    body += "\r\n"
    body += new Buffer( img, 'utf-8' )
    body += "\r\n"
    body += "--#{boundary}--\r\n"
    body =
      type: 'photo'
      state: 'draft'
      #source: 'http://29.media.tumblr.com/tumblr_lx1tnqatVp1qkgyddo1_500.jpg'
    #console.log buffer
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

