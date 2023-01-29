local CHOICE = {}

CHOICE.Name = "Poison"
CHOICE.Id = "poison"

function CHOICE:Choose(owner, target)
    print(target:Nick() .. " is now poisoned, thanks to " .. owner:Nick() .. "!")
end

SECRETSANTA:RegisterChoice(CHOICE, true)