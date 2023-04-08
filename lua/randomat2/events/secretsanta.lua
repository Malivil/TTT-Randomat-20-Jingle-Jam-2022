SECRETSANTA = {
    NiceGifts = {},
    NaughtyGifts = {}
}

function SECRETSANTA:RegisterGift(gift, isNaughty)
    -- Make sure this is set correctly
    gift.Id = gift.Id or gift.id or gift.ID
    gift.IsNaughty = isNaughty

    if SECRETSANTA.NiceGifts[gift.Id] or SECRETSANTA.NaughtyGifts[gift.Id] then
        ErrorNoHalt("[RANDOMAT] Secret Santa gift already exists with ID '" .. gift.Id .. "'\n")
        return
    end

    -- Create the "enabled" ConVar for each gift
    local enabled = CreateConVar("randomat_secretsanta_" .. gift.Id .. "_enabled", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether this gift is enabled.", 0, 1)
    gift.Enabled = function()
        return enabled:GetBool()
    end

    if isNaughty then
        SECRETSANTA.NaughtyGifts[gift.Id] = gift
    else
        SECRETSANTA.NiceGifts[gift.Id] = gift
    end
end

local EVENT = {}

util.AddNetworkString("RdmtSecretSantaBegin")
util.AddNetworkString("RdmtSecretSantaChoose")
util.AddNetworkString("RdmtSecretSantaEnd")

resource.AddFile("materials/vgui/ttt/icon_secretsanta.vmt")

CreateConVar("randomat_secretsanta_niceoptions", 2, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of nice gift options to give each player", 1, 10)
CreateConVar("randomat_secretsanta_naughtyoptions", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "The number of naughty gift options to give each player", 1, 10)

EVENT.Title = "Secret Santa"
EVENT.Description = "Every player gets a choice of presents to send, in secret. Will you be nice... or naughty?"
EVENT.id = "secretsanta"
EVENT.Type = EVENT_TYPE_VOTING
EVENT.Categories = {"biased_traitor", "biased", "moderateimpact"}

local plyRecipients = {}
local plyGifts = {}

local function ChooseRandomOptions(options, gifts, giftKeys, giftCount, giftOptions)
    local chosen = {}
    local count = 1
    while count <= giftOptions do
        local idx = math.random(1, giftCount)

        -- If we've already chosen this one (yay GMod randomization) then try again
        if table.HasValue(chosen, idx) then
            continue
        end

        local key = giftKeys[idx]
        local gift = gifts[key]
        if gift:Enabled() and (not gift.Condition or gift:Condition()) then
            table.insert(options, {
                id = key,
                name = gift.name or gift.Name
            })
            table.insert(chosen, idx)
            count = count + 1
        end
    end
end

local function CleanUpGifts()
    for _, gift in pairs(SECRETSANTA.NaughtyGifts) do
        if gift.CleanUp then
            gift:CleanUp()
        end
    end
    for _, gift in pairs(SECRETSANTA.NiceGifts) do
        if gift.CleanUp then
            gift:CleanUp()
        end
    end
end

function EVENT:Begin()
    plyRecipients = {}
    plyGifts = {}

    -- Ensure all gifts are reset back to their default state
    CleanUpGifts()

    -- Generate Santa/Recipient pairs
    local alivePlayers = self:GetAlivePlayers(true)

    -- Assign the first player to the last
    local current = alivePlayers[1]:SteamID64()
    local recip = alivePlayers[#alivePlayers]
    plyRecipients[current] = recip

    -- And then assign everyone else in twos, the "current" to the "previous"
    for idx=2, #alivePlayers do
        current = alivePlayers[idx]:SteamID64()
        recip = alivePlayers[idx - 1]
        plyRecipients[current] = recip
    end

    local niceKeys = table.GetKeys(SECRETSANTA.NiceGifts)
    local niceCount = table.Count(SECRETSANTA.NiceGifts)
    local niceOptions = GetConVar("randomat_secretsanta_niceoptions"):GetInt()
    local naughtyKeys = table.GetKeys(SECRETSANTA.NaughtyGifts)
    local naughtyCount = table.Count(SECRETSANTA.NaughtyGifts)
    local naughtyOptions = GetConVar("randomat_secretsanta_naughtyoptions"):GetInt()

    -- Add a short delay so the chat description has a chance to show before we start sending all these messages
    timer.Simple(0.1, function()
        for _, ply in ipairs(alivePlayers) do
            local options = {}
            ChooseRandomOptions(options, SECRETSANTA.NiceGifts, niceKeys, niceCount, niceOptions)
            ChooseRandomOptions(options, SECRETSANTA.NaughtyGifts, naughtyKeys, naughtyCount, naughtyOptions)

            -- Send options to pairs
            recip = plyRecipients[ply:SteamID64()]
            net.Start("RdmtSecretSantaBegin")
            net.WriteString(recip:Nick())
            net.WriteTable(options)
            net.Send(ply)

            -- Notify each person who their target is
            ply:PrintMessage(HUD_PRINTTALK, "Your '" .. EVENT.Title .. "' recipient is: " .. recip:Nick())
        end
    end)
end

function EVENT:End()
    CleanUpGifts()
    net.Start("RdmtSecretSantaEnd")
    net.Broadcast()
end

local function AddGiftConVars(gift, sliders, checks, textboxes)
    if not gift.AddConVars then return end

    gift:AddConVars(sliders, checks, textboxes)
end

local function AddEnableConVars(gift, checks)
    local name = gift.Id .. "_enabled"
    local convar = GetConVar("randomat_" .. EVENT.id .. "_" .. name)
    table.insert(checks, {
        cmd = name,
        dsc = gift.Name .. " - " .. convar:GetHelpText()
    })
end

function EVENT:GetConVars()
    local sliders = {}
    for _, v in ipairs({"niceoptions", "naughtyoptions"}) do
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

    -- Copy all the gifts into a single table
    local gifts = table.Add(table.Add({}, SECRETSANTA.NaughtyGifts), SECRETSANTA.NiceGifts)

    -- Add enable convars for all of the gifts
    -- Do these first so they are all together above the other checkboxes
    local checks = {}
    for _, gift in SortedPairsByMemberValue(gifts, "Name") do
        AddEnableConVars(gift, checks)
    end

    -- Add all the convars from the gifts
    local textboxes = {}
    for _, gift in SortedPairsByMemberValue(gifts, "Name") do
        AddGiftConVars(gift, sliders, checks, textboxes)
    end

    return sliders, checks, textboxes
end

net.Receive("RdmtSecretSantaChoose", function(len, ply)
    local sid64 = ply:SteamID64()
    if not plyRecipients[sid64] then
        ply:PrintMessage(HUD_PRINTTALK, "You don't have a recipient =(")
        return
    end

    local giftId = net.ReadString()
    -- Get the gift from either list
    local gift = SECRETSANTA.NiceGifts[giftId] or SECRETSANTA.NaughtyGifts[giftId]
    if not gift then
        ply:PrintMessage(HUD_PRINTTALK, "'" .. giftId .. "' is not a valid gift.")
        return
    end

    if plyGifts[sid64] then
        ply:PrintMessage(HUD_PRINTTALK, "You've already sent a present to your recipient.")
        return
    end
    plyGifts[sid64] = giftId

    local recipient = plyRecipients[sid64]
    -- Don't tell the player that this person is dead in case they didn't already know that
    if not IsPlayer(recipient) or not recipient:Alive() or recipient:IsSpec() then
        return
    end

    -- Give their present to their target
    gift:Choose(ply, recipient)
    -- If this is a naughty gift and the Krampus role exists, then mark this player as naughty
    if gift.IsNaughty and type(KRAMPUS_NAUGHTY_OTHER) == "number" and type(MarkPlayerNaughty) == "function" then
        MarkPlayerNaughty(ply, KRAMPUS_NAUGHTY_OTHER)
    end
    recipient:PrintMessage(HUD_PRINTTALK, "Your Secret Santa gave you: " .. gift.Name)
    Randomat:LogEvent("[RANDOMAT] " .. EVENT.Title .. ": " .. ply:Nick() .. " gave " .. recipient:Nick() .. " '" .. gift.Name .. "'")
end)

Randomat:register(EVENT)