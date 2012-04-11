fs          = require('fs')
qs          = require('querystring')
quote       = require('./escape-py').quote
doublequote = require('./escape-py').doublequote

# Referene: http://unspecified.wordpress.com/2008/05/24/uri-encoding/

_toHex = (n) ->
  return "0" + n.toString(16)  if n < 16
  n.toString 16

_hexSlice = (buffer, start, end) ->

  len   = buffer.length
  start = 0  if not start or start < 0
  end   = len  if not end or end < 0 or end > len
  out   = ""

  i = start
  
  while i < end
    b = _toHex(buffer[i])
    deci = parseInt ( "0x" + b )
    if 32 < deci < 126
      b = String.fromCharCode(deci)
    else
      b = "0x" + b
    out += b.toUpperCase()
    i++
  out

module.exports.encodeToHexOld = (buffer)->
  "data:" + _hexSlice(buffer)

module.exports.encodeToHex = (buffer)->
  "data:" + (buffer.toString('binary'))

module.exports.replaceAfterEncode = (str, originalBody = null)->
  
  pattern = /data%3A([\w\!\'\(\)\*\-\._~%]+)/g
  if originalBody?
    pattern = /data%255B(\d+)%255D%3Ddata%253A([\w\!\'\(\)\*\-\._~%]+)/g
  _s = str.replace pattern, (a, g1, g2) ->
    unless isNaN( g1 )
      index = g1
      data = originalBody["data[#{index}]"].replace('data:', '')
      g1 = g2
      g1 = "data%5B#{index}%5D%3D" + doublequote(data)
    else
      g1 = quote( decodeURIComponent(g1) )
      g1 = g1.replace( /%20/g, "+" )
    g1
  _s

