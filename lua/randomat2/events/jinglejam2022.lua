local plymeta = FindMetaTable("Player")
if not plymeta then return end

local EVENT = {}

util.AddNetworkString("RdmtJingleJam2022Begin")
util.AddNetworkString("RdmtJingleJam2022End")
util.AddNetworkString("RdmtJingleJam2022Donation")
util.AddNetworkString("RdmtJingleJam2022RoundSound")

resource.AddSingleFile("materials/vgui/ttt/Pattern_money.png")
resource.AddSingleFile("materials/vgui/ttt/Pattern_money_gold.png")
resource.AddSingleFile("sound/randomat/wholikestoparty.mp3")

CreateConVar("randomat_jinglejam2022_mult", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The multiplier used when calculating the number of credits to win", 0.1, 5)

EVENT.Title = "Jingle Jam 2022"
EVENT.Description = "Let's raise some credits for charity! Open the shop menu to donate"
EVENT.id = "jinglejam2022"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local donationGoal = nil
local donationCurrent = 0
local donationMet = false

local winSoundLength = 10
local roundEndTime = nil

local oldCanLootCredits
function EVENT:Begin()
    donationGoal = nil
    donationCurrent = 0
    donationMet = false
    roundEndTime = nil

    -- Let everyone loot credits
    if not oldCanLootCredits then
        oldCanLootCredits = plymeta.CanLootCredits
        function plymeta:CanLootCredits(active_only)
            if active_only and not self:IsActive() then return false end
            return true
        end
    end

    local alivePlayers = self:GetAlivePlayers()
    local mult = GetConVar("randomat_jinglejam2022_mult"):GetFloat()
    local creditCount = math.floor(#alivePlayers * mult)
    donationGoal = math.max(creditCount, 1)

    net.Start("RdmtJingleJam2022Begin")
    net.WriteUInt(donationGoal, 8)
    net.Broadcast()

    -- If we've met the donation goal, innocents win
    self:AddHook("TTTCheckForWin", function()
        if donationMet then
            -- Play win sound
            if roundEndTime == nil then
                roundEndTime = CurTime()
                self:DisableRoundEndSounds()
                net.Start("RdmtJingleJam2022RoundSound")
                net.WriteString("randomat/wholikestoparty.mp3")
                net.Broadcast()
            end

            -- Block round wins until the sound is done
            if roundEndTime + winSoundLength > CurTime() then
                return WIN_NONE
            end

            -- Then have the innocents win
            return WIN_INNOCENT
        end
    end)
end

function EVENT:End()
    -- Reset this
    if oldCanLootCredits then
        plymeta.CanLootCredits = oldCanLootCredits
        oldCanLootCredits = nil
    end

    net.Start("RdmtJingleJam2022End")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"mult"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end
    return sliders
end

net.Receive("RdmtJingleJam2022Donation", function(len, ply)
    if donationMet then return end

    local credits = net.ReadUInt(8)
    if credits > ply:GetCredits() then
        local errorMessage = "You don't have enough credits to donate " .. credits
        ply:PrintMessage(HUD_PRINTCENTER, errorMessage)
        ply:PrintMessage(HUD_PRINTTALK, errorMessage)
        return
    end

    -- Make sure we don't donate more credits than are needed for the goal
    credits = math.min(credits, donationGoal - donationCurrent)

    local creditName = " credit"
    if credits > 1 then
        creditName = creditName .. "s"
    end

    -- Get the donator's message
    local donationMessage = net.ReadString()

    -- Get the donator's name
    local anon = net.ReadBool()
    local name
    if anon then
        name = "No Name Provided"
    else
        name = ply:Nick()
    end

    -- Save the donation amount
    donationCurrent = donationCurrent + credits
    -- Figure out if we're done
    donationMet = donationCurrent >= donationGoal

    -- Tell everyone
    local message = name .. " donated " .. credits .. creditName .. " to charity!"
    if donationMessage and #donationMessage > 0 then
        message = message .. "\n\t" .. donationMessage
    end
    if donationMet then
        message = message .. "\n\n" .. "GOAL REACHED!"
    end
    PrintMessage(HUD_PRINTCENTER, message)
    PrintMessage(HUD_PRINTTALK, message)

    -- Subtract the donation from the player
    ply:AddCredits(-credits)
    -- And broadcast the change to everyone
    net.Start("RdmtJingleJam2022Donation")
    net.WriteUInt(donationCurrent, 8)
    net.Broadcast()
end)

Randomat:register(EVENT)