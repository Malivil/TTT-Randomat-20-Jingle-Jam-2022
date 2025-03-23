local GIFT = {}

GIFT.Name = "Unlimited Ammo"
GIFT.Id = "unlimitedammo"

CreateConVar("randomat_secretsanta_unlimitedammo_affectbuymenu", 0, FCVAR_NONE, "Affects buy menu weapons.")

local hookIds = {}

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaUnlimitedAmmo_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    local affects_buy = GetConVar("randomat_secretsanta_unlimitedammo_affectbuymenu"):GetBool()
    hook.Add("Think", hookId, function()
        local active_weapon = target:GetActiveWeapon()
        if IsValid(active_weapon) and (active_weapon.AutoSpawnable or (not active_weapon.CanBuy or affects_buy)) then
            active_weapon:SetClip1(active_weapon.Primary.ClipSize)
        end
    end)
end

function GIFT:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("Think", hookId)
    end
    table.Empty(hookIds)
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"affectbuymenu"}) do
        local name = "randomat_secretsanta_" .. self.Id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = self.Id .. "_" .. v,
                dsc = self.Name .. " - " .. convar:GetHelpText()
            })
        end
    end
end

function GIFT:Condition()
    return not Randomat:IsEventActive("ammo")
end

SECRETSANTA:RegisterGift(GIFT)