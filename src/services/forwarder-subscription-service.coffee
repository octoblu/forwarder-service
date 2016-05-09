MeshbluHttp = require 'meshblu-http'
{Validator} =require 'jsonschema'
forwarderTypes = require '../forwarder-types/forwarder-types'
_ = require 'lodash'

class ForwarderSubscriptionService
  constructor: (@meshbluOptions)->
    @validator = new Validator()

  _getForwarderDeviceOptions: (forwarderType, forwarderConfig, meshbluAuth ) ->
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
    return forwarderDeviceOptions

  createForwarder: ( forwarderType, forwarderConfig, meshbluAuth,  callback) =>

    configureSchema = forwarderType.schemas?.configure
    validationResult = @validator.validate forwarderConfig, configureSchema
    return callback @_createError(400, "Could not validate config against forwarder type configure schema") unless _.isEmpty validationResult.errors
    {uuid, token} = meshbluAuth
    meshbluConfig = _.assign @meshbluOptions, {uuid, token}
    meshbluHttp = new MeshbluHttp meshbluConfig

    forwarderDeviceOptions = @_getForwarderDeviceOptions(forwarderType, forwarderConfig, meshbluAuth)
    meshbluHttp.register forwarderDeviceOptions, (error, createdForwarder) =>
      return callback(@_createError 500, error.message )if error
      return callback(null, createdForwarder)

  deleteForwarder: ({uuid, token}, forwarderUuid, callback)=>
    meshbluConfig = _.assign @meshbluOptions, {uuid, token}
    meshbluHttp = new MeshbluHttp meshbluConfig
    meshbluHttp.device forwarderUuid, (error, deviceResults) =>
      return callback(@_createError 404, "Forwarder not found" ) if error?
      return callback(@_createError 404, "Forwarder not found" ) unless deviceResults
      meshbluHttp.unregister {uuid: forwarderUuid}, (error, deviceResult) =>
        return callback(@_createError 500, "Could not delete forwarder" ) if error?
        callback null, deviceResult

  getForwarders:({uuid, token}, callback) =>
    meshbluConfig = _.assign @meshbluOptions, {uuid, token}
    meshbluHttp = new MeshbluHttp meshbluConfig
    query =
      owner: uuid
      $exists:
        forwarder: true

    meshbluHttp.search query, {}, callback

  getForwarderSubscriptions:(meshbluAuth, forwarderUuid,  callback ) =>

  addForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>
    meshbluConfig = _.assign @meshbluOptions, meshbluAuth
    meshbluHttp = new MeshbluHttp meshbluConfig
    update =
      $addToSet:
        "meshblu.whitelists.#{type}": {uuid: forwarderUuid}

    meshbluHttp.updateDangerously emitterUuid, update, (error) =>
      return callback(@_createError 403, "Cannot modify #{emitterUuid}" ) if error?

      meshbluHttp.createSubscription {
        subscriberUuid: forwarderUuid
        emitterUuid: emitterUuid
        type: type
      }, callback

  removeForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>
    meshbluConfig = _.assign @meshbluOptions, meshbluAuth
    meshbluHttp = new MeshbluHttp meshbluConfig
    update =
      $pull:
        "meshblu.whitelists.#{type}": {uuid: forwarderUuid}

    meshbluHttp.updateDangerously emitterUuid, update, (error) =>
      return callback(@_createError 403, "Cannot modify #{emitterUuid}" ) if error?

      meshbluHttp.deleteSubscription {
        subscriberUuid: forwarderUuid
        emitterUuid: emitterUuid
        type: type
      }, callback

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ForwarderSubscriptionService
