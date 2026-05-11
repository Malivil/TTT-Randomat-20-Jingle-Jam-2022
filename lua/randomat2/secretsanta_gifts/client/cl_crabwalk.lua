net.Receive("RdmtSecretSantaCrabWalkBegin", function()
    hook.Add("StartCommand", "RdmtSecretSantaCrabWalk_StartCommand", function(ply, cmd)
        if ply ~= Randomat.Client or not ply:Alive() or ply:IsSpec() then return end
        cmd:SetForwardMove(0)
    end)
end)

net.Receive("RdmtSecretSantaCrabWalkEnd", function()
    hook.Remove("StartCommand", "RdmtSecretSantaCrabWalk_StartCommand")
end)