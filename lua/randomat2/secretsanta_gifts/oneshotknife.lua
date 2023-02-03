local GIFT = {}

GIFT.Name = "One-Shot Knife"
GIFT.Id = "oneshotknife"

function GIFT:Choose(owner, target)
    target:Give("weapon_ttt_secretsantaknife")
end

SECRETSANTA:RegisterGift(GIFT)