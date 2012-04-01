fs          = require('fs')
encodedTxt  = fs.readFileSync('test/url-encoded-image.txt').toString('utf-8')
photo       = fs.readFileSync('test/photo.jpg')
{ encodeData, replaceAfterEncode } = require('./../src/encode-image')

describe "encodeData", ->
  it "should encode image as same as python's dump", ->
    encodedString = encodeURIComponent( encodeData(photo) )

    encodedString = encodedString.replace /data%3A([%\w]+)/g, (a, g) ->
      g.replace(/0X/g, "%").replace /%20/g, "+"

    encodedTxt.should.equal encodedString
