local GIFT = {}

util.AddNetworkString("RdmtSecretSantaRandomSensitivityValue")

GIFT.Name = "Random Sensitivity"
GIFT.Id = "randomsensitivity"

local change_interval = CreateConVar("randomat_secretsanta_randomsensitivity_change_interval", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Sensitivity change interval", 5, 60)
local scale_min = CreateConVar("randomat_secretsanta_randomsensitivity_scale_min", 25, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Minimum sensitivity to use", 10, 100)
local scale_max = CreateConVar("randomat_secretsanta_randomsensitivity_scale_max", 500, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Maximum sensitivity to use", 100, 1000)

local timerAndHookIds = {}

local function SetSensitivity(ply, sensitivity)
    net.Start("RdmtSecretSantaRandomSensitivityValue")
    net.WriteFloat(sensitivity)
    net.Send(ply)
end

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local timerAndHookId = "RdmtSecretSantaRandomSensitivity_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(timerAndHookIds, timerAndHookId)

    local interval = change_interval:GetInt()
    local min = scale_min:GetInt()
    local max = scale_max:GetInt()
    timer.Create(timerAndHookId, interval, 0, function()
        -- Stop the timer if this player is gone
        if not IsPlayer(target) then
            timer.Remove(timerAndHookId)
            return
        end

        -- If they are dead, stop the timer and reset their sensitivity
        if not target:Alive() or target:IsSpec() then
            SetSensitivity(target, 0)
            timer.Remove(timerAndHookId)
            return
        end

        local sensitivity = math.random(min, max) / 100
        SetSensitivity(target, sensitivity)
    end)

    -- Reset dead player's sensitivity
    hook.Add("PlayerDeath", timerAndHookId, function(victim, entity, killer)
        if not IsValid(victim) or victim ~= target then return end
        SetSensitivity(target, 0)
    end)
end

function GIFT:CleanUp()
    for _, timerAndHookId in ipairs(timerAndHookIds) do
        timer.Remove(timerAndHookId)
        hook.Remove("PlayerDeath", timerAndHookId)
    end
    table.Empty(timerAndHookIds)

    for _, v in ipairs(player.GetAll()) do
        SetSensitivity(v, 0)
    end
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"change_interval", "scale_min", "scale_max"}) do
        local name = "randomat_secretsanta_" .. self.Id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = self.Id .. "_" .. v,
                dsc = self.Name .. " - " .. convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
end

function GIFT:Condition()
    return not Randomat:IsEventActive("sensitive")
end

SECRETSANTA:RegisterGift(GIFT, true)
