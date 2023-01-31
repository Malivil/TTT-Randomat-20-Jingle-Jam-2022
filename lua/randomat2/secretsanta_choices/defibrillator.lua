local CHOICE = {}

CHOICE.Name = "Defibrillator"
CHOICE.Id = "defibrillator"

function CHOICE:Choose(owner, target)
    target:Give("weapon_vadim_defib")
end

function CHOICE:Condition()
    return weapons.Get("weapon_vadim_defib") ~= nil
end

SECRETSANTA:RegisterChoice(CHOICE)