local CHOICE = {}

local math = math

local MathRound = math.Round

CHOICE.Name = "Reduce Health"
CHOICE.Id = "reducehp"

local reducehp_factor = CreateConVar("randomat_secretsanta_reducehp_factor", "0.5", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The reduction factor (0.5 = 50% less HP).", 0.05, 0.95)

function CHOICE:Choose(owner, target)
    local factor = 1 - reducehp_factor:GetFloat()
    print("Factor:", factor)
    local hp = MathRound(target:Health() * factor)
    print("HP:", hp)
    target:SetHealth(hp)
    local max = MathRound(target:GetMaxHealth() * factor)
    print("Max:", max)
    target:SetMaxHealth(max)
end

function CHOICE:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"factor"}) do
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

SECRETSANTA:RegisterChoice(CHOICE, true)