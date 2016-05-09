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
      .get '/v2/whoami'
      .persist()
      .set 'Authorization', "Basic #{@userAuth}"
      .reply 200, uuid: 'some-uuid', token: 'some-token'

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
    context 'when trying to remove a subscription for a device that I cannot modify', ->
      beforeEach (done) ->

        @myEmitterDeviceHandler = @meshblu
          .put '/v2/devices/not-in-the-list-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .send {$pull: {"meshblu.whitelists.broadcast.sent": {uuid: "forwarder-uuid"}}}
          .reply 403

        options =
          uri: "http://localhost:#{@serverPort}/forwarders/forwarder-uuid/subscriptions/not-in-the-list-uuid/broadcast.sent"
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true

        request.delete options, (error, @response) => done error

      it 'should return a 403', ->
        expect(@response.statusCode).to.equal 403

    context 'when trying to remove a subscription for a device that I can configure', ->
      beforeEach 'set up subscription meshblu calls', ->
        @myEmitterDeviceHandler = @meshblu
          .put '/v2/devices/emitter-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .send {$pull: {"meshblu.whitelists.broadcast.sent": {uuid: "forwarder-uuid"}}}
          .reply 204

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

      it 'should update the whitelist', ->
        @myEmitterDeviceHandler.done()

      it 'should create the subscription', ->
        @createSubscriptionHandler.done()

      it 'should return a 201', ->
        expect(@response.statusCode).to.equal 204
