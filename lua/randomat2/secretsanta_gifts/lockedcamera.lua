local GIFT = {}

util.AddNetworkString("RdmtSecretSantaLockedCameraBegin")
util.AddNetworkString("RdmtSecretSantaLockedCameraEnd")

GIFT.Name = "Locked Camera"
GIFT.Id = "lockedcamera"

local timerAndHookIds = {}

local function ResetView(ply)
    local angles = ply:EyeAngles()
    angles.pitch = 0
    ply:SetEyeAngles(angles)
end

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local timerAndHookId = "RdmtSecretSantaLockedCamera_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(timerAndHookIds, timerAndHookId)

    ResetView(target)
    net.Start("RdmtSecretSantaLockedCameraBegin")
    net.Send(target)

    timer.Create(timerAndHookId, 1, 0, function()
        -- Stop the timer if this player is gone or dead
        if not IsPlayer(target) or not target:Alive() or target:IsSpec() then
            timer.Remove(timerAndHookId)
            return
        end

        ResetView(target)
    end)

    hook.Add("PlayerSpawn", timerAndHookId, function(ply)
        if ply ~= target then return end

        timer.Simple(1, function()
            if not IsPlayer(target) or not target:Alive() or target:IsSpec() then return end
            ResetView(target)
        end)
    end)
end

function GIFT:CleanUp()
    for _, timerAndHookId in ipairs(timerAndHookIds) do
        timer.Remove(timerAndHookId)
        hook.Remove("PlayerSpawn", timerAndHookId)
    end
    table.Empty(timerAndHookIds)

    net.Start("RdmtSecretSantaLockedCameraEnd")
    net.Broadcast()
end

SECRETSANTA:RegisterGift(GIFT, true)