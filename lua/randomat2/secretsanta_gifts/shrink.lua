local GIFT = {}

GIFT.Name = "Shrink Player"
GIFT.Id = "shrink"

local shrink_scale = CreateConVar("randomat_secretsanta_shrink_scale", "0.5", FCVAR_ARCHIVE, "The shrinking scale factor", 0.1, 0.9)

function GIFT:Choose(owner, target)
    local scale = shrink_scale:GetFloat()
    Randomat:SetPlayerScale(target, scale, "SecretSanta_Shrink")
end

function GIFT:CleanUp()
    for _, p in player.Iterator() do
        Randomat:ResetPlayerScale(p, "SecretSanta_Shrink")
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

SECRETSANTA:RegisterGift(GIFT)
