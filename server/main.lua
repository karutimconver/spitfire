local enet = require "enet"

local host = enet.host_create("*:6750")
if host then
    print("Success creating host!")
end

while true do
    local event = host:service(100)
    while event do
        if event.type == "receive" then
            print("message received" .. event.data)
        elseif event.type == "connect" then
            print(event.peer, "connected.")
            event.peer:send( "ping" )
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = host:service(0)
    end
end