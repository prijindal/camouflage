- [ ] Using peerdart to directly connect two clients

  - [ ] POC first

  - [ ] in UI, "Online" status should have another state "Directly connected"
  - [ ] on initial registration, send the peer_id to server
  - [ ] on home page, start listening on peer connection
  - [ ] on user chat page, connect to another peer, make sure to disconnect on dispose
    - [ ] also update the status to "directly connected"
  - [ ] send and receive data based on peer
  - [ ] Create another class/provider for a user connection, this will help organize 2 tier connection

- [ ] making app work, when server is down

- [ ] replace polling based online check for chat page with something better

- [ ] UI improvements

  - [ ] register and new chat page
  - [x] sending images
  - [ ] on chat page, after every interval, check for unread messages, and mark them as read
  - [ ] border and padding on images
  - [ ] saving images, sharing images, forwarding texts
  - [ ] click on image to view in fullscreen with zoom
