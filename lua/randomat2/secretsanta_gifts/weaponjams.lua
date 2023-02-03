local GIFT = {}

local math = math

local MathRandom = math.random

util.AddNetworkString("RdmtSecretSantaWeaponJamsStart")
util.AddNetworkString("RdmtSecretSantaWeaponJamsStop")
util.AddNetworkString("RdmtSecretSantaWeaponJamsEnd")

GIFT.Name = "Weapon Jams"
GIFT.Id = "weaponjams"

local weaponjams_interval_min = CreateConVar("randomat_secretsanta_weaponjams_interval_min", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum time between jams", 1, 60)
local weaponjams_interval_max = CreateConVar("randomat_secretsanta_weaponjams_interval_max", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Maximum time between jams", 2, 120)
local weaponjams_duration = CreateConVar("randomat_secretsanta_weaponjams_duration", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Weapon jam duration", 1, 30)

local function GetInterval()
    local interval_min = weaponjams_interval_min:GetInt()
    local interval_max = weaponjams_interval_max:GetInt()
    local interval
    if interval_min > interval_max then
        interval = interval_min
    else
        interval = MathRandom(interval_min, interval_max)
    end
    return interval
end

-- Only jam primary weapons and pistols
function GIFT:IsValidWeapon(weap)
    return IsValid(weap) and (weap.Kind == WEAPON_HEAVY or weap.Kind == WEAPON_PISTOL)
end

local timerAndHookIds = {}
function GIFT:JamWeapon(ply, weap)
    if not weap.OldPrimaryAttack then
        weap.OldPrimaryAttack = weap.PrimaryAttack
        weap.JammedMessage = false
        weap.PrimaryAttack = function(w, worldsnd)
            local has_delay = type(w.Primary.Delay) == "number"
            -- Workaround for the weapons that don't use the normal delay system: Just use a fixed delay time and don't check CanPrimaryAttack
            if has_delay then
                w:SetNextSecondaryFire(CurTime() + w.Primary.Delay)
                w:SetNextPrimaryFire(CurTime() + w.Primary.Delay)

                if not w:CanPrimaryAttack() then return end
            else
                w:SetNextSecondaryFire(CurTime() + 0.2)
                w:SetNextPrimaryFire(CurTime() + 0.2)
            end

            if not worldsnd then
                w:EmitSound("Weapon_Pistol.Empty", w.Primary.SoundLevel or 100)
            elseif SERVER then
                sound.Play("Weapon_Pistol.Empty", w:GetPos(), w.Primary.SoundLevel or 100)
            end

            -- Let the player know their weapon is jammed if we haven't told them already
            local owner = w:GetOwner()
            if IsPlayer(owner) and not w.JammedMessage then
                w.JammedMessage = true
                owner:PrintMessage(HUD_PRINTTALK, "Your weapon has jammed!")
                owner:PrintMessage(HUD_PRINTCENTER, "Your weapon has jammed!")
            end
        end

        local timerId = "RdmtSecretSantaWeaponJamsStartDelay_" .. weap:EntIndex()
        table.insert(timerAndHookIds, timerId)
        -- Let the client realize they have the weapon before telling them to jam it
        timer.Create(timerId, 0.1, 1, function()
            net.Start("RdmtSecretSantaWeaponJamsStart")
            net.WriteString(WEPS.GetClass(weap))
            net.Send(ply)
        end)
    end
end

function GIFT:JamWeapons(ply)
    for _, w in ipairs(ply:GetWeapons()) do
        if self:IsValidWeapon(w) then
            self:JamWeapon(ply, w)
        end
    end
end

function GIFT:UnjamWeapon(ply, weap)
    if weap.OldPrimaryAttack then
        local timerId = "RdmtSecretSantaWeaponJamsStartDelay_" .. weap:EntIndex()
        timer.Remove(timerId)

        local weap_class = WEPS.GetClass(weap)
        weap.PrimaryAttack = weap.OldPrimaryAttack
        weap.OldPrimaryAttack = nil

        -- If the player knows their weapon was jammed, let them know they've unjammed it
        local owner = weap:GetOwner()
        if IsPlayer(owner) and weap.JammedMessage then
            owner:PrintMessage(HUD_PRINTTALK, "You have cleared your jammed weapon!")
            owner:PrintMessage(HUD_PRINTCENTER, "You have cleared your jammed weapon!")
        end

        net.Start("RdmtSecretSantaWeaponJamsStop")
        net.WriteString(weap_class)
        net.Send(ply)
    end
end

function GIFT:UnjamWeapons(ply)
    for _, w in ipairs(ply:GetWeapons()) do
        self:UnjamWeapon(ply, w)
    end
end

function GIFT:Choose(owner, target)
    local duration = weaponjams_duration:GetInt()

    local timerAndHookId = "RdmtSecretSantaWeaponJams_" .. owner:SteamID64() .. "_" .. target:SteamID64()
    local checkTimerId = timerAndHookId .. "_JamCheck"
    local durationTimerId = timerAndHookId .. "_Duration"
    timer.Create(checkTimerId, GetInterval(), 0, function()
        timer.Stop(checkTimerId)

        -- Jam current weapons
        target.RdmtSecretSantaWeaponJamsJammed = true
        self:JamWeapons(target)

        -- Jam when picking up weapon
        hook.Add("WeaponEquip", timerAndHookId, function(weap, ply)
            if ply ~= target then return end
            if not self:IsValidWeapon(weap) or not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
            if not ply.RdmtSecretSantaWeaponJamsJammed then return false end

            self:JamWeapon(ply, weap)
        end)

        -- Un-jam when dropping weapon
        hook.Add("PlayerDroppedWeapon", timerAndHookId, function(ply, weap)
            if ply ~= target then return end
            if not self:IsValidWeapon(weap) or not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
            if not ply.RdmtSecretSantaWeaponJamsJammed then return false end

            self:UnjamWeapon(ply, weap)
        end)

        timer.Create(durationTimerId, duration, 1, function()
            self:UnjamWeapons(target)
            target.RdmtSecretSantaWeaponJamsJammed = false

            timer.Adjust(checkTimerId, GetInterval())
            timer.Start(checkTimerId)
        end)
    end)
end

function GIFT:CleanUp()
    for _, timerAndHookId in ipairs(timerAndHookIds) do
        timer.Remove(timerAndHookId .. "_JamCheck")
        timer.Remove(timerAndHookId .. "_Duration")
        hook.Remove("WeaponEquip", timerAndHookId)
        hook.Remove("PlayerDroppedWeapon", timerAndHookId)
    end
    table.Empty(timerAndHookIds)

    net.Start("RdmtSecretSantaWeaponJamsEnd")
    net.Broadcast()
end

function GIFT:AddConVars(sliders, checks, textboxes)
    for _, v in ipairs({"interval_min", "interval_max", "duration"}) do
        local name = "randomat_secretsanta_" .. self.Id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = self.Id .. "_" .. v,
                dsc = self.Name .. " - " .. convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end
end

function GIFT:Condition()
    return not Randomat:IsEventActive("jinglejam2021")
end

SECRETSANTA:RegisterGift(GIFT, true)