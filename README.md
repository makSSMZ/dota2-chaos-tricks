# Dota2Mode Chaos Tricks
Мод Chaos Tricks для игры Dota 2 
https://steamcommunity.com/sharedfiles/filedetails/?id=2602215701

Все права пренадлежат https://chaostricks.com/

## Использование
В доте общая папка *:\SteamLibrary\steamapps\common\dota 2 beta две ключевые папки games и content
Для кастомного плагина надо из соответствующих папок гита Dota2-mod взять файлы

Релиз кастомки делать по гайду из воркшоп тулзы разработчиков:
https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Workshop_Manager

Папка аддона должна совпадать с прошлой (bits_for_tricks) чтобы избежать переименования у других

## Bots
Enable cheats
chat cmd: spawnbots

## Linl to app
* test: "https://---.com"
* prod: "https://---.com"
To change linkapp need to write in chat: ChangeLinkToApp

## Implemented functions
* add_spell - temporarily adds the ability to the hero. **Call example: add_spell_mirana_arrow**
* ability_on_position - applies an ability from a dummy to a random position. **Call example: ability_on_position_faceless_void_chronosphere**
* random_tp - moves heroes to a random position. **Call example: random_tp**
* change_scale - temporarily сhanges the size of hero models. **Call example: change_scale**
* ability_on_target - applies an ability from a dummy to hero. **Call example: ability_on_target_axe_battle_hunger**
* ability_buff - cast ability on hero. **Call example: ability_buff_dragon_knight_elder_dragon_form**
* respawn_die_hero - respawn hero when die. **Call example: respawn_die_hero**
* need_wtf - enable WTF mode. **Call example: need_wtf**
* spawn_boss - Spawn boss. **Call example: spawn_boss**
* give_two_rapiers - Give 2 rapiers to random hero. **Call example: give_two_rapiers**
* respawn_alive_hero - respawn hero if alive. **Call example: respawn_alive_hero**

### add_spell
* eventsTable["add_spell_mirana_arrow"] = "mirana_arrow_datadriven"
* eventsTable["add_spell_pudge_meat_hook"] = "pudge_meat_hook_lua"
* eventsTable["add_spell_huskar_life_break"] = "life_break_datadriven"
* eventsTable["add_spell_vengefulspirit_nether_swap"] = "vengefulspirit_nether_swap_datadriven"
* eventsTable["add_spell_techies_land_mines"] = "techies_land_mines_datadriven"
* eventsTable["add_spell_terrorblade_sunder"] = "terrorblade_sunder_datadriven"
* eventsTable["add_spell_blinding_light"] = "blinding_light_rewrite"
* eventsTable["add_spell_puck_phase_shift"] = "puck_phase_shift_datadriven"

### ability_on_position
* eventsTable["ability_on_position_faceless_void_chronosphere"] = "faceless_void_chronosphere"
* eventsTable["ability_on_position_enigma_black_hole"] = "enigma_black_hole"
* eventsTable["ability_on_position_silencer_global_silence"] = "silencer_global_silence_datadriven"
* eventsTable["ability_on_position_disruptor_kinetic_field"] = "disruptor_kinetic_field"
* eventsTable["ability_on_position_puck_dream_coil"] = "puck_dream_coil"
* eventsTable["ability_on_position_undying_tombstone"] = "undying_tombstone"
* eventsTable["ability_on_position_gyrocopter_call_down"] = "gyrocopter_call_down"
* eventsTable["ability_on_position_bloodseeker_blood_bath"] = "bloodseeker_blood_bath"
* eventsTable["ability_on_position_techies_stasis_trap"] = "techies_stasis_trap"
* eventsTable["ability_on_position_techies_land_mines"] = "techies_land_mines"
* eventsTable["ability_on_position_kunkka_torrent"] = "kunkka_torrent"
* eventsTable["ability_on_position_sandking_sand_storm"] = "sandking_sand_storm"
* eventsTable["ability_on_position_zuus_thundergods_wrath"] = "zuus_thundergods_wrath"

### ability_on_target
* eventsTable["ability_on_target_axe_battle_hunger"] = "axe_battle_hunger"
* eventsTable["ability_on_target_chaos_knight_chaos_bolt"] = "chaos_knight_chaos_bolt"
* eventsTable["ability_on_target_bloodseeker_rupture"] = "bloodseeker_rupture"
* eventsTable["ability_on_target_bane_nightmare"] = "bane_nightmare"
* eventsTable["ability_on_target_doom_bringer_doom"] = "doom_bringer_doom"
* eventsTable["ability_on_target_crystal_maiden_frostbite"] = "frostbite_datadriven"
* eventsTable["ability_on_target_oracle_false_promise"] = "oracle_false_promise"	

### ability_buff
* eventsTable["ability_buff_dragon_knight_elder_dragon_form"] = "elder_dragon_form_datadriven"
* eventsTable["ability_buff_lycan_shapeshift"] = "lycan_shapeshift_datadriven"
* eventsTable["ability_buff_juggernaut_blade_fury"] = "juggernaut_blade_fury"
* eventsTable["ability_buff_nyx_assassin_vendetta"] = "nyx_assassin_vendetta_datadriven"
* eventsTable["ability_buff_medusa_stone_gaze"] = "medusa_stone_gaze_datadriven"
* eventsTable["ability_buff_surge_datadriven"] = "surge_datadriven"
* eventsTable["ability_buff_omniknight_guardian_angel_datadriven"] = "omniknight_guardian_angel_datadriven"
