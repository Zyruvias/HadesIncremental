local CreateBoonPresentation = function (screen, traitName, x, y)

    -- fetchInfo
    local zyruBoonData = GameState.ZyruIncremental.BoonData[traitName]
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
        for i, existingTrait in pairs( CurrentRun.Hero.TraitDictionary[trait.Name]) do
            if (AreTraitsIdentical(trait, existingTrait) and rarityValue < GetRarityValue( existingTrait.Rarity )) then
                rarityValue = GetRarityValue( existingTrait.Rarity )
                traitFrame = GetTraitFrame( existingTrait )
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
        Text = "Boon Level: " .. tostring(round(zyruBoonData.Level or 0)),
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
    
	-- 	Text = "LMAO I MADE THIS",
	-- 	FontSize = 72,
	-- 	OffsetX = 3, OffsetY = 3,
	-- 	Color = { 255, 255, 255, 255 },
	-- 	Font = "AlegreyaSansSCRegular",
	-- 	ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 3},
	-- 	Justification = "Left" })

    table.insert( components, traitIcon )

end

ModUtil.Path.Wrap("CloseRunClearScreen", function (base, ...) 
    local value = base( ... )

    ScreenAnchors.ZyruBoonProgress = { Components = {} }
	local screen = ScreenAnchors.ZyruBoonProgress
	screen.Name = "ZyruBoonProgress"

    local components = screen.Components

    if IsScreenOpen( screen.Name ) then
		return
	end
	OnScreenOpened({ Flag = screen.Name, PersistCombatUI = false })
	HideCombatUI("BoonProgressMenu")
	FreezePlayerUnit()
	EnableShopGamepadCursor()

	PlaySound({ Name = "/SFX/Menu Sounds/DialoguePanelIn" })

    components.Blackout = CreateScreenComponent({ Name = "rectangle01", X = ScreenCenterX, Y = ScreenCenterY })
	SetScale({ Id = components.Blackout.Id, Fraction = 10 })
	SetColor({ Id = components.Blackout.Id, Color = Color.Black })
	SetAlpha({ Id = components.Blackout.Id, Fraction = 0 })
	SetAlpha({ Id = components.Blackout.Id, Fraction = 0.85, Duration = 0.5 })

    components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.Blackout.Id, OffsetX = 3, OffsetY = 480 })
	components.CloseButton.OnPressedFunctionName = "CloseZyruBoonProgressScreen"
	components.CloseButton.ControlHotkey = "Cancel"

    CreateTextBox({ Id = components.Blackout.Id,
		Text = "Boon Progression",
		FontSize = 32,
		X = ScreenCenterX, OffsetY = -480,
		Color = { 255, 255, 255, 255 },
		Font = "AlegreyaSansSCRegular",
		ShadowBlur = 0, ShadowColor = {0,0,0,0}, ShadowOffset={0, 3},
		Justification = "Center" 
    })

    -- TODO: sort boons by zyruData
    local boonsToDisplay = {}

    for k, trait in pairs(CurrentRun.Hero.Traits) do
        if GameState.ZyruIncremental.BoonData[trait.Name] ~= nil and not Contains(boonsToDisplay, trait.Name) then
            table.insert(boonsToDisplay, trait.Name)
        end
    end

    local startX = TraitUI.SpacerX + 100
    local startY = TraitUI.SpacerY + 100
    local xGap = ScreenWidth / 5
    local yGap = ScreenHeight / 6
    for i, traitName in ipairs(boonsToDisplay) do
        local x = startX + xGap * math.floor((i - 1) / 5)
        local y = startY + yGap * ((i - 1) % 5)
        DebugPrint { Text = tostring(i) .. " " .. traitName .. " " .. tostring(x) .. " " .. tostring(y)}
        CreateBoonPresentation(screen, traitName, x, y)
    end
    
	HandleScreenInput( screen )

    return value
end, Z)

function CloseZyruBoonProgressScreen( )
	local screen = ScreenAnchors.ZyruBoonProgress
	DisableShopGamepadCursor()
	CloseScreen( GetAllIds( screen.Components ) )
	PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
	UnfreezePlayerUnit()
	ToggleControl({ Names = { "AdvancedTooltip" }, Enabled = true })
	ShowCombatUI("BoonProgressMenu")
	screen.KeepOpen = false
	OnScreenClosed({ Flag = screen.Name })
end

function DisplayExperiencePopup (amount)
    local displayAmount = round(amount)
    if displayAmount <= 0 then
        return
    end
    
	local randomOffsetX = RandomInt( -50, 50 )
	local randomOffsetY = RandomInt( -50, 50 )

    local damageTextAnchor = SpawnObstacle({
        Name = "BlankObstacleNoTimeModifier",
        DestinationId = CurrentRun.Hero.ObjectId,
        Group = "Combat_UI_World", 
        OffsetX = randomOffsetX,
        OffsetY = randomOffsetY,
    })
    
    local color = { 192, 192, 192, 255 }
    local fontScaling = math.min(18, math.pow(displayAmount, 0.333))
    CreateTextBox({
        Id = damageTextAnchor,
        RawText = "+ " .. tostring(displayAmount) .. "xp",
        FontSize = 12 + fontScaling,
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

function DisplayBoonLevelupPopup( traitNamesImproved, level )
	local offsetY = 0
	for i, traitName in ipairs( traitNamesImproved ) do
		local traitTitle = traitName
		if TraitData[traitName] then 
			traitTitle = GetTraitTooltipTitle(TraitData[traitName])
		end
		CreateAnimation({ Name = "ItemGet_PomUpgraded", DestinationId = CurrentRun.Hero.ObjectId, Scale = 2.0 })
		thread( InCombatTextArgs, {
            TargetId = CurrentRun.Hero.ObjectId,
            Text = traitTitle .. " level " .. tostring(level) .. "!",
            SkipRise = false,
            SkipFlash = true,
            ShadowScale = 0.66,
            Duration = 1.5,
            OffsetY = -100 + offsetY,
            LuaKey = "TempTextData",
            LuaValue = { Name = traitTitle, Amount = level }})
		PlaySound({ Name = "/SFX/PomegranateLevelUpSFX", DestinationId = CurrentRun.Hero.ObjectId })
		offsetY = offsetY - 60
		wait(0.75)
	end
end

-- assigns basic global state, creates background and close button
function CreateScreenWithCloseButton( name, args ) 
    args = args or {}
    local screen = { Components = {} }
    ScreenAnchors[name] = screen
	screen.Name = name

    local components = screen.Components

    if IsScreenOpen( screen.Name ) then
		return
	end
	OnScreenOpened({ Flag = screen.Name, PersistCombatUI = false })
	HideCombatUI(name)
	FreezePlayerUnit()
	EnableShopGamepadCursor()

	PlaySound({ Name = "/SFX/Menu Sounds/DialoguePanelIn" })

    components.Background = CreateScreenComponent({ Name = "rectangle01", X = ScreenCenterX, Y = ScreenCenterY })
	SetScale({ Id = components.Background.Id, Fraction = 10 })
	SetColor({ Id = components.Background.Id, Color = Color.Black })
	SetAlpha({ Id = components.Background.Id, Fraction = 0 })
	SetAlpha({ Id = components.Background.Id, Fraction = 0.85, Duration = 0.5 })

    components.CloseButton = CreateScreenComponent({ Name = "ButtonClose", Scale = 0.7 })
	Attach({ Id = components.CloseButton.Id, DestinationId = components.Background.Id, OffsetX = 3, OffsetY = 480 })
	components.CloseButton.OnPressedFunctionName = "Close" .. name .. "Screen"
	components.CloseButton.ControlHotkey = "Cancel"

    if _G["Close" .. name .. "Screen"] == nil then
        _G["Close" .. name .. "Screen"] = function()
            CloseScreenByName ( name )
            if args.CloseScreenFunctionName ~= nil then
                _G[args.CloseScreenFunctionName]()
            end
        end
    end

    -- TODO: Figure out system to have HandleScreenInput called by default, possibly callback method
	-- HandleScreenInput( screen )
    return screen
end

function CloseScreenByName ( name )
	local screen = ScreenAnchors[name]
	DisableShopGamepadCursor()
	CloseScreen( GetAllIds( screen.Components ) )
	PlaySound({ Name = "/SFX/Menu Sounds/GeneralWhooshMENU" })
	UnfreezePlayerUnit()
	ToggleControl({ Names = { "AdvancedTooltip" }, Enabled = true })
	ShowCombatUI(name)
	screen.KeepOpen = false
	OnScreenClosed({ Flag = screen.Name })
end

-- Courtyard Upgrade Screen
function ShowZyruUpgradeScreen()
	local screen = CreateScreenWithCloseButton("ZyruUpgrade")
    local components = screen.Components

    -- 
    -- Title TODO: fix title
    CreateTextBox({ Id = components.Background.Id, Text = "Upgrades",
    Font = "SpectralSCLightTitling", FontSize = "36", Color = Color.White,
    OffsetY = -450, Justification = "Center" })
    -- Suytitle
    CreateTextBox({ Id = components.Background.Id, Text = "Purchase powerful boons, abilities, and insights into the finer workings of the underworld!",
        Font = "AlegreyaSansSCLight", FontSize = "22", Color = Color.White,
        OffsetY = -400, Justification = "Center" })

    local portraitsToDisplay = {
        -- Olympians
        "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter",
        -- Other portraits Nyx, Chaos, Hammer, Pom(?), Heart (?), Coin (?), Zagrues (?)
        "Nyx", "Chaos", "Pom", "Heart", "Coin", "Zagreus"
    }
    for i, name in ipairs(portraitsToDisplay) do
        local index = i
        local rowIndex = (index - 1) % 9
        local xOffset = ScreenWidth / 10 * (-5 + rowIndex + 1)
        local yOffset = 150 + ScreenHeight / 2 *  (math.floor((index - 1) / 9) - 1)
        local scale = 0.5
        local components = screen.Components
        local godButton = CreateScreenComponent({
            Name = "BaseInteractableButton",
            Group = "Combat_Menu_TraitTray",
            Color = {1, 1, 1, 1}
        })
        components[ "Icon_"..name ] = godButton
        SetAnimation({ Name = "Codex_Portrait_" .. name, DestinationId = godButton.Id })
        Attach({ Id = godButton.Id, DestinationId = components.Background.Id, OffsetX = xOffset, OffsetY = yOffset })
        SetScale({ Id = godButton.Id, Fraction = scale })

        godButton.OnPressedFunctionName = "ShowUpgradeScreenForItem"
        godButton.Source = name
    end
    

    
	HandleScreenInput( screen )
end

function CloseZyruUpgradeScreen( )
    CloseScreenByName("ZyruUpgrade")
end

function CanPurchaseUpgrade( upgrade ) 
    -- ZyruIncremental.GodData[upgrade.source] ? 
    -- should use ZI.Currencies[source]
    if 
        upgrade.CostType ~= nil
        and upgrade.Cost ~= nil
        and GameState.ZyruIncremental.Currencies[upgrade.source] ~= nil
        and GameState.ZyruIncremental.Currencies[upgrade.source] >= upgrade.Cost
    then
        return true
    end
    return false
end

function CreateUpgradeListItem( upgrade )

    
--[[
    Upgrade shape: {
        Name -- TODO: is this necessary
        CostType
        Cost
        OnApplyFunction
        OnApplyFunctionArgs
        Purchased
        Source
        ButtonType?
    }
    ]]--
    local defaultButtonStyles = {
        Font = "SpectralSCLightTitling",
        FontSize = 20,
        Justification = "Center",
    }
    local button = {
        IsEnabled = CanPurchaseUpgrade(upgrade)
    }
    if upgrade.ButtonType == Z.UpgradeTypeEnums.STANDARD then
        button = {
            event = function(list)
                DebugPrint({Text = "Woah you enabled me"})
            end,
            Text = "Purchase Boon: " .. upgrade.Name,
            -- IsEnabled = savefile does not contain upgrade.Name
            Description = "bleh",
            Offset = {X = 0, Y = 0},
            FontSize = 20,
            Font = "SpectralSCLightTitling",
            ImageStyle = {
                Image = "GUI\\Screens\\BoonIcons\\" .. TraitData[upgrade.Name].Icon,
                Offset = {X = -225, Y = 0},
                Scale = 0.7, 
            },
        }
    elseif upgrade.ButtonType == Z.UpgradeTypeEnums.PURCHASE_BOON then
        
    end

    return ModUtil.Table.Merge(button, defaultButtonStyles)
end

function ShowUpgradeScreenForItem( screen, button )
    
    CloseZyruUpgradeScreen()
	local screen = CreateScreenWithCloseButton ("Zyru" .. button.Source .. "Upgrades", {
        CloseScreenFunctionName = "ShowZyruUpgradeScreen"
    })
    local components = screen.Components

    -- TODO: use UI friendly texts
    CreateTextBox({ Id = components.Background.Id, Text = button.Source,
    Font = "SpectralSCLightTitling", FontSize = "36", Color = Color.White,
    OffsetY = -450, Justification = "Center" })

    -- TODO: filter upgrades by type
    -- CreateUpgreadePurchaseButton for each upgrade
    -- assign display args to button
    local upgradesForThisSource = {}
    for i, upgrade in pairs(Z.UpgradeData) do
        DebugPrint { Text = "Checking " .. tostring(upgrade.name) .. " " .. tostring(upgrade.Source)}
        if button.Source == upgrade.Source then
            table.insert(upgradesForThisSource, 
                {
                    event = function(list)
                        DebugPrint({Text = "Woah you enabled me"})
                    end,
                    Text = "Purchase Boon: " .. upgrade.Name,
                    -- IsEnabled = savefile does not contain upgrade.Name
                    Description = "bleh",
                    Offset = {X = 0, Y = 0},
                    Justification = "Center",
                    FontSize = 20,
                    Font = "SpectralSCLightTitling",
                    ImageStyle = {
                        Image = "GUI\\Screens\\BoonIcons\\" .. TraitData[upgrade.Name].Icon,
                        Offset = {X = -225, Y = 0},
                        Scale = 0.7, 
                    },
                }
            )
            -- CreateUpgradePurchaseButton(screen, button)-- 
            -- Items = {
        --     {
        --         event = function(list)
        --             DebugPrint({Text = "Woah you enabled me"})
        --         end,
        --         Text = "I'm not enabled",
        --         IsEnabled = false,
        --         Description = "Denabled's desc"
        --         Offset = {X = 0, Y = 0},
        --         Justification = "Center",
        --         FontSize = 20,
        --         Font = "MonospaceTypewriterBold",
        --         ImageStyle = {
        --             Image = "Tilesets\\Gameplay\\Gameplay_Gemstones_01",
        --             Offset = {X = -225, Y = 0},
        --             Scale = 0.7,
                                            
        --         },
        --     },
        -- },
        end
    end

    -- testing ErumiUILib ScrollingList
    local myScroll = ErumiUILib.ScrollingList.CreateScrollingList(
		screen, {
            Name = "MyScrollingList", 
            Group = "GardenBoxGroup",
            Scale = {X = 0.6, Y = 1},
            Padding = {X = 0, Y = 5},
            X = 1550, Y = 115,
            ImageStyle = {
                Image = "GUI\\Screens\\SeasonalItem",
                Offset = {X = -225, Y = 0},
            },
            GeneralOffset = {X = -195, Y = -25},
            GeneralFontSize = 18,
            Justification = "Left",
            Font = "AlegreyaSansSCBold",
            ItemsPerPage = 9,
            ArrowStyle = {
                Offset = {X = 325, Y = 0},
                Scale = 1,
                CreationPositions = {Style = "TB"}
            },
            DescriptionFontSize = 13,
            DescriptionOffset = {X = -195, Y = 0},
            DescriptionColor = Color.Yellow,
            DeEnabledColor = {1,0,0,0.33},
            Items = upgradesForThisSource,
        
    })
    --end testing
    
	HandleScreenInput( screen )
end

function CreateUpgradePurchaseButton ( screen, button )
    local components = screen.Components

    local traitName = button.UpgradeArgs.TraitName

	local traitInfo = {}
	local offset = { X = 110, Y = BoonInfoScreenData.ButtonStartY + 1 * BoonInfoScreenData.ButtonYSpacer }
	components[traitName .. "DetailsBacking"] = CreateScreenComponent({
        Name = "BoonInfoButton",
        DestinationId = components.Background.Id,
        Group = "Combat_Menu_TraitTray_Backing",
        X = offset.X + 455,
        Y = offset.Y + 200
    })
	
	CreateTextBoxWithFormat({
		Id = components[traitName .. "DetailsBacking"].Id,
		OffsetX = -260,
		OffsetY = BoonInfoScreenData.DecriptionBoxOffsetY,
		Width = 665,
		Justification = "Left",
		VerticalJustification = "Top",
		LineSpacingBottom = 8,
		UseDescription = true,
		Format = "BaseFormat",
		VariableAutoFormat = "BoldFormatGraft",
		TextSymbolScale = 0.8,
	})

	components[traitName .. "TitleBox"] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray", X = offset.X + 20, Y = offset.Y + 170 })
	CreateTextBox({
		Id = components[traitName .. "TitleBox"].Id,
		FontSize = 25,
		OffsetX = 170,
		OffsetY = BoonInfoScreenData.TextBoxOffsetY,
		Color = color,
		Font = "AlegreyaSansSCLight",
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Left",
	})

	components[traitName .. "RarityBox"] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray", X = offset.X + 20, Y = offset.Y + 170 })
	CreateTextBox({
		Id = components[traitName .. "RarityBox"].Id,
		FontSize = 25,
		OffsetX = 860,
		OffsetY = -17,
		Color = color,
		Font = "AlegreyaSansSCLight",
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Right",
	})

	components[traitName .. "Patch"] = CreateScreenComponent({
        Name = "BlankObstacle",
        Group = "Combat_Menu_TraitTray",
        X = offset.X + 110,
        Y = offset.Y + 205,
        Scale = 0.8
    })
	SetAnimation({ DestinationId = components[traitName .. "Patch"].Id, Name = "BoonRarityPatch"})
	SetColor({ Id = components[traitName .. "Patch"].Id, Color = Color.Transparent })

	components[traitName .. "Frame"] = CreateScreenComponent({ Name = "BoonInfoTraitFrame", Group = "Combat_Menu_TraitTray", X = offset.X + 90, Y = offset.Y + 200, Scale = 0.8 })
	components[traitName .. "Icon"] = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu_TraitTray", X = offset.X + 90, Y = offset.Y + 200, Scale = 0.8 })
	local newTraitData =  GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = traitName, Rarity = "Common", ForBoonInfo = true })
	newTraitData.ForBoonInfo = true
	SetTraitTextData( newTraitData )
	SetTraitTrayDetails( { TraitData = newTraitData, ForBoonInfo = true }, components[traitName .. "DetailsBacking"], components[traitName .. "RarityBox"], components[traitName .. "TitleBox"], components[traitName .. "Patch"], components[traitName .. "Icon"] )

    
end

-- Courtyard Progress Screen
function ShowZyruProgressScreen()
	local screen = CreateScreenWithCloseButton ("ZyruProgress")
    local components = screen.Components
    -- Title TODO: fix title
    CreateTextBox({ Id = components.Background.Id, Text = "God Progression",
        Font = "SpectralSCLightTitling", FontSize = "36", Color = Color.White,
        OffsetY = -450, Justification = "Center" })
    -- Suytitle
    CreateTextBox({ Id = components.Background.Id, Text = "Select an Olympian to view your progress with their gifts!",
        Font = "AlegreyaSansSCLight", FontSize = "22", Color = Color.White,
        OffsetY = -400, Justification = "Center" })
    
    for i, name in ipairs({ "Zeus", "Poseidon", "Athena", "Ares", "Aphrodite", "Artemis", "Dionysus", "Hermes", "Demeter" }) do
        CreateGodPageButton(screen, name, i)
    end

	HandleScreenInput( screen )
end

function CreateGodPageButton( screen, god, index )
    local xOffset = ScreenWidth / 10 * (-5 + index)
    local yOffset = (ScreenHeight / 10) * (-0.5 + index % 2)
    local components = screen.Components
    local godButton = CreateScreenComponent({
        Name = "BaseInteractableButton",
        Group = "Combat_Menu_TraitTray",
        Color = {1, 1, 1, 1}
    })
	components[ "Icon_"..god ] = godButton
	SetAnimation({ Name = "Codex_Portrait_" .. god, DestinationId = godButton.Id })
	Attach({ Id = godButton.Id, DestinationId = components.Background.Id, OffsetX = xOffset, OffsetY = yOffset })
    godButton.OnPressedFunctionName = "ShowZyruGodProgressScreen"
    godButton.God = god

    -- godButton.OnMouseOverFunctionName = "GrowButtonScale"
    -- godButton.OnMouseOffFunctionName = "ShrinkButtonScale"
end

function ShowZyruGodProgressScreen( screen, button )
    DebugPrint { Text = ModUtil.ToString.Shallow(screen)}
    DebugPrint { Text = ModUtil.ToString.Shallow(button)}
    CloseZyruProgressScreen()
	local screen = CreateScreenWithCloseButton ("Zyru" .. button.God .. "Progress", {
        CloseScreenFunctionName = "ShowZyruProgressScreen"
    })
    local components = screen.Components

    CreateTextBox({ Id = components.Background.Id, Text = button.God,
    Font = "SpectralSCLightTitling", FontSize = "36", Color = Color.White,
    OffsetY = -450, Justification = "Center" })

    -- add scrolling list of items
    -- get aggregate list of boons used to display
    local boonsToDisplay = BoonInfoScreenData.SortedTraitIndex[button.God .. "Upgrade"]
    -- create scrolling list
    local boonItemsToDisplay = {}
    for i, boonName in ipairs(boonsToDisplay) do
        if not TraitData[boonName] then
            DebugPrint { Text = boonName .. " not found in TraitData" }
        end
        if not Contains(TraitData[boonName] and TraitData[boonName].InheritFrom or {}, "SynergyTrait") then
            table.insert(boonItemsToDisplay, {
                event = function () end,
                Text = boonName,
                RenderCallback = "CreateZyruBoonProgressInfo"
            })
        end
    end
    local scrollingList = ErumiUILib.ScrollingList.CreateScrollingList(screen, {
        -- X, Y, Name, ItemsPerPage, ItemBackground, Items
        --[[
            -- Items = {
        --     {
        --         event = function,
        --         Text,
        --         IsEnabled,
        --         Description
        --         Offset = {X = 0, Y = 0},
        --         Justification = "Center",
        --         FontSize = 20,
        --         Font = "MonospaceTypewriterBold",
        --         ImageStyle = {
        --             Image = "Tilesets\\Gameplay\\Gameplay_Gemstones_01",
        --             Offset = {X = -225, Y = 0},
        --             Scale = 0.7,
                                            
        --         },
        --     },
        ]]
        Name = button.God .. "ProgressScrollingList",
        ItemsPerPage = 4,
        Scale = {
            X = 1,
            Y = 1,
        },
        ItemBackground = "BoonInfoButton",
        Items = boonItemsToDisplay,
        Group = "GardenBoxGroup",
        Padding = {X = 0, Y = 90},
        X = 500, Y = 150,
        GeneralOffset = {X = 0, Y = 0},
        GeneralFontSize = 18,
        Justification = "Left",
        Font = "AlegreyaSansSCBold",
        ArrowStyle = {
            Offset = {X = 700, Y = 0},
            Scale = 1,
            CreationPositions = {Style = "TB"}
        },


    })

    
	HandleScreenInput( screen )
end

function ScrollingListRenderTest (screen, listItem, listItemArgs)
    DebugPrint { Text = ModUtil.ToString.Shallow(listItem)}
    DebugPrint { Text = ModUtil.ToString.Shallow(listItemArgs)}
end

function ApplyPrestigeSettings ( screen, button )
    DebugPrint { Text = tostring(button.Difficulty or "you fucked up")}
end

function ShowZyruResetScreen ()
	local screen = CreateScreenWithCloseButton ("ZyruReset")
    local components = screen.Components

    -- title
    CreateTextBox({ Id = components.Background.Id, Text = "Travel back in time to try again ... ?",
        Font = "SpectralSCLightTitling", FontSize = "24", Color = Color.White,
        OffsetY = -450, Justification = "Center" })

    CreateTextBox({ Id = components.Background.Id, Text = "Select a new lifetime difficulty setting...",
        Font = "AlegreyaSansSCLight", FontSize = "22", Color = Color.White,
        OffsetY = -300, Justification = "Center" })
    -- difficulty buttons TODO: abstract formally with difficulties
    
    local xPosArray = { 150, 500, 150, 500 }
    local yPosArray = { 600, 600, 900, 900 }
    for k, v in ipairs({"Easy", "Medium", "Hard", "Impossible"}) do
        components[v .. "DetailsBacking"] = CreateScreenComponent({
            Name = "BoonInfoButton",
            DestinationId = components.Background.Id,
            Group = "Combat_Menu_TraitTray_Backing",
            X = xPosArray[k],
            Y = yPosArray[k],
        })
        
        CreateTextBoxWithFormat({
            Id = components[v .. "DetailsBacking"].Id,
            Width = 300,
            Justification = "Left",
            VerticalJustification = "Top",
            LineSpacingBottom = 8,
            UseDescription = true,
            Format = "BaseFormat",
            VariableAutoFormat = "BoldFormatGraft",
            TextSymbolScale = 0.8,
        })
        
        SetScaleX({ Id = components[v .. "DetailsBacking"].Id, Fraction = 0.25, Duration = 0.0 })
        components[v .. "DetailsBacking"].OnPressedFunctionName = "ApplyPrestigeSettings"
        components[v .. "DetailsBacking"].Difficulty = v

    end 


	HandleScreenInput( screen )
end

-- function CloseZyruProgressScreen( )
--     CloseScreenByName("ZyruProgress")
-- end

function CreateZyruBoonProgressInfo( screen, component, args )
    -- component: id, scrollingListPressedArgs
    -- DebugPrint { Text = ModUtil.ToString.Shallow(component)}
    -- args: item / list item component args
    DebugPrint { Text = "creating Boon Progress for " .. args.Text}
    -- if true then return end
    local components = screen.Components
    for key, value in pairs(components) do
        DebugPrint { Text = key}
    end
    -- DebugPrint { Text = ModUtil.ToString.TableKeys(components)}
    local scrollingListPressedArgs = component.scrollingListPressedArgs
    
    local scrollingList = scrollingListPressedArgs.parent
    local index = scrollingListPressedArgs.Index - (scrollingList.CurrentPage * scrollingListPressedArgs.Args.ItemsPerPage)

	local traitInfo = {}
	local offset = { X = 110, Y = BoonInfoScreenData.ButtonStartY + index * BoonInfoScreenData.ButtonYSpacer }
	local traitName = args.Text

    local group = scrollingListPressedArgs.Args.Group .. "ScrollingList"
    
    -- BACKING ALREADY CREATED
    -- components[traitName .. "DetailsBacking"] = CreateScreenComponent({
    --     Name = "BoonInfoButton",
    --     -- DestinationId = components.Background.Id,
    --     Group = "Combat_Menu_TraitTray_Backing",
    --     X = offset.X + 455,
    --     Y = offset.Y + 200
    -- })
	
    -- args.Name .. "ScrollingListBacking" .. k
    -- destroy the title because we are using the title from the boon info button code
    -- components[component.Id] = component
    -- if components[scrollingListPressedArgs.Args.Name .. "ScrollingListBacking" .. index] ~= nil then
    --     Destroy { Id = scrollingListPressedArgs.Args.Name .. "ScrollingListBacking" .. index }
    -- end
    CreateTextBoxWithFormat({
        Id = component.Id,
        Group = group,
        OffsetX = -260,
        OffsetY = BoonInfoScreenData.DecriptionBoxOffsetY,
        Width = 665,
        Justification = "Left",
        VerticalJustification = "Top",
        LineSpacingBottom = 8,
        UseDescription = true,
        Format = "BaseFormat",
        VariableAutoFormat = "BoldFormatGraft",
        TextSymbolScale = 0.8,
    })

	traitInfo.TitleBox = CreateScreenComponent({
        Id = component.Id,
        Name = "BlankObstacle",
        Group = group,
        X = offset.X + 20,
        Y = offset.Y + 170, 
    })
	CreateTextBox({
		-- Id = component.Id,
		Id = traitInfo.TitleBox.Id,
        Group = group,
		FontSize = 25,
		OffsetX = 170,
		OffsetY = BoonInfoScreenData.TextBoxOffsetY,
		Color = color,
		Font = "AlegreyaSansSCLight",
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Left",
	})

	traitInfo.RarityBox = CreateScreenComponent({ Name = "BlankObstacle", X = offset.X + 20, Y = offset.Y + 170 })
	CreateTextBox({
		Id = traitInfo.RarityBox.Id,
		FontSize = 25,
        Group = group,
		OffsetX = 860,
		OffsetY = -17,
		Color = color,
		Font = "AlegreyaSansSCLight",
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Right",
	})

	traitInfo.Patch = CreateScreenComponent({
        Name = "BlankObstacle",
        Group = group,
        X = offset.X + 110,
        Y = offset.Y + 205,
        Scale = 0.8
    })
	SetAnimation({ DestinationId = traitInfo.Patch.Id, Name = "BoonRarityPatch"})
	SetColor({ Id = traitInfo.Patch.Id, Color = Color.Transparent })

	traitInfo.Frame = CreateScreenComponent({
        Name = "BoonInfoTraitFrame",
        X = offset.X + 90,
        Y = offset.Y + 200,
        Scale = 0.8,
        Group = group 
    })
	traitInfo.Icon = CreateScreenComponent({
        Name = "BlankObstacle",
        X = offset.X + 90,
        Y = offset.Y + 200,
        Scale = 0.8,
        Group = group
    })
	local newTraitData =  GetProcessedTraitData({ Unit = CurrentRun.Hero, TraitName = traitName, Rarity = "Common", ForBoonInfo = true })
	newTraitData.ForBoonInfo = true
	SetTraitTextData( newTraitData )
	SetTraitTrayDetails( { TraitData = newTraitData, ForBoonInfo = true }, component, traitInfo.RarityBox, traitInfo.TitleBox, traitInfo.Patch, traitInfo.Icon )

    -- show boon level in top right corner
    local boonData = GameState.ZyruIncremental.BoonData[traitName]
    if boonData == nil then
        DebugPrint { Text = "nil trait data for " .. traitName .. " at " .. index }
        return
    end

    local boonLevel = boonData.Level
    -- show exp to next level, bar in bottom

    local boonExp = boonData.Experience
    local expBaseline = boonExp - Z.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expTNL = Z.GetExperienceForNextBoonLevel ( boonLevel ) - Z.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expProportion = expBaseline / expTNL

    local RECTANGLE_01_HEIGHT = 270
    local RECTANGLE_01_WIDTH = 480
    DebugPrint { Text = expBaseline .. " / " .. expTNL .. " = " .. expProportion }

    

    traitInfo.ExperienceBarBackground = CreateScreenComponent({
        Id = component.Id,
        Name = "rectangle01",
        Group = group,
        X = offset.X + 230 + RECTANGLE_01_WIDTH / 2,
        Y = offset.Y + 260,
        Color = {32, 32, 32, 255}
     })
     CreateTextBox({
		Id = traitInfo.ExperienceBarBackground.Id,
		FontSize = 9,
        Group = group,
		Color = {0, 0, 0, 255},
		Font = "AlegreyaSansSC",
        Text = expBaseline .. " / " .. expTNL,
		-- ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Center",
	})
     SetColor{ Id = traitInfo.ExperienceBarBackground.Id, Color = {96, 96, 96, 255} }
     SetScaleY{ Id = traitInfo.ExperienceBarBackground.Id, Fraction = 0.05 }

    traitInfo.ExperienceBar = CreateScreenComponent({
        Id = component.Id,
        Name = "rectangle01",
        Group = group,
        X = offset.X + 230 + RECTANGLE_01_WIDTH * expProportion / 2,
        Y = offset.Y + 260,
        Color = Color.White
     })
     SetColor{ Id = traitInfo.ExperienceBar.Id, Color = Color.White }
     SetScaleX{ Id = traitInfo.ExperienceBar.Id, Fraction = expProportion }
     SetScaleY{ Id = traitInfo.ExperienceBar.Id, Fraction = 0.05 }

    -- currentLevel nextLevel text
    traitInfo.CurrentLevel = CreateScreenComponent({
        Id = component.Id,
        Name = "BlankObstacle",
        Group = group,
        X = offset.X + 20,
        Y = offset.Y + 170
    })
	CreateTextBox({
		Id = traitInfo.CurrentLevel.Id,
		FontSize = 14,
		OffsetX = 170,
		OffsetY = 90,
		Color = color,
        Group = group,
		Font = "AlegreyaSansSCLight",
        Text = "Lv. " .. boonData.Level,
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Left",
	})

    traitInfo.NextLevel = CreateScreenComponent({
        Id = component.Id,
        Name = "BlankObstacle",
        Group = group,
        X = offset.X + 20,
        Y = offset.Y + 170
    })
	CreateTextBox({
		Id = traitInfo.NextLevel.Id,
		FontSize = 14,
		OffsetX = 170 + RECTANGLE_01_WIDTH + 50,
		OffsetY = 90,
		Color = color,
        Group = group,
		Font = "AlegreyaSansSCLight",
        Text = "Lv. " .. (boonData.Level + 1),
		ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
		Justification = "Left",
	})

    -- assign items created to the scrollingList parent

end

function GrowButtonScale ( screen, button )
    DebugPrint { Text = "LOL" }
    SetScale { Id = button.Id, Fraction = 1.1 }
end

function ShrinkButtonScale ( button )
    DebugPrint { Text = "LMAO" }
    SetScale { Id = button.Id, Fraction = 1/1.1 }
end

-- Courtyard Interface

function LolLmao()
    DebugPrint { Text = "LMAO" }
    local voiceline = GetRandomValue(Z.DropLevelUpVoiceLines.RoomRewardMaxHealthDrop)
    
    thread( PlayVoiceLines, voiceline )
end

OnAnyLoad{"RoomPreRun", function(triggerArgs)
    -- TODO: selector.BlockExitUntilUsed, selector.BlockExitText
    -- Upgrade Loading
    local selector = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    selector.UseText = "{I} View Upgrades"
    selector.OnUsedFunctionName = "ShowZyruUpgradeScreen"
    selector.Activate = true
    selector.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        AttachedTable = selector,
        OffsetX = 2000,
        OffsetY = -700,
    })
    SetScale{ Id = selector.ObjectId, Fraction = 0.17 }
    SetColor{ Id = selector.ObjectId, Color = { 120, 255, 170, 255 } }
    SetupObstacle( selector )
    AddToGroup({Id = selector.ObjectId, Name = "ChallengeSelector"})
    -- Boon Data Loading
    
    selector = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    selector.UseText = "{I} View Progress"
    selector.OnUsedFunctionName = "ShowZyruProgressScreen"
    selector.Activate = true
    selector.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        AttachedTable = selector,
        OffsetX = 2200,
        OffsetY = -600,
    })
    SetScale{ Id = selector.ObjectId, Fraction = 0.17 }
    SetupObstacle( selector )
    AddToGroup({Id = selector.ObjectId, Name = "ChallengeSelector"})


    --------------------------
    -- RESET GATE ---
    --------------------------
    local shrinePointDoor = DeepCopyTable( ObstacleData.ShrinePointDoor )
    shrinePointDoor.ObjectId = SpawnObstacle({
        Name = "ShrinePointDoor",
        Group = "FX_Terrain",
        DestinationId = CurrentRun.Hero.ObjectId,
        OffsetX = 1000,
        OffsetY = -600,
        AttachedTable = shrinePointDoor
    })
    SetupObstacle( shrinePointDoor )
    shrinePointDoor.ShrinePointReq = 0
    shrinePointDoor.UseText = "{I} Begin Anew?"
    shrinePointDoor.OnUsedFunctionName = "ShowZyruResetScreen"
    shrinePointDoor.Activate = true
    -- SetScale{ Id = shrinePointDoor.ObjectId, Fraction = 0.17 }
    -- SetColor{ Id = shrinePointDoor.ObjectId, Color = { 120, 255, 170, 255 } }
    AddToGroup({Id = shrinePointDoor.ObjectId, Name = "ChallengeSelector"})
end}