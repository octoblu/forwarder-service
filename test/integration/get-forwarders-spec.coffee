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

  beforeEach ->
    @deviceQuery =
      type:
        $regex: "^forwarder"

  describe 'when there are no devices', ->
    beforeEach (done) ->
      @myDeviceHandler = @meshblu
        .post '/search/devices'
        .set 'Authorization', "Basic #{@userAuth}"
        .send @deviceQuery
        .reply 200, []

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

  describe 'when the octoblu user has forwarders in the list of owned devices', ->
    beforeEach (done) ->
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
        .post '/search/devices'
        .set 'Authorization', "Basic #{@userAuth}"
        .send @deviceQuery
        .reply 200, @forwarders

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
