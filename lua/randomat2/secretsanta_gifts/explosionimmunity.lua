local GIFT = {}

GIFT.Name = "Explosion Immunity"
GIFT.Id = "explosionimmunity"

local hookIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaExplosionImmunity_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("EntityTakeDamage", hookId, function(ent, dmginfo)
        if not IsValid(ent) then return end

        if GetRoundState() >= ROUND_ACTIVE then
            if ent == target and dmginfo:IsExplosionDamage() then
                dmginfo:ScaleDamage(0)
                dmginfo:SetDamage(0)
            end
        end
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("EntityTakeDamage", hookId)
    end
    table.Empty(hookIds)
end

SECRETSANTA:RegisterGift(GIFT)