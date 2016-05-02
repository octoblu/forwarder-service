cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuth        = require 'express-meshblu-auth'
MeshbluConfig      = require 'meshblu-config'
debug              = require('debug')('forwarder-subscription-service:server')
Router             = require './router'
ForwarderSubscriptionService = require './services/forwarder-subscription-service'

class Server
  constructor: ({@disableLogging, @port}, {@meshbluConfig})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()

  address: =>
    @server.address()

  run: (callback) =>
    {server, port, protocol} = @meshbluConfig
    console.log "Meshblu Config from server", @meshbluConfig
    meshbluAuth = new MeshbluAuth {server, port, protocol}

    app = express()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluHealthcheck()
    app.use meshbluAuth.retrieve()
    app.use meshbluAuth.gateway()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    forwarderSubscriptionService = new ForwarderSubscriptionService {server, port, protocol }
    router = new Router {@meshbluConfig, forwarderSubscriptionService}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
