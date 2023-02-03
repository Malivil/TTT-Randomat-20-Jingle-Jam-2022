local GIFT = {}

GIFT.Name = "Teleporter"
GIFT.Id = "teleporter"

function GIFT:Choose(owner, target)
    target:Give("weapon_ttt_teleport")
end

SECRETSANTA:RegisterGift(GIFT)