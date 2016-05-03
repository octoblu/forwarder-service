http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Creating a Forwarder', ->
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
          configuration:
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
          configuration:
            name: 'useless forwarder'

      request.post options, (error, @response, @body) =>
        done error

    it 'should return a 400', ->
      expect(@response.statusCode).to.equal 400
    it 'should tell you that you are missing a forwarderId', ->
      expect(@body.error).to.equal 'Missing Forwarder Type Id'

  describe 'when creating a forwarder without a configuration', ->
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

    it 'should tell you that you are missing configuration', ->
      expect(@body.error).to.equal 'Missing forwarder configuration'

  describe 'when creating a forwarder with valid config options', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString('base64')
      registerDeviceOptions =
        name: "My new forwarder"
        EventCollectorToken: "1231231231"
        SplunkEventUrl: "https://hello.splunk.io"
        owner: "some-uuid"
        connector: "meshblu-forwarder-splunk"
        forwarderTypeId: "meshblu-forwarder-splunk"
        type: "forwarder:splunk"
        schemas:
          version: '1.0.0'
          configure:
            type: 'object'
            properties:
              EventCollectorToken:
                title: 'Event Collector Token'
                type: 'string'
                required: true
              SplunkEventUrl:
                title: 'Splunk Event URL'
                type: 'string'
                required: true
        forwarderSubscriptions:{}
        online: true
        logoUrl: "https://s3-us-west-2.amazonaws.com/octoblu-icons/channel/splunk.svg"
        meshblu:
          version: "2.0.0"
          whitelists:
            discover:
              view: [{uuid: "some-uuid"}]
            broadcast:
              sent: [{uuid: "some-uuid"}]
            configure:
              sent: [{uuid: "some-uuid"}]
              update: [{uuid: "some-uuid"}]
            message:
              from: [{uuid: "some-uuid"}]

      @registeredDevice = _.assign {}, {
        uuid: "forwarder-1234"
        token: "my-forwarder-token"
        },
        registerDeviceOptions
      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      @registerDeviceHandler = @meshblu.post '/devices'
        .set 'Authorization', "Basic #{userAuth}"
        .send registerDeviceOptions
        .reply 201, @registeredDevice

      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true
        body:
          forwarderTypeId: "meshblu-forwarder-splunk"
          configuration:
            name: "My new forwarder"
            EventCollectorToken: "1231231231"
            SplunkEventUrl: "https://hello.splunk.io"

      request.post "http://localhost:#{@serverPort}/forwarders", options, (error, @response, @body) =>
        done(error)

    it 'should return a 201 with the created forwarder', ->
      expect(@response.statusCode).to.equal 201

    it 'should register the device with meshblu',  ->
      expect(@registerDeviceHandler.isDone).to.equal true

    it 'should set the body to the registered device', ->
      expect(@body).to.deep.equal(@registeredDevice)
