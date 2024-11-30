local GIFT = {}

util.AddNetworkString("RdmtSecretSantaBlindishBegin")
util.AddNetworkString("RdmtSecretSantaBlindishEnd")

GIFT.Name = "Blind...ish"
GIFT.Id = "blindish"

function GIFT:Choose(owner, target)
    target:ScreenFade(SCREENFADE.STAYOUT, Color(0, 0, 0, 255), 0, 0)

    net.Start("RdmtSecretSantaBlindishBegin")
    net.Send(target)
end

function GIFT:CleanUp()
    for _, p in player.Iterator() do
        p:ScreenFade(SCREENFADE.PURGE, Color(0, 0, 0, 255), 0, 0)
    end

    net.Start("RdmtSecretSantaBlindishEnd")
    net.Broadcast()
end

SECRETSANTA:RegisterGift(GIFT, true)
