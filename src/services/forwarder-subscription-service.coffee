MeshbluHttp = require 'meshblu-http'
{Validator} =require 'jsonschema'
forwarderTypes = require '../forwarder-types/forwarder-types'
_ = require 'lodash'

class ForwarderSubscriptionService
  constructor: (@meshbluOptions)->
    console.log "Meshblu Options", @meshbluOptions
    @validator = new Validator()

  _getForwarderDeviceOptions: (forwarderType, forwarderConfig, meshbluAuth ) =>
    forwarderTypeOptions =
      connector: forwarderType.connector
      forwarderTypeId: forwarderType.forwarderTypeId
      logoUrl: forwarderType.logoUrl
      owner: meshbluAuth.uuid
      type: forwarderType.deviceType
      schemas: forwarderType.schemas
      online: true
      forwarderSubscriptions:{}
      meshblu:
        version: "2.0.0"
        whitelists:
          discover:
            view: [{uuid: meshbluAuth.uuid}]
          broadcast:
            sent: [{uuid: meshbluAuth.uuid}]
          configure:
            sent: [{uuid: meshbluAuth.uuid}]
            update: [{uuid: meshbluAuth.uuid}]
          message:
            from: [{uuid: meshbluAuth.uuid}]

    forwarderDeviceOptions = _.assign {},forwarderConfig,forwarderTypeOptions
    console.log "ForwarderTypeOptions", forwarderDeviceOptions
    return forwarderDeviceOptions

  createForwarder: ( forwarderType, forwarderConfig, meshbluAuth,  callback) =>

    configureSchema = forwarderType.schemas?.configure
    validationResult = @validator.validate forwarderConfig, configureSchema
    return callback @_createError(400, "Could not validate config against forwarder type configure schema") unless _.isEmpty validationResult.errors
    {uuid, token} = meshbluAuth
    meshbluConfig = _.assign @meshbluOptions, {uuid, token}
    meshbluHttp = new MeshbluHttp meshbluConfig

    forwarderDeviceOptions = @_getForwarderDeviceOptions(forwarderType, forwarderConfig, meshbluAuth)
    console.log "ForwarderDeviceOptions",  forwarderDeviceOptions
    meshbluHttp.register forwarderDeviceOptions, (error, createdForwarder) =>
      console.error('error', error)
      return callback(@_createError 500, error.message )if error
      return callback(null, createdForwarder)

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ForwarderSubscriptionService
