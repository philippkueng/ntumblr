fs      = require('fs')
qs      = require('querystring')


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

module.exports.encodeToHex = (buffer)->
  "data:" + _hexSlice(buffer)

module.exports.replaceAfterEncode = (str)->
  str.replace /data%3A([%\w]+)/g, (a, g) ->
    g.replace(/0X/g, "%").replace /%20/g, "+"
