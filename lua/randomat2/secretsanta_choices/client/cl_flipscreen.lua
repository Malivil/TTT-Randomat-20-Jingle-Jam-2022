net.Receive("RdmtSecretSantaFlipScreenBegin", function()
    local client = LocalPlayer()
    local view = { origin = vector_origin, angles = angle_zero, fov = 0 }
    hook.Add("CalcView", "RdmtSecretSantaFlipScreen_CalcView", function(ply, origin, angles, fov)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() or ply ~= client then return end

        view.origin = origin
        view.angles = angles
        view.fov = fov

        local wep = ply:GetActiveWeapon()
        if IsValid(wep) then
            local func = wep.CalcView
            if func then
                view.origin, view.angles, view.fov = func(wep, ply, origin * 1, angles * 1, fov)
            end
        end

        view.angles.r = view.angles.r + 180

        return view
    end)

    hook.Add("InputMouseApply", "RdmtSecretSantaFlipScreen_InputMouseApply", function(cmd, x, y, ang)
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end

        ang.yaw = ang.yaw + (x / 50)
        ang.pitch = math.Clamp(ang.pitch - y / 50, -89, 89)
        cmd:SetViewAngles(ang)

        return true
    end)
end)

net.Receive("RdmtSecretSantaFlipScreenEnd", function()
    hook.Remove("CalcView", "RdmtSecretSantaFlipScreen_CalcView")
    hook.Remove("InputMouseApply", "RdmtSecretSantaFlipScreen_InputMouseApply")
end)