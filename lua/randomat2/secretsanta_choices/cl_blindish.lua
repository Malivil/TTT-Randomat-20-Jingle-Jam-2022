local hookIds = {}

local function IsTargetHighlighted(ply, target)
    return ply.IsTargetHighlighted and ply:IsTargetHighlighted(target)
end

net.Receive("RdmtSecretSantaBlindishBegin", function()
    local target = net.ReadString()
    local owner = net.ReadString()

    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaBlindish_" .. owner .. "_" .. target
    table.insert(hookIds, hookId)

    local client = LocalPlayer()
    hook.Add("PreDrawHalos", hookId, function()
        if client:SteamID64() ~= target then return end

        local alivePlys = {}
        for k, v in ipairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() and not IsTargetHighlighted(client, v) then
                alivePlys[k] = v
            end
        end

        halo.Add(alivePlys, Color(255,0,0), 0, 0, 1, true, true)
    end)
end)

net.Receive("RdmtSecretSantaBlindishEnd", function()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("PreDrawHalos", hookId)
    end
    table.Empty(hookIds)
end)