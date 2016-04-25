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
The UUID and Token should belong to the user or device that will have subscriptions created on their behalf

### Register Forwarder /register/forwarder PUT
Register a new forwarder with the forwarder options in the body of the request
Input:
_forwarderOptions_ - The forwarder specific device options that need to be set upon registration of the forwarder.
 e.g
````
 {
  "forwarderOptions": {
  "type": "forwarder:mongo",

  "host": "https://computes.io",
  "port": "12341"
  "databaseName": "IoTDB",
  "user": "myuser",
  "password": ""
 }
}
````
Responses:
201 Forwarder successfully created
````
{
  "forwarder": {
    "uuid": "new-forwarder-uuid",
    "type": "forwarder:mongo",
    "host": "https://computes.io",
    "port": "12341"
    "databaseName": "IoTDB",
    "user": "myuser",
    "password": ""
  }
}
````

### Create forwarder message subscriptions for devices /forwarder/:forwarder_uuid/subscribe PUT
Input:
__devices__ - Arr
  - Device UUIDs
  - Forwarder UUID
  - Subscription Type
Remove Message subscriptions from devices
  - Device UUIDs
  - Forwarder UUID
  - Subscription type (Broadcast | Send | Receive)
Add Device Message Subscription (Device UUID, Forwarder UUID, Subscription Type (Broadcast | Send | Receive))
Remove Device message subscription
  - Device UUID
  - Forwarder UUID
