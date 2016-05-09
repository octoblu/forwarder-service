#Forwarder Subscription Service

This micro-service registers forwarder devices and can setup device message subscriptions on
behalf of the device owner.

## What are Forwarders?
Forwarders are devices that receive messages intended for other devices and forward the messages received
somewhere else - like a datastore or another messaging platform. They allow you to spy on messages sent, received or broadcast to or from your devices to another endpoint.

## Forwarder Subscription API
All APIs should have the following fields in the header of the HTTP request
````
meshblu_auth_uuid
meshblu_auth_token
````
The Uuid and Token should belong to the user or device that will have subscriptions created on their behalf
### Get Forwarder Types /types GET
Get the list of forwarder types.

### Get all forwarders /forwarders GET
Returns the list of forwarders that the authorized user owns

response ```200``` with the list of forwarders

### Get Forwarder Subscriptions /forwarders/:uuid/subscriptions
#### Parameters:
**uuid** - The forwarder meshblu uuid

#### Response:
Returns the list of devices that the forwarder is subscribed to

### Add Forwarder Subscription /forwarders/:forwarderUuid/subscriptions/:emitterUuid/:type POST
#### Parameters:
**forwarderUuid** - The meshblu uuid of the forwarder device
**emitterUuid** - The meshblu uuid of the device we would like the forwarder to subscribe to
**type** - The type of message subscription. Valid types are [message.sent, message.received, broadcast.sent]

#### Response:
204 - The subscription was sucessfully created if the owner can update the forwarder and emitter devices
403 - The authorized owner cannot update either the forwarder or emitter device.

### Remove Forwarder subscriptions /forwarders/:forwarderUuid/subscriptions/:emitterUuid/:type DELETE
**forwarderUuid** - The meshblu uuid of the forwarder device
**emitterUuid** - The meshblu uuid of the device we would like the forwarder to subscribe to
**type** - The type of message subscription. Valid types are [message.sent, message.received, broadcast.sent]

#### Response:
204 - The subscription was sucessfully removed if the owner can update the forwarder and emitter devices
403 - The authorized owner cannot update either the forwarder or emitter device.
