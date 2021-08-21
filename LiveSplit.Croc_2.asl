state("Croc2", "US")
{
	int CurTribe            : 0xA8C44;
	int CurLevel            : 0xA8C48;
	int CurMap              : 0xA8C4C;
	int CurType             : 0xA8C50;
	int InGameState         : 0xB7880;
	int IsCheatMenuOpen     : 0xB788C;
	bool IsMapLoaded        : 0xB78C4;
	int NewMainState        : 0xB7930;
	int IsNewMainStateValid : 0xB7934;
	int MainState           : 0xB793C;
	int GobboCounter        : 0x12AEE0;
	int AllowReturnToHub    : 0x12AEFC;
	int DFCrystal5IP        : 0x223D10;
	
	// Temporary solution. This only works for Save Slot 0
	int PrevTribeSS0        : 0x204374;
	// These last three are only used for hub GOA detection
	// You could use LastWad + CurWad instead,
	// BUT it seems every once and a while livesplit will catch the game with its
	// pants down in the middle of updating the wad values, breaking the logic.
	// Haven't seen that elsewhere, so I'm hoping it's a GOA specific thing...
	int PrevLevelSS0        : 0x204378;
	int PrevMapSS0          : 0x20437C;
	int PrevTypeSS0         : 0x204380;
}

state("Croc2", "EU")
{
	int CurTribe            : 0xA9C44;
	int CurLevel            : 0xA9C48;
	int CurMap              : 0xA9C4C;
	int CurType             : 0xA9C50;
	int InGameState         : 0xBEA70;
	int IsCheatMenuOpen     : 0xBEA7C;
	bool IsMapLoaded        : 0xBEAB4;
	int NewMainState        : 0xBEB20;
	int IsNewMainStateValid : 0xBEB24;
	int MainState           : 0xBEB2C;
	int GobboCounter        : 0x1320D0;
	int AllowReturnToHub    : 0x1320EC;
	int DFCrystal5IP        : 0x22AF00;
}

startup
{
	// Start
	settings.Add("RequireUnusedBossWarps", true,
		"Do not start if any boss warp has already been used");
	settings.Add("SaveSlotStart", true,
		"Save slot start");
		settings.SetToolTip("SaveSlotStart",
		"Starts timer on overwriting or creating in a save slot");
	settings.Add("ILstart", false,
		"IL start");
		settings.SetToolTip("ILstart",
		"Starts timer on map change when you enter a level");
	settings.Add("OTSstart", false,
		"OTS start");
		settings.SetToolTip("OTSstart",
		"Starts timer on map change when you enter hub" +
		"\n\n(note: used to record times for the Overworld Times Sheet)" +
		"\n(note: secret is currently disabled, as its OTS isn't set up yet)");
		settings.Add("OTSstart_SMP", false,
		"Also start on SMP entry", "OTSstart");
	settings.Add("IWstart", false,
		"IW start");
		settings.SetToolTip("IWstart",
		"Starts timer on map change when you exit SMP to hub" +
		"\n\n(note: using the cheat menu to warp is equivalent)" +
		"\n(fun fact: WW, SQ, DA, and GOA are not equivalent" +
			"; they give a different hub spawn!)");

	// Split
	settings.Add("SplitOnMapChange", false,
		"IL/OTS end split");
		settings.SetToolTip("SplitOnMapChange",
		"Splits timer on any relevant map change" +
		"\n\n(note: this can be used to chain multiple IL and OTS segments!)" +
		"\n(update: now works even when exiting via GOA)");
		settings.Add("SplitOnMapChange_literal", false,
		"Split on literally any map change", "SplitOnMapChange");
	settings.Add("SplitOnSMPEntry", false,
		"IW end split");
		settings.SetToolTip("SplitOnSMPEntry",
		"Splits timer on map change into SMP" +
		"\n\n(note: this option is redundant if IL/OTS end split is enabled)");
	settings.Add("SplitOnObjectiveCompletion", true,
		"Split on objective completion");
		settings.SetToolTip("SplitOnObjectiveCompletion",
		"(note: you probably want to disable this if doing IL splits)");
		settings.Add("SplitOnGoldenGobbo", false,
		"100% (require Golden Gobbo)", "SplitOnObjectiveCompletion");
	settings.Add("SplitOnBabies", false,
		"Split on 7, 15, 21, and 26 babies");
	settings.Add("SplitOnDanteCrystals", false,
		"Split on collecting crystals in Dante's World");

	// Debug
	settings.Add("DebugOutput", false,
		"Debug output");
		settings.SetToolTip("DebugOutput",
		"Prints debug info in Dbgview.exe" +
		"\n\n(note: allows you to see which changes happened in the same ASL cycle)");
		settings.Add("DO_MapChanges", true,
		"Map changes", "DebugOutput");
		settings.Add("DO_PrevWadSS0", true,
		"PrevWadSS0 changes", "DebugOutput");
		settings.Add("DO_MainState", true,
		"MainState changes", "DebugOutput");
		settings.Add("DO_InGameState", true,
		"InGameState changes", "DebugOutput");
		settings.Add("DO_IsCheatMenuOpen", true,
		"IsCheatMenuOpen changes", "DebugOutput");
		settings.Add("DO_AllowReturnToHub", true,
		"AllowReturnToHub changes", "DebugOutput");
		settings.Add("DO_IsMapLoaded", true,
		"IsMapLoaded changes", "DebugOutput");

	// Returns true iff the current map ID changed
	vars.HasMapIDChanged = new Func<dynamic, dynamic, bool>((state1, state2) =>
		state1.CurTribe != state2.CurTribe || state1.CurLevel != state2.CurLevel ||
		state1.CurMap != state2.CurMap || state1.CurType != state2.CurType);

	// Returns true iff map has specified map ID
	vars.IsThisMap = new Func<dynamic, int, int, int, int, bool>(
		(state, tribe, level, map, type) =>
		state.CurTribe == tribe && state.CurLevel == level &&
		state.CurMap == map && state.CurType == type);
		
	// Returns true iff map is a gobbo hub map
	vars.IsGobboHub = new Func<dynamic, bool>(state =>
		state.CurTribe >= 1 && state.CurTribe <= 4 &&
		state.CurLevel == 1 && state.CurMap == 1 && state.CurType == 0);

	// Returns true iff map is "Swap Meet Pete's General Store"
	vars.IsShopMap = new Func<dynamic, bool>(state =>
		state.CurTribe >= 1 && state.CurTribe <= 4 &&
		state.CurLevel == 1 && state.CurMap == 4 && state.CurType == 0);
		
	// Returns true iff a wrong warp is being performed
	vars.IsWrongWarp = new Func<dynamic, dynamic, bool>((oldState, curState) =>
		// old map is not hub map - can't use functions in functions :(
		!(oldState.CurTribe >= 1 && oldState.CurTribe <= 4 &&
		oldState.CurLevel == 1 && oldState.CurMap == 1 && oldState.CurType == 0) &&
		// new map is hub map
		curState.CurTribe >= 1 && curState.CurTribe <= 4 &&
		curState.CurLevel == 1 && curState.CurMap == 1 && curState.CurType == 0 &&
		// return to hub option enabled (usually set to 0 on door, but will stick if ww)
		curState.AllowReturnToHub == 1 &&
		// saveslot PrevTribe is already 0 (this is the main indicator)
		curState.PrevTribeSS0 == 0);
}

init
{
	// Initialize LastWad
	//		LastWad is simply the previous map you were in
	//		old/current CurWad shows you the map change currently happening
	//		old/current LastWad shows you the previous map change
	// Reminder that this is entirely different from PrevWad!
	//		There is a PrevWad in each save slot, as part of your save data
	//		PrevWad has similar behaviour, but happens on a different timeframe
	current.LastTribe = 0;
	current.LastLevel = 0;
	current.LastMap = 0;
	current.LastType = 0;
	
	vars.LevelBeforeHubWasMasher = false;
	
	var firstModule = modules.First();
	var baseAddr = firstModule.BaseAddress;
	int addrScriptMgr;
	switch (firstModule.ModuleMemorySize)
	{
		case 0x23A000:
			version = "US";
			addrScriptMgr = 0xB78BC;
			vars.AddrSaveSlots      = baseAddr + 0x2040C0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2220FC;
			vars.AddrUsedBossWarps  = baseAddr + 0x222D50;
			vars.DFCrystal5FinalIP  = 0x1741C8;
			break;
		case 0x242000:
			version = "EU";
			addrScriptMgr = 0xBEAAC;
			vars.AddrSaveSlots      = baseAddr + 0x20B2B0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2292EC;
			vars.AddrUsedBossWarps  = baseAddr + 0x229F40;
			vars.DFCrystal5FinalIP  = 0x174210;
			break;
		default:
			return;
	}

	vars.ScriptCodeStart = new DeepPointer(addrScriptMgr, 0x1C);
}

update
{
	if (vars.HasMapIDChanged(old, current))
	{
		// Update LastWad (see definition in `init` for more info)
		current.LastTribe = old.CurTribe;
		current.LastLevel = old.CurLevel;
		current.LastMap = old.CurMap;
		current.LastType = old.CurType;
		
		// Update LevelBeforeHubWasMasher if in caveman hub
		if (vars.IsThisMap(current, 3, 1, 1, 0))
		{
			vars.LevelBeforeHubWasMasher =
			(vars.IsThisMap(old, 3, 2, 1, 1) || vars.IsThisMap(old, 3, 2, 2, 1));
		}
	}
	
	// Debug output
	if (settings["DebugOutput"])
	{
		string debugText = "";
		
		// Map changes
		if (settings["DO_MapChanges"] &&
			vars.HasMapIDChanged(old, current))
		{
			debugText += "\n┃Tribe: " + old.LastTribe.ToString() +
					" -> " + old.CurTribe.ToString() +
					" -> " + current.CurTribe.ToString() +
				"\n┃Level: " + old.LastLevel.ToString() +
					" -> " + old.CurLevel.ToString() +
					" -> " + current.CurLevel.ToString() +
				"\n┃Map:   " + old.LastMap.ToString() +
					" -> " + old.CurMap.ToString() +
					" -> " + current.CurMap.ToString() +
				"\n┃Type:  " + old.LastType.ToString() +
					" -> " + old.CurType.ToString() +
					" -> " + current.CurType.ToString();
		}
		
		// PrevWadSS0 changes
		if (settings["DO_PrevWadSS0"] &&
			(old.PrevTribeSS0 != current.PrevTribeSS0 ||
			old.PrevLevelSS0 != current.PrevLevelSS0 ||
			old.PrevMapSS0 != current.PrevMapSS0 ||
			old.PrevTypeSS0 != current.PrevTypeSS0))
		{
			debugText += "\n┃PrevTribeSS0: " + old.PrevTribeSS0.ToString() +
					" -> " + current.PrevTribeSS0.ToString() +
				"\n┃PrevLevelSS0: " + old.PrevLevelSS0.ToString() +
					" -> " + current.PrevLevelSS0.ToString() +
				"\n┃PrevMapSS0:   " + old.PrevMapSS0.ToString() +
					" -> " + current.PrevMapSS0.ToString() +
				"\n┃PrevTypeSS0:  " + old.PrevTypeSS0.ToString() +
					" -> " + current.PrevTypeSS0.ToString();
		}
		
		// MainState changes
		if (settings["DO_MainState"] &&
			old.MainState != current.MainState)
		{
			debugText += "\n┃MainState: " + old.MainState.ToString() +
				" -> " + current.MainState.ToString();
		}
		
		// InGameState changes
		if (settings["DO_InGameState"] &&
			old.InGameState != current.InGameState)
		{
			debugText += "\n┃InGameState: " + old.InGameState.ToString() +
				" -> " + current.InGameState.ToString();
		}
		
		// IsCheatMenuOpen changes
		if (settings["DO_IsCheatMenuOpen"] &&
			old.IsCheatMenuOpen != current.IsCheatMenuOpen)
		{
			debugText += "\n┃IsCheatMenuOpen: " + old.IsCheatMenuOpen.ToString() +
				" -> " + current.IsCheatMenuOpen.ToString();
		}
		
		// AllowReturnToHub changes
		if (settings["DO_AllowReturnToHub"] &&
			old.AllowReturnToHub != current.AllowReturnToHub)
		{
			debugText += "\n┃AllowReturnToHub: " + old.AllowReturnToHub.ToString() +
				" -> " + current.AllowReturnToHub.ToString();
		}
		
		// IsMapLoaded changes
		if (settings["DO_IsMapLoaded"] &&
			old.IsMapLoaded != current.IsMapLoaded)
		{
			debugText += "\n┃IsMapLoaded: " + old.IsMapLoaded.ToString() +
				" -> " + current.IsMapLoaded.ToString();
		}
		
		// Print output
		if (debugText != "")
		{
			print("┏━━━━━━━━━━━━━┓" +
				debugText +
				"\n┗━━━━━━━━━━━━━┛");
		}
	}
	
	return version != "";
}

start
{
	const int MainState_ChooseSaveSlot =  2;
	const int MainState_Running        = 11;
	const int MainState_LevelSelect    = 18;

	// Reset progress list
	((IDictionary<string, object>)current).Remove("ProgressList");

	// Do not start timer if any boss warp has already been used
	if (settings["RequireUnusedBossWarps"] &&
		memory.ReadValue<int>((IntPtr)vars.AddrUsedBossWarps) != 0)
	{
		return false;
	}

	// Start when main state is in transition from
	// "level select" or "save slot selection" to "running"
	if (settings["SaveSlotStart"] && (
		current.MainState == MainState_ChooseSaveSlot ||
		current.MainState == MainState_LevelSelect) &&
		current.IsNewMainStateValid != 0 &&
		current.NewMainState == MainState_Running)
	{
		return true;
	}

	// The following start condition checks assume the game is running
	// and the current map is an ingame tribe and not a cutscene
	if (current.MainState != MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5 || current.CurType == 3)
	{
		return false;
	}

	// IL start
	if (settings["ILstart"] && 
		vars.HasMapIDChanged(old, current) &&
		// Current map is a non-village map of Dante's World
		// or a non-village level of the Gobbo tribes
		(current.CurTribe == 5 ?
			current.CurMap > 1 :
			(current.CurType != 0 || current.CurLevel > 1)))
	{
		return true;
	}
	
	// OTS start (on hub entry)
	if (settings["OTSstart"] &&
		// entering hub
		// (no secret village for now; its OTS isn't set up yet)
		!vars.IsGobboHub(old) && vars.IsGobboHub(current) &&
		// disallow starting on cheat menu warp
		// (technically a valid SMP->__ segment start, but more intrusive than useful)
		current.IsCheatMenuOpen == 0 &&
		// disallow starting after the opening cutscene when you start a new game
		!vars.IsThisMap(old, 1, 1, 2, 3) &&
		// disallow starting after loading a save
		!vars.IsThisMap(old, 0, 0, 4, 3) &&
		// disallow starting after GOA in gobbo hub or secret hub (invalid spawn)
		!(
			// was on GOA screen
			vars.IsThisMap(old, 0, 0, 2, 3) &&
			// previous map is equal to current map (which is already constrained to hub)
			current.PrevTribeSS0 == current.CurTribe &&
			current.PrevLevelSS0 == current.CurLevel &&
			current.PrevMapSS0 == current.CurMap &&
			current.PrevTypeSS0 == current.CurType
		) &&
		// disallow starting on doing a wrong warp (invalid spawn)
		!vars.IsWrongWarp(old, current))
	{
		return true;
	}
	
	// OTS start (on SMP entry)
	if (settings["OTSstart_SMP"] &&
		vars.HasMapIDChanged(old, current) && vars.IsShopMap(current))
	{
		return true;
	}

	// IW start
	if (settings["IWstart"] &&
		// advancing to a later village
		old.CurTribe < current.CurTribe &&
		// was in one of these places
		(
			// SMP
			vars.IsShopMap(old) ||
			// anywhere, as long as the cheat menu was used
			old.IsCheatMenuOpen == 1
		) &&
		// now in one of these places
		(
			// hub of cossack, caveman, or inca
			(vars.IsGobboHub(current) && current.CurTribe != 1) ||
			// hub of secret sailor
			vars.IsThisMap(current, 5, 2, 1, 0)
		))
	{
		return true;
	}
}

split
{
	// Split on literally any map change
	if (settings["SplitOnMapChange_literal"] &&
		vars.HasMapIDChanged(old, current))
	{
		return true;
	}
	
	// Cancel if main state is not "running" or
	// current tribe is not an ingame tribe
	const int MainState_Running = 11;
	if (current.MainState != MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5)
	{
		((IDictionary<string, object>)current).Remove("ProgressList");
		return false;
	}

	// Prevent IL/OTS end from being skipped when exiting via GOA
	// (old progress list not available at this point, which is why this must go up here?)
	if (settings["SplitOnMapChange"] &&
		vars.HasMapIDChanged(old, current) &&
		// was on GOA screen
		vars.IsThisMap(old, 0, 0, 2, 3) &&
		// disallow split after GOAing in gobbo hub or secret hub (invalid spawn)
		!(
			(
				vars.IsGobboHub(current) ||
				(current.CurTribe == 5 &&
				current.CurLevel >= 2 && current.CurLevel <= 4 &&
				current.CurMap == 1 &&
				current.CurType == 0)
			) &&
			// previous map is equal to current map (hub)
			current.PrevTribeSS0 == current.CurTribe &&
			current.PrevLevelSS0 == current.CurLevel &&
			current.PrevMapSS0 == current.CurMap &&
			current.PrevTypeSS0 == current.CurType
		))
	{
		return true;
	}
	
	// Read progress list
	const int SaveSlotSize = 0x2000;
	var addrSaveSlot = vars.AddrSaveSlots +
		memory.ReadValue<int>((IntPtr)vars.AddrCurSaveSlotIdx) * SaveSlotSize;
	const int ProgressListSize = 0xf0;
	current.ProgressList = memory.ReadBytes(
		(IntPtr)addrSaveSlot + 0x2d0, ProgressListSize);

	// Cancel if old progress list is not available
	if (!((IDictionary<string, object>)old).ContainsKey("ProgressList")) return false;

	// IL/OTS end
	if (settings["SplitOnMapChange"] &&
		vars.HasMapIDChanged(old, current) &&
		// disallow the split after the opening cutscene when you start a new game
		!vars.IsThisMap(old, 1, 1, 2, 3) &&
		// disallow when changing maps within soveena, flytrap, and masher
		!(
			(current.CurTribe == 1 || current.CurTribe == 3) &&
			(current.CurLevel == 1 || current.CurLevel == 2) &&
			old.CurMap == 1 && current.CurMap == 2 &&
			current.CurType == 1
		) &&
		// disallow when re-entering for wrong warp
		// (currently doesn't work if you exit via GOA)
		!(
			// General case
			(
				vars.IsGobboHub(old) && !vars.IsGobboHub(current) &&
				old.LastTribe == current.CurTribe &&
				old.LastLevel == current.CurLevel &&
				// allow the map to be different, so this works for levels like flytrap
				old.LastType == current.CurType &&
				current.AllowReturnToHub == 1
			) ||
			// Masher (the only wrong warpable level with a cutscene)
			(
				// entered caveman hub from masher
				vars.LevelBeforeHubWasMasher &&
				// entering masher from caveman hub
				(
					// caveman hub -> masher cutscene
					(vars.IsThisMap(old, 3, 1, 1, 0) &&
					vars.IsThisMap(current, 3, 1, 1, 3)) ||
					// (caveman hub -> ) masher cutscene -> masher overworld
					(old.LastTribe == 3 &&
					old.LastLevel == 1 &&
					old.LastMap == 1 &&
					old.LastType == 0 &&
					vars.IsThisMap(old, 3, 1, 1, 3) &&
					vars.IsThisMap(current, 3, 2, 1, 1))
				) &&
				// masher objective is complete
				current.ProgressList[129] % 2 == 1
			)
		) &&
		// disallow when doing a wrong warp (invalid spawn)
		!vars.IsWrongWarp(old, current))
	{		
		return true;
	}

	// IW end
	if (settings["SplitOnSMPEntry"] &&
		// was in hub
		vars.IsGobboHub(old) &&
		// now in SMP
		vars.IsShopMap(current) &&
		// restrict to sailor through caveman
		// (inca ends on yellow dante crystal; secret ends on final egg)
		current.CurTribe >= 1 && current.CurTribe <= 3)
	{
		return true;
	}

	// Split on main babies areas
	if (current.CurTribe == 4 &&
		settings["SplitOnBabies"] &&
		old.GobboCounter != current.GobboCounter && (
		current.GobboCounter == 7 ||
		current.GobboCounter == 15 ||
		current.GobboCounter == 21 ||
		current.GobboCounter == 26))
	{
		return true;
	}

	// "Dante's Final Fight": Split when last crystal is placed
	if (current.CurTribe == 4 && current.CurLevel == 2 &&
		current.CurMap == 1 && current.CurType == 1)
	{
		if (old.DFCrystal5IP != current.DFCrystal5IP && current.DFCrystal5IP ==
			vars.ScriptCodeStart.Deref<int>(game) + vars.DFCrystal5FinalIP)
		{
			return true;
		}
	}
	// Other levels: check whether progress has changed
	else
	{
		for (int tribe = 1; tribe <= 5; ++tribe)
		for (int level = 1; level <= 7; ++level)
		for (int type  = 0; type  <= 3; ++type)
		{
			// Index into progress list
			int i = tribe * 40 + level * 4 + type;

			// Skip unchanged entries
			int oldFlags = old.ProgressList[i], newFlags = current.ProgressList[i];
			if (oldFlags == newFlags) continue;

			// Dante's World (Secret Village)
			if (tribe == 5)
			{
				// Split on both gems and eggs
				if (settings["SplitOnDanteCrystals"])
				{
					return true;
				}
				// Or only split on eggs
				else
				{
					const int CrystalFlags = 0x1f;
					if ((oldFlags & ~CrystalFlags) != (newFlags & ~CrystalFlags))
					{
						return true;
					}
				}
			}
			
			// Stop if not using split on objective completion
			else if (!settings["SplitOnObjectiveCompletion"]) continue;

			// Split on any progress change for certain levels
			else if (
				// Boss level or secret level (as in Jigsaw)
				type != 0 ||
				// "Bride of the Dungeon of Defright" or "Goo Man Chu's Tower"
				(tribe == 4 && (level == 5 || level == 6)))
			{
				return true;
			}
			
			// Other levels
			else
			{
				// Check for main objective and possibly Golden Gobbo
				int checkFlags = settings["SplitOnGoldenGobbo"] ? 5 : 1;
				int currentFlags = newFlags & checkFlags;
				// Split if all flags are set now and were not set previously
				if (currentFlags == checkFlags &&
					currentFlags != (oldFlags & checkFlags))
				{
					return true;
				}
			}
		}
	}
}

isLoading
{
	const int MainState_Running = 11;
	return current.MainState == MainState_Running && (
		current.InGameState == 6 || current.InGameState == 7 ||
		!current.IsMapLoaded);
}
