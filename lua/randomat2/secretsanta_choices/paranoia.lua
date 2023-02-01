local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaParanoiaBegin")
util.AddNetworkString("RdmtSecretSantaParanoiaEnd")

CHOICE.Name = "Paranoia"
CHOICE.Id = "paranoia"

local paranoia_timer_min = CreateConVar("randomat_secretsanta_paranoia_timer_min", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The minimum time before the sound should play", 1, 120)
local paranoia_timer_max = CreateConVar("randomat_secretsanta_paranoia_timer_max", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The maximum time before the sound should play", 1, 120)



function CHOICE:Choose(owner, target)
    net.Start("RdmtSecretSantaParanoiaBegin")
    net.WriteString(target:SteamID64())
    net.WriteString(owner:SteamID64())
    net.WriteUInt(paranoia_timer_min:GetInt(), 8)
    net.WriteUInt(paranoia_timer_max:GetInt(), 8)
    net.Broadcast()
end

function CHOICE:CleanUp()
    net.Start("RdmtSecretSantaParanoiaEnd")
    net.Broadcast()
end

function CHOICE:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"timer_min", "timer_max"}) do
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

function CHOICE:Condition()
    return not Randomat:IsEventActive("paranoid")
end

SECRETSANTA:RegisterChoice(CHOICE, true)
