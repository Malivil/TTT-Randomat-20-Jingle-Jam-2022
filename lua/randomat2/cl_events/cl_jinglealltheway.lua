
local function GetReplicatedValue(onreplicated, onglobal)
    if CRVersion("1.9.3") then
        return onreplicated()
    end
    return onglobal()
end

net.Receive("RdmtJingleAllTheWayBegin", function()
    hook.Add("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery", function(client, recovery)
        if IsPlayer(client) and not client:IsLootGoblin() then
            return GetReplicatedValue(function()
                    return GetConVar("ttt_lootgoblin_sprint_recovery"):GetFloat()
                end,
                function()
                    return GetGlobalFloat("ttt_lootgoblin_sprint_recovery", 0.12)
                end)
        end
    end)
end)

net.Receive("RdmtJingleAllTheWayEnd", function()
    hook.Remove("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery")
end)