quote = require('../src/escape-py').quote

describe "quote", ->
  it "should escape acii string", ->
    quote('abcd').should.equal 'abcd'

  it 'should not escape `! \' ( ) * - . _ ~`', ->
    noEscapeChars = '! \' ( ) * - . _ ~'.split(' ')

    for char in noEscapeChars
      quote(char).should.equal(char)

  it 'should escape `+ / @`', ->
    escapeChars  = '+ \/ @'.split(' ')
    escapedChars = ['%2B', '%2F', '%40']
    for char, i in escapeChars
      quote(char).should.not.equal(escapedChars[i])

  it 'should not encode unicode', ->
    euro = '€'
    quote(euro).should.equal('%u20AC')
