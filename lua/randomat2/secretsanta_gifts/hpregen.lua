local GIFT = {}

GIFT.Name = "Health Regen"
GIFT.Id = "hpregen"

local hpregen_amount = CreateConVar("randomat_secretsanta_hpregen_amount", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much health to give.", 1, 100)
local hpregen_interval = CreateConVar("randomat_secretsanta_hpregen_interval", "5", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often to heal.", 1, 100)

local timerIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local timerId = "RdmtSecretSantaHPRegen_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(timerIds, timerId)

    local amount = hpregen_amount:GetInt()
    local interval = hpregen_interval:GetInt()
    timer.Create(timerId, interval, 0, function()
        -- Stop the timer if this player is gone or dead
        if not IsPlayer(target) or not target:Alive() or target:IsSpec() then
            timer.Remove(timerId)
            return
        end

        local hp = target:Health()
        local max_hp = target:GetMaxHealth()

        -- If they already have more than their max, don't change anything
        if hp > max_hp then
            return
        end

        -- Heal the player up to their max HP
        hp = math.min(hp + amount, max_hp)
        target:SetHealth(hp)
    end)
end

function GIFT:CleanUp()
    for _, timerId in ipairs(timerIds) do
        timer.Remove(timerId)
    end
    table.Empty(timerIds)
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"amount", "interval"}) do
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

SECRETSANTA:RegisterGift(GIFT)