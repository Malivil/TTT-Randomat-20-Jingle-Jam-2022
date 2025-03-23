local GIFT = {}

GIFT.Name = "Speed Boost"
GIFT.Id = "speedboost"

local speedboost_mult = CreateConVar("randomat_secretsanta_speedboost_mult", 1.25, FCVAR_NONE, "Speed multiplier (1.25=125%, a 25% boost).", 1.05, 2)

local multIds = {}
local multIdPrefix = "SecretSantaSpeedBoost_"

function GIFT:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local multId = multIdPrefix .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(multIds, multId)

    local mult = speedboost_mult:GetFloat()
    net.Start("RdmtSetSpeedMultiplier")
    net.WriteFloat(mult)
    net.WriteString(multId)
    net.Send(target)

    hook.Add("TTTSpeedMultiplier", multId, function(ply, mults)
        if ply ~= target or not ply:Alive() or ply:IsSpec() then return end
        table.insert(mults, mult)
    end)
end

function GIFT:CleanUp()
    net.Start("RdmtRemoveSpeedMultipliers")
    net.WriteString(multIdPrefix)
    net.Broadcast()

    for _, multId in pairs(multIds) do
        hook.Remove("TTTSpeedMultiplier", multId)
    end
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"mult"}) do
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