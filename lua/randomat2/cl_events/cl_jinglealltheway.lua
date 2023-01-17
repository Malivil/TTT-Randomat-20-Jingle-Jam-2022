net.Receive("RdmtJingleAllTheWayBegin", function()
    hook.Add("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery", function(client, recovery)
        if IsPlayer(client) and not client:IsLootGoblin() then
            return GetGlobalFloat("ttt_lootgoblin_sprint_recovery", 0.12)
        end
    end)
end)

net.Receive("RdmtJingleAllTheWayEnd", function()
    hook.Remove("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery")
end)