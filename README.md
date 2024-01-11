- [ ] Requirements

- User will enter a username

  - A new user will be created using this username with a randomly generated key as master_key
  - hash this master_key on frontend to obtain a master_hash which get sent to the server
  - hash this master_key in a seperate way to obtain a encryption_key which will be use to do encryption

- one ecdh public and private keys will be generated
- encryption_key will be used to encrypt private key for above
- public_key is sent to the server

- once a user sends a chat to the user, they send their public key and an encrypted message

  - this encryption is done by using ecdh of self.private_key + receiver.public_key
  - the receiver will be able to use their private key + sender.public_key to unencrypt

- on client, these things will be stored

  - username
  - auth token
  - encryption_key
  - ecdh public_keys, private_keys
  - chat history
    - sender username, public_key
    - encrypted messages

- server side implementation

  - /login (receive username, master_hash, public_key)
    - creates an entry in user table with an auth token
    - returns auth token
  - /user/:username
    - POST
      - parameters: username
      - returns that user's public_key
      - 404 if user not found
  - socket messages
    - type: "chat"
      - parameters: username, message_id, timestamp, encrypted_payload
      - sends that encrypted_payload to username
      - encrypted_payload: {
        type: "text",
        body: "Hello"
        } or {
        type: "image",
        body: "base64 of image"
        }
    - type: "received"
      - parameters: username, timestamp, message_id
    - type: "read"
      - parameters: username, timestamp, message_id

- on frontend
  - [x] check if server is up on app launch using health api
  - [x] check if user is valid using /me api
  - [ ] add chat window and server websocket API to establish connection
