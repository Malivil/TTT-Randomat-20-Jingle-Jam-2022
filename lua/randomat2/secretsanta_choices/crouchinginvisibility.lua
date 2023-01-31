local CHOICE = {}

CHOICE.Name = "Invisibility When Crouching"
CHOICE.Id = "crouchinginvisibility"

local crouchinginvisibility_reveal_timer = CreateConVar("randomat_secretsanta_crouchinginvisibility_reveal_timer", "3", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How long to reveal the target after they shoot their gun", 0, 30)

local hookIds = {}

local function SetPlayerVisibility(ply, visible)
    if visible then
        Randomat:SetPlayerVisible(ply)
    else
        Randomat:SetPlayerInvisible(ply)
    end
    ply:DrawWorldModel(visible)
end

function CHOICE:Choose(owner, target)
    -- Generate a unique ID for this pairing and save it to be cleaned up later
    local hookId = "RdmtSecretSantaCrouchingInvisibility_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    table.insert(hookIds, hookId)

    hook.Add("FinishMove", hookId .. "_FinishMove", function(ply, mv)
        if not IsValid(ply) or not ply:Alive() or ply:IsSpec() or target ~= ply then return end
        SetPlayerVisibility(ply, not ply:Crouching() or ply:GetNWBool("RdmtSecretSantaCrouchingInvisibilityRevealed", false))
    end)

    hook.Add("PlayerDeath", hookId .. "_PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) or target ~= victim then return end
        SetPlayerVisibility(ply, true)
    end)

    hook.Add("EntityFireBullets", hookId .. "_EntityFireBullets", function(entity, data)
        if not IsPlayer(entity) or target ~= entity then return end
        local reveal_time = crouchinginvisibility_reveal_timer:GetInt()
        if reveal_time > 0 then
            entity:SetNWBool("RdmtSecretSantaCrouchingInvisibilityRevealed", true)
            timer.Create("RdmtTSecretSantaCrouchingInvisibilityRevealTimer_" .. entity:Nick(), reveal_time, 1, function()
                entity:SetNWBool("RdmtSecretSantaCrouchingInvisibilityRevealed", false)
            end)
        end
    end)
end

function CHOICE:CleanUp()
    for _, hookId in ipairs(hookIds) do
        hook.Remove("FinishMove", hookId .. "_FinishMove")
        hook.Remove("PlayerDeath", hookId .. "_PlayerDeath")
        hook.Remove("EntityFireBullets", hookId .. "_EntityFireBullets")
    end
    for _, p in ipairs(player.GetAll()) do
        SetPlayerVisibility(p, true)
        timer.Remove("RdmtTSecretSantaCrouchingInvisibilityRevealTimer_" .. p:Nick())
    end
end

SECRETSANTA:RegisterChoice(CHOICE)