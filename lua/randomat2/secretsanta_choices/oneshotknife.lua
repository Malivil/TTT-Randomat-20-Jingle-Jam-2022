local CHOICE = {}

CHOICE.Name = "One-Shot Knife"
CHOICE.Id = "oneshotknife"

function CHOICE:Choose(owner, target)
    target:Give("weapon_ttt_secretsantaknife")
end

SECRETSANTA:RegisterChoice(CHOICE)