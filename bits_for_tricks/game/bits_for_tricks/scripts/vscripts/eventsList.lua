eventsTable = { }

----------add_spell
eventsTable["add_spell_mirana_arrow"] = "mirana_arrow_datadriven"
eventsTable["add_spell_pudge_meat_hook"] = "pudge_meat_hook_lua"
eventsTable["add_spell_huskar_life_break"] = "life_break_datadriven"
eventsTable["add_spell_vengefulspirit_nether_swap"] = "vengefulspirit_nether_swap_datadriven"
eventsTable["add_spell_techies_land_mines"] = "techies_land_mines_datadriven"
eventsTable["add_spell_terrorblade_sunder"] = "terrorblade_sunder_datadriven"
eventsTable["add_spell_blinding_light"] = "blinding_light_rewrite"
eventsTable["add_spell_puck_phase_shift"] = "puck_phase_shift_datadriven"

----------ability_on_position
eventsTable["ability_on_position_faceless_void_chronosphere"] = "faceless_void_chronosphere"
eventsTable["ability_on_position_enigma_black_hole"] = "enigma_black_hole"
eventsTable["ability_on_position_silencer_global_silence"] = "silencer_global_silence_datadriven"
eventsTable["ability_on_position_disruptor_kinetic_field"] = "disruptor_kinetic_field"
eventsTable["ability_on_position_puck_dream_coil"] = "puck_dream_coil"
eventsTable["ability_on_position_undying_tombstone"] = "undying_tombstone"
eventsTable["ability_on_position_gyrocopter_call_down"] = "gyrocopter_call_down"
eventsTable["ability_on_position_bloodseeker_blood_bath"] = "bloodseeker_blood_bath"
eventsTable["ability_on_position_techies_stasis_trap"] = "techies_stasis_trap"
eventsTable["ability_on_position_techies_land_mines"] = "techies_land_mines"
eventsTable["ability_on_position_kunkka_torrent"] = "kunkka_torrent"
eventsTable["ability_on_position_sandking_sand_storm"] = "sandking_sand_storm"
eventsTable["ability_on_position_zuus_thundergods_wrath"] = "zuus_thundergods_wrath"

----------ability_on_target
eventsTable["ability_on_target_axe_battle_hunger"] = "axe_battle_hunger"
eventsTable["ability_on_target_chaos_knight_chaos_bolt"] = "chaos_knight_chaos_bolt"
eventsTable["ability_on_target_bloodseeker_rupture"] = "bloodseeker_rupture"
eventsTable["ability_on_target_bane_nightmare"] = "bane_nightmare"
eventsTable["ability_on_target_doom_bringer_doom"] = "doom_bringer_doom"
eventsTable["ability_on_target_crystal_maiden_frostbite"] = "frostbite_datadriven"
eventsTable["ability_on_target_oracle_false_promise"] = "oracle_false_promise"

----------ability_buff
eventsTable["ability_buff_dragon_knight_elder_dragon_form"] = "elder_dragon_form_datadriven"
eventsTable["ability_buff_lycan_shapeshift"] = "lycan_shapeshift_datadriven"
eventsTable["ability_buff_juggernaut_blade_fury"] = "juggernaut_blade_fury"
eventsTable["ability_buff_nyx_assassin_vendetta"] = "nyx_assassin_vendetta_datadriven"
eventsTable["ability_buff_medusa_stone_gaze"] = "medusa_stone_gaze_datadriven"
eventsTable["ability_buff_surge_datadriven"] = "surge_datadriven"
eventsTable["ability_buff_omniknight_guardian_angel_datadriven"] = "omniknight_guardian_angel_datadriven"


return eventsTable


--[[ you may need to reset keyTable and myTable before using them
keyTable = { }
myTable = { }

-- to add a new item
addNewItem(keyTable, myTable, "key", "value")
print(myTable["test"])

for _, k in ipairs(keyTable) do 
    print(myTable[k]) 
end]]