local enet = require "enet"

local host = enet.host_create("localhost:7777")
if host then
    print("Success creating host!")    
end

while true do
    event = host:service(100)
    while event do
        if event.type == "connect" then
            print("message received", event.data, "from", event.peer)
        elseif event.type == "connect" then
            print(event.peer, "connected.")
            event.peer:send( "ping" )
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
    end
end