net.Receive("RdmtSecretSantaCrabWalkBegin", function()
    local client = LocalPlayer()
    hook.Add("StartCommand", "RdmtSecretSantaCrabWalk_StartCommand", function(ply, cmd)
        if ply ~= client or not ply:Alive() or ply:IsSpec() then return end
        cmd:SetForwardMove(0)
    end)
end)

net.Receive("RdmtSecretSantaCrabWalkEnd", function()
    hook.Remove("StartCommand", "RdmtSecretSantaCrabWalk_StartCommand")
end)