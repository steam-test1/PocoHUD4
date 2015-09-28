-- PocoHud4 Config manager
local ENV = PocoHud4.moduleBegin()
local TRUE,FALSE = true,false
local scheme = {
	root = {	'_opt_root_desc',
		-- enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		detailedModeKey = {'key','`',nil,'_opt_detailedModeKey_desc'},
		detailedModeToggle = {'bool',FALSE,nil,'_opt_detailedModeToggle_desc'},
		showMusicTitlePrefix = {'string','Now Playing: ',nil,'_opt_showMusicTitlePrefix_desc'},
		showMusicTitle = {'bool',TRUE,nil,'_opt_showMusicTitle_desc'},
		shuffleMusic = {'bool',FALSE,nil,'_opt_shuffleMusic_desc'},
		silentKitShortcut = {'bool',TRUE,nil,'_opt_silentKitShortcut_desc'},
		pocoRoseKey = {'key','b',nil,'_opt_pocoRoseKey_desc'},
		pocoRoseHalt = {'bool',FALSE,nil,'_opt_pocoRoseHalt_desc'},
		language = {'string','EN',nil,'_opt_language_desc','language'},
		colorPositive = {'color','YellowGreen','color','_opt_colorPositive_desc',nil,nil,2},
		colorNegative = {'color','Gold','color','_opt_colorNegative_desc',nil,nil,2},
		['24HourClock'] = {'bool',TRUE,nil,'_opt_24HourClock_desc'},
	}, corner = {	'_opt_corner_desc',
		color  = {'color','White','color','_opt_color_desc'},
		opacity = {'num',80,{0,100},'_opt_opacity_desc',nil,5},
		size  = {'num',22,{10,30},'_opt_size_desc'},
		defaultFont  = {'bool',TRUE,nil,'_opt_defaultFont_desc'},
		detailedOnly  = {'bool',FALSE,nil,'_opt_detailedOnly_desc'},
		showFPS  = {'bool',TRUE,nil,'_opt_showFPS_desc'},
		showClockIngame  = {'bool',FALSE,nil,'_opt_showClockIngame_desc'},
		showClockOutgame  = {'bool',TRUE,nil,'_opt_showClockOutgame_desc'},
	}, buff = {	'_opt_buff_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},

		xPosition = {'num',10,{0,100},'_opt_xPosition_desc',nil,2,1},
		yPosition = {'num',22,{0,100},'_opt_yPosition_desc',nil,2,1},
		maxFPS  = {'num',50,nil,'_opt_maxFPS_desc',nil,5,3},
		buffSize = {'num',70,nil,'_opt_buffSize_desc',nil,nil,2},
		gap = {'num',10,nil,'_opt_gap_desc',nil,nil,2},
		justify = {'num',1,{1,3},'_opt_justify_desc','align',nil,2},
		mirrorDirection = {'bool',TRUE,nil,'_opt_mirrorDirection_desc',nil,nil,2},
		style = {'num',1,{1,3},'_opt_style_desc','style',nil,2},

		showBerserker = {'bool',TRUE,nil,'_opt_showBerserker_desc'},
		showSwanSong = {'bool',TRUE,nil,'_opt_showSwanSong_desc'},
		showPainkiller = {'bool',TRUE,nil,'_opt_showPainkiller_desc'},
		showStamina = {'bool',TRUE,nil,'_opt_showStamina_desc'},
		showCharge = {'bool',TRUE,nil,'_opt_showCharge_desc'},
		showTransition = {'bool',TRUE,nil,'_opt_showTransition_desc'},
		showCarryDrop = {'bool',TRUE,nil,'_opt_showCarryDrop_desc'},
		showInteract = {'bool',TRUE,nil,'_opt_showInteract_desc'},
		showInteraction = {'bool',TRUE,nil,'_opt_showInteraction_desc'},
		showInspire = {'bool',TRUE,nil,'_opt_showInspire_desc'},
		showBoost = {'bool',TRUE,nil,'_opt_showBoost_desc'},
		showShield = {'bool',TRUE,nil,'_opt_showShield_desc'},
		showECM = {'bool',TRUE,nil,'_opt_showECM_desc'},
		showFeedback = {'bool',TRUE,nil,'_opt_showFeedback_desc'},
		showTapeLoop = {'bool',TRUE,nil,'_opt_showTapeLoop_desc'},
		showOverkill = {'bool',TRUE,nil,'_opt_showOverkill_desc'},
		showCombatMedic = {'bool',TRUE,nil,'_opt_showCombatMedic_desc'},
		showUnderdog = {'bool',TRUE,nil,'_opt_showUnderdog_desc'},
		showBulletstorm = {'bool',TRUE,nil,'_opt_showBulletstorm_desc'},
		showSuppressed = {'bool',FALSE,nil,'_opt_showSuppressed_desc'},
		showReload = {'bool',TRUE,nil,'_opt_showReload_desc'},
		showTriggerHappy = {'bool',TRUE,nil,'_opt_showTriggerHappy_desc'},
		showFirstAid = {'bool',TRUE,nil,'_opt_showFirstAid_desc'},
		showLifeLeech = {'bool',TRUE,nil,'_opt_showLifeLeech_desc'},
		showCloseCombat = {'bool',TRUE,nil,'_opt_showCloseCombat_desc'},

		noSprintDelay  = {'bool',TRUE,nil,'_opt_noSprintDelay_desc',nil,nil,4},
		hideInteractionCircle  = {'bool',FALSE,nil,'_opt_hideInteractionCircle_desc',nil,nil,4},
		simpleBusyIndicator = {'bool',TRUE,nil,'_opt_simpleBusyIndicator_desc',nil,nil,4},
		simpleBusySize = {'num',10,{5,30},'_opt_simpleBusySize_desc',nil,5,4},
	}, playerFloat = {	'_opt_playerFloat_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		uppercaseNames = {'bool',TRUE,nil,'_opt_uppercaseNames_desc'},
		showIcon = {'num',2,{0,2},'_opt_showIcon_desc','Verbose'},
		showRank = {'num',2,{0,2},'_opt_showRank_desc','Verbose'},
		showDistance = {'num',2,{0,2},'_opt_showDistance_desc','Verbose'},
		showInspire = {'num',2,{0,2},'_opt_showInspire_desc2','Verbose'},
	}, playerBottom = {	'_opt_playerBottom_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		size = {'num',17,{15,30},'_opt_size_desc',nil,2,1},
		offset = {'num',0,{-30,30},'_opt_offset_desc',nil,2,1},
		offsetX = {'num',0,{-3000,3000},'_opt_offsetX_desc',nil,2,1},
		underneath = {'bool',TRUE,nil,'_opt_underneath_desc',nil,nil,1},
		uppercaseNames = {'bool',TRUE,nil,'_opt_uppercaseNames_desc',nil,nil,1},
		showClock = {'num',2,{0,2},'_opt_showClock_desc','Verbose'},
		showRank = {'bool',TRUE,nil,'_opt_showRank_desc'},
		showInteraction = {'num',2,{0,2},'_opt_showInteraction_desc','Verbose'},
		showInteractionTime = {'num',2,{0,2},'_opt_showInteractionTime_desc','Verbose'},
		showKill = {'num',2,{0,2},'_opt_showKill_desc','Verbose'},
		showPosition = {'num',2,{0,2},'_opt_showPosition_desc','Verbose'},
		showSpecial = {'num',2,{0,2},'_opt_showSpecial_desc','Verbose'},
		showInspire = {'num',2,{0,2},'_opt_showInspire_desc2','Verbose'},
		showAverageDamage = {'num',1,{0,2},'_opt_showAverageDamage_desc','Verbose'},
		showHostages = {'num',1,{0,2},'_opt_showHostages_desc','Verbose'},
		showDistance = {'num',2,{0,2},'_opt_showDistance_desc','Verbose'},
		showDowns = {'num',2,{0,2},'_opt_showDowns_desc','Verbose'},
		showPing = {'num',2,{0,2},'_opt_showPing_desc','Verbose'},
		showConvertedEnemy = {'num',1,{0,2},'_opt_showConvertedEnemy_desc','Verbose'},
		showArrow = {'bool',TRUE,nil,'_opt_showArrow_desc'},
		showDetectionRisk = {'num',1,{0,2},'_opt_showDetectionRisk_desc','Verbose'},
	}, popup = {	'_opt_popup_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		size  = {'num',22,{10,30},'_opt_size_desc',nil,nil,1},
		damageDecay  = {'num',10,{3,15},'_opt_damageDecay_desc',nil,nil,1},
		myDamage  = {'bool',TRUE,nil,'_opt_myDamage_desc',nil,nil,2},
		crewDamage  = {'bool',TRUE,nil,'_opt_crewDamage_desc',nil,nil,2},
		AiDamage  = {'bool',TRUE,nil,'_opt_AiDamage_desc',nil,nil,3},
		handsUp  = {'bool',TRUE,nil,'_opt_handsUp_desc',nil,nil,4},
		dominated  = {'bool',TRUE,nil,'_opt_dominated_desc',nil,nil,4},

	}, chat = {	'_opt_chat_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		fallbackToMe = {'bool',TRUE,nil,'_opt_fallbackToMe_desc',nil,nil,1},
		includeLocation = {'bool',TRUE,nil,'_opt_includeLocation_desc',nil,nil,1},
		midstatAnnounce = {'num',0,{0,2},'_opt_midstatAnnounce_desc','MidStat',nil,2},
		midStat  = {'num',1,{0,2},'_opt_midStat_desc','ChatSend',nil,2},
		endStat  = {'num',2,{0,4},'_opt_endStat_desc','ChatSend',nil,3},
		endStatCredit  = {'num',2,{0,4},'_opt_endStatCredit_desc','ChatSend',nil,3},
		dominated  = {'num',2,{0,4},'_opt_dominated_desc','ChatSend',nil,4},
		converted  = {'num',2,{0,4},'_opt_converted_desc','ChatSend',nil,4},
		minionLost  = {'num',2,{0,4},'_opt_minionLost_desc','ChatSend',nil,4},
		minionShot  = {'num',4,{0,4},'_opt_minionShot_desc','ChatSend',nil,4},
		hostageChanged  = {'num',2,{0,4},'_opt_hostageChanged_desc','ChatSend',nil,4},
		custody  = {'num',2,{0,4},'_opt_custody_desc','ChatSend',nil,4},
		downed  = {'num',1,{0,4},'_opt_downed_desc','ChatSend',nil,4},
		downedWarning  = {'num',4,{0,4},'_opt_downedWarning_desc','ChatSend',nil,4},
		replenished  = {'num',3,{0,4},'_opt_replenished_desc','ChatSend',nil,4},
		messiah  = {'num',5,{0,5},'_opt_messiah_desc','ChatSend',nil,5},
		drillDone = {'num',2,{0,4},'_opt_drillDone_desc','ChatSend',nil,6},
		drillAlmostDone = {'num',2,{0,4},'_opt_drillAlmostDone_desc','ChatSend',nil,6},
	}, hit = {	'_opt_hit_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		gainIndicator = {'num',2,{1,3},'_opt_gainIndicator_desc','cantedSight'},
		duration  = {'num',0,{0,10},'_opt_duration_desc','Auto',nil,1},
		opacity  = {'num',50,{0,100},'_opt_opacity_desc',nil,5,1},
		number  = {'bool',TRUE,nil,'_opt_number_desc',nil,nil,1},
		numberSize  = {'num',25,{20,30},'_opt_numberSize_desc',nil,nil,1},
		numberDefaultFont  = {'bool',FALSE,nil,'_opt_numberDefaultFont_desc',nil,nil,1},
		sizeStart  = {'num',100,{50,250},'_opt_sizeStart_desc',nil,50,2},
		sizeEnd  = {'num',200,{50,500},'_opt_sizeEnd_desc',nil,50,3},
		shieldColor = {'color','LawnGreen','color','_opt_shieldColor_desc',nil,nil,4},
		healthColor = {'color','Red','color','_opt_healthColor_desc',nil,nil,5},
		shieldColorDepleted = {'color','Aqua','color','_opt_shieldColorDepleted_desc',nil,nil,4},
		healthColorDepleted = {'color','Magenta','color','_opt_healthColorDepleted_desc',nil,nil,5},
	}, float = {	'_opt_float_desc',
		enable = {'bool',TRUE,nil,'_opt_enable_desc'},
		frame = {'bool',FALSE,nil,'_opt_frame_desc',nil,nil,3},
		size = {'num',15,{10,20},'_opt_size_desc',nil,nil,1},
		margin = {'num',3,{0,5},'_opt_margin_desc',nil,nil,1},
		keepOnScreen = {'bool',TRUE,nil,'_opt_keepOnScreen_desc',nil,nil,2},
		keepOnScreenMarginX = {'num',2,{0,20},'_opt_keepOnScreenMarginX_desc',nil,nil,2},
		keepOnScreenMarginY = {'num',15,{0,20},'_opt_keepOnScreenMarginY_desc',nil,nil,2},
		opacity  = {'num',90,{10,100},'_opt_opacity_desc',nil,5,1},
		showTargets = {'bool',TRUE,nil,'_opt_showTargets_desc',nil,nil,4},
		showDrills = {'bool',TRUE,nil,'_opt_showDrills_desc'},
		showHighlighted = {'bool',TRUE,nil,'_opt_showHighlighted_desc'},
		showConvertedEnemy = {'bool',TRUE,nil,'_opt_showConvertedEnemy_desc2'},
		showBags = {'bool',TRUE,nil,'_opt_showBags_desc'},
	}, game = {	'_opt_game_desc',
		fasterDesyncResolve = {'num',2,{1,3},'_opt_fasterDesyncResolve_desc','DesyncResolve',nil,1},
		fasterAIDesyncResolve = {'num',1,{1,2},'_opt_fasterAIDesyncResolve_desc','DesyncResolve',nil,1},
		interactionClickStick = {'bool',TRUE,nil,'_opt_interactionClickStick_desc',nil,nil,1},
		ingameJoinRemaining = {'bool',TRUE,nil,'_opt_ingameJoinRemaining_desc',nil,nil,1},
		showRankInKickMenu = {'bool',TRUE,nil,'_opt_showRankInKickMenu_desc',nil,nil,1},
		corpseLimit = {'num',3,{1,10},'_opt_corpseLimit_desc','corpse',nil,3},
		corpseRagdollTimeout = {'num',3,{2,10},'_opt_corpseRagdollTimeout_desc','corpse',nil,3},
		cantedSightCrook = {'num',4,{1,4},'_opt_cantedSightCrook_desc','cantedSight',nil,3},
		rememberGadgetState = {'bool',TRUE,nil,'_opt_rememberGadgetState_desc',nil,nil,3},
		subtitleFontSize = {'num',20,{10,30},'_opt_subtitleFontSize_desc',nil,nil,2},
		subtitleFontColor = {'color','White',nil,'_opt_subtitleFontColor_desc',nil,nil,2},
		subtitleOpacity = {'num',100,{10,100},'_opt_subtitleOpacity_desc',nil,10,2},
		romanInfamy = {'bool',TRUE,nil,'_opt_romanInfamy_desc','truncateNames',nil,4},
		truncateNames = {'num',1,{1,8},'_opt_truncateNames_desc','truncateNames',nil,4},
		truncateTags = {'bool',TRUE,nil,'_opt_truncateTags_desc',nil,nil,4},
		sortCrimenet = {'bool',TRUE,nil,'_opt_sortCrimenet_desc',nil,nil,5},
		gridCrimenet = {'bool',TRUE,nil,'_opt_gridCrimenet_desc',nil,nil,5},
		colorizeCrimenet = {'bool',FALSE,nil,'_opt_colorizeCrimenet_desc',nil,nil,5},
		resizeCrimenet = {'num',2,{1,5},'_opt_resizeCrimenet_desc','resizeCrimenet',nil,5},
}}

export = scheme

PocoHud4.moduleEnd()