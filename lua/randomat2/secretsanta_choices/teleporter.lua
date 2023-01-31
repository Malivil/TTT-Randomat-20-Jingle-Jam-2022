local CHOICE = {}

CHOICE.Name = "Teleporter"
CHOICE.Id = "teleporter"

function CHOICE:Choose(owner, target)
    target:Give("weapon_ttt_teleport")
end

SECRETSANTA:RegisterChoice(CHOICE)