###
Python's urllib.quote

escape does not escape:
`* + - . / @ _`

encodeURIComponent does not escape:

! ' ( ) * - . _ ~
###

module.exports.quote = quote = (str)->
  str = escape(str)
             .replace(/\%21/g, '!')
             .replace(/\%27/g, '\'')
             .replace(/\%28/g, '\(')
             .replace(/\%29/g, '\)')
             .replace(/\%7E/g, '\~')
  
  str.replace(/\+/g, '%2B')
     .replace(/\//g, '%2F')
     .replace(/@/g,  '%40')
     .replace(/\s/g, '%2B')

module.exports.replaceMismatch = replaceMismatch = (str)->
  str.replace(/\!/g, "%21")
     .replace(/\'/g, "%27")
     .replace(/\(/g, "%28")
     .replace(/\)/g, "%29")
     .replace(/\*/g, "%2A")
  
module.exports.doublequote = (str)->
  _str = replaceMismatch( quote(str) )
  replaceMismatch(quote(_str))
  
module.exports.unquote = (str)->

  unescape(str).replace(/\%21/g, '!')
               .replace(/\%27/g, '\'')
               .replace(/\%28/g, '\(')
               .replace(/\%29/g, '\)')
               .replace(/\%7E/g, '\~')
               .replace(/\s/g,   '%2B')
