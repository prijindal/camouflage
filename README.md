- [ ] Message delivery when one of the user is offline

  - [ ] on server
    - [ ] on a new chat message, save message to database
      - from, to, id, encrypted_payload
    - [ ] on received, remove message to database
    - [ ] on user connect
      - [ ] fetch messages for that user, and send them (as "chat" socket message), when they are acknowledged, step 2 will occur
    - [ ] no changes required on client side for this change
    - [ ] abstract the layer for chat db, so that it is easier to replace it with some other database in the future

- [ ] Using peerdart to directly connect two clients

  - [ ] in UI, "Online" status should have another state "Directly connected"
  - [ ] on initial registration, send the peer_id to server
  - [ ] on home page, start listening on peer connection
  - [ ] on user chat page, connect to another peer, make sure to disconnect on dispose
    - [ ] also update the status to "directly connected"
  - [ ] send and receive data based on peer
  - [ ] Create another class/provider for a user connection, this will help organize 2 tier connection

- [ ] making app work, when server is down

- [ ] replace polling based online check for chat page with something better
