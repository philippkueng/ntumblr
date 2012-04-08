###
Python's urllib.quote
escape does not escape:
`* + - . / @ _`

encodeURIComponent does not escape:

! ' ( ) * - . _ ~
###

module.exports.quote = (str, ignoreSpecial = no)->
  escape(str).replace(/\%21/g, '!')
             .replace(/\%27/g, '\'')
             .replace(/\%28/g, '\(')
             .replace(/\%29/g, '\)')
             .replace(/\%7E/g, '\~')
             .replace(/\s/g, '%2B')
  
module.exports.unquote = (str)->

  unescape(str).replace(/\%21/g, '!')
               .replace(/\%27/g, '\'')
               .replace(/\%28/g, '\(')
               .replace(/\%29/g, '\)')
               .replace(/\%7E/g, '\~')
               .replace(/\s/g,   '%2B')
