http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Get forwarders', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d
      protocol: 'http'

    @server = new Server serverOptions, {meshbluConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'when there are no forwarders', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'
      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      @myDeviceHandler = @meshblu
        .get '/v2/devices'
        .query {owner: "some-uuid"}
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, {devices:[]}

      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true


      request.get "http://localhost:#{@serverPort}/forwarders", options, (error, @response, @body) =>
        done error

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should fetch the devices from meshblu', ->
      @myDeviceHandler.done()

    it 'should return no an empty list', ->
      expect(@body).to.deep.equal([])
