local CHOICE = {}

CHOICE.Name = "Radar"
CHOICE.Id = "radar"

function CHOICE:Choose(owner, target)
    target:GiveEquipmentItem(EQUIP_RADAR)
    Randomat:CallShopHooks(true, EQUIP_RADAR, target)
end

SECRETSANTA:RegisterChoice(CHOICE)