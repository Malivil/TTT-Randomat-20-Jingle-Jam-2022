local GIFT = {}

GIFT.Name = "Damage Resistance"
GIFT.Id = "damageresistance"

local damageresistance_resistance = CreateConVar("randomat_secretsanta_damageresistance_resistance", "0.3", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Incoming damage reduction.", 0, 1)

local hookIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaDamageResistance_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    local resistance = damageresistance_resistance:GetFloat()

    hook.Add("ScalePlayerDamage", hookId, function(ply, hitgroup, dmginfo)
        if GetRoundState() >= ROUND_ACTIVE then
            if ply == target then
                dmginfo:ScaleDamage(1 - resistance)
            end
        end
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("ScalePlayerDamage", hookId)
    end
    table.Empty(hookIds)
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"resistance"}) do
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

SECRETSANTA:RegisterGift(GIFT)