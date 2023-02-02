local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaFlipScreenBegin")
util.AddNetworkString("RdmtSecretSantaFlipScreenEnd")

CHOICE.Name = "Flipped Screen"
CHOICE.Id = "flipscreen"

local hookIds = {}

function CHOICE:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaFlipScreen_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("SetupMove", hookId, function(ply, mv, cmd)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() or ply ~= target then return end

        local sidespeed = mv:GetSideSpeed()
        mv:SetSideSpeed(-sidespeed)
    end)

    net.Start("RdmtSecretSantaFlipScreenBegin")
    net.Send(target)
end

function CHOICE:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("SetupMove", hookId)
    end
    table.Empty(hookIds)

    net.Start("RdmtSecretSantaFlipScreenEnd")
    net.Broadcast()
end

function CHOICE:Condition()
    return not Randomat:IsEventActive("downunder")
end

SECRETSANTA:RegisterChoice(CHOICE, true)
