cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
OctobluRaven       = require 'octoblu-raven'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuth        = require 'express-meshblu-auth'
expressVersion     = require 'express-package-version'
MeshbluConfig      = require 'meshblu-config'
enableDestroy      = require 'server-destroy'
debug              = require('debug')('forwarder-subscription-service:server')
Router             = require './router'
ForwarderSubscriptionService = require './services/forwarder-subscription-service'

class Server
  constructor: ({@disableLogging, @port, @octobluRaven}, {@meshbluConfig})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()
    @octobluRaven ?= new OctobluRaven()

  address: =>
    @server.address()

  run: (callback) =>
    {server, port, protocol} = @meshbluConfig
    meshbluAuth = new MeshbluAuth {server, port, protocol}

    app = express()
    app.use @octobluRaven.express().handleErrors()
    app.use meshbluHealthcheck()
    app.use expressVersion({format: '{"version": "%s"}'})
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use meshbluAuth.retrieve()
    app.use meshbluAuth.gateway()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    forwarderSubscriptionService = new ForwarderSubscriptionService {server, port, protocol }
    router = new Router {@meshbluConfig, forwarderSubscriptionService}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
