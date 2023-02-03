local GIFT = {}

util.AddNetworkString("RdmtSecretSantaChangedFOVBegin")

GIFT.Name = "Changed FOV"
GIFT.Id = "changedfov"

local fov_scale = CreateConVar("randomat_secretsanta_changedfov_scale", 1.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "FOV increase scale", 1.1, 2.0)
local fov_scale_ironsight = CreateConVar("randomat_secretsanta_changedfov_scale_ironsight", 1.0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Ironsighted FOV increase scale", 0.8, 2.0)

local timerIds = {}
local originalFOV = {}

local function PlayerInIronsights(ply)
    if not ply.GetActiveWeapon then return false end
    local weap = ply:GetActiveWeapon()
    return IsValid(weap) and weap.GetIronsights and weap:GetIronsights()
end

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local timerId = "RdmtSecretSantaChangedFOV_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(timerIds, timerId)

    if PlayerInIronsights(target) then
        target:GetActiveWeapon():SetIronsights(false)
        target:SetFOV(0, 0)
    end
    net.Start("RdmtSecretSantaChangedFOVBegin")
    net.Send(target)

    local scale = fov_scale:GetFloat()
    local scaleIronsight = fov_scale_ironsight:GetFloat()
    timer.Create(timerId, 0.1, 0, function()
        -- Stop the timer if this player is gone
        if not IsPlayer(target) then
            timer.Remove(timerId)
            return
        end

        -- If they are dead, stop the timer and reset their FOV
        if not target:Alive() or target:IsSpec() then
            target:SetFOV(0, 0)
            timer.Remove(timerId)
            return
        end

        local fovScale
        if PlayerInIronsights(target) then
            fovScale = scaleIronsight
        else
            fovScale = scale
        end

        -- Save the player's scaled FOV the first time we see them
        if originalFOV[target:SteamID64()] == nil then
            originalFOV[target:SteamID64()] = target:GetFOV()
        end

        target:SetFOV(originalFOV[target:SteamID64()] * fovScale, 0)
    end)
end

function GIFT:CleanUp()
    for _, timerId in ipairs(timerIds) do
        timer.Remove(timerId)
    end
    table.Empty(timerIds)

    for _, v in ipairs(player.GetAll()) do
        v:SetFOV(0, 0)
    end
    table.Empty(originalFOV)
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"scale", "scale_ironsight"}) do
        local name = "randomat_secretsanta_" .. self.Id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = self.Id .. "_" .. v,
                dsc = self.Name .. " - " .. convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end
end

SECRETSANTA:RegisterGift(GIFT, true)