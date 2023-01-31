local CHOICE = {}

CHOICE.Name = "Health Station"
CHOICE.Id = "healthstation"

function CHOICE:Choose(owner, target)
    target:Give("weapon_ttt_health_station")
end

SECRETSANTA:RegisterChoice(CHOICE)