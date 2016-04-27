MeshbluHttp = require 'meshblu-http'
{Validator} =require 'jsonschema'
forwarderTypes = require '../forwarder-types/forwarder-types'
_ = require 'lodash'

class ForwarderSubscriptionService
  constructor: ({@meshbluOptions})->
    @validator = new Validator()


  createForwarder: ( forwarderType, forwarderConfig, meshbluAuth,  callback) =>

    configureSchema = forwarderType.schemas?.configure
    validationResult = @validator.validate forwarderConfig, configureSchema
    return callback @_createError(400, "Could not validate config against forwarder type configure schema") unless _.isEmpty result.errors
    {uuid, token} = meshbluAuth
    meshbluConfig = _.assign @meshbluOptions, {uuid, token}
    meshbluHttp = new MeshbluHttp meshbluConfig

    forwarderDeviceOptions = _getForwarderDeviceOptions(forwarderConfig, forwarderType)
    meshbluHttp.register config, (error, createdForwarder) =>
      return callback(@_createError 500, error.message )if error
      return callback(null, createdForwarder)

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ForwarderSubscriptionService
