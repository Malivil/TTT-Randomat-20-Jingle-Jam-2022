net.Receive("RdmtSecretSantaLockedCameraBegin", function()
    local client = LocalPlayer()

    -- Prevents up/down movement with the mouse
    hook.Add("InputMouseApply", "RdmtSecretSantaChangedFOV_InputMouseApply", function(cmd, x, y, ang)
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end

        ang.pitch = 0
        ang.yaw = ang.yaw - (x / 50)
        cmd:SetViewAngles(ang)

        return true
    end)
end)

net.Receive("RdmtSecretSantaLockedCameraEnd", function()
    hook.Remove("InputMouseApply", "RdmtSecretSantaChangedFOV_InputMouseApply")
end)