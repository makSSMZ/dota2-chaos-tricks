"use strict";

function OnExecuteAbility1ButtonPressed(name) {
	let playerID = Players.GetLocalPlayer();
	let hero = Players.GetPlayerHeroEntityIndex(playerID);
	let abil = null;

	let abilsCount = 0;
	let count = 1;
	let indexArr = Array.from({ length: 14 }, (v, k) => 17 + k);

	switch (name) {
		case "CustomGameExecuteAbility1":
			abilsCount = 1;
			break;
		case "CustomGameExecuteAbility2":
			abilsCount = 2;
			break;
		case "CustomGameExecuteAbility3":
			abilsCount = 3;
			break;
		case "CustomGameExecuteAbility4":
			abilsCount = 4;
			break;
		case "CustomGameExecuteAbility5":
			abilsCount = 5;
			break;
		case "CustomGameExecuteAbility6":
			abilsCount = 6;
			break;
		case "CustomGameExecuteAbility7":
			abilsCount = 7;
			break;
		case "CustomGameExecuteAbility8":
			abilsCount = 8;
			break;
		case "CustomGameExecuteAbility9":
			abilsCount = 9;
			break;
		default:
			abilsCount = 1;
	}

	indexArr.every(function (abilIndex, i) {
		abil = Entities.GetAbility(hero, abilIndex);
		if (abil) {
			if ((Abilities.IsActivated(abil) == true) && (Abilities.IsHidden(abil) == false)) {
				if (abilsCount == count) {
					Abilities.ExecuteAbility(abil, hero, false);
					return false;
				}
				else {
					count = count + 1;
					return true;
				}
			}
			else {
				return true;
			}
		}
	});
}

Game.AddCommand("CustomGameExecuteAbility1", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility2", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility3", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility4", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility5", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility6", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility7", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility8", OnExecuteAbility1ButtonPressed, "", 0);
Game.AddCommand("CustomGameExecuteAbility9", OnExecuteAbility1ButtonPressed, "", 0);
