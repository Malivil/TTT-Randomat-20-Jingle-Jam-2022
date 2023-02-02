local CHOICE = {}

util.AddNetworkString("RdmtSecretSantaBlindishBegin")
util.AddNetworkString("RdmtSecretSantaBlindishEnd")

CHOICE.Name = "Blind...ish"
CHOICE.Id = "blindish"

function CHOICE:Choose(owner, target)
    target:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 0)

    net.Start("RdmtSecretSantaBlindishBegin")
    net.Send(target)
end

function CHOICE:CleanUp()
    for _, p in ipairs(player.GetAll()) do
        p:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 255), 0, 0)
    end

    net.Start("RdmtSecretSantaBlindishEnd")
    net.Broadcast()
end

SECRETSANTA:RegisterChoice(CHOICE, true)
