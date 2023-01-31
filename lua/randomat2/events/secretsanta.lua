SECRETSANTA = {
    NiceChoices = {},
    NaughtyChoices = {}
}

function SECRETSANTA:RegisterChoice(choice, isNaughty)
    -- Make sure this is set correctly
    choice.Id = choice.Id or choice.id or choice.ID

    if SECRETSANTA.NiceChoices[choice.Id] or SECRETSANTA.NaughtyChoices[choice.Id] then
        ErrorNoHalt("[RANDOMAT] Secret Santa choice already exists with ID '" .. choice.Id .. "'")
        return
    end

    -- Create the "enabled" ConVar for each choice
    local enabled = CreateConVar("randomat_secretsanta_" .. choice.Id .. "_enabled", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Whether this choice is enabled.", 0, 1)
    choice.Enabled = function()
        return enabled:GetBool()
    end

    if isNaughty then
        SECRETSANTA.NaughtyChoices[choice.Id] = choice
    else
        SECRETSANTA.NiceChoices[choice.Id] = choice
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
local plyChoices = {}

local function ChooseRandomOptions(options, choices, choiceKeys, choiceCount, choiceOptions)
    local chosen = {}
    local count = 1
    while count <= choiceOptions do
        local idx = math.random(1, choiceCount)

        -- If we've already chosen this one (yay GMod randomization) then try again
        if table.HasValue(chosen, idx) then
            continue
        end

        local key = choiceKeys[idx]
        local choice = choices[key]
        if choice:Enabled() and (not choice.Condition or choice:Condition()) then
            table.insert(options, {
                id = key,
                name = choice.name or choice.Name
            })
            table.insert(chosen, idx)
            count = count + 1
        end
    end
end

local function CleanUpChoices()
    for _, choice in pairs(SECRETSANTA.NaughtyChoices) do
        if choice.CleanUp then
            choice:CleanUp()
        end
    end
    for _, choice in pairs(SECRETSANTA.NiceChoices) do
        if choice.CleanUp then
            choice:CleanUp()
        end
    end
end

function EVENT:Begin()
    plyRecipients = {}
    plyChoices = {}

    -- Ensure all choices are reset back to their default state
    CleanUpChoices()

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

    local niceKeys = table.GetKeys(SECRETSANTA.NiceChoices)
    local niceCount = table.Count(SECRETSANTA.NiceChoices)
    local niceOptions = GetConVar("randomat_secretsanta_niceoptions"):GetInt()
    local naughtyKeys = table.GetKeys(SECRETSANTA.NaughtyChoices)
    local naughtyCount = table.Count(SECRETSANTA.NaughtyChoices)
    local naughtyOptions = GetConVar("randomat_secretsanta_naughtyoptions"):GetInt()
    for _, ply in ipairs(alivePlayers) do
        local options = {}
        ChooseRandomOptions(options, SECRETSANTA.NiceChoices, niceKeys, niceCount, niceOptions)
        ChooseRandomOptions(options, SECRETSANTA.NaughtyChoices, naughtyKeys, naughtyCount, naughtyOptions)

        -- Send options to pairs
        recip = plyRecipients[ply:SteamID64()]
        net.Start("RdmtSecretSantaBegin")
        net.WriteString(recip:Nick())
        net.WriteTable(options)
        net.Send(ply)

        -- Notify each person who their target is
        ply:PrintMessage(HUD_PRINTTALK, "Your '" .. EVENT.Title .. "' recipient is: " .. recip:Nick())
    end
end

function EVENT:End()
    CleanUpChoices()
    net.Start("RdmtSecretSantaEnd")
    net.Broadcast()
end

local function AddChoiceConVars(choice, sliders, checks, textboxes)
    if not choice.AddConVars then return end

    choice:AddConVars(sliders, checks, textboxes)
end

local function AddEnableConVars(choice, checks)
    local name = choice.Id .. "_enabled"
    local convar = GetConVar("randomat_" .. EVENT.id .. "_" .. name)
    table.insert(checks, {
        cmd = name,
        dsc = choice.Name .. " - " .. convar:GetHelpText()
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

    -- Copy all the choices into a single table
    local choices = table.Add(table.Add({}, SECRETSANTA.NaughtyChoices), SECRETSANTA.NiceChoices)

    -- Add enable convars for all of the choices
    -- Do these first so they are all together above the other checkboxes
    local checks = {}
    for _, choice in SortedPairsByMemberValue(choices, "Name") do
        AddEnableConVars(choice, checks)
    end

    -- Add all the convars from the choices
    local textboxes = {}
    for _, choice in SortedPairsByMemberValue(choices, "Name") do
        AddChoiceConVars(choice, sliders, checks, textboxes)
    end

    return sliders, checks, textboxes
end

net.Receive("RdmtSecretSantaChoose", function(len, ply)
    local sid64 = ply:SteamID64()
    if not plyRecipients[sid64] then
        ply:PrintMessage(HUD_PRINTTALK, "You don't have a recipient =(")
        return
    end

    local choiceId = net.ReadString()
    -- Get the choice from either list
    local choice = SECRETSANTA.NiceChoices[choiceId] or SECRETSANTA.NaughtyChoices[choiceId]
    if not choice then
        ply:PrintMessage(HUD_PRINTTALK, "'" .. choiceId .. "' is not a valid choice.")
        return
    end

    if plyChoices[sid64] then
        ply:PrintMessage(HUD_PRINTTALK, "You've already sent a present to your recipient.")
        return
    end
    plyChoices[sid64] = choiceId

    local recipient = plyRecipients[sid64]
    -- Don't tell the player that this person is dead in case they didn't already know that
    if not IsPlayer(recipient) or not recipient:Alive() or recipient:IsSpec() then
        return
    end

    -- Give their present to their target
    choice:Choose(ply, recipient)
    recipient:PrintMessage(HUD_PRINTTALK, "Your Secret Santa gave you: " .. choice.Name)
    Randomat:LogEvent("[RANDOMAT] " .. EVENT.Title .. ": " .. ply:Nick() .. " gave " .. recipient:Nick() .. " '" .. choice.Name .. "'")
end)

Randomat:register(EVENT)