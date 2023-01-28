local EVENT = {}

util.AddNetworkString("RdmtJingleJam2022Begin")
util.AddNetworkString("RdmtJingleJam2022End")
util.AddNetworkString("RdmtJingleJam2022Donation")

resource.AddSingleFile("materials/vgui/ttt/Pattern_money.png")
resource.AddSingleFile("materials/vgui/ttt/Pattern_money_gold.png")

CreateConVar("randomat_jinglejam2022_mult", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The multiplier used when calculating the number of credits to win", 0.1, 5)

EVENT.Title = "Jingle Jam 2022"
EVENT.Description = "Let's raise some credits for charity! Open the shop menu to donate"
EVENT.id = "jinglejam2022"
EVENT.Categories = {"biased_innocent", "biased", "largeimpact"}

local donationGoal = nil
local donationCurrent = 0
local donationMet = false

function EVENT:Begin()
    donationGoal = nil
    donationCurrent = 0
    donationMet = false

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
            return WIN_INNOCENT
        end
    end)

    -- TODO: Earn credits somehow
end

function EVENT:End()
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
    local credits = net.ReadUInt(8)
    if credits > ply:GetCredits() then
        local errorMessage = "You don't have enough credits to donate " .. credits
        ply:PrintMessage(HUD_PRINTCENTER, errorMessage)
        ply:PrintMessage(HUD_PRINTTALK, errorMessage)
        return
    end

    local creditName = " credit"
    if credits > 1 then
        creditName = creditName .. "s"
    end

    local message = ply:Nick() .. " donated " .. credits .. creditName .. " to charity!"
    PrintMessage(HUD_PRINTCENTER, message)
    PrintMessage(HUD_PRINTTALK, message)

    -- Subtract the donation from the player
    ply:AddCredits(-credits)
    -- Save the donation amount
    donationCurrent = donationCurrent + credits
    -- Figure out if we're done
    donationMet = donationCurrent >= donationGoal
    -- And broadcast the change to everyone
    net.Start("RdmtJingleJam2022Donation")
    net.WriteUInt(donationCurrent, 8)
    net.Broadcast()
end)

Randomat:register(EVENT)