local GIFT = {}

GIFT.Name = "Less Ammo"
GIFT.Id = "lessammo"

local hookIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaLessAmmo_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("EntityFireBullets", hookId, function(ent, data)
        if not IsPlayer(ent) or ent ~= target then return end

        local wep = ent:GetActiveWeapon()
        if not IsValid(wep) or not wep.Primary or wep.Primary.ClipSize <= 0 then return end

        local ammo = wep:Clip1()
        if ammo <= 0 then return end

        wep:SetClip1(math.max(0, ammo - 1))
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("EntityFireBullets", hookId)
    end
    table.Empty(hookIds)
end

SECRETSANTA:RegisterGift(GIFT, true)