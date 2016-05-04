http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Delete Forwarder', ->
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

  describe 'when given a blank UUID', ->
    beforeEach (done) ->
      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'

      request.delete "http://localhost:#{@serverPort}/forwarders", options, (error, @response, @body) =>
        done error

    it 'should return a 400', ->
      expect(@response.statusCode).to.equal 404

    # it 'should tell you that you that the forwarder UUID is missing', ->
    #   expect(@body.error).to.equal 'Missing Forwarder UUID'

  describe 'when given an invalid UUID that is does not belong to one of my devices', ->
    beforeEach (done) ->
      @myDeviceHandler = @meshblu
        .get '/v2/devices/invalid-forwarder-uuid'
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 404

      options =
        json:true
        auth:
          username: 'some-uuid'
          password: 'some-token'

      request.delete "http://localhost:#{@serverPort}/forwarders/invalid-forwarder-uuid", options, (error, @response, @body) =>
        done error
    it 'should try to find the device in meshblu',(done) ->
      @myDeviceHandler.done()
      done()

    it 'should return a 404', ->
      expect(@response.statusCode).to.equal 404

    it 'should tell you that your Forwarder could not be found', ->
      console.log "Body", @body
      expect(@body.error).to.equal 'Forwarder not found'

  describe 'when given a valid Forwarder UUID', ->
    beforeEach (done) ->
      @myDeviceHandler = @meshblu
        .get '/v2/devices/forwarder-elasticsearch-uuid'
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 200, {devices: [
          name: "Elastic Search Forwarder"
          uuid: "forwarder-elasticsearch-uuid"
          token: "forwarder-elasticsearch-token"
          type: "forwarder:elasticsearch"
          owner: "some-uuid"
        ]}
      @deleteResult = {uuid: 'forwarder-elasticsearch-uuid', timestamp: moment.utc().valueOf()}
      @myDeviceHandler = @meshblu
        .delete '/devices/forwarder-elasticsearch-uuid'
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 200, @deleteResult
      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.delete "http://localhost:#{@serverPort}/forwarders/forwarder-elasticsearch-uuid", options, (error, @response, @body) =>
        done()

    it 'should return a 200',(done) ->
      expect(@response.statusCode).to.equal 200
      done()

    it 'should return the deleted uuid and the time it was deleted',->
      expect(@body).to.deep.equal @deleteResult
