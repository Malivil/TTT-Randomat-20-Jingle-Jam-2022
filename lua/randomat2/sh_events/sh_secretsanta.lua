local string = string

local StringStartsWith = string.StartsWith

local function AddServer(fil)
    if SERVER then include(fil) end
end

local function AddClient(fil)
    if SERVER then AddCSLuaFile(fil) end
    if CLIENT then include(fil) end
end

local files, _ = file.Find("randomat2/secretsanta_choices/*.lua", "LUA")
for _, fil in ipairs(files) do
    -- Files that start with "cl_" should be loaded on the client
    if StringStartsWith(fil, "cl_") then
        AddClient("randomat2/secretsanta_choices/" .. fil)
    -- Files that start with "sh_" should be loaded on both the server and the client
    elseif StringStartsWith(fil, "sh_") then
        AddServer("randomat2/secretsanta_choices/" .. fil)
        AddClient("randomat2/secretsanta_choices/" .. fil)
    else
        AddServer("randomat2/secretsanta_choices/" .. fil)
    end
end