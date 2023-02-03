local GIFT = {}

GIFT.Name = "Permanent H.U.G.E."
GIFT.Id = "undroppablehuge"

local hookIds = {}

local function UpdateHuge(huge)
    -- Don't let them drop it
    huge.AllowDrop = false
    -- Disable ironsights
    huge.NoSights = true
    -- Give them infinite ammo
    huge:SetClip1(huge.Primary.ClipSize)
end

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaUndroppableHUGE_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("Think", hookId, function()
        for _, wep in ipairs(target:GetWeapons()) do
            if wep.Kind ~= WEAPON_HEAVY then continue end

            local class = WEPS.GetClass(wep)
            if class == "weapon_zm_sledge" then
                UpdateHuge(wep)
                continue
            end

            target:StripWeapon(class)
            target:Give("weapon_zm_sledge")
        end
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("Think", hookId)
    end
    table.Empty(hookIds)
end

function GIFT:Condition()
    return not Randomat:IsEventActive("derptective")
end

SECRETSANTA:RegisterGift(GIFT, true)