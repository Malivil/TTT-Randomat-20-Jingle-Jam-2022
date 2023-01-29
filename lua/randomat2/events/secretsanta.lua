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
        table.insert(options, {
            id = key,
            name = choice.name or choice.Name
        })
        table.insert(chosen, idx)
        count = count + 1
    end
end

function EVENT:Begin()
    plyRecipients = {}
    plyChoices = {}

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
    net.Start("RdmtSecretSantaEnd")
    net.Broadcast()
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
    return sliders
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
    choice:Choose(ply, plyRecipients[sid64])
end)

Randomat:register(EVENT)