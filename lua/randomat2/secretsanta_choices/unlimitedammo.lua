local CHOICE = {}

CHOICE.Name = "Unlimited Ammo"
CHOICE.Id = "unlimitedammo"

function CHOICE:Choose(owner, target)
    print(target:Nick() .. " now has unlimited ammo, thanks to " .. owner:Nick() .. "!")
end

SECRETSANTA:RegisterChoice(CHOICE)