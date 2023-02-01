# _Randomat 2.0_ Events Pack for Jingle Jam 2022
A pack of [Randomat 2.0](https://github.com/Malivil/TTT-Randomat-20) events created based on the generous donations of our community members in support of [Jingle Jam 2022](https://www.jinglejam.co.uk/).

# Events

## Jingle All the Way
_Suggested By_: The Lonely Yogs\
If everyone jingles, how will you ever find the Loot Goblin?
\
\
**ConVars**
\
_ttt_randomat_jinglealltheway_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_jinglealltheway_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_jinglealltheway_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.

## Jingle Jam 2022
_Suggested By_: Malivil\
Let's raise some credits for charity! Open the shop menu to donate
\
\
**ConVars**
\
_ttt_randomat_jinglejam2022_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_jinglejam2022_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_jinglejam2022_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_jinglejam2022_mult_ - Default: 1 - The multiplier used when calculating the number of credits to win.

## Secret Santa
_Suggested By_: Noxx\
Every player gets a choice of presents to send, in secret. Will you be nice... or naughty?
\
\
**ConVars**
\
_ttt_randomat_secretsanta_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_secretsanta_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_secretsanta_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_secretsanta_niceoptions_ - Default: 2 - The number of nice gift options to give each player.\
_randomat_secretsanta_naughtyoptions_ - Default: 1 - The number of naughty gift options to give each player.

### Nice Gifts
Gifts that benefit the target player

### *Damage Bonus*
Gives the target player a bonus to the damage they to do others.

#### ConVars
_randomat_secretsanta_damagebonus_bonus_ - Default: 0.5 - The outgoing damage bonus factor. A value of `0.5` means a 50% bonus for a total of 150% of normal damage done.

### *Damage Resistance*
Gives the target player a resistance to the damage done to them.

#### ConVars
_randomat_secretsanta_damageresistance_resistance_ - Default: 0.3 - The incoming damage resistance factor. A value of `0.3` means a 30% resistance for a total of 70% of normal damage received.

### *Defibrillator*
Gives the target player a defibrillator, allowing them to resurrect other players.

### *Explosion Immunity*
Gives the target player immunity to explosions, preventing explosion damage from harming them.

### *Extra HP*
Gives the target player more health and more maximum health.

#### ConVars
_randomat_secretsanta_extrahp_amount_ - Default: 50 - The amount of HP and Maximum HP to give the target.

### *Extra Life*
Gives the target player an extra life, respawning them automatically when they die the first time.

### *Health Regen*
Gives the target player health regeneration, slowly giving them back any lost health over time.

#### ConVars
_randomat_secretsanta_hpregen_amount_ - Default: 1 - How much health to give each interval.\
_randomat_secretsanta_hpregen_interval_ - Default: 5 - How often (in seconds) to heal the player.

### *Health Station*
Gives the target player a deployable health station.

### *Invisible Crouching*
Causes the target player to go invisible when they crouch, making it easier for them to hide.

#### ConVars
_randomat_secretsanta_crouchinvis_reveal_timer_ - Default: 3 - How long (in seconds) to make the target player visible again after they shoot their weapon.

### *One-Shot Knife*
Gives the target player a knife that can kill in one hit.

### *Radar*
Gives the target player radar.

### *Shrink Player*
Causes the target player to shrink smaller in size.

#### ConVars
_randomat_secretsanta_shrink_scale_ - Default: 0.5 - The shrinking scale factor. A value of `0.5` means 50% of normal size, a 50% decrease.

### *Speed Boost*
Gives the target player a boost to their movement speed.

#### ConVars
_randomat_secretsanta_speedboost_mult_ - Default: 1.25 - The speed multiplier. A value of `1.25` means 125% of normal movement speed, a 25% boost.

### *Sprint Speed*
Gives the target player a boost to their movement speed while sprinting.

#### ConVars
_randomat_secretsanta_sprintspeed_mult_ - Default: 1.25 - The speed multiplier. A value of `1.25` means 125% of normal sprinting speed, a 25% boost.

### *Teleporter*
Gives the target player a teleporter.

### *Unlimited Ammo*
Gives the target player unlimited ammunition in their current weapon meaning they will never have to reload.

#### ConVars
_randomat_secretsanta_unlimitedammo_affectbuymenu_ - Default: 0 - Whether it gives buy menu weapons infinite ammo too.

### Naughty Gifts

### *Crab Walk*
Causes the target player to only be able to move sideways.

### *Damage Penalty*
Gives the target player a penalty to the damage they to do others.

#### ConVars
_randomat_secretsanta_damagepenalty_penalty_ - Default: 0.3 - The outgoing damage penalty factor. A value of `0.3` means a 30% penalty for a total of 70% of normal damage done.

### *Flipped Screen*
Flips the target player's screen so everything appears upside-down

### *Grow Player*
Causes the target player to grow larger in size.

#### ConVars
_randomat_secretsanta_grow_scale_ - Default: 1.5 - The growing scale factor. A value of `1.5` means 150% of normal size, a 50% increase.

### *Move Slowly*
Reduce's the target player's movement speed.

#### ConVars
_randomat_secretsanta_speedreduction_mult_ - Default: 0.75 - The speed multiplier. A value of `0.75` means 75% of normal movement speed, a 25% boost.

### *Permanent H.U.G.E.*
Gives the target a H.U.G.E. with infinite ammunition that cannot be dropped

### *Poison*
Poisons the target player, slowly damaging them over time.

#### ConVars
_randomat_secretsanta_poison_amount_ - Default: 1 - How much damage to do each interval.\
_randomat_secretsanta_poison_interval_ - Default: 5 - How often (in seconds) to damage the player.\
_randomat_secretsanta_poison_max_ - Default: 0 - The maximum total damage to do. Set to 0 to disable, causing damage forever.

### *Reduce Health*
Reduces the target player's health and maximum health.

#### ConVars
_randomat_secretsanta_reducehp_factor_ - Default: 0.5 - The health reduction factor. A value of `0.5` means the target player will have 50% less HP and maximum HP.

## The Snap
_Suggested By_: Dragna\
Thanos has activated the Infinity Gauntlet... say goodbye to 1/2 of your friends. If this causes the round to be won by the innocents, everyone snapped will respawn exactly where they were.
\
\
**ConVars**
\
_ttt_randomat_thesnap_ - Default: 1 - Whether this event is enabled.\
_ttt_randomat_thesnap_min_players_ - Default: 0 - The minimum number of players required for this event to start.\
_ttt_randomat_thesnap_weight_ - Default: -1 - The weight this event should use during the randomized event selection process.\
_randomat_thesnap_fadetime_ - Default: 5 - The amount of time the "Five years later" fade lasts.\
_randomat_thesnap_deathdelay_ - Default: 5 - The amount of time before the chosen players are killed.\

## Special Thanks
- Angela of the Lonely Yogs for helping find resources for the "Jingle Jam 2022" event
- Harry and Nick of the Yogscast for providing the bar texture for the "Jingle Jam 2022" event
- Kevin Macleod for the donation complete song used in the "Jingle Jam 2022" event, [Who Likes to Party](https://incompetech.com/music/royalty-free/index.html?Search=Search&isrc=USUAN1200075)