local hookIds = {}

net.Receive("RdmtSecretSantaCrabWalkBegin", function()
    local target = net.ReadString()
    local owner = net.ReadString()

    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaCrabWalk_" .. owner .. "_" .. target
    table.insert(hookIds, hookId)

    hook.Add("StartCommand", hookId, function(ply, CUserCmd)
        if ply:Alive() and not ply:IsSpec() and ply:SteamID64() == target then
            CUserCmd:SetForwardMove(0)
        end
    end)
end)

net.Receive("RdmtSecretSantaCrabWalkEnd", function()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("StartCommand", hookId)
    end
    table.Empty(hookIds)
end)