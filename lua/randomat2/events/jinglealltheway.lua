local EVENT = {}

local MathRandom = math.random

util.AddNetworkString("RdmtJingleAllTheWayBegin")
util.AddNetworkString("RdmtJingleAllTheWayEnd")

EVENT.Title = "Jingle All the Way"
EVENT.Description = "If everyone jingles, how will you ever find the Loot Goblin?"
EVENT.id = "jinglealltheway"
EVENT.Categories = {"fun", "mediumimpact"}

local cackles = {
    Sound("lootgoblin/cackle1.wav"),
    Sound("lootgoblin/cackle2.wav"),
    Sound("lootgoblin/cackle3.wav")
}
local footsteps = {
    Sound("lootgoblin/jingle1.wav"),
    Sound("lootgoblin/jingle2.wav"),
    Sound("lootgoblin/jingle3.wav"),
    Sound("lootgoblin/jingle4.wav"),
    Sound("lootgoblin/jingle5.wav"),
    Sound("lootgoblin/jingle6.wav"),
    Sound("lootgoblin/jingle7.wav"),
    Sound("lootgoblin/jingle8.wav")
}
local defaultJumpPower = 160

function EVENT:Begin()
    EVENT.Description = "If everyone jingles, how will you ever find the " .. Randomat:GetRoleString(ROLE_LOOTGOBLIN) .. "?"

    local goblinTimer = timer.TimeLeft("LootGoblinActivate")
    timer.Create("RdmtJingleAllTheWayActivate", goblinTimer, 1, function()
        local goblinAlive = player.IsRoleLiving(ROLE_LOOTGOBLIN)
        if not goblinAlive then
            local message = string.Capitalize(ROLE_STRINGS_EXT[ROLE_LOOTGOBLIN]) .. " has been killed! Christmas is cancelled!"
            PrintMessage(HUD_PRINTTALK, message)
            PrintMessage(HUD_PRINTCENTER, message)
            return
        end

        -- Activate everyone else

        -- Player scale and jump power
        local scale = GetConVar("ttt_lootgoblin_size"):GetFloat()
        local jumpPower = defaultJumpPower
        -- Compensate the jump power of smaller players so they have roughly the same jump height as normal
        -- In testing, scales >= 1 all seem to work fine with the default jump power and that's not the intent of this role anyway
        if scale < 1 then
            -- Derived formula is y = -120x + 280
            -- We take the base jump power out of this as a known constant and then
            -- give a small jump boost of 5 extra power to "round up" the jump estimates
            -- so that smaller sizes can still clear jump+crouch blocks
            jumpPower = jumpPower + (-(120 * scale) + 125)
        end
        for _, v in ipairs(self:GetAlivePlayers()) do
            v:SetPlayerScale(scale)
            v:SetJumpPower(jumpPower)
        end

        -- Jingle, if it's enabled
        if GetConVar("ttt_lootgoblin_jingle_enabled"):GetBool() then
            self:AddHook("PlayerFootstep", function(ply, pos, foot, snd, volume, rf)
                if not ply:IsActiveLootGoblin() then
                    local idx = MathRandom(1, #footsteps)
                    local chosen_sound = footsteps[idx]
                    sound.Play(chosen_sound, pos, volume, 100, 1)
                end
            end)
        end

        -- Cackle, if it's enabled
        if GetConVar("ttt_lootgoblin_cackle_enabled"):GetBool() then
            local min = GetConVar("ttt_lootgoblin_cackle_timer_min"):GetInt()
            local max = GetConVar("ttt_lootgoblin_cackle_timer_max"):GetInt()
            if max < min then
                max = min
            end
            timer.Create("RdmtJingleAllTheWayCackle", MathRandom(min, max), 0, function()
                for _, v in ipairs(self:GetAlivePlayers()) do
                    if not v:IsLootGoblin() then
                        local idx = MathRandom(1, #cackles)
                        local chosen_sound = cackles[idx]
                        sound.Play(chosen_sound, v:GetPos())
                    end
                end
                timer.Adjust("RdmtJingleAllTheWayCackle", MathRandom(min, max), 0, nil)
            end)
        end

        -- Increase stamina recovery
        self:AddHook("TTTSprintStaminaRecovery", function(ply, recovery)
            if IsPlayer(ply) and not ply:IsLootGoblin() then
                return GetConVar("ttt_lootgoblin_sprint_recovery"):GetFloat()
            end
        end)

        net.Start("RdmtJingleAllTheWayBegin")
        net.Broadcast()
    end)
end

function EVENT:End()
    timer.Remove("RdmtJingleAllTheWayActivate")
    timer.Remove("RdmtJingleAllTheWayCackle")

    net.Start("RdmtJingleAllTheWayEnd")
    net.Broadcast()

    for _, v in ipairs(self:GetAlivePlayers()) do
        if not v:IsLootGoblin() then
            v:ResetPlayerScale()
            v:SetJumpPower(defaultJumpPower)
        end
    end
end

function EVENT:Condition()
    return player.IsRoleLiving(ROLE_LOOTGOBLIN)
end

Randomat:register(EVENT)