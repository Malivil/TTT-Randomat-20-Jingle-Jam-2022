local CHOICE = {}

CHOICE.Name = "Extra Life"
CHOICE.Id = "extralife"

local hookIds = {}
local timerIds = {}

function CHOICE:Choose(owner, target)
    target:SetNWBool("RdmtSecretSantaExtraLife", true)

    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaExtraLife_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("PlayerDeath", hookId .. "_PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or target ~= victim or not victim:GetNWBool("RdmtSecretSantaExtraLife", false) then return end

        local timerId = "RdmtSecretSantaExtraLifeTimer_" .. owner:SteamID64() .. "_" .. target:SteamID64()
        table.insert(timerIds, timerId)

        timer.Create(timerId, 0.25, 1, function()
            victim:SpawnForRound(true)
            local body = victim.server_ragdoll or victim:GetRagdollEntity()
            if IsValid(body) then
                body:Remove()
            end
            victim:PrintMessage(HUD_PRINTTALK, "You have been respawned with your extra life!")
            victim:PrintMessage(HUD_PRINTCENTER, "You have been respawned with your extra life!")
            target:SetNWBool("RdmtSecretSantaExtraLife", false)
        end)
    end)

    hook.Add("TTTDeathNotifyOverride", hookId .. "_TTTDeathNotifyOverride", function(victim, inflictor, attacker, reason, killerName, role)
        if not IsPlayer(victim) or target ~= victim or not target:GetNWBool("RdmtSecretSantaExtraLife", false) then return end
        if reason ~= "ply" then return end

        return reason, killerName, ROLE_NONE
    end)
end

function CHOICE:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("PlayerDeath", hookId .. "_PlayerDeath")
        hook.Remove("TTTDeathNotifyOverride", hookId .. "_TTTDeathNotifyOverride")
    end
    table.Empty(hookIds)

    for _, timerId in ipairs(timerIds) do
        timer.Remove(timerId)
    end
    table.Empty(timerIds)

    for _, p in ipairs(player.GetAll()) do
        p:SetNWBool("RdmtSecretSantaExtraLife", false)
    end
end

SECRETSANTA:RegisterChoice(CHOICE)