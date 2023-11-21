net.Receive("RdmtJingleAllTheWayBegin", function()
    hook.Add("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery", function(client, recovery)
        if IsPlayer(client) and not client:IsLootGoblin() then
            return GetConVar("ttt_lootgoblin_sprint_recovery"):GetFloat()
        end
    end)
end)

net.Receive("RdmtJingleAllTheWayEnd", function()
    hook.Remove("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery")
end)