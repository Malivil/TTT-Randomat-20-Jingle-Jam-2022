local GIFT = {}

GIFT.Name = "Defibrillator"
GIFT.Id = "defibrillator"

function GIFT:Choose(owner, target)
    target:Give("weapon_vadim_defib")
end

function GIFT:Condition()
    return weapons.Get("weapon_vadim_defib") ~= nil
end

SECRETSANTA:RegisterGift(GIFT)