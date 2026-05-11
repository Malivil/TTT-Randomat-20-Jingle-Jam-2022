local function IsTargetHighlighted(ply, target)
    return ply.IsTargetHighlighted and ply:IsTargetHighlighted(target)
end

net.Receive("RdmtSecretSantaBlindishBegin", function()
    hook.Add("PreDrawHalos", "RdmtSecretSantaBlindish_PreDrawHalos", function()
        local alivePlys = {}
        for _, v in player.Iterator() do
            if v ~= Randomat.Client and v:Alive() and not v:IsSpec() and not IsTargetHighlighted(Randomat.Client, v) then
                table.insert(alivePlys, v)
            end
        end

        halo.Add(alivePlys, COLOR_RED, 0, 0, 1, true, true)
    end)
end)

net.Receive("RdmtSecretSantaBlindishEnd", function()
    hook.Remove("PreDrawHalos", "RdmtSecretSantaBlindish_PreDrawHalos")
end)