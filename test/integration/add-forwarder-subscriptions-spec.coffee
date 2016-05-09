http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Adding Forwarder Subscriptions', ->
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

  describe 'Add a broadcast subscription', ->
    context 'when trying to add a subscription for a device that I cannot modify', ->
      beforeEach (done) ->
        @forwarder =
          uuid: "forwarder-uuid"
          type: "forwarder:mongodb"

        @myEmitterDeviceHandler = @meshblu
          .put '/v2/devices/not-in-the-list-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .send {$addToSet: {"meshblu.whitelists.broadcast.sent": {uuid: "forwarder-uuid"}}}
          .reply 403

        options =
          url: "http://localhost:#{@serverPort}/forwarders/forwarder-uuid/subscriptions/not-in-the-list-uuid/broadcast.sent"
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true

        request.post options, (error, @response, @body) => done error

      it 'should return a 403', ->
        expect(@response.statusCode).to.equal 403

      it 'should return an error message saying that the Uuid is not in the list of owned devices', ->
        expect(@body.error).to.equal "Cannot modify not-in-the-list-uuid"

    context 'when trying to add a subscription for a device that I can configure', ->
      beforeEach 'set up subscription meshblu calls', ->
        @myEmitterDeviceHandler = @meshblu
          .put '/v2/devices/emitter-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .send {$addToSet: {"meshblu.whitelists.broadcast.sent": {uuid: "forwarder-uuid"}}}
          .reply 204

        @createSubscriptionHandler = @meshblu
          .post '/v2/devices/forwarder-uuid/subscriptions/emitter-uuid/broadcast.sent'
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

        request.post options, (error, @response) => done()

      it 'should update the whitelist', ->
        @myEmitterDeviceHandler.done()

      it 'should create the subscription', ->
        @createSubscriptionHandler.done()

      it 'should return a 201', ->
        expect(@response.statusCode).to.equal 201
