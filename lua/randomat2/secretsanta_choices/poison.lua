local CHOICE = {}

CHOICE.Name = "Poison"
CHOICE.Id = "poison"

local poison_amount = CreateConVar("randomat_secretsanta_poison_amount", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much damage to do.", 1, 100)
local poison_interval = CreateConVar("randomat_secretsanta_poison_interval", "5", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often to do damage.", 1, 100)
local poison_max = CreateConVar("randomat_secretsanta_poison_max", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The maximum total damage to do (0 to disable).", 0, 100)

local timerIds = {}

function CHOICE:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local timerId = "RdmtSecretSantaPoison_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(timerIds, timerId)

    local amount = poison_amount:GetInt()
    local interval = poison_interval:GetInt()
    local max = poison_max:GetInt()
    local damage_done = 0
    timer.Create(timerId, interval, 0, function()
        -- Stop the timer if this player is gone or dead
        if not IsPlayer(target) or not target:Alive() or target:IsSpec() then
            timer.Remove(timerId)
            return
        end

        -- Damage the player
        target:TakeDamage(amount, owner, nil)

        -- Only bother tracking damage if we have a maximum
        if max > 0 then
            damage_done = damage_done + amount
            -- Stop the timer if we've done enough damage
            if damage_done >= max then
                timer.Remove(timerId)
            end
        end
    end)
end

function CHOICE:CleanUp()
    for _, timerId in ipairs(timerIds) do
        timer.Remove(timerId)
    end
    table.Empty(timerIds)
end

function CHOICE:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"amount", "interval", "max"}) do
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

SECRETSANTA:RegisterChoice(CHOICE, true)