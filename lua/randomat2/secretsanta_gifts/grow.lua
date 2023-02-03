local GIFT = {}

GIFT.Name = "Grow Player"
GIFT.Id = "grow"

local grow_scale = CreateConVar("randomat_secretsanta_grow_scale", "1.5", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The growing scale factor", 1.1, 3.0)

function GIFT:Choose(owner, target)
    local scale = grow_scale:GetFloat()
    Randomat:SetPlayerScale(target, scale, "SecretSanta_Grow")
end

function GIFT:CleanUp()
    for _, p in ipairs(player.GetAll()) do
        Randomat:ResetPlayerScale(p, "SecretSanta_Grow")
    end
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"scale"}) do
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
