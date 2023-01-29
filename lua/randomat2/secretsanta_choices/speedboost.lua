local CHOICE = {}

CHOICE.Name = "Speed Boost"
CHOICE.Id = "speedboost"

function CHOICE:Choose(owner, target)
    print(target:Nick() .. " now has a speed boost, thanks to " .. owner:Nick() .. "!")
end

SECRETSANTA:RegisterChoice(CHOICE)