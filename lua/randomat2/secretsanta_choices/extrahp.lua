local CHOICE = {}

CHOICE.Name = "Extra Health"
CHOICE.Id = "extrahp"

local extrahp_amount = CreateConVar("randomat_secretsanta_extrahp_amount", "50", FCVAR_NONE, "The amount of HP to give the target", 1, 100)

function CHOICE:Choose(owner, target)
    local hp = extrahp_amount:GetInt()
    target:SetHealth(target:Health() + hp)
    target:SetMaxHealth(target:GetMaxHealth() + hp)
end

function CHOICE:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"amount"}) do
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

SECRETSANTA:RegisterChoice(CHOICE)