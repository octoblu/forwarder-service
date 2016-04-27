http    = require 'http'
request = require 'request'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'

describe 'Creating a Forwarder', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @server = new Server serverOptions, {meshbluConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'when create a forwarder with an invalid forwarder type', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/forwarders'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true
        body:
          forwarderTypeId: "invalid-forwarder-id"
          config:
            name: 'useless forwarder'




      request.post options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 400', ->
      expect(@response.statusCode).to.equal 400

  describe 'when trying to create a forwarder without a forwarderId', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/forwarders'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true
        body:
          config:
            name: 'useless forwarder'




      request.post options, (error, @response, @body) =>
        done error

    it 'should return a 400', ->
      expect(@response.statusCode).to.equal 400
    it 'should tell you that you are missing a forwarderId', ->
      expect(@body.error).to.equal 'Missing Forwarder Id'

  describe 'when creating a forwarder without a config', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/forwarders'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true
        body:
          forwarderTypeId: "splunk-event-collector"





      request.post options, (error, @response, @body) =>
        done error


    it 'should return a 400', ->
      expect(@response.statusCode).to.equal 400

    it 'should tell you that you are missing config', ->
      expect(@body.error).to.equal 'Missing forwarder config'
