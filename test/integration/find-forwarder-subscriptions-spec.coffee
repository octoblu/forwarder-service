http    = require 'http'
request = require 'request'
shmock  = require 'shmock'
Server  = require '../../src/server'
moment  = require 'moment'
_       = require 'lodash'

describe 'Forwarder Subscriptions-Find', ->
  beforeEach 'setup shmock', (done) ->
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

  context 'asking for a list of subscriptions', ->
    beforeEach 'setup meshblu', (done) ->
      @authDevice = @meshblu
        .get '/v2/devices/forwarder-uuid/subscriptions'
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 200, [
          {emitterUuid: 'e1', type: 'broadcast.sent'}
          {emitterUuid: 'e2', type: 'broadcast.received'}
        ]

      options =
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.get "http://localhost:#{@serverPort}/forwarders/forwarder-uuid/subscriptions", options, (error, response, @body) =>
        done error

    it 'should respond with the list of subscriptions', ->
      expect(@body).to.deep.equal [
        {emitterUuid: 'e1', type: 'broadcast.sent'}
        {emitterUuid: 'e2', type: 'broadcast.received'}
      ]
