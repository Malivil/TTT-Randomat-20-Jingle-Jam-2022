local GIFT = {}

GIFT.Name = "Health Station"
GIFT.Id = "healthstation"

function GIFT:Choose(owner, target)
    target:Give("weapon_ttt_health_station")
end

SECRETSANTA:RegisterGift(GIFT)