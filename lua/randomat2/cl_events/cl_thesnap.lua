local math = math

local MathRand = math.Rand

local EVENT = {}
EVENT.id = "thesnap"

function EVENT:Begin()
    local client = LocalPlayer()
    local grey_min = 105
    local grey_max = 220

    hook.Add("Think", "RdmtTheSnapThink", function()
        local grey = MathRand(grey_min, grey_max)
        Randomat:HandleEntitySmoke(ents.GetAll(), client, function(v)
            return v:GetNWBool("RdmtTheSnapDissolve", false)
        end, Color(grey, grey, grey), nil, 1, 1)
    end)
end

function EVENT:End()
    hook.Remove("Think", "RdmtTheSnapThink")
end

Randomat:register(EVENT)