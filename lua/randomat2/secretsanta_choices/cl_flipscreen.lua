local hookIds = {}

net.Receive("RdmtSecretSantaFlipScreenBegin", function()
    local target = net.ReadString()
    local owner = net.ReadString()

    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaFlipScreen_" .. owner .. "_" .. target
    table.insert(hookIds, hookId)

    local view = { origin = vector_origin, angles = angle_zero, fov = 0 }
    hook.Add("CalcView", hookId .. "_CalcView", function(ply, origin, angles, fov)
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        if ply:SteamID64() ~= target then return end

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

    local client = LocalPlayer()
    hook.Add("InputMouseApply", hookId .. "_InputMouseApply", function(cmd, x, y, ang)
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end
        if client:SteamID64() ~= target then return end

        ang.yaw = ang.yaw + (x / 50)
        ang.pitch = math.Clamp(ang.pitch - y / 50, -89, 89)
        cmd:SetViewAngles(ang)

        return true
    end)
end)

net.Receive("RdmtSecretSantaFlipScreenEnd", function()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("CalcView", hookId .. "_CalcView")
        hook.Remove("InputMouseApply", hookId .. "_InputMouseApply")
    end
    table.Empty(hookIds)
end)