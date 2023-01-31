local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaCrabwalkBegin")
util.AddNetworkString("RdmtSecretSantaCrabwalkEnd")

CHOICE.Name = "Crab Walk"
CHOICE.Id = "crabwalk"

function CHOICE:Choose(owner, target)
    net.Start("RdmtSecretSantaCrabwalkBegin")
    net.WriteString(target:SteamID64())
    net.WriteString(owner:SteamID64())
    net.Broadcast()
end

function CHOICE:CleanUp()
    net.Start("RdmtSecretSantaCrabwalkEnd")
    net.Broadcast()
end

SECRETSANTA:RegisterChoice(CHOICE, true)
