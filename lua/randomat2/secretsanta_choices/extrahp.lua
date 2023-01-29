local CHOICE = {}

CHOICE.Name = "Extra Health"
CHOICE.Id = "extrahp"

function CHOICE:Choose(owner, target)
    print(target:Nick() .. " now has extra health, thanks to " .. owner:Nick() .. "!")
end

SECRETSANTA:RegisterChoice(CHOICE)