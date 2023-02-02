local sounds = {
    death = {
        sound = {
            Sound("player/death1.wav"),
            Sound("player/death2.wav"),
            Sound("player/death3.wav"),
            Sound("player/death4.wav"),
            Sound("player/death5.wav"),
            Sound("player/death6.wav"),
            Sound("vo/npc/male01/pain07.wav"),
            Sound("vo/npc/male01/pain08.wav"),
            Sound("vo/npc/male01/pain09.wav"),
            Sound("vo/npc/male01/pain04.wav"),
            Sound("vo/npc/Barney/ba_pain06.wav"),
            Sound("vo/npc/Barney/ba_pain07.wav"),
            Sound("vo/npc/Barney/ba_pain09.wav"),
            Sound("vo/npc/Barney/ba_ohshit03.wav"),
            Sound("vo/npc/Barney/ba_no01.wav"),
            Sound("vo/npc/male01/no02.wav"),
            Sound("hostage/hpain/hpain1.wav"),
            Sound("hostage/hpain/hpain2.wav"),
            Sound("hostage/hpain/hpain3.wav"),
            Sound("hostage/hpain/hpain4.wav"),
            Sound("hostage/hpain/hpain5.wav"),
            Sound("hostage/hpain/hpain6.wav")
        },
        delay = 0,
        times = {1, 1},
        burst = false
    },

    shotgun = {
        sound = { Sound("Weapon_XM1014.Single") },
        delay = 0.8,
        times = {1, 3},
        burst = false
    },

    pistol = {
        sound = { Sound("Weapon_FiveSeven.Single") },
        delay = 0.4,
        times = {2, 4},
        burst = false
    },

    mac10 = {
        sound = { Sound("Weapon_mac10.Single") },
        delay = 0.065,
        times = {5, 10},
        burst = true
    },

    deagle = {
        sound = { Sound("Weapon_Deagle.Single") },
        delay = 0.6,
        times = {1, 3},
        burst = false
    },

    m16 = {
        sound = { Sound("Weapon_M4A1.Single") },
        delay = 0.2,
        times = {1, 5},
        burst = true
    },

    rifle = {
        sound = { Sound("weapons/scout/scout_fire-1.wav") },
        delay = 1.5,
        times = {1, 1},
        burst = false,
        ampl = 80
    },

    huge = {
        sound = { Sound("Weapon_m249.Single") },
        delay = 0.055,
        times = {6, 12},
        burst = true
    },

    beeps = {
        sound = { Sound("weapons/c4/c4_beep1.wav") },
        delay = 0.75,
        times = {8, 12},
        burst = true,
        ampl = 70
    }
};

local function startTimer(id, ply, delay_min, delay_max)
    local delay = math.random(delay_min, delay_max)
    timer.Create(id, delay, 1, function()
        -- Get a random player and their position
        local target = nil
        local players = player.GetAll()
        table.Shuffle(players)
        for _, v in pairs(players) do
            if v == ply or not v:Alive() or v:IsSpec() then continue end
            target = v
            break
        end

        if target then
            local pos = target:GetPos()

            -- Move it around a little
            pos.x = pos.x + math.random(-50, 50)
            pos.y = pos.y + math.random(-50, 50)

            local chosen_sound = table.Random(sounds)

            local times = math.random(chosen_sound.times[1], chosen_sound.times[2])
            local t = 0
            for _ = 1, times do
                timer.Simple(t, function()
                    sound.Play(table.Random(chosen_sound.sound), pos, chosen_sound.ampl or 90)
                end)
                if chosen_sound.burst then
                    t = t + chosen_sound.delay
                else
                    t = t + math.Rand(chosen_sound.delay, chosen_sound.delay * 2)
                end
            end

            startTimer(id, target, delay_min, delay_max)
        end
    end)
end

net.Receive("RdmtSecretSantaParanoiaBegin", function()
    local delay_min = net.ReadUInt(8)
    local delay_max = math.max(delay_min, net.ReadUInt(8))
    local client = LocalPlayer()
    startTimer("RdmtSecretSantaParanoia", client, delay_min, delay_max)
end)

net.Receive("RdmtSecretSantaParanoiaEnd", function()
    timer.Remove("RdmtSecretSantaParanoia")
end)