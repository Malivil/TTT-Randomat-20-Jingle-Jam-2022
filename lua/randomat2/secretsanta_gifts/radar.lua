local GIFT = {}

GIFT.Name = "Radar"
GIFT.Id = "radar"

function GIFT:Choose(owner, target)
    target:GiveEquipmentItem(EQUIP_RADAR)
    Randomat:CallShopHooks(true, EQUIP_RADAR, target)
end

SECRETSANTA:RegisterGift(GIFT)