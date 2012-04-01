fs     = require('fs')
Tumblr = require('./../src/tumblr')
config = JSON.parse(fs.readFileSync('config.json'))

describe "Tumblr", ->

  beforeEach ->
    @tumblr = new Tumblr
      consumerKey: config.consumerKey
      consumerSecret: config.secretKey
      accessTokenKey: config.accessToken
      accessTokenSecret: config.accessTokenSecret
      host: config.host

  it "should return blog info", (done)->
    @tumblr.get 'info', (err, data, response)->
      data = JSON.parse(data)
      data.should.have.keys('response', 'meta')
      
      data.response.blog.should.have.keys([
                                          'title'
                                          'posts'
                                          'name'
                                          'url'
                                          'updated'
                                          'description'
                                          'ask' ])

      done()
    
  it "should return posts", (done)->
    @tumblr.get 'posts', (err, data, response)->
      postsData = JSON.parse(data).response.posts

      postsData.forEach (post)->
        keyList = [
          'blog_name'
          'id'
          'post_url'
          'type'
          'date'
          'timestamp'
          'format'
          'reblog_key'
          'tags'
          'highlighted'
          'note_count'
        ]
        switch post.type
          when 'text'
            keyList = keyList.concat ['title', 'body']
          when 'photo'
            keyList = keyList.concat ['photos', 'caption']
          when 'quote'
            keyList = keyList.concat ['source_url', 'source_title', 'text', 'source']
          when 'link'
            keyList = keyList.concat ['title', 'url', 'description']

        post.should.have.keys keyList

      done()

  it "should return only text posts", (done)->
    @tumblr.get 'posts', type: 'text', (err, data, response)->
      postsData = JSON.parse(data).response.posts
      for post in postsData
        post.type.should.equal('text')

      done()
      

  it "should return only one text post", (done)->

    filterParam =
      type: 'text'
      limit: 1
    
    @tumblr.get 'posts', filterParam, (err, data, response)->
      post = JSON.parse(data).response.posts
      post.should.have.lengthOf(1)
      post[0].type.should.equal('text')
      done()

  it "should create new Text Post as draft", (done)->
    postObj =
      type: 'text'
      title: 'Demo Post'
      body: 'Having a nice day :D'
      status: 'draft'

    @tumblr.post postObj, (err, data, response)->
      data = JSON.parse(data)
      data.should.have.property('meta')
      data.meta.should.have.property('status', 201)
      data.meta.should.have.property('msg', 'Created')
      data.response.should.have.property('id')
      done()

  
  it "should create new Photo Post", (done)->

    postObj =
      type: 'photo'
      data: fs.readFileSync('test/photo.jpg')

    @tumblr.post postObj, (err, data, response)->
      data = JSON.parse(data)
      data.should.have.property('meta')
      data.meta.should.have.property('status', 201)
      data.meta.should.have.property('msg', 'Created')
      data.response.should.have.property('id')
      done()
