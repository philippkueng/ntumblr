fs          = require('fs')
encodedTxt  = fs.readFileSync('test/assets/url-encoded-image.txt').toString('utf-8')
photo       = fs.readFileSync('test/assets/photo.jpg')
{ encodeToHex, replaceAfterEncode } = require('./../src/encode-image')

describe "encodeToHex", ->
  it "should encode image as same as python's dump", ->
    encodedString = encodeURIComponent( encodeToHex(photo) )
    encodedString = replaceAfterEncode( encodedString )
    encodedTxt.should.equal encodedString
