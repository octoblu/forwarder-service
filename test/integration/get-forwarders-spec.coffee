http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Get forwarders', ->
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

  describe 'when there are no devices', ->
    beforeEach (done) ->

      @myDeviceHandler = @meshblu
        .get '/v2/devices'
        .query {owner: "some-uuid"}
        .set 'Authorization', "Basic #{@userAuth}"
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

  describe 'when the octoblu user has no forwarders in the list of owned devices', ->
    beforeEach (done) ->
      @mydevices = [
        {
          name: "Device 1"
          uuid: "device-1-uuid"
          token: "device-1-token"
          type: "device:1"
          owner: "some-uuid"
        },
        {
          name: "Device 2"
          uuid: "device-2-uuid"
          token: "device-2-token"
          type: "device:2"
          owner: "some-uuid"
        },
        {
          name: "Device 3"
          uuid: "device-3-uuid"
          token: "device-3-token"
          type: "device:3"
          owner: "some-uuid"
        },
        {
          name: "Device 4"
          uuid: "device-4-uuid"
          token: "device-4-token"
          type: "device:4"
          owner: "some-uuid"
        }
      ]
      @myDeviceHandler = @meshblu
        .get '/v2/devices'
        .query {owner: "some-uuid"}
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 200, {devices:@mydevices}

      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true


      request.get "http://localhost:#{@serverPort}/forwarders", options, (error, @response, @body) =>
        done error

    it 'should fetch the devices from meshblu', ->
      @myDeviceHandler.done()

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should return an empty list of forwarders', ->
      expect(@body).to.deep.equal []

  describe 'when the octoblu user has forwarders in the list of owned devices', ->
    beforeEach (done) ->
      @mydevices = [
        {
          name: "Device 1"
          uuid: "device-1-uuid"
          token: "device-1-token"
          type: "device:1"
          owner: "some-uuid"
        },
        {
          name: "Device 2"
          uuid: "device-2-uuid"
          token: "device-2-token"
          type: "device:2"
          owner: "some-uuid"
        },
        {
          name: "Splunk Forwarder"
          uuid: "forwarder-splunk-uuid"
          token: "forwarder-splunk-token"
          type: "forwarder:splunk"
          owner: "some-uuid"
        },
        {
          name: "Elastic Search Forwarder"
          uuid: "forwarder-elasticsearch-uuid"
          token: "forwarder-elasticsearch-token"
          type: "forwarder:elasticsearch"
          owner: "some-uuid"
        }
      ]

      @forwarders = [{
        name: "Splunk Forwarder"
        uuid: "forwarder-splunk-uuid"
        token: "forwarder-splunk-token"
        type: "forwarder:splunk"
        owner: "some-uuid"
      },
      {
        name: "Elastic Search Forwarder"
        uuid: "forwarder-elasticsearch-uuid"
        token: "forwarder-elasticsearch-token"
        type: "forwarder:elasticsearch"
        owner: "some-uuid"
      }]

      @myDeviceHandler = @meshblu
        .get '/v2/devices'
        .query {owner: "some-uuid"}
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 200, {devices: @mydevices}

        options =
          auth:
            username: 'some-uuid'
            password: 'some-token'
          json: true


        request.get "http://localhost:#{@serverPort}/forwarders", options, (error, @response, @body) =>
          done error
    it 'should fetch the devices from meshblu', ->
      @myDeviceHandler.done()

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

    it 'should return the list of forwarders', ->
      expect(@body.length).to.equal 2
      expect(@body).to.deep.equal @forwarders
