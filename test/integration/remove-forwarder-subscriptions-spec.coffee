http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Remove Forwarder Subscriptions', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    @userAuth = new Buffer('some-uuid:some-token').toString 'base64'
    @authDevice = @meshblu
      .post '/authenticate'
      .persist()
      .set 'Authorization', "Basic #{@userAuth}"
      .reply 200

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

  describe 'Remove a broadcast subscription', ->
    context 'when trying to remove a subscription for a device that I can configure', ->
      beforeEach 'set up subscription meshblu calls', ->
        @createSubscriptionHandler = @meshblu
          .delete '/v2/devices/forwarder-uuid/subscriptions/emitter-uuid/broadcast.sent'
          .set 'Authorization', "Basic #{@userAuth}"
          .send()
          .reply 201

      beforeEach 'make the call', (done) ->
        options =
          uri: "http://localhost:#{@serverPort}/forwarders/forwarder-uuid/subscriptions/emitter-uuid/broadcast.sent"
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true

        request.delete options, (error, @response) => done error

      it 'should create the subscription', ->
        @createSubscriptionHandler.done()

      it 'should return a 201', ->
        expect(@response.statusCode).to.equal 204
