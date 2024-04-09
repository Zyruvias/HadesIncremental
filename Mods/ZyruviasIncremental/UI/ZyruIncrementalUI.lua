local CreateBoonPresentation = function (screen, traitName, x, y)

    -- fetchInfo
    local originalData = ZyruIncremental.Data.BoonData[traitName]
    local zyruBoonData = CurrentRun.ZyruBoonData[traitName]
    local trait = TraitData[traitName]

    --setup UI info
    local components = screen.Components
    local xOffset = x
    local yOffset = y

    -- create boon icon
    local traitIcon = CreateScreenComponent({ Name = "TraitTrayIconButton", X = xOffset, Y = yOffset })
    SetAnimation({ Name = GetTraitIcon( trait ), DestinationId = traitIcon.Id })
    trait.AnchorId = traitIcon.Id
    traitIcon.OffsetX = xOffset
    traitIcon.OffsetY = yOffset
    -- create boon frame
    local traitFrameId = CreateScreenObstacle({ Name = "BlankObstacle" })
    Attach({ Id = traitFrameId, DestinationId = traitIcon.Id })
    if GetTraitFrame(trait) ~= nil then
        local traitFrame = GetTraitFrame( trait )
        local rarityValue = GetRarityValue( trait )
        if CurrentRun.Hero.TraitDictionary[trait.Name] ~= nil then
            for i, existingTrait in pairs( CurrentRun.Hero.TraitDictionary[trait.Name]) do
                if (AreTraitsIdentical(trait, existingTrait) and rarityValue < GetRarityValue( existingTrait.Rarity )) then
                    rarityValue = GetRarityValue( existingTrait.Rarity )
                    traitFrame = GetTraitFrame( existingTrait )
                end
            end
        end
        SetAnimation({ Name = traitFrame, DestinationId = traitFrameId })
    end
    -- boon name
    CreateTextBox({
        Id = traitIcon.Id,
        Text = GetTraitTooltip(trait),
        Font = "AlegreyaSansSCRegular",
        Color = Color.White,
        ShadowBlur = 0,ShadowColor = {0,0,0,1}, ShadowOffset={1, 2},
        FontSize = 20,
        OffsetX = 60, OffsetY = - 6 * TraitUI.SpacerY / 8 ,
        Justification = "Center",
    })

    -- boon level
    local traitCount = GetTraitCount(CurrentRun.Hero, trait)
    if traitCount > 1 then
        traitIcon.TraitInfoCardId = CreateScreenObstacle({ Name = "TraitTray_LevelBacking" })
        Attach({ Id = traitIcon.TraitInfoCardId, DestinationId = traitIcon.Id, OffsetY = 32 })
        CreateTextBox({
            Id = trait.TraitInfoCardId,
            Text = "UI_TraitLevel",
            Font = "AlegreyaSansSCBold",
            Color = Color.White,
            ShadowBlur = 0,ShadowColor = {0,0,0,1}, ShadowOffset={1, 2},
            FontSize = 16,
            OffsetX = 45, OffsetY = 0 ,
            Justification = "Center",
            LuaKey = "TempTextData", LuaValue = { Amount = traitCount }
        })
    end
    -- boon progress info per boon
    -- activation count
    local traitTextOffsetY = - 3 * TraitUI.SpacerY / 8
    CreateTextBox({
        Id = traitIcon.Id,
        Text = "Activation Count: " .. tostring(zyruBoonData.Count or 0),
        FontSize = 14,
        OffsetX = 60,
        OffsetY = traitTextOffsetY,
        Color = { 192, 192, 192, 255 },
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0,
        ShadowColor = {0,0,0,0},
        ShadowOffset={0, 3},
        Justification = "Left",
    })
    traitTextOffsetY = traitTextOffsetY + TraitUI.SpacerY / 4
    -- total damage
    CreateTextBox({
        Id = traitIcon.Id,
        Text = "Damage Contribution: " .. tostring(round(zyruBoonData.Value) or 0),
        FontSize = 14,
        OffsetX = 60,
        OffsetY = traitTextOffsetY,
        Color = { 192, 192, 192, 255 },
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0,
        ShadowColor = {0,0,0,0},
        ShadowOffset={0, 3},
        Justification = "Left",
    })
    traitTextOffsetY = traitTextOffsetY + TraitUI.SpacerY / 4

    -- Experience Gained
    CreateTextBox({
        Id = traitIcon.Id,
        Text = "Experience Gained: " .. tostring(round(zyruBoonData.Experience) or 0),
        FontSize = 14,
        OffsetX = 60,
        OffsetY = traitTextOffsetY,
        Color = { 192, 192, 192, 255 },
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0,
        ShadowColor = {0,0,0,0},
        ShadowOffset={0, 3},
        Justification = "Left",
    })
    -- Leve Gained
    traitTextOffsetY = traitTextOffsetY + TraitUI.SpacerY / 4
    CreateTextBox({
        Id = traitIcon.Id,
        Text = "Boon Level: " .. tostring(round(originalData.Level) or 0),
        FontSize = 14,
        OffsetX = 60,
        OffsetY = traitTextOffsetY,
        Color = { 192, 192, 192, 255 },
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0,
        ShadowColor = {0,0,0,0},
        ShadowOffset={0, 3},
        Justification = "Left",
    })
    table.insert( components, traitIcon )

end

function CreateAnalyticsScreen (screen)

    local pageToDisplay = screen.PageIndex
    local boonsPerPage = 20

    local components = screen.Components

    local boonsToDisplay = {}

    for name, data in pairs(CurrentRun.ZyruBoonData) do
        if TraitData[name] ~= nil and ZyruIncremental.Data.BoonData[name] ~= nil and not Contains(boonsToDisplay, name) then
            table.insert(boonsToDisplay, name)
        end
    end

    local startX = TraitUI.SpacerX + 100
    local startY = TraitUI.SpacerY + 250
    local xGap = ScreenWidth / 5
    local yGap = ScreenHeight / 7
    for i, traitName in ipairs(boonsToDisplay) do
        if i <= pageToDisplay * boonsPerPage and i >= (pageToDisplay - 1) * boonsPerPage then
            local x = startX + xGap * math.floor((i - 1) / 5)
            local y = startY + yGap * ((i - 1) % 5)
            CreateBoonPresentation(screen, traitName, x, y)
        end
    end
end

ModUtil.Path.Wrap("CloseRunClearScreen", function (baseFunc, ...)
    baseFunc( ... )
    -- note: threading to not force players to give up in case of crash, sorry beta users.
    thread(function()
        local screen = ZyruIncremental.CreateMenu("RunAnalyticsScreen", {
            PauseBlock = true,
            Pages = {
                [1] = "CreateAnalyticsScreen",
                [2] = "CreateAnalyticsScreen",
                [3] = "CreateAnalyticsScreen",
            },
            Components = {
                {
                    Type = "Button",
                    SubType = "Close"
                },
                {
                    Type = "Text",
                    SubType = "Title",
                    FieldName = "BoonProgressionTitle",
                    Args = {
                        Text = "Boon Progression"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "BoonProgressionSubtitle",
                    Args = {
                        Text = "Wow, you sure used some boons today Zagreus."
                    }
                }
            },
        })
    end)
end, ZyruIncremental)

function ZyruIncremental.HandleExperiencePresentationBehavior(traitName, godName, expGained, victim)
    local behavior = ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior
    godName = godName or "Unknown"
    if behavior == ZyruIncremental.Constants.Settings.EXP_ON_HIT or victim == nil or victim == CurrentRun.Hero then
        color = ZyruIncremental.BoonToGod[traitName] and Color[ZyruIncremental.BoonToGod[traitName] .. "DamageLight"] or Color.Gray
        thread( DisplayExperiencePopup, expGained, { Color = color })
    elseif behavior == ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_BOON  then
        victim.ZyruExperienceMap = victim.ZyruExperienceMap or {}
        victim.ZyruExperienceMap[traitName] = victim.ZyruExperienceMap[traitName] or 0
        victim.ZyruExperienceMap[traitName] = victim.ZyruExperienceMap[traitName] + expGained
    elseif behavior == ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_GOD then
        victim.ZyruExperienceMap = victim.ZyruExperienceMap or {}
        victim.ZyruExperienceMap[godName] = victim.ZyruExperienceMap[godName] or 0
        victim.ZyruExperienceMap[godName] = victim.ZyruExperienceMap[godName] + expGained
    end
end

function ZyruIncremental.HandleKillEnemyExperiencePresentation(victim)
    local behavior = ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior
    ZyruIncremental.Victim = victim
    if not victim or not victim.ZyruExperienceMap then
        return
    end
    if  behavior == ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_BOON then
        for traitName, expGained in pairs(victim.ZyruExperienceMap or {}) do
            local color = Color[tostring(ZyruIncremental.BoonToGod[traitName]) .. "DamageLight"] or Color.White
            thread( DisplayExperiencePopup, expGained, { Color = color, DestinationId = victim.ObjectId })
            wait(0.1)
        end
    elseif behavior == ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_GOD then
        for godName, expGained in pairs(victim.ZyruExperienceMap) do
            thread( DisplayExperiencePopup, expGained, { Color = Color[godName .. "DamageLight"], DestinationId = victim.ObjectId })
            wait(0.25)
        end
    end
end

ModUtil.Path.Wrap("KillEnemy", function (base, victim, triggerArgs)
    thread(ZyruIncremental.HandleKillEnemyExperiencePresentation, victim)
    base(victim, triggerArgs)
end, ZyruIncremental)

function DisplayExperiencePopup (amount, args)
    local displayAmount = round(amount)
    if displayAmount <= 0 then
        return
    end
    
	local randomOffsetX = RandomInt( -50, 50 )
	local randomOffsetY = RandomInt( -50, 50 )

    local damageTextAnchor = SpawnObstacle({
        Name = "BlankObstacleNoTimeModifier",
        DestinationId = args.DestinationId or CurrentRun.Hero.ObjectId,
        Group = "Combat_UI_World", 
        OffsetX = randomOffsetX,
        OffsetY = randomOffsetY,
    })
    
    local color = args.Color or { 192, 192, 192, 255 }
    local fontScaling = math.min(18, math.pow(displayAmount, 0.333))
    CreateTextBox({
        Id = damageTextAnchor,
        RawText = "+ " .. tostring(displayAmount) .. "xp",
        FontSize = 18 + fontScaling,
        Justification = "CENTER",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset = {2, 2},
        OutlineThickness = 1, OutlineColor = {0,0,0},
        Color = color,
        Font = "AlegreyaSansSCExtraBold",
        AutoSetDataProperties = false,
    })
    
	SetAlpha({ Id = damageTextAnchor, Fraction = 0.0, Duration = 1 + math.min(2, math.pow(amount, 0.25)) })
    
    wait(1 + math.min(2, math.pow(amount, 0.25)))
    Destroy({Id = damageTextAnchor })
					
end

function ZyruIncremental.HandleBoonLevelupBehavior (traitName, level, god)

    local showOverhead = 
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_POPUP or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_ALL

    local playVoiceline = 
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_VOICELINE or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_PORTRAIT or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_ALL

    local showPortrait = 
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_PORTRAIT or
        ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior == ZyruIncremental.Constants.Settings.LEVEL_ALL

    if showOverhead then
        thread(DisplayBoonLevelupPopup, traitName, level)
    end

    if playVoiceline and god ~= nil then
        local voiceLine = GetRandomValue(ZyruIncremental.BoonLevelUpVoiceLines[god])
        if voiceline ~= nil then
            thread(PlayVoiceLine, voiceLine)
        end
    end

    if showPortrait and god ~= nil then
        thread(ShowBoonLevelupPortrait, god)
    end
end

function DisplayBoonLevelupPopup( traitName, level )
    local traitTitle = traitName
    if TraitData[traitName] then 
        traitTitle = GetTraitTooltipTitle(TraitData[traitName])
    end
    PlaySound({ Name = "/SFX/PomegranateLevelUpSFX", DestinationId = CurrentRun.Hero.ObjectId })
    InCombatTextArgs({
        TargetId = CurrentRun.Hero.ObjectId,
        Text = "ZyruBoonLevelUp",
        SkipRise = false,
        SkipFlash = true,
        ShadowScale = 1.1,
        ShadowScaleX = 1.2,
        Duration = 1.5,
        OffsetY = -150,
        LuaKey = "TempTextData",
        LuaValue = { Name = tostring(traitTitle), Level = tostring(level) }
    })
end

function ShowBoonLevelupPortrait (god)
    local screen = {} 
    screen.PortraitId = CreateScreenObstacle({ Name = "BlankObstacle", X = ScreenCenterX - 490, Y = ScreenCenterY + 105, Group = "Combat_Menu" })
    SetAnimation({ DestinationId = screen.PortraitId, Name = "Portrait_" .. god .. "_Default_01"})
    wait(1.5)
    SetAnimation({ DestinationId = screen.PortraitId, Name = "Portrait_" .. god .. "_Default_01_Exit"})
    wait(0.3)
    Destroy { Id = screen.PortraitId }
end

function CloseScreenByName ( name )
	local screen = ScreenAnchors[name]
	DisableShopGamepadCursor()
	CloseScreen( GetAllIds( screen.Components ) )
	PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
	UnfreezePlayerUnit()
	ToggleControl({ Names = { "AdvancedTooltip" }, Enabled = true })
	ShowCombatUI(name)
    screen.AllowInput = false
	SetConfigOption({ Name = "ExclusiveInteractGroup", Value = nil })
	-- SetConfigOption({ Name = "FreeFormSelectRepeatDelay", Value = 0.0 })
	-- SetConfigOption({ Name = "GamepadCursorFreeFormSelect", Value = true })
	-- SetConfigOption({ Name = "FreeFormSelectGridLock", Value = false })
	-- SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 8 })
	-- SetConfigOption({ Name = "FreeFormSelecSearchFromId", Value = 0 })
	screen.KeepOpen = false
	OnScreenClosed({ Flag = screen.Name })
end

-- Courtyard Progress Screen
function ShowZyruResetScreen ()
    CreateAnimation({ Name = "ItemGet_PomUpgraded", DestinationId = CurrentRun.Hero.ObjectId, Scale = 2.0 })
    thread( InCombatTextArgs, {
        TargetId = CurrentRun.Hero.ObjectId,
        Text = "Coming Soon!",
        SkipRise = false,
        SkipFlash = true,
        ShadowScale = 0.66,
        Duration = 1.5,
        OffsetY = -100 })
    offsetY = offsetY - 60
    thread(PlayVoiceLines, GlobalVoiceLines.InvalidResourceInteractionVoiceLines)
end

-- Courtyard Interface

function LolLmao(button)
    local voiceline = GetRandomValue(ZyruIncremental.DropLevelUpVoiceLines.RoomRewardMaxHealthDrop)
    
    thread( PlayVoiceLines, voiceline )
end
function ZyruIncremental.DirectionHint(goal)
    local indicatorId = SpawnObstacle({ Name = "DirectionHintArrow", Group = "FX_Standing_Add", DestinationId = CurrentRun.Hero.ObjectId, OffsetX = 0, OffsetZ = 0 })
    AdjustZLocation({ Id = indicatorId, Distance = 100 })
    SetScale({ Id = indicatorId, Fraction = 2.0 })
    SetAngle({
        Id = indicatorId,
        Angle = GetAngleBetween({
            Id = CurrentRun.Hero.ObjectId,
            DestinationId = goal.ObjectId
        })
    })
    Move({ Id = indicatorId, DestinationId = goal.ObjectId, Duration = 1, SmoothStep = true })
    PlaySound({ Name = "/Leftovers/SFX/PowerUpFwoosh", id = indicatorId })

    wait (1, RoomThreadName)

    Destroy({ Id = indicatorId })
end
-- EventPresentation.lua:1246
function ZyruIncremental.DirectionHintPresentationRework()
    local voicelines = HeroVoiceLines.InteractionBlockedVoiceLines
    local text  = "ExitNotActive"
    if CheckCooldown( "DirectionHint", 3 ) then
        -- iterate over active objects and simulate the direction hint
        local i = 0
        for objectId, goal in pairs( ActivatedObjects ) do
			if goal.BlockExitText ~= nil then
				text = goal.BlockExitText
			end
            wait( 0.75, RoomThreadName )
            if not IsAlive({ Id = goal.ObjectId }) then
                return
            end

            thread(ZyruIncremental.DirectionHint, goal)

            thread( PlayVoiceLines, voiceLines, true )
            thread( InCombatText, CurrentRun.Hero.ObjectId, text, 1.5, { ShadowScale = 0.66, OffsetY = 55 - 60 * i } )
            i = i + 1
		end
		

	end
end

ModUtil.Path.Wrap("UseEscapeDoor", function(base, usee, args)
    -- courtyard flags to force users to Check Shit Out
    if (
        not ZyruIncremental.Data.Flags.SeenProgressMenu
        or not ZyruIncremental.Data.Flags.SeenUpgradeMenu
        or not ZyruIncremental.Data.Flags.SeenSettingsMenu
        or not ZyruIncremental.Data.Flags.SeenRamblingsMenu
    ) then
        return thread( ZyruIncremental.DirectionHintPresentationRework )
    end
    
    if ZyruIncremental.Data.FileOptions.StartingPoint == ZyruIncremental.Constants.SaveFile.EPILOGUE then
        return UseShrineObject(usee, args)
    end
    return base(usee, args)
end, ZyruIncremental)

OnAnyLoad{"RoomPreRun", function(triggerArgs)
    -- Upgrade Loading
    local upgradeCabinet = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    upgradeCabinet.UseText = "{I} View Upgrades"
    upgradeCabinet.OnUsedFunctionName = "ShowZyruUpgradeScreen"
    upgradeCabinet.Activate = true
    upgradeCabinet.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        AttachedTable = upgradeCabinet,
        OffsetX = 2000,
        OffsetY = -750,
    })
    if not ZyruIncremental.Data.Flags.SeenUpgradeMenu then
        ZyruIncremental.UpgradeMenuObjectId = upgradeCabinet.ObjectId
        upgradeCabinet.BlockExitUntilUsed = true
        upgradeCabinet.BlockExitText = "View upgrades!"
    end
    SetScale{ Id = upgradeCabinet.ObjectId, Fraction = 0.17 }
    SetColor{ Id = upgradeCabinet.ObjectId, Color = { 120, 255, 170, 255 } }
    SetupObstacle( upgradeCabinet )
    AddToGroup({Id = upgradeCabinet.ObjectId, Name = "ChallengeSelector"})
    -- Boon Data Loading
    
    local progressCabinet = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    progressCabinet.UseText = "{I} View Progress and Stats"
    progressCabinet.OnUsedFunctionName = "ShowZyruProgressScreen"
    progressCabinet.Activate = true
    progressCabinet.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        AttachedTable = progressCabinet,
        OffsetX = 2300,
        OffsetY = -650,
    })
    
    if not ZyruIncremental.Data.Flags.SeenProgressMenu then
        ZyruIncremental.ProgressMenuObjectId = progressCabinet.ObjectId
        progressCabinet.BlockExitUntilUsed = true
        progressCabinet.BlockExitText = "View your boon level progress!"
    end
    SetScale{ Id = progressCabinet.ObjectId, Fraction = 0.17 }
    SetupObstacle( progressCabinet )
    AddToGroup({Id = progressCabinet.ObjectId, Name = "ChallengeSelector"})


    --------------------------
    -- RESET GATE ---
    --------------------------
    local shrinePointDoor = DeepCopyTable( ObstacleData.ShrinePointDoor )
    shrinePointDoor.ObjectId = SpawnObstacle({
        Name = "ShrinePointDoor",
        Group = "FX_Terrain",
        DestinationId = CurrentRun.Hero.ObjectId,
        OffsetX = -1250, OffsetY = -1150,
        AttachedTable = shrinePointDoor
    })
    SetupObstacle( shrinePointDoor )
    shrinePointDoor.ShrinePointReq = 0
    shrinePointDoor.UseText = "{I} Begin Anew?"
    shrinePointDoor.OnUsedFunctionName = "ShowZyruResetScreen"
    shrinePointDoor.Activate = true
    -- SetScale{ Id = shrinePointDoor.ObjectId, Fraction = 0.17 }
    SetColor{ Id = shrinePointDoor.ObjectId, Color = { 120, 255, 170, 255 } }
    AddToGroup({Id = shrinePointDoor.ObjectId, Name = "ChallengeSelector"})

    --------------------------
    -- SETTINGS TABLE ---
    --------------------------
    local settingsSelector = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699]  )
    settingsSelector.ObjectId = SpawnObstacle({
        Name = "HouseFiles01",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        OffsetX = 2150, OffsetY = -700,
        AttachedTable = settingsSelector,
        ForceToValidLocation = true,
    })
    settingsSelector.ShrinePointReq = 0
    settingsSelector.UseText = "{I} Mod Settings"
    settingsSelector.OnUsedFunctionName = "ShowZyruSettingsMenu"
    settingsSelector.Activate = true
    if not ZyruIncremental.Data.Flags.SeenSettingsMenu then
        ZyruIncremental.SettingsMenuObjectId = settingsSelector.ObjectId
        settingsSelector.BlockExitUntilUsed = true
        settingsSelector.BlockExitText = "Check out mod settings!"
    end
    SetScale{ Id = settingsSelector.ObjectId, Fraction = 0.666 } -- :croven:
    SetColor{ Id = settingsSelector.ObjectId, Color = { 120, 255, 170, 255 } }
    AddToGroup({Id = settingsSelector.ObjectId, Name = "ChallengeSelector"})
    SetupObstacle( settingsSelector )
    --------------------------
    -- Acknowledgements / ramble TABLE ---
    --------------------------
    local ramblingsScrollCabinet = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699]  )
    ramblingsScrollCabinet.ObjectId = SpawnObstacle({
        Name = "HouseFiles01",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        OffsetX = 1250, OffsetY = -1150,
        AttachedTable = ramblingsScrollCabinet,
        ForceToValidLocation = true,
    })
    ramblingsScrollCabinet.ShrinePointReq = 0
    ramblingsScrollCabinet.UseText = "{I} Tutorial and More..."
    ramblingsScrollCabinet.OnUsedFunctionName = "ShowZyruRamblingMenu"
    ramblingsScrollCabinet.Activate = true
    if not ZyruIncremental.Data.Flags.SeenRamblingsMenu then
        ZyruIncremental.RamblingsMenuId = ramblingsScrollCabinet.ObjectId
        ramblingsScrollCabinet.BlockExitUntilUsed = true
        ramblingsScrollCabinet.BlockExitText = "Read the FAQ and tutorial!"
    end
    SetScale{ Id = ramblingsScrollCabinet.ObjectId, Fraction = 0.5 }
    SetColor{ Id = ramblingsScrollCabinet.ObjectId, Color = { 255, 120, 170, 255 } }
    AddToGroup({Id = ramblingsScrollCabinet.ObjectId, Name = "ChallengeSelector"})
    SetupObstacle( ramblingsScrollCabinet )


end}

-- START SCREEN UPDATE

function ShowZyruRamblingMenu()
    ZyruIncremental.Data.Flags.SeenRamblingsMenu = true
    if ZyruIncremental.RamblingsMenuId ~= nil then
        ActivatedObjects[ZyruIncremental.RamblingsMenuId] = nil
    end
    local screen = ZyruIncremental.CreateMenu("RamblingMenu", {
        PauseBlock = true,
        Components = {
            {
                Type = "Text",
                SubType = "Title",
                FieldName = "MenuTitle",
                Args = {
                    Text = "FAQ / Tutorial / Roadmap",
                },
            },
            {
                Type = "Button",
                SubType = "Close",
            }
        },
        Pages = {
            [1] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "TutorialRamblingsText",
                    Args = {
                        Text = "Frequently Asked Questions and Basic Explanations for this weird-ass mod by a weird-ass modder",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "TutorialText",
                    Args = {
                        Text = 
                            "How do I gain experience for my booons? \\n Use your boons! It's that easy. If a boon does damage, deal damage with it equipped" ..
                            " to gain experience. If it applies an extra effect to enemies, apply that effect to enemies to get some activation experience! " .. 
                            " With enough experience, you can increase your boons' experience level, which is a permanent long-term bonus that gives meaningful bonuses. \\n \\n " ..

                            "What do boon experience levels do? \\n Boon levels increase the rate at which boons benefit from pomegranates. For example," ..
                            " the first three levels of Crush Shot from Aprhodite give 90, 154, and 182 damage. The damage numbers on Experience Level 10 " ..
                            " give 90, 208, and 284 damage, respectively. Your strength increases tremendously the more experience you muster up for your boons."..
                            " Boon levels also give God Currencies (Points) equivalent to the level acquired. You can use these points to upgrade God benefits, unlock" ..
                            " new mechanics, or unlock new Boons! This includes the new rare set of Duo boons between Hermes and the Olympians! \\n\\n " .. 

                            "Why does boon rarity seem a little bit different? \\n The rarity system has been reworked to act as a rolling distribution across "..
                            " 10 tiers of rarity, instead of 4 discrete categories. Some rarity bonuses no longer grant guaranteed rarity tiers, but rather shift the "..
                            " proability distribution significantly towards the higher end of rarity. For example, Minibosses may grant more common boons overall than the vanilla game, but also "..
                            "have the chance to naturally offer Heroic boons from the start of your mod experience (and even higher tiers later on!!!)."
                            
                            ,
                    }
                },
            },
            [2] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "TutorialRamblingsText2",
                    Args = {
                        Text = "Frequently Asked Questions and Basic Explanations for this weird-ass mod by a weird-ass modder",
                    }
                },
                {
                    Type = "Text",
                    FieldName = "TutorialText2",
                    SubType = "Paragraph",
                    Args = {
                        Text = 
                            "What's the point? \\n It's an incremental game, honey. Numbers go up, pump dopamine straight into the veins. Simple as. \\n\\n "..

                            "What do I do if I find a bug? \\n This mod cannot possibly have bugs, but in case you do find one (or two, or ten), please feel free"..
                            " to DM me in the Hades Modding discord (discoverable server). My discord username is \"zyruvias\". All bug and feedback reports are" .. 
                            " greatly appreciated, and help improve the mod experience for you and your fellow incremental overhaul mod gamer :) \\n\\n " .. 

                            "What do I do if I don't like this mod? \\n Stop playing. Why are you even asking this question? \\n\\n " .. 

                            "Is there any risk to my savefile by playing this mod? \\n No, because I required you to start a new save file specifically for this mod. "
                            .."However, considering this " ..
                            " mod will eventually overhaul most mechanical systems by the time it reaches its final version, it is not too "..
                            " unlikely that different values in overlapping mechanics may cause problems once you uninstall this mod and use the mod savefile for other mods. "..
                            " I will do my best to note known issues for the sake of transparency and pissing off as few people as possible :)"
                            ,
                    }
                },
            },
            
            [3] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "RoadmapText",
                    Args = {
                        Text = "Roadmap",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "RoadmapText1",
                    Args = {
                        Text = 
                            "1.0.0 - Initial Release \\n Primary changes: 5 new tiers of boon rarity added, with a new rarity distribution system. "..
                            " New set of unlockable Duo Boons between Olympians and Hermes. New Olympian Legendary Boons. Boon Experience system that "..
                            " tracks how effectively you use your boons over the course of your runs. Boon Point system that lets you unlock various upgrades"..
                            " for the different Olympians to power up your play as you go. \\n\\n " .. 
                            "1.1.0 - TBD / Heat and Prestige balancing \\n Primary ambitions: properly incentivize climbing heat while playing this mod "..
                            ", finish the \"Prestige System\" mechanics for dealing with mod scaling getting too difficult. Mod feedback and boon balancing "..
                            " from YOUR feedback. \\n \\n "..
                            "1.2.0+ - Future content expansions - In no particular order: \\n * Pomegranate Overhaul - enable rarity in Pom menus, control your pom "..
                            " options per god, and more! \\n * Courtyard Extension - increase aspect levels, keepsake levels and more. \\n * Hammer Explosion - "..
                            " add rarity for hammers, hammer leveling, and ... actually that's it. No more for this one. \\n * Void Update - Chaos Trial expansion, Mirror of Night expansion."
                            ,
                    }
                },
            },
            [4] = CreateAcknowledgementsPage(),
            [5] = {
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "RoadmapText2",
                    Args = {
                        Text = "This Page Is Intentionally Left Blank",
                    }
                },
            }
        }
    })
end

function ShowZyruSettingsMenu()
    ZyruIncremental.Data.Flags.SeenSettingsMenu = true
    if ZyruIncremental.SettingsMenuObjectId ~= nil then
        ActivatedObjects[ZyruIncremental.SettingsMenuObjectId] = nil
    end
    local screen = ZyruIncremental.CreateMenu("SettingsMenu", {
        PauseBlock = true,
        Components = {
            {
                Type = "Text",
                SubType = "Title",
                FieldName = "MenuTitle",
                Args = {
                    Text = "Mod Settings",
                },
            },
            {
                Type = "Text",
                SubType = "Subtitle",
                FieldName = "WelcomeTitle",
                Args = {
                    Text = "Change mod configurations according to your heart's desires.",
                }
            },
            {
                Type = "Dropdown",
                SubType = "Standard",
                FieldName = "DifficultyDropdown",
                Args = {
                    Group = "DifficultyGroup",
                    -- X, Y, Items, Name
                    X = ScreenWidth / 6,
                    Y = ScreenHeight / 3,
                    Scale = {
                        X = 0.5
                    },
                    Items = {
                        Default = {
                            Text = ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior or ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_BOON,
                            event = function() end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.EXP_ON_HIT,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior = ZyruIncremental.Constants.Settings.EXP_ON_HIT
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_BOON,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior = ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_BOON
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_GOD,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.ExperiencePopupBehavior = ZyruIncremental.Constants.Settings.EXP_ON_DEATH_BY_GOD
                            end
                        },
                    }
                }
            },
            {
                Type = "Text",
                SubType = "Paragraph",
                FieldName = "ExpDropText",
                Args = {
                    Text = "Configure EXP popup behavior",
                    OffsetX = - ScreenWidth / 4 + 100,
                    OffsetY = - ScreenHeight / 6 - 25,
                    Width = ScreenWidth * 0.60
                }
            },
            {
                Type = "Dropdown",
                SubType = "Standard",
                FieldName = "LevelUpSettingDropdown",
                Args = {
                    Group = "LevelupGroup",
                    -- X, Y, Items, Name
                    X = ScreenWidth / 6,
                    Y = ScreenHeight / 2 - 125,
                    Scale = {
                        X = 0.5
                    },
                    Items = {
                        Default = {
                            Text = ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior or ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE,
                            event = function() end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.LEVEL_POPUP,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_POPUP
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.LEVEL_VOICELINE,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_VOICELINE
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_POPUP_VOICELINE
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.LEVEL_PORTRAIT,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_PORTRAIT
                            end
                        },
                        {
                            Text = ZyruIncremental.Constants.Settings.LEVEL_ALL,
                            event = function ()
                                ZyruIncremental.Data.FileOptions.LevelUpPopupBehavior = ZyruIncremental.Constants.Settings.LEVEL_ALL
                            end
                        },
                    }
                }
            },
            {
                Type = "Text",
                SubType = "Paragraph",
                FieldName = "LevelupText",
                Args = {
                    Text = "Configure Level-up notification behavior",
                    OffsetX = - ScreenWidth / 4 + 100,
                    OffsetY = - 145,
                    Width = ScreenWidth * 0.60
                }
            },
            {
                Type = "Button",
                SubType = "Close",
            }
            }
        })
end

local cabinetId = nil

function ModInitializationScreenUpdateDifficultyText(screen, text)
    ZyruIncremental.UpdateText(screen, {
        Type = "Text",
        SubType = "Paragraph",
        FieldName = "DifficultyDropdownSelectedText",
        Args = {
            Text = "Difficulty Selected: " .. text,
        }
    })
end

function ModInitializationScreenUpdateStartingPointText(screen, text)
    ZyruIncremental.UpdateText(screen, {
        Type = "Text",
        SubType = "Paragraph",
        FieldName = "StartingPointDropdownSelectedText",
        Args = {
            Text = "Starting Point Selected: " .. text,
            OffsetY = - ScreenHeight / 6 -25,
            Justification = "Left",
        }
    })
end

function CreateAcknowledgementsPage()
    return {
        {
            Type = "Text",
            SubType = "Subtitle",
            FieldName = "AcknowledgementsTitle",
            Args = {
                Text = "Acknowledgements"
            }
        },
        {
            Type = "Text",
            SubType = "Paragraph",
            FieldName = "ContextText",
            Args = {
                Text = "A giant thanks to all the support I've gotten over the development of this mod, whether emotional or technical. I love you all."
            }
        },
        {
            Type = "Text",
            SubType = "Paragraph",
            FieldName = "AcknowledgementsColumn1",
            Args = {
                OffsetY = -200,
                Width = ScreenWidth * 0.4,
                Text = 
                    "" ..
                    "Museus \\n " ..
                    "CherryDad \\n " ..
                    "Mysduck \\n " ..
                    "nnevic \\n " ..
                    "Wriste13 \\n " ..
                    "EinsteinsBarber \\n " ..
                    "Ananke \\n " ..
                    "hell \\n " ..
                    "Retr0spektre \\n " ..
                    "Unovarydrdake \\n " ..
                    "violetblight \\n " ..
                    "Alexca  \\n "
            },
        },
        {
            Type = "Text",
            SubType = "Paragraph",
            FieldName = "AcknowledgementsColumn3",
            Args = {
                OffsetY = -200,
                Width = ScreenWidth * 0.17,
                OffsetX = - ScreenWidth * 0.2,
                Text = 
                    "Magic_Gonads \\n " ..
                    "PonyWarrior \\n " ..
                    "SleepSoul \\n " ..
                    "nbusseneau \\n " ..
                    "physiX \\n \\n " ..
                    "My wife and dearest friends \\n\\n " .. 
                    "The absurd amount of coffee I drank along the way \\n \\n "
                    ,
            },
        },
        
        {
            Type = "Text",
            SubType = "Paragraph",
            FieldName = "AcknowledgementsColumn2",
            Args = {
                OffsetY = -200,
                Width = ScreenWidth * 0.4,
                OffsetX = 0,
                Text = 
                    "Hades Speedrunning Community for tolerating my incessant memery about the mod \\n\\n " ..
                    "Hades Modding Community for technical support \\n\\n " ..
                    "Unofficial Hades Retirement Home for emotional support \\n\\n " ..
                    "Haelfam for encouragement and anticipation when I was in a slump \\n\\n " ..
                    "And last but not least ... players like you if you! \\n (Especially if you contribute to reporting bugs / giiving feedback / submitting pull requests :) ) " ..
                    ""
            },
        },
    }
end

function ModInitializationScreen2()
    if not IsEmpty( GameState.RunHistory ) then
        local screen = ZyruIncremental.CreateMenu("NotFreshFile", {
            Components = {
                {
                    Type = "Text",
                    SubType = "Title",
                    FieldName = "MenuTitle",
                    Args = {
                        Text = "Incremental Mod Setup",
                    },
                },
                    {
                        Type = "Text",
                        SubType = "Subtitle",
                        FieldName = "WelcomeTitle",
                        Args = {
                            Text = "Existing Save Detected",
                        }
                    },
                    {
                        Type = "Text",
                        SubType = "Paragraph",
                        FieldName = "WelcomeText",
                        Args = {
                            Text = "Hello there,\\n\\n In order to use this mod, you must start a new save file. Your current"
                            .." savefile progress does not translate well in the new mod systems, so it does not make sense to"
                            .." allow you to continue. Please select \"Give Up\" or \"Quit\" and create a new file to access the mod setup page and begin your "
                            .." Incremental Mod Experience.",
                        }
                    }
                }
            })
        return
    end
    local screen = ZyruIncremental.CreateMenu("ModInitialization", {
        PauseBlock = true,
        Pages = {
            [1] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "WelcomeTitle",
                    Args = {
                        Text = "Welcome",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "WelcomeText",
                    Args = {
                        Text = "Welcome to the Incremental Overhaul Mod. The game has been transformed from a roguelike"
                        .." with primary emphasis on single runs to large, long term emphasis on metaprogression, unlocks,"
                        .." practice, and various other points of focus of the Incremental game genre. Please understand that"
                        .." this mod was intended to be enjoyed at a slower, sustainable pace, and cannot be completed or"
                        .." fully uncovered in a single session. With that in mind, there are a few starting settings that need"
                        .." to be configured. Please proceed through the next few pages and answer the questions to begin your"
                        .." Incremental Journey\\n\\n\\n\\n With love,\\n Zyruvias",
                    }
                }
            },
            [2] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "ContextTitle",
                    Args = {
                        Text = "Story Context"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "ContextText",
                    Args = {
                        Text = "When you finally resolve the plot of Hades for the first time, you "
                        .."agree to continue traversing through the underworld more-or-less as a "
                        .."glorified security analyst. Through your further battles in Tartarus, Asphodel, "
                        .."Elysium, and Styx, you gather data on everything from the enemies attack patterns, "
                        .."weaknesses, to environmental perils. You report back to Hades, your father and boss, "
                        .."and he uses this information to improve the Underworld security, so no soul can escape. "
                        .."But in reality, your reports and parchmentwork are lit aflame and he does absolutely fucking "
                        .."nothing with the information. Your clears and field research just becomes easier and more "
                        .."soul-sucking as time goes on, as you master optimizing the art of escaping the underworld."

                        .."\\n\\n In this mod, Hades will finally respect your work, and begin to improve the security "
                        .."systems as you progress. The Olympians are well attuned to this new detail, and unanimously "
                        .."agree to teach you the finer side of their gifts and abilities. A new co-evolution begins; father "
                        .."against son, spirit against the body. Only one can prevail.\\n\\n Good luck."
                    }
                }
            },
            [3] = CreateAcknowledgementsPage(),
            [4] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "DifficultyTitle",
                    Args = {
                        Text = "Difficulty Settings"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "DifficultyText",
                    Args = {
                        Text = "This mod is intended to be difficult by nature of infinite scaling and building off the original game's innate difficulty. Please select your preferred difficulty settings below."
                    }
                },
                {
                    Type = "Dropdown",
                    SubType = "Standard",
                    FieldName = "DifficultyDropdown",
                    Args = {
                        Group = "DifficultyGroup",
                        -- X, Y, Items, Name
                        X = ScreenWidth / 6,
                        Y = ScreenHeight / 3 + 75,
                        Items = {
                            Default = {
                                Text = "",
                                event = function() end
                            },
                            {
                                Text = "Easy",
                                event = function (parent, button)
                                    ModInitializationScreenUpdateDifficultyText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.DifficultySetting = "Easy"
                                end
                            },
                            {
                                Text = "Standard",
                                event = function (parent, button)
                                    ModInitializationScreenUpdateDifficultyText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.DifficultySetting = "Standard"
                                end
                            },
                            {
                                Text = "Hard",
                                event = function (parent, button)
                                    ModInitializationScreenUpdateDifficultyText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.DifficultySetting = "Hard"
                                end
                            },
                            {
                                Text = "Freeplay",
                                event = function (parent, button)
                                    ModInitializationScreenUpdateDifficultyText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.DifficultySetting = "Freeplay"
                                end
                            },
                        }
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "DifficultyDropdownSelectedText",
                    Args = {
                        Text = "Difficulty Selected: " .. (ZyruIncremental.Data.FileOptions.DifficultySetting or "Standard"),
                        OffsetY = - ScreenHeight / 6 - 25,
                        Justification = "Left",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "DifficultyExplanation",
                    Args = {
                        Text = "Standard - The originally intended difficulty by the developer (that's me!! lmao) - enemies grow in strength "
                        .."and health, and a few other challenges sneak their way in throughout the course of gameplay. \\n\\n "
                        
                        .."Easy - Original intended mechanics, but scaled back to a much more casual experience of the mod. Good "
                        .."for players still dabbling with Heat in the primary game (under 32 Heat). \\n\\n "

                        .."Hard - Original intended mechanics, but skewed towards significantly harder scaling. Please do not select "
                        .."this mode unless you are very experienced with Hades AND want pain and suffering. \\n\\n "

                        .."Freeplay -  difficulty scaling is disabled, and you are free to enjoy the content that the mod has to offer without "
                        .."artificial difficulty gates. Please note that you will become overpowered eventually, and the mod may feel boring in this mode after a certain point."
                        ,
                        OffsetX = - ScreenWidth / 4,
                        OffsetY = - ScreenHeight / 6 + 50,
                        Width = ScreenWidth * 0.65
                    }
                }
            },
            [5] = {
                -- starting point
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "StartingPointTitle",
                    Args = {
                        Text = "Starting Point Settings"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "StartingPointText",
                    Args = {
                        Text = "This mod requires you to start a fresh file since the context of game progression in normal "
                        .."Hades does not make sense in the context of this mod. However, that does not mean you have to complete "
                        .."the whole story again. You are free to start a fresh file and re-experience the story, but you may "
                        .."also skip past the story and start with a state of all base-game features unlocked if you so choose."
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "StartingPointDropdownSelectedText",
                    Args = {
                        Text = "Starting Point Selected: " .. 
                            (ZyruIncremental.Data.FileOptions.StartingPoint or ZyruIncremental.Constants.SaveFile.EPILOGUE),
                        OffsetY = - ScreenHeight / 6 + 25,
                        Justification = "Left",
                    }
                },
                {
                    Type = "Dropdown",
                    SubType = "Standard",
                    FieldName = "StartingPointDropdown",
                    Args = {
                        Group = "bleh",
                        X = ScreenWidth / 2,
                        Y = ScreenHeight / 2,
                        Scale = { X = 1.0, Y = 1.0 },
                        Items = {
                            Default = {
                                Text = "Select a starting point...",
                                event = function() end
                            },
                            { 
                                Text = ZyruIncremental.Constants.SaveFile.FRESH_FILE,
                                event = function (parent, button)
                                    ModInitializationScreenUpdateStartingPointText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.StartingPoint = ZyruIncremental.Constants.SaveFile.FRESH_FILE
                                end
                            },
                            { 
                                Text = ZyruIncremental.Constants.SaveFile.EPILOGUE,
                                event = function (parent, button)
                                    ModInitializationScreenUpdateStartingPointText(parent.screen, button.Text)
                                    ZyruIncremental.Data.FileOptions.StartingPoint = ZyruIncremental.Constants.SaveFile.EPILOGUE
                                end
                            },
                        }
                    }
                }
            },
            [6] = {
                -- progress bars / loading screen / 
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    FieldName = "finishedTitle",
                    Args = {
                        Text = "Final Step",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    FieldName = "FinishedText",
                    Args = {
                        Text = "Click the button below to finish your file configuration. Please note that if you are "
                        .."starting from the Epilogue file setting, it will take a minute to process save file changes. "
                        .."Additionally, there are extra miscellaneous settings in the Courtyard when you get there."

                        .. "\\n\\n Thank you for playing <3"
                    }
                },
                {
                    Type = "Button",
                    SubType = "Basic",
                    FieldName = "FinishedFileConfiguration",
                    Args = {
                        Scale = 1.0,
                        Label = {
                            Type = "Text",
                            SubType = "Paragraph",
                            FieldName = "FinishedFileConfigurationText",
                            Args = {
                                Text = "Finish",
                                FontSize = "30",
                                OffsetY = 0,
                                OffsetX = 0,
                                Justification = "Center",
                                VerticalJustification = "Center"
                            }
                        },
                        ComponentArgs = {
                            OnPressedFunctionName = "CloseInitializationScreen"
                        }
                    },
                }

            }
        },
        Components = {
            {
                Type = "Text",
                SubType = "Title",
                FieldName = "MenuTitle",
                Args = {
                    Text = "Incremental Mod Setup",
                }
            }
        }
    })
end

function CloseInitializationScreen(screen, button)
    ZyruIncremental.Data.Flags.SeenInitialMenuScreen = true
    if ZyruIncremental.Data.FileOptions.StartingPoint == ZyruIncremental.Constants.SaveFile.FRESH_FILE then
        ActivatedObjects[cabinetId] = nil
        return CloseScreenByName("ModInitialization")
    end


    -- actually set save data, the dang fools think this is slow :jeb:
    ZyruIncremental.InitializeEpilogueStartSaveData()

    -- wipe the screen
    Destroy({Ids = GetScreenIdsToDestroy(screen, button)})
    --[[
        -- Updating Conversation History ...
        -- Acquiring Olympian Drama and Hot Goss
        -- Settling familial disputes ...
        -- Dusting off Dad's junk in the courtyard ...
        -- Informants seeking out Persephone and telling her the truth quickly and not over a series of dozens of painful excursions...
        -- Working the House Contractor Overtime (2x pay, of course) ...
        -- Killing Zagreus (wha? No... )
    ]]--

    local stages = {
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 1, UpdateDuration = 3, Text = "Updating Conversation History ...",
            -- Noted.
            Voicelines = {{ Cue = "/VO/ZagreusHome_0378", PreLineWait = 1.0 }}
        },
        { Proportion = 0, UpdateDuration = 0},
        {
			Proportion = 1, UpdateDuration = 4, Text = "Acquiring Olympian Drama and Hot Goss ...",
            -- Ooh.
		    Voicelines = {{ Cue = "/VO/ZagreusField_3379", PreLineWait = 1.5 }},
        },
        { Proportion = 0, UpdateDuration = 0},
        {
			Proportion = 1, UpdateDuration = 6, Text = "Dusting off Dad's junk in the courtyard ...",
            -- I see you there.
            Voicelines = {{ Cue = "/VO/Intercom_0237", PreLineWait = 1.7 }}
        },
        { Proportion = 0, UpdateDuration = 0},
        {
			Proportion = 1, UpdateDuration = 17, Text = "Settling familial disputes ...",
            CascadeVoicelines = true,
            Voicelines = {
                -- "That oaf Poseidon spoke to you already, didn't he? All bluster, muscles, and bravado, that one. I'm glad you're not the type."
				{ 
                    Cue = "/VO/Aphrodite_0045",
                },
                -- "You've come to know your Uncle Zeus, by now, correct? Just want to let you know, good Zeus gets very busy on the regular, so you just stick with me, I've always time for you, Nephew!"
                {
                    Cue = "/VO/Poseidon_0049",
                    PreLineWait = 1.0
                },
                -- "I suppose even down in the Underworld, you would have heard such tales of me, young man. They're all untrue, hahaha! Except the tales of my bravery. Those are completely accurate, though all too modest, in most cases, I must say."
                {
                    Cue = "/VO/Zeus_0218",
                    PreLineWait = 2.0
                },
                -- I said, shut up, old man!
                {
                    Cue =  "/VO/ZagreusHome_0177",
                    PreLineWait = 16
                },
            }
        },
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 1, UpdateDuration = 9, Text = "Informants seeking out Persephone and telling her the truth quickly and not over a series of dozens of painful excursions...",
            -- "No... Zagreus, what have you done? You've led them *here*?
            Voicelines = {{ Cue = "/VO/Persephone_0060", PreLineWait = 2.0}, }
        },
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 0.6, UpdateDuration = 6, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            
            -- A crimson color for the drapery is sure to be a better fit for the decor.
            Voicelines = {{ Cue = "/VO/ZagreusHome_1085" } },
        },
        {
            Proportion = 0.6, UpdateDuration = 4, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            -- I did not authorize such an expenditure.
            Voicelines = {{ Cue = "/VO/Hades_0518" }},
        },
        {
            Proportion = 0.3, UpdateDuration = 3, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            -- You know what, I changed my mind about the drapery.
            Voicelines = {{ Cue = "/VO/ZagreusHome_1086" }},
        },
        {
            Proportion = 0.8, UpdateDuration = 9, Text = "Working the House Contractor Overtime (2x pay, of course) ...", 
            Voicelines = {
                -- A fine hallway requires a fine rug, I always say! I say it sometimes...
                { Cue = "/VO/ZagreusHome_1710" },
                -- So wasteful of my realm's resources, boy.
                { Cue = "/VO/Hades_0643", PreLineWait = 3.90},
            }
        },
        {
            Proportion = 1, UpdateDuration = 4, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
        },
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 1, UpdateDuration = 4, Text = "Killing Zagreus ...",
            Voicelines = {
                -- Wha-?
                { Cue = "/VO/ZagreusField_2462" },
                -- Ungf no...
                { Cue = "/VO/ZagreusField_1125", PreLineWait = 2.0, }
            }
        },
    }
    
    local progressBar = {
        Type = "ProgressBar",
        SubType = "Standard",
        FieldName = "SaveStateBar",
        Args = {
            X = ScreenCenterX - 480 * 1.5,
            ScaleX = 3,
            ScaleY = 3,
        }
    }
    local progressText = {
        Type = "Text",
        SubType = "Paragraph",
        FieldName = "SaveStateText",
        Args = {
            Text = "",
            OffsetY = -100,
            OffsetX = 0,
            Width = ScreenWidth * 0.75,
            Justification = "Center",
            
        }
    }
    ZyruIncremental.RenderComponent(screen, progressBar)
    ZyruIncremental.RenderComponent(screen, progressText)

    for _, stage in ipairs(stages) do
        if stage.Voicelines then
            if stage.CascadeVoicelines then
                for i, line in ipairs(stage.Voicelines) do
                    -- hack to get things to overlap...
                    thread( function(line, k)
                        wait (line.PreLineWait)
                        PlaySpeech { Name = line.Cue, Id = k, UseSubtitles = false,  } 
                    end, line, i)
                end
            else
                thread( PlayVoiceLines, stage.Voicelines, false, {})
            end
        end

        if stage.Text then
            progressText.Args.Text = stage.Text
            ZyruIncremental.UpdateComponent(screen, progressText)
        end

        progressBar.Args.Proportion = stage.Proportion
        progressBar.Args.UpdateDuration = stage.UpdateDuration
        ZyruIncremental.UpdateProgressBar(screen, progressBar, { WaitForUpdate = true })
    end


    
    ActivatedObjects[cabinetId] = nil
    CloseScreenByName("ModInitialization")
    
    Kill(CurrentRun.Hero)
end

ModUtil.Path.Wrap("SetupMap", function(base)
    LoadPackages({Name = "DeathArea"})
    base()
end, ZyruIncremental)

ModUtil.Path.Wrap("StartRoom", function (base, currentRun, currentRoom)

    if ZyruIncremental.Data.Flags.SeenInitialMenuScreen then
        return base(currentRun, currentRoom)
    end

    base(currentRun, currentRoom)

    local selector = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    selector.BlockExitUntilUsed = true
    selector.BlockExitText = TableLength(GameState.RunHistory) > 0 and "Create a new file to continue..." or "Mod Setup Not Completed..."
    selector.UseText = "{I} Begin Incremental Journey"
    selector.OnUsedFunctionName = "ModInitializationScreen2"
    selector.Activate = true
    
	local targetId = SpawnObstacle({ Name = "BlankObstacle", Group = "Standing", DestinationId = CurrentRun.Hero.ObjectId, OffsetX = 0, OffsetY = 0 })

    selector.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = targetId,
        ForceToValidLocation = true,
        AttachedTable = selector,
        OffsetX = 2500,
        OffsetY = -1000,
    })
    cabinetId = selector.ObjectId
    SetScale{ Id = selector.ObjectId, Fraction = 0.17 }
    SetColor{ Id = selector.ObjectId, Color = { 120, 255, 0, 255 } }
    SetupObstacle( selector )
    
    
end, ZyruIncremental)



ModUtil.Path.Wrap("ShowRunIntro", function() end, ZyruIncremental)

function UpdateBoonInfoProgressScreen(screen, boonName)

    -- UPDATE TEXT
    ZyruIncremental.UpdateComponent(screen, {
        Type = "Text",
        SubType = "Subtitle",
        FieldName = "BoonProgressSubtitle",
        Args = {
            Text = boonName
        }

    })
    -- UPDATE ICON
    ZyruIncremental.UpdateComponent(screen, {
        Type = "Icon",
        SubType = "Standard",
        FieldName = "BoonProgressBoonIcon",
        Args = {
            Animation = GetTraitIcon( TraitData[boonName] or {} ),
            Scale = 2.0
        }
    })
    -- UPDATE PROGRESS BAR
    -- show boon level in top right corner
    local boonLevelLabel = {
        Type = "Text",
        SubType = "Note",
        FieldName = "BoonLevelUniqueLabel",
        Args = {
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY - 120,
            Text = "Boon Level",
            FontSize = 20,
        }
    }
    ZyruIncremental.CreateOrUpdateComponent(screen, boonLevelLabel)
    local boonData = ZyruIncremental.Data.BoonData[boonName] or {}

    local boonLevel = boonData.Level or 1
    -- show exp to next level, bar in bottom

    local boonExp = boonData.Experience or 0
    local expBaseline = boonExp - ZyruIncremental.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expTNL = ZyruIncremental.GetExperienceForNextBoonLevel ( boonLevel ) - ZyruIncremental.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expProportion = expBaseline / expTNL
    local expProportionLabel = tostring(math.floor((1000 * expBaseline) / expTNL) / 10) .. "%"
    ZyruIncremental.UpdateProgressBar(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        FieldName = "BoonProgressBar",
        Args = {
            BackgroundColor = {96, 96, 96, 255}, -- Default color.
            ForegroundColor = {255, 255, 255, 255},
            Proportion = 0,
            UpdateDuration = 0,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY - 90,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
            BarText = tostring(math.floor(expBaseline)) .. " / " .. tostring(expTNL) .. " = " .. expProportionLabel,
            LeftText = "Level " .. tostring(boonLevel),
            RightText = "Level " .. tostring(boonLevel + 1)
        }
    })
    ZyruIncremental.UpdateProgressBar(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        FieldName = "BoonProgressBar",
        Args = {
            Proportion = expProportion,
            UpdateDuration = 1,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY - 90,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
        }
    })
    

    -- ZyruIncremental.RenderComponents(screen, components)
end

function ShowGodProgressScreen(screen, button)

    local traitIndexName = button.PageIndex .. "Upgrade"
    if button.PageIndex == "Chaos" then
        traitIndexName = "TrialUpgrade"
    end

    local boonsToDisplay = BoonInfoScreenData.SortedTraitIndex[traitIndexName]
    -- create scrolling list
    local boonItemsToDisplay = {}
    for i, boonName in ipairs(boonsToDisplay) do
        if not Contains(TraitData[boonName] and TraitData[boonName].InheritFrom or {}, "SynergyTrait") then
            table.insert(boonItemsToDisplay, {
                event = function () 
                    UpdateBoonInfoProgressScreen(screen, boonName)
                end,
                Text = boonName,
                ImageStyle = {
                    Image = GetTraitIcon( TraitData[boonName] or {} ),
                    Offset = {X = -225, Y = 0},
                    Scale = 0.7, 
                },
            })
        end
    end

    -- create title (god name)
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            Args = {
                FieldName = button.PageIndex .. "ProgressTitle",
                Text = button.PageIndex, -- todo: generalize args or properties or something??
            }
        },
        {
            Type = "List",
            SubType = "Standard",
            Args = {
                ItemsPerPage = 7,
                Items = boonItemsToDisplay,
                X = 375,
            }
        },
        {
            Type = "Text",
            SubType = "Subtitle",
            FieldName = "BoonProgressSubtitle",
            Args = {
                OffsetX = ScreenWidth / 6,
                Text = ""
            }
        },
        -- boon icon
        {
            Type = "Icon",
            SubType = "Standard",
            FieldName = "BoonProgressBoonIcon",
            Args = {
                OffsetX = ScreenWidth / 3,
                OffsetY = -250,
                Scale = 2,
            }
        },
        -- progress bar
        {
            Type = "ProgressBar",
            SubType = "Standard",
            FieldName = "BoonProgressBar",
            Args = {
                X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
                Y = ScreenCenterY - 90,
                -- BackgroundColor = {0, 0, 0, 0},
                ScaleX = 1.5,
                ScaleY = 1.5,
            }
        },
        {
            -- TODO: fix this shit
            Type = "Button",
            SubType = "Back",
        },
    }
    ZyruIncremental.RenderComponents(screen, componentsToRender)
    ZyruIncremental.RenderComponents(screen, "ZyruIncremental.ShowGodProgressUI", { Source = button })
end

function ZyruIncremental.GetRarityDistributionForUI(god)
    local chanceArray = ZyruIncremental.ComputeRarityArrayForGod( god )
    local distributionData = {}
    for rarityName, rarityValue in pairs(chanceArray) do
        distributionData[GetRarityValue(rarityName)] = {
            Name = rarityName,
            Value = rarityValue,
            Color = Color["BoonPatch" .. rarityName]
        }
    end
    DebugPrint { Text = ModUtil.ToString.Deep(chanceArray)}
    return distributionData
end

function ZyruIncremental.ShowGodProgressUI(screen, button)

    local rarityBarLabel = {
        Type = "Text",
        SubType = "Note",
        FieldName = "DistributionLabel",
        Args = {
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 6 - 150,
            Text = "Rarity Bonus: " .. (100 + ZyruIncremental.ComputeRarityBonusForGod(button.PageIndex)) .. "% \\n Boons' Offered Rarity Distribution",
            FontSize = 20,
        }
    }
    local distributionData = ZyruIncremental.GetRarityDistributionForUI(button.PageIndex)
    distributionData.Legendary = nil
    local rarityBarComponent = {
        Type = "Distribution",
        SubType = "Standard",
        FieldName = "RarityDistributionBar",
        Args = {
            BackgroundColor = {96, 96, 96, 255}, -- Default color.
            ForegroundColor = {255, 255, 255, 255},
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 6 - 70,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
            DistributionData = distributionData
        }
    }

    ZyruIncremental.RenderComponent(screen, rarityBarLabel)
    ZyruIncremental.RenderComponent(screen, rarityBarComponent)

    -- UPDATE EXP PROGRESS BAR
    local godLevelLabel = {
        Type = "Text",
        SubType = "Note",
        FieldName = "GodLevelLabel",
        Args = {
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 6 + 100,
            Text = button.PageIndex .. "'s God Level",
            FontSize = 20,
        }
    }
    ZyruIncremental.RenderComponent(screen, godLevelLabel)
    local data = ZyruIncremental.Data.GodData[button.PageIndex]

    local level = data.Level or 1
    -- show exp to next level, bar in bottom

    local exp = data.Experience or 0
    local expBaseline = exp - ZyruIncremental.GetExperienceForNextGodLevel(level - 1)
    local expTNL = ZyruIncremental.GetExperienceForNextGodLevel ( level ) - ZyruIncremental.GetExperienceForNextGodLevel(level - 1)
    local expProportion = expBaseline / expTNL
    local expProportionLabel = tostring(math.floor((1000 * expBaseline) / expTNL) / 10) .. "%"
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        FieldName = "GodProgressBar",
        Args = {
            BackgroundColor = {96, 96, 96, 255}, -- Default color.
            ForegroundColor = {255, 255, 255, 255},
            Proportion = 0,
            UpdateDuration = 0,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 6 + 130,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
            BarText = tostring(math.floor(expBaseline)) .. " / " .. tostring(expTNL) .. " = " .. expProportionLabel,
            LeftText = "Level " .. tostring(level),
            RightText = "Level " .. tostring(level + 1)
        }
    })
    ZyruIncremental.UpdateProgressBar(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        FieldName = "GodProgressBar",
        Args = {
            BackgroundColor = {96, 96, 96, 255}, -- Default color.
            ForegroundColor = {255, 255, 255, 255},
            Proportion = expProportion,
            UpdateDuration = 1,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 6 + 130,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
            BarText = tostring(math.floor(expBaseline)) .. " / " .. tostring(expTNL) .. " = " .. expProportionLabel,
            LeftText = "Level " .. tostring(level),
            RightText = "Level " .. tostring(level + 1)
        }
    })
end

function ShowZyruProgressScreen()
    ZyruIncremental.Data.Flags.SeenProgressMenu = true
    if ZyruIncremental.ProgressMenuObjectId ~= nil then
        ActivatedObjects[ZyruIncremental.ProgressMenuObjectId] = nil
    end
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            FieldName = "ProgressTitle",
            Args = {
                Text = "Incremental Progress",
            }
        },
        {
            Type = "Text",
            SubType = "Subtitle",
            FieldName = "ProgressSubtitle",
            Args = {
                Text = "Click on a God's portrait to see your progress with their gifts!",
            }
        },
        {
            Type = "Button",
            SubType = "Back",
        },
    }
    for i, name in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter", "Chaos" }) do
        table.insert(componentsToRender, {
            Type = "Button",
            SubType = "Icon",
            Args = {
                FieldName = name .. "Button",
                Animation = "Codex_Portrait_" .. name,
                -- series layout
                OffsetX = - ScreenWidth / 2 + ScreenWidth / 11 * i,
                ComponentArgs = {
                    OnPressedFunctionName = "GoToPageFromSource",
                    PageIndex = name,
                }
            }
        })
    end

    local pages = {
        [1] = componentsToRender,
    }
    for i, name in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter", "Chaos" }) do
        pages[name] = "ShowGodProgressScreen"
    end

    local screen = ZyruIncremental.CreateMenu("ProgressScreen", {
        PauseBlock = true,
        PaginationStyle = "Keyed",
        Pages = pages,
        Components = {}
    })
end

function ShowZyruUpgradeScreen()
    ZyruIncremental.Data.Flags.SeenUpgradeMenu = true
    if ZyruIncremental.UpgradeMenuObjectId ~= nil then
        ActivatedObjects[ZyruIncremental.UpgradeMenuObjectId] = nil
    end
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            FieldName = "UpgradeTitle",
            Args = {
                Text = "Olympian Upgrades",
            }
        },
        {
            Type = "Text",
            SubType = "Subtitle",
            FieldName = "UpgradeSubtitle",
            Args = {
                Text = "Click on a God's portrait to see additional gifts and bonuses they can offer!",
            }
        },
        {
            Type = "Button",
            SubType = "Back",
        },
    }
    for i, name in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter" }) do
        table.insert(componentsToRender, {
            Type = "Button",
            SubType = "Icon",
            Args = {
                FieldName = name .. "Button",
                Animation = "Codex_Portrait_" .. name,
                -- series layout
                OffsetX = - ScreenWidth / 2 + ScreenWidth / 10 * i,
                ComponentArgs = {
                    OnPressedFunctionName = "GoToPageFromSource",
                    PageIndex = name,
                }
            }
        })
    end

    local pages = {
        [1] = componentsToRender,
    }
    for i, name in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter" }) do
        pages[name] = "ShowGodUpgradeScreen"
    end

    local screen = ZyruIncremental.CreateMenu("UpgradeScreen", {
        PauseBlock = true,
        PaginationStyle = "Keyed",
        Pages = pages,
        Components = {}
    })
end

function GetUpgradeGostText(upgrade)
    local costText = "Cost: "
    local costs = GetUpgradeCost(upgrade)
    local sourceCostTexts = {}
    for source, cost in pairs(costs) do 
        table.insert(sourceCostTexts, tostring(cost or 0) .. " " .. source .. " Points")
    end
    if upgrade.Sources ~= nil then
        DebugPrint { Text = ModUtil.ToString.Deep(upgrade.Sources) .. " " .. ModUtil.ToString.Deep(sourceCostTexts)}
        -- TODO: generalize
        if sourceCostTexts[1] and sourceCostTexts[2] then 
            return costText .. tostring(sourceCostTexts[1]) .. " and " .. (sourceCostTexts[2])
        end
    end
    return costText .. sourceCostTexts[1]
end

function UpdateUpgradeInfoScreen(screen, upgrade, button)
    -- UPDATE ICON
    local god = screen.PageIndex
    _G["a"] = screen
    _G["b"] = upgrade
    _G["c"] = button
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "Icon",
        SubType = "Standard",
        FieldName = "UpgradeIcon" .. god,
        Args = {
            Animation = GetTraitIcon( TraitData[upgrade.Name] or {} ),
            OffsetX = ScreenWidth / 6,
            OffsetY = -100,
            Scale = 4,
        }
    })
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "Text",
        SubType = "Note",
        FieldName = "UpgradeCurrencyText" .. god,
        Args = {
            OffsetX = ScreenWidth / 3 - 50,
            OffsetY = -450,
            Justification = "Right",
            FontSize = 20,
            Text = "Available " .. god .. " Points: " .. tostring(ZyruIncremental.Data.GodData[god].CurrentPoints or 0)
        }
    })
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "Text",
        SubType = "Paragraph",
        FieldName = "UpgradeDescriptionText" .. god,
        Args = {
            Text = "",
            OffsetX = ScreenWidth / 6,
            OffsetY = 0,

        }
    })
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "Text",
        SubType = "Note",
        FieldName = "UpgradeCostText" .. god,
        Args = {
            Text = GetUpgradeGostText(upgrade),
            OffsetX = ScreenWidth / 6,
            OffsetY = 110,
            Justification = "Center",
        }
    })
    -- Add Purchase Button
    ZyruIncremental.CreateOrUpdateComponent(screen, {
        Type = "Button",
        SubType = "Basic",
        FieldName = "PurchaseButton" .. god,
        Args = {
            OffsetX = ScreenWidth / 6,
            OffsetY = 200,
            Label = "Purchase Upgrade",
            ComponentArgs = {
                OnPressedFunctionName = "ZyruIncremental.AttemptPurchaseUpgrade",
                Upgrade = upgrade
            },
        },
    })
end

function GetUpgradeListItem(screen, upgrade, button)
    local description = "Unlock a new Boon from " .. 
        (upgrade.Source or upgrade.Sources[1] .. " and " .. upgrade.Sources[2])
    return {
        event = function () 
            DebugPrint { Text = "clicked button..."}
            UpdateUpgradeInfoScreen(screen, upgrade, button)
        end,
        Text = upgrade.Name,
        Description = description,
        ImageStyle = {
            Image = GetTraitIcon( TraitData[upgrade.Name] or {} ),
            Offset = {X = -225, Y = 0},
            Scale = 0.7, 
        },
    }
end

function GetRarityBuffListItem(screen, upgrade, button)
    return {
        event = function () 
            UpdateUpgradeInfoScreen(screen, upgrade, button)
        end,
        Text = "GodRarityBonusBuff",
        Description = "GodRarityBonusBuff_Description",
        DescriptionArgs = {
            LuaKey = "TempTextData",
            LuaValue = {
                Bonus = upgrade.Value,
                God = upgrade.Source, -- TODO: upgrade source is hardcoded english, can I recursively translate?
            }
        },
        ImageStyle = {
            Image = GetTraitIcon( TraitData[upgrade.Name] or {} ),
            Offset = {X = -225, Y = 0},
            Scale = 0.7, 
        },
    }
end

function ShowGodUpgradeScreen(screen, button)
    -- upgradesTodisplay
    local source = button.PageIndex
    DebugPrint { Text = "showing god upgrade screen for " .. source}
    local upgradesToDisplay = ZyruIncremental.GetAllUpgradesBySource(source)
    -- create scrolling list
    local upgradeItemsToDisplay = {}
    for i, upgrade in ipairs(upgradesToDisplay) do
        if upgrade.Type == ZyruIncremental.Constants.Upgrades.Types.PURCHASE_BOON then
            table.insert(upgradeItemsToDisplay, GetUpgradeListItem(screen, upgrade, button))
        elseif upgrade.Type == ZyruIncremental.Constants.Upgrades.Types.AUGMENT_RARITY then
            table.insert(upgradeItemsToDisplay, GetRarityBuffListItem(screen, upgrade, button))
        else
            -- TODO: figure out default
            table.insert(upgradeItemsToDisplay, GetUpgradeListItem(screen, upgrade, button))
        end
    end


    -- create title (god name)
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            Args = {
                FieldName = source .. "UpgradeTitle",
                Text = source, -- todo: generalize args or properties or something??
            }
        },
        {
            Type = "List",
            SubType = "Standard",
            Args = {
                ItemsPerPage = 7,
                Items = upgradeItemsToDisplay,
                X = 375,
            }
        },
        {
            Type = "Icon",
            SubType = "Standard",
            FieldName = "UpgradeCurrency" .. source,
            Args = {
                OffsetX = ScreenWidth / 3,
                OffsetY = -450,
                Scale = 0.75,
                Animation = "BoonInfoSymbol" .. source .. "Icon",
            }
        },
        {
            Type = "Text",
            SubType = "Note",
            FieldName = "UpgradeCurrencyText" .. source,
            Args = {
                OffsetX = ScreenWidth / 3 - 50,
                OffsetY = -450,
                Justification = "Right",
                FontSize = 20,
                Text = "Available " .. source .. " Points: " .. tostring(ZyruIncremental.Data.GodData[source].CurrentPoints or 0)
            }
        },
        {
            Type = "Button",
            SubType = "Back",
        },
    }
    -- ZyruIncremental.RenderComponents(screen, componentsToRender)
    ZyruIncremental.CreateOrUpdateComponent(screen, componentsToRender[1])
    ZyruIncremental.CreateOrUpdateComponent(screen, componentsToRender[2])
    ZyruIncremental.CreateOrUpdateComponent(screen, componentsToRender[3])
    ZyruIncremental.CreateOrUpdateComponent(screen, componentsToRender[4])
    ZyruIncremental.CreateOrUpdateComponent(screen, componentsToRender[5])
end
