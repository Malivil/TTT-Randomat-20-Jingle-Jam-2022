local function AddServer(fil)
    if SERVER then include(fil) end
end

local function AddClient(fil)
    if SERVER then AddCSLuaFile(fil) end
    if CLIENT then include(fil) end
end

local serverFiles, _ = file.Find("randomat2/secretsanta_gifts/*.lua", "LUA")
for _, fil in ipairs(serverFiles) do
    AddServer("randomat2/secretsanta_gifts/" .. fil)
end

local clientFiles, _ = file.Find("randomat2/secretsanta_gifts/client/*.lua", "LUA")
for _, fil in ipairs(clientFiles) do
    AddClient("randomat2/secretsanta_gifts/client/" .. fil)
end

local sharedFiles, _ = file.Find("randomat2/secretsanta_gifts/shared/*.lua", "LUA")
for _, fil in ipairs(sharedFiles) do
    AddServer("randomat2/secretsanta_gifts/shared/" .. fil)
    AddClient("randomat2/secretsanta_gifts/shared/" .. fil)
end