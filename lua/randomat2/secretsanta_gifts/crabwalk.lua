local GIFT = {}

util.AddNetworkString("RdmtSecretSantaCrabWalkBegin")
util.AddNetworkString("RdmtSecretSantaCrabWalkEnd")

GIFT.Name = "Crab Walk"
GIFT.Id = "crabwalk"

function GIFT:Choose(owner, target)
    net.Start("RdmtSecretSantaCrabWalkBegin")
    net.Send(target)
end

function GIFT:CleanUp()
    net.Start("RdmtSecretSantaCrabWalkEnd")
    net.Broadcast()
end

function GIFT:Condition()
    return not Randomat:IsEventActive("crabwalk")
end

SECRETSANTA:RegisterGift(GIFT, true)
