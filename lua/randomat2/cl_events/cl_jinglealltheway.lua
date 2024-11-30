local EVENT = {}
EVENT.id = "jinglealltheway"

function EVENT:End()
    hook.Remove("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery")
end

Randomat:register(EVENT)

net.Receive("RdmtJingleAllTheWayBegin", function()
    hook.Add("TTTSprintStaminaRecovery", "JingleAllTheWay_TTTSprintStaminaRecovery", function(client, recovery)
        if IsPlayer(client) and not client:IsLootGoblin() then
            return GetConVar("ttt_lootgoblin_sprint_recovery"):GetFloat()
        end
    end)
end)