local math = math

local MathRand = math.Rand

net.Receive("RdmtTheSnapBegin", function()
    local client = LocalPlayer()
    local grey_min = 105
    local grey_max = 220

    hook.Add("Think", "RdmtTheSnapThink", function()
        local grey = MathRand(grey_min, grey_max)
        Randomat:HandleEntitySmoke(ents.GetAll(), client, function(v)
            return v:GetNWBool("RdmtTheSnapDissolve", false)
        end, Color(grey, grey, grey), nil, 1, 1)
    end)
end)

net.Receive("RdmtTheSnapEnd", function()
    hook.Remove("Think", "RdmtTheSnapThink")
end)