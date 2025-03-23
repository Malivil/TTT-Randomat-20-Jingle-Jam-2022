local GIFT = {}

GIFT.Name = "Damage Bonus"
GIFT.Id = "damagebonus"

local damagebonus_bonus = CreateConVar("randomat_secretsanta_damagebonus_bonus", "0.5", FCVAR_NONE, "Outgoing damage bonus.", 0, 1)

local hookIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaDamageBonus_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    local bonus = damagebonus_bonus:GetFloat()

    hook.Add("ScalePlayerDamage", hookId, function(ply, hitgroup, dmginfo)
        local att = dmginfo:GetAttacker()
        if IsPlayer(att) and GetRoundState() >= ROUND_ACTIVE then
            if att == target and ply ~= att then
                dmginfo:ScaleDamage(1 + bonus)
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
    for _, v in ipairs({"bonus"}) do
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