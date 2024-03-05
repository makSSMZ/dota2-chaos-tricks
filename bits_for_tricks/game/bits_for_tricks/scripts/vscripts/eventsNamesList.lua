eventsNamesTable = { }

----------add_spell
eventsNamesTable["add_spell_mirana_arrow"] = "dota2_add_spell_mirana_arrow"
eventsNamesTable["add_spell_pudge_meat_hook"] = "dota2_add_spell_pudge_meat_hook"
eventsNamesTable["add_spell_huskar_life_break"] = "dota2_add_spell_huskar_life_break"
eventsNamesTable["add_spell_vengefulspirit_nether_swap"] = "dota2_add_spell_vengefulspirit_nether_swap"
eventsNamesTable["add_spell_techies_land_mines"] = "dota2_add_spell_techies_land_mines"
eventsNamesTable["add_spell_terrorblade_sunder"] = "dota2_add_spell_terrorblade_sunder"
eventsNamesTable["add_spell_blinding_light"] = "dota2_add_spell_blinding_light"
eventsNamesTable["add_spell_puck_phase_shift"] = "dota2_add_spell_puck_phase_shift"

----------ability_on_position
eventsNamesTable["ability_on_position_faceless_void_chronosphere"] = "dota2_ability_on_position_faceless_void_chronosphere"
eventsNamesTable["ability_on_position_enigma_black_hole"] = "dota2_ability_on_position_enigma_black_hole"
eventsNamesTable["ability_on_position_silencer_global_silence"] = "dota2_ability_on_position_silencer_global_silence"
eventsNamesTable["ability_on_position_disruptor_kinetic_field"] = "dota2_ability_on_position_disruptor_kinetic_field"
eventsNamesTable["ability_on_position_puck_dream_coil"] = "dota2_ability_on_position_puck_dream_coil"
eventsNamesTable["ability_on_position_undying_tombstone"] = "dota2_ability_on_position_undying_tombstone" 
eventsNamesTable["ability_on_position_gyrocopter_call_down"] = "dota2_ability_on_position_gyrocopter_call_down"
eventsNamesTable["ability_on_position_bloodseeker_blood_bath"] = "dota2_ability_on_position_bloodseeker_blood_bath"
eventsNamesTable["ability_on_position_techies_stasis_trap"] = "dota2_ability_on_position_techies_land_mines"
eventsNamesTable["ability_on_position_techies_land_mines"] = "dota2_ability_on_position_techies_land_mines"
eventsNamesTable["ability_on_position_kunkka_torrent"] = "dota2_ability_on_position_kunkka_torrent"
eventsNamesTable["ability_on_position_sandking_sand_storm"] = "sandking_sand_storm"
eventsNamesTable["ability_on_position_zuus_thundergods_wrath"] = "dota2_ability_on_position_zuus_thundergods_wrath"

----------ability_on_target
eventsNamesTable["ability_on_target_axe_battle_hunger"] = "dota2_ability_on_target_axe_battle_hunger"
eventsNamesTable["ability_on_target_chaos_knight_chaos_bolt"] = "dota2_ability_on_target_chaos_knight_chaos_bolt"
eventsNamesTable["ability_on_target_bloodseeker_rupture"] = "dota2_ability_on_target_bloodseeker_rupture" 
eventsNamesTable["ability_on_target_bane_nightmare"] = "dota2_ability_on_target_bane_nightmare"
eventsNamesTable["ability_on_target_doom_bringer_doom"] = "dota2_ability_on_target_doom_bringer_doom"
eventsNamesTable["ability_on_target_crystal_maiden_frostbite"] = "dota2_ability_on_target_crystal_maiden_frostbite"
eventsNamesTable["ability_on_target_oracle_false_promise"] = "dota2_ability_on_target_oracle_false_promise"

----------ability_buff
eventsNamesTable["ability_buff_dragon_knight_elder_dragon_form"] = "dota2_ability_buff_dragon_knight_elder_dragon_form"
eventsNamesTable["ability_buff_lycan_shapeshift"] = "dota2_ability_buff_lycan_shapeshift" 
eventsNamesTable["ability_buff_juggernaut_blade_fury"] = "dota2_ability_buff_juggernaut_blade_fury"
eventsNamesTable["ability_buff_nyx_assassin_vendetta"] = "dota2_ability_buff_nyx_assassin_vendetta" 
eventsNamesTable["ability_buff_medusa_stone_gaze"] = "dota2_ability_buff_medusa_stone_gaze"
eventsNamesTable["ability_buff_surge_datadriven"] = "dota2_ability_buff_surge_datadriven"
eventsNamesTable["ability_buff_omniknight_guardian_angel_datadriven"] = "dota2_ability_buff_omniknight_guardian_angel_datadriven"

----------random_tp
eventsNamesTable["random_tp"] = "dota2_random_tp"

----------change_scale
eventsNamesTable["change_scale"] = "dota2_change_scale"

----------respawn_die_hero
eventsNamesTable["respawn_die_hero"] = "dota2_respawn_die_hero"

----------give_two_rapiers
eventsNamesTable["give_two_rapiers"] = "dota2_give_two_rapiers" 

----------need_wtf
eventsNamesTable["need_wtf"] = "dota2_need_wtf"

----------spawn_boss
eventsNamesTable["spawn_boss"] = "dota2_spawn_boss" 

----------respawn_alive_hero
eventsNamesTable["respawn_alive_hero"] = "dota2_respawn_alive_hero"


return eventsNamesTable


--[[ you may need to reset keyTable and myTable before using them
keyTable = { }
myTable = { }

-- to add a new item
addNewItem(keyTable, myTable, "key", "value")
print(myTable["test"])

for _, k in ipairs(keyTable) do 
    print(myTable[k]) 
end]]