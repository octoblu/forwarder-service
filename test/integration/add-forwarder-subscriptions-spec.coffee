http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

xdescribe 'Adding Forwarder Subscriptions', ->
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

  describe 'Add a message.sent subscription', ->
    context 'when trying to add a subscription for a device with a UUID NOT in my list of devices', ->
      beforeEach (done) ->
        @forwarder =
          uuid: "forwarder-uuid"
          type: "forwarder:mongodb"
          forwarders: {
            version: "1.0.0"
            subscriptions: {
              message:
                sent: [uuid: 'blink-1-uuid']
            }
          }
        @myEmitterDeviceHandler = @meshblu
          .get '/v2/devices/not-in-the-list-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .reply 404
        @myForwarderDeviceHandler = @meshblu
          .get '/v2/devices/forwarder-uuid'
          .set 'Authorization', "Basic #{@userAuth}"
          .reply 200, {devices: [@forwarder]}

        options =
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true
          body:
            subscriptions:
              message:
                sent: [uuid: 'not-in-the-list-uuid']

        request.put "http://localhost:#{@serverPort}/forwarders/forwarder-uuid/subscriptions",options,
          (error, @response, @body) =>
            done error

      it 'should return a 400', ->
        expect(@response.statusCode).to.equal 400

      it 'should return an error message saying that the UUID is not in the list of owned devices', ->
        expect (@body.error).to.equal "UUID is not in the list of owned devices"

    xcontext 'when trying to add a subscription for a device with a UUID in my list of devices', ->
      it 'should add the subscription', ->
      it 'should return a 201', ->
      it 'return the map of forwarder subsciptions', ->
    xcontext 'when trying to add a duplicate subscription for a device that already has a subscription', ->
      it 'should add the subscription', ->
      it 'should return a 200', ->
      it 'return the map of forwarder subsciptions', ->


  xdescribe 'Add a message.received subscription', ->
    context 'when trying to add a subscription for a device with a UUID NOT in my list of devices', ->
    context 'when trying to add a subscription for a device with a UUID in my list of devices', ->

  xdescribe 'Add a broadcast.sent subscription', ->
    context 'when trying to add a subscription for a device with a UUID NOT in my list of devices', ->
    context 'when trying to add a subscription for a device with a UUID in my list of devices', ->
