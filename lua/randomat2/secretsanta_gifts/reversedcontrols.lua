local GIFT = {}

util.AddNetworkString("RdmtSecretSantaReversedControlsBegin")
util.AddNetworkString("RdmtSecretSantaReversedControlsEnd")

GIFT.Name = "Reversed Controls"
GIFT.Id = "reversedcontrols"

local reversedcontrols_hardmode = CreateConVar("randomat_secretsanta_reversedcontrols_hardmode", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether to swap Jump/Crouch", 0, 1)

local hookIds = {}

local function ReverseControls(ply)
    net.Start("RdmtSecretSantaReversedControlsBegin")
    net.WriteBool(reversedcontrols_hardmode:GetBool())
    net.Send(ply)

    ply:SetLadderClimbSpeed(-200)
end

local function FixControls(ply)
    net.Start("RdmtSecretSantaReversedControlsEnd")
    net.Send(ply)

    ply:SetLadderClimbSpeed(200)
end

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaReversedControls_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    ReverseControls(target)

    hook.Add("PlayerSpawn", hookId .. "_PlayerSpawn", function(ply)
        if not IsValid(ply) or ply ~= target then return end
        ReverseControls(target)
    end)

    hook.Add("PlayerDeath", hookId .. "_PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or victim ~= target then return end
        FixControls(target)
    end)

    -- Override the sprint key so the target player can sprint forward while holding the back key
    hook.Add("TTTSprintKey", hookId .. "_TTTSprintKey", function(ply)
        if ply ~= target then return end

        return IN_BACK
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("PlayerSpawn", hookId .. "_PlayerSpawn")
        hook.Remove("PlayerDeath", hookId .. "_PlayerDeath")
        hook.Remove("TTTSprintKey", hookId .. "_TTTSprintKey")
    end
    table.Empty(hookIds)

    for _, p in player.Iterator() do
        p:SetLadderClimbSpeed(200)
    end

    net.Start("RdmtSecretSantaReversedControlsEnd")
    net.Broadcast()
end

function GIFT:Condition()
    return not Randomat:IsEventActive("opposite")
end

SECRETSANTA:RegisterGift(GIFT, true)
