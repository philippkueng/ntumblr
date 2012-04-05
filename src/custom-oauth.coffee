OAuth               = require('oauth').OAuth
replaceAfterEncode  = require('./encode-image').replaceAfterEncode

class CustomOAuth extends OAuth
  
  _encodeData: (toEncode)->
    result = super(toEncode)
    # if this is binary data, treat it a bit differently
    if /data%3A/g.test(result)
      result = replaceAfterEncode(result)
    result
    
  _createClient: ->

    # Get the request client
    client = super
    
    # Keep the original function
    _write  = client.write.bind(client)

    # `request.write` should handle binary data
    client.write = (chunk, encoding) ->
      
      # if body contains `data%3A === encodeURIComponent('data:')`
      if /data%3A/g.test( chunk )
        chunk = replaceAfterEncode(chunk)

      # Content-Length should be re-valuated as we replaced some bits of chunk
      contentLength = 0
      if Buffer.isBuffer(chunk)?
        contentLength = chunk.length
      else
        contentLength = Buffer.byteLength(chunk)
      @setHeader "Content-Length", contentLength
      _write(chunk, encoding)

    client

module.exports = CustomOAuth