local EVENT = {}

CreateConVar("randomat_thesnap_fadetime", 5, FCVAR_ARCHIVE, "The amount of time the \"Five years later\" fade lasts", 3, 60)
CreateConVar("randomat_thesnap_deathdelay", 5, FCVAR_ARCHIVE, "The amount of time before the chosen players are killed", 1, 60)

EVENT.Title = "The Snap"
EVENT.Description = "Thanos has activated the Infinity Gauntlet... say goodbye to 1/2 of your friends"
EVENT.id = "thesnap"
EVENT.Type = EVENT_TYPE_SMOKING
EVENT.Categories = {"biased_traitor", "biased", "largeimpact"}

function EVENT:Begin()
    local death_delay = GetConVar("randomat_thesnap_deathdelay"):GetInt()
    local fade_time = GetConVar("randomat_thesnap_fadetime"):GetInt()

    local fade_sent = false
    local snap_time = CurTime() + death_delay
    local ply_info = {}

    self:AddHook("TTTWinCheckBlocks", function(win_blocks)
        -- If the snap is gone and done with, stop checking the wins
        if CurTime() - snap_time > fade_time then
            self:RemoveHook("TTTWinCheckBlocks")
            return
        end

        -- If innocents win after the snap, trigger the "5 years later" scenario and respawn everyone who was snapped
        table.insert(win_blocks, function(win_type)
            if win_type ~= WIN_INNOCENT then return win_type end
            if not fade_sent then
                fade_sent = true

                -- Reset this to ensure the fade stays in place long enough
                snap_time = CurTime()

                for _, p in ipairs(self:GetPlayers()) do
                    -- Respawn the people who were killed by the snap
                    local sid64 = p:SteamID64()
                    if ply_info[sid64] and (not p:Alive() or p:IsSpec()) then
                        p:SpawnForRound(true)
                        p:SetNWBool("RdmtTheSnapDissolve", false)
                        p:SetCredits(ply_info[sid64].credits)
                        p:SetEyeAngles(Angle(0, ply_info[sid64].ang.y, 0))
                        p:SetPos(FindRespawnLocation(ply_info[sid64].pos) or ply_info[sid64].pos)
                    end

                    -- Fade the screen
                    p:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 1, fade_time)
                    Randomat:SmallNotify("Five years later...", fade_time, nil, true, true, COLOR_WHITE)
                end
            end
            return WIN_NONE
        end)
    end)

    local living_players = self:GetAlivePlayers(true)
    local kill_count = math.floor(#living_players / 2)
    for _, p in ipairs(living_players) do
        Randomat:PrintMessage(p, MSG_PRINTBOTH, "You don't feel so good...")
        p:SetNWBool("RdmtTheSnapKilled", true)
        p:SetNWBool("RdmtTheSnapDissolve", true)

        local sid64 = p:SteamID64()
        timer.Create("RdmtTheSnapKill_" .. sid64, death_delay, 1, function()
            ply_info[sid64] = {pos=p:GetPos(), ang=p:GetAngles(), credits=p:GetCredits()}
            p:Kill()
        end)

        kill_count = kill_count - 1
        if kill_count <= 0 then
            break
        end
    end

    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        if not ply_info[ply:SteamID64()] then return end

        local body = ply.server_ragdoll or ply:GetRagdollEntity()
        if IsValid(body) then
            ply:SetNWBool("RdmtTheSnapDissolve", false)
            body:SetNWBool("RdmtTheSnapDissolve", true)
            SafeRemoveEntityDelayed(body, death_delay)
        end
    end)
end

function EVENT:End()
    for _, p in player.Iterator() do
        local sid64 = p:SteamID64()
        timer.Remove("RdmtTheSnapKill_" .. sid64)
        timer.Remove("RdmtTheSnapMessage_" .. sid64)
        p:SetNWBool("RdmtTheSnapKilled", false)
        p:SetNWBool("RdmtTheSnapDissolve", false)
    end
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"fadetime", "deathdelay"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
    return sliders
end

Randomat:register(EVENT)