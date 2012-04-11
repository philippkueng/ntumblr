OAuth               = require('oauth').OAuth
replaceAfterEncode  = require('./encode-image').replaceAfterEncode
quote            = require('./escape-py').quote

class CustomOAuth extends OAuth
  _createSignatureBase: ->
    _signatureBase = super
    #console.t.log _signatureBase

    if /data%255B\d%255D/g.test _signatureBase
      #_remain        = _signatureBase.split('%26').slice(1).join('%26')
      _signatureBase = replaceAfterEncode _signatureBase, @originalBody
      #require('fs').writeFileSync 'log.txt', _signatureBase + "%26" + _remain
      #console.t.log _signatureBase
      return _signatureBase # + "%26" + _remain
    else
      #console.t.log _signatureBase
      return _signatureBase

    
    # "data%5B0%5D%3Ddata%253A%25C3%25B"
    #_signatureBase.replace(/%2B/g, '%2520')
    #              .replace(/data%255B(\d+)%255D/gi, "data%5B$1%5D")



  _encodeData: (toEncode)->
    if ( not toEncode? ) or (toEncode is '')
      return ''
    else
    
      if /data(\:|%5B)/g.test(toEncode)
        result = quote(toEncode.replace(/data( \:|%5B )/g, ''))
      else
        result = encodeURIComponent(toEncode)
      
      #console.t.log result
      result.replace(/\!/g, "%21").replace(/\'/g, "%27")
                 .replace(/\(/g, "%28")
                 .replace(/\)/g, "%29")
                 .replace(/\*/g, "%2A")

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
                          .replace("*", '%2A')
                          .replace("/", '%2F')
      #console.t.log chunk
      # Content-Length should be re-valuated as we replaced some bits of chunk
      contentLength = 0
      if Buffer.isBuffer(chunk)?
        contentLength = chunk.length
      else
        contentLength = Buffer.byteLength(chunk)
      @setHeader "Content-Length", contentLength
      @removeHeader "Connection"
      _write(chunk, encoding)

    client

module.exports = CustomOAuth
