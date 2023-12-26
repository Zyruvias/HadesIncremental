local CreateBoonPresentation = function (screen, traitName, x, y)

    -- fetchInfo
    local zyruBoonData = Z.Data.BoonData[traitName]
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
    table.insert( components, traitIcon )

end

ModUtil.Path.Wrap("CloseRunClearScreen", function (baseFunc, ...) 
    -- TODO: use new framework
    local value = baseFunc( ... )

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
        if Z.Data.BoonData[trait.Name] ~= nil and not Contains(boonsToDisplay, trait.Name) then
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

-- Courtyard Progress Screen
function ShowZyruResetScreen ()
    -- TODO: implement this in new framework
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

-- START SCREEN UPDATE


local cabinetId = nil

function ModInitializationScreen2()
    local screen = Z.CreateMenu("ModInitialization", {
        Pages = {
            [1] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    Args = {
                        Text = "Welcome",
                        FieldName = "WelcomeTitle",
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "WelcomeText",
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
                    Args = {
                        FieldName = "ContextTitle",
                        Text = "Story Context"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "ContextText",
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
            [3] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    Args = {
                        FieldName = "AcknowledgementsTitle",
                        Text = "Acknowledgements"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "ContextText",
                        Text = "A giant thanks to all the support I've gotten over the development of this mod."
                        .." I will list you by name later. I love you all."
                    }
                }
            },
            [4] = {
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    Args = {
                        FieldName = "DifficultyTitle",
                        Text = "Difficulty Settings"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "DifficultyText",
                        Text = "This mod is intended to be difficult by nature of infinite scaling and building off the original game's innate difficulty. Please select your preferred difficulty settings below."
                    }
                },
                {
                    Type = "Dropdown",
                    SubType = "Standard",
                    Args = {
                        FieldName = "DifficultyDropdown",
                        Group = "DifficultyGroup",
                        -- X, Y, Items, Name
                        X = ScreenWidth / 6,
                        Y = ScreenHeight / 3,
                        Items = {
                            Default = {
                                Text = Z.Data.FileOptions.DifficultySetting or "Standard",
                                event = function() end
                            },
                            { Text = "Easy", event = function () Z.Data.FileOptions.DifficultySetting = "Easy" end },
                            { Text = "Standard", event = function() Z.Data.FileOptions.DifficultySetting = "Standard" end },
                            { Text = "Hard", event = function () Z.Data.FileOptions.DifficultySetting = "Hard" end },
                            { Text = "Freeplay", event = function () Z.Data.FileOptions.DifficultySetting = "Freeplay" end },
                        }
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "DifficultyExplanation",
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
                        OffsetY = - ScreenHeight / 6 - 25,
                        Width = ScreenWidth * 0.65
                    }
                }
            },
            [5] = {
                -- starting point
                {
                    Type = "Text",
                    SubType = "Subtitle",
                    Args = {
                        FieldName = "StartingPointTitle",
                        Text = "Starting Point Settings"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "StartingPointText",
                        Text = "This mod requires you to start a fresh file since the context of game progression in normal "
                        .."Hades does not make sense in the context of this mod. However, that does not mean you have to complete "
                        .."the whole story again. You are free to start a fresh file and re-experience the story, but you may "
                        .."also skip past the epilogue and start with a state of all base-game features unlocked if you so choose."
                    }
                },
                {
                    Type = "Dropdown",
                    SubType = "Standard",
                    Args = {
                        FieldName = "StartingPointDropdown",
                        Group = "bleh",
                        X = ScreenWidth / 2,
                        Y = ScreenHeight / 2,
                        Scale = { X = 1.0, Y = 1.0 },
                        Items = {
                            Default = {
                                Text = Z.Data.FileOptions.StartingPoint or "Epilogue",
                                event = function() end
                            },
                            { 
                                Text = Z.Constants.SaveFile.FRESH_FILE,
                                event = function ()
                                    Z.Data.FileOptions.StartingPoint = Z.Constants.SaveFile.FRESH_FILE
                                end
                            },
                            { 
                                Text = "Epilogue",
                                event = function ()
                                    Z.Data.FileOptions.StartingPoint = "Epilogue"
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
                    Args = {
                        Text = "Final Step",
                        FieldName = "finishedTitle"
                    }
                },
                {
                    Type = "Text",
                    SubType = "Paragraph",
                    Args = {
                        FieldName = "FinishedText",
                        Text = "Click the button below to finish your file configuration. Please note that if you are "
                        .."starting from the Epilogue file setting, it will take a minute to process save file changes. "
                        .."Additionally, there are extra miscellaneos settings in the Courtyard when you get there."

                        .. "\\n\\n Thank you for playing <3"
                    }
                },
                {
                    Type = "Button",
                    SubType = "Basic",
                    Args = {
                        Scale = 1.0,
                        FieldName = "FinishedFileConfiguration",
                        Label = {
                            Type = "Text",
                            SubType = "Paragraph",
                            Args = {
                                FieldName = "FinishedFileConfigurationText",
                                Text = "Finish",
                                FontSize = "30",
                                OffsetY = 0,
                                OffsetX = 0,
                                Justification = "Center",
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
                Args = {
                    FieldName = "MenuTitle",
                    Text = "Incremental Mod Setup",
                }
            }
        }
    })
end

function CloseInitializationScreen(screen, button)
    if Z.Data.FileOptions.StartingPoint == Z.Constants.SaveFile.FRESH_FILE then
        ActivatedObjects[cabinetId] = nil
        return CloseScreenByName("ModInitialization")
    end


    -- actually set save data, the dang fools think this is slow :jeb:
    -- Z.InitializeEpilogueStartSaveData()

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
			Proportion = 1, UpdateDuration = 5, Text = "Settling familial disputes ..."
        },
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 1, UpdateDuration = 12, Text = "Informants seeking out Persephone and telling her the truth quickly and not over a series of dozens of painful excursions...",
            -- "No... Zagreus, what have you done? You've led them *here*? TODO: one more - boat line rides?
            Voicelines = {{ Cue = "/VO/Persephone_0060", PreLineWait = 1.5}, }
        },
        { Proportion = 0, UpdateDuration = 0},
        {
            Proportion = 0.6, UpdateDuration = 7, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            
            -- A crimson color for the drapery is sure to be a better fit for the decor.
            Voicelines = {{ Cue = "/VO/ZagreusHome_1085" } },
        },
        {
            Proportion = 0.6, UpdateDuration = 4, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            -- I did not authorize such an expenditure.
            Voicelines = {{ Cue = "/VO/Hades_0518" }},
        },
        {
            Proportion = 0.3, UpdateDuration = 4, Text = "Working the House Contractor Overtime (2x pay, of course) ...",
            -- You know what, I changed my mind about the drapery.
            Voicelines = {{ Cue = "/VO/ZagreusHome_1086" }},
        },
        {
            Proportion = 0.8, UpdateDuration = 11, Text = "Working the House Contractor Overtime (2x pay, of course) ...", 
            Voicelines = {
                -- A fine hallway requires a fine rug, I always say! I say it sometimes...
                { Cue = "/VO/ZagreusHome_1710" },
                -- So wasteful of my realm's resources, boy.
                { Cue = "/VO/Hades_0643", PreLineWait = 5.80},
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
        Args = {
            FieldName = "SaveStateBar",
            X = ScreenCenterX - 480 * 1.5,
            ScaleX = 3,
            ScaleY = 3,
        }
    }
    local progressText = {
        Type = "Text",
        SubType = "Paragraph",
        Args = {
            FieldName = "SaveStateText",
            Text = "",
            OffsetY = -100,
            OffsetX = 0,
            Width = ScreenWidth * 0.75,
            Justification = "Center",
            
        }
    }
    Z.RenderComponent(screen, progressBar)
    Z.RenderComponent(screen, progressText)

    for _, stage in ipairs(stages) do
        DebugPrint { Text = ModUtil.ToString.Deep(stage)}
        if stage.Voicelines then
            thread( PlayVoiceLines, stage.Voicelines )
        end

        if stage.Text then
            progressText.Args.Text = stage.Text
            Z.UpdateComponent(screen, progressText)
        end

        progressBar.Args.Proportion = stage.Proportion
        progressBar.Args.UpdateDuration = stage.UpdateDuration
        Z.UpdateProgressBar(screen, progressBar, { WaitForUpdate = true })
    end


    
    ActivatedObjects[cabinetId] = nil
    CloseScreenByName("ModInitialization")
    
    Kill(CurrentRun.Hero)
end

ModUtil.Path.Wrap("StartRoom", function (base, currentRun, currentRoom)

    if Z.Data.SeenInitialMenuScreen then
        return base(currentRun, currentRoom)
    end

    base(currentRun, currentRoom)
    LoadPackages({Name = "DeathArea"})
    local selector = DeepCopyTable( DeathLoopData.DeathAreaOffice.ObstacleData[488699] )
    selector.BlockExitUntilUsed = true
    selector.BlockExitText = "Mod Setup Not Completed..."
    selector.UseText = "{I} Begin Incremental Journey"
    selector.OnUsedFunctionName = "ModInitializationScreen2"
    selector.Activate = true
    selector.ShrinePointReq = 0

    selector.ObjectId = SpawnObstacle({
        Name = "HouseFileCabinet03",
        Group = "Standing",
        DestinationId = CurrentRun.Hero.ObjectId,
        ForceToValidLocation = true,
        AttachedTable = selector,
        OffsetX = 2550,
        OffsetY = -950,
    })
    cabinetId = selector.ObjectId
    SetScale{ Id = selector.ObjectId, Fraction = 0.17 }
    SetColor{ Id = selector.ObjectId, Color = { 120, 255, 0, 255 } }
    SetupObstacle( selector )
    
    
end, Z)

function Z.TestFrameworkMenu()
    local screen = Z.CreateMenu("Test", {
        Components = {
            {
                Type = "Button",
                SubType = "Icon",
                Args = {
                    FieldName = "IconTest",
                    Group = "Combat_Menu_TraitTray",
                    Animation = "Codex_Portrait_Zagreus",
                    OffsetX = 0,
                    OffsetY = 0,
                    ComponentArgs = {
                        OnPressedFunctionName = "LolLmao"
                    }
                },
            },
            {
                Type = "Button",
                SubType = "Close",
            }
        }
    })
end



ModUtil.Path.Wrap("ShowRunIntro", function() end, Z)

function UpdateBoonInfoProgressScreen(screen, boonName)

    -- UPDATE TEXT
    Z.UpdateComponent(screen, {
        Type = "Text",
        SubType = "Subtitle",
        Args = {
            FieldName = "BoonProgressSubtitle",
            Text = boonName
        }

    })
    -- UPDATE ICON
    Z.UpdateComponent(screen, {
        Type = "Icon",
        SubType = "Standard",
        Args = {
            FieldName = "BoonProgressBoonIcon",
            Animation = GetTraitIcon( TraitData[boonName] or {} ),
            Scale = 4.0
        }
    })
    -- UPDATE PROGRESS BAR
    -- show boon level in top right corner
    local boonData = Z.Data.BoonData[boonName] or {}

    local boonLevel = boonData.Level or 1
    -- show exp to next level, bar in bottom

    local boonExp = boonData.Experience or 0
    local expBaseline = boonExp - Z.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expTNL = Z.GetExperienceForNextBoonLevel ( boonLevel ) - Z.GetExperienceForNextBoonLevel(boonLevel - 1)
    local expProportion = expBaseline / expTNL
    local expProportionLabel = tostring(math.floor((1000 * expBaseline) / expTNL) / 10) .. "%"
    Z.UpdateProgressBar(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        Args = {
            FieldName = "BoonProgressBar",
            BackgroundColor = {96, 96, 96, 255}, -- Default color.
            ForegroundColor = {255, 255, 255, 255},
            Proportion = 0,
            UpdateDuration = 0,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 5,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
            BarText = tostring(expBaseline .. " / " .. expTNL .. " = " .. expProportionLabel),
            LeftText = "Level " .. tostring(boonLevel),
            RightText = "Level " .. tostring(boonLevel + 1)
        }
    })
    Z.UpdateProgressBar(screen, {
        Type = "ProgressBar",
        SubType = "Standard",
        Args = {
            FieldName = "BoonProgressBar",
            Proportion = expProportion,
            UpdateDuration = 1,
            X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
            Y = ScreenCenterY + ScreenHeight / 5,
            -- BackgroundColor = {0, 0, 0, 0},
            ScaleX = 1.5,
            ScaleY = 1.5,
        }
    })
    

    -- Z.RenderComponents(screen, components)
end

function ShowGodProgressScreen(screen, button)
    DebugPrint { Text = ModUtil.ToString.Deep(button)}

    local boonsToDisplay = BoonInfoScreenData.SortedTraitIndex[button.PageIndex .. "Upgrade"]
    -- create scrolling list
    local boonItemsToDisplay = {}
    for i, boonName in ipairs(boonsToDisplay) do
        if not TraitData[boonName] then
            DebugPrint { Text = boonName .. " not found in TraitData" }
        end
        if not Contains(TraitData[boonName] and TraitData[boonName].InheritFrom or {}, "SynergyTrait") then
            table.insert(boonItemsToDisplay, {
                event = function () 
                    DebugPrint { Text = "clicked " .. boonName}
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
            Args = {
                OffsetX = ScreenWidth / 6,
                FieldName = "BoonProgressSubtitle",
                Text = ""
            }
        },
        -- boon icon
        {
            Type = "Icon",
            SubType = "Standard",
            Args = {
                FieldName = "BoonProgressBoonIcon",
                OffsetX = ScreenWidth / 6,
                OffsetY = -100,
                Scale = 4,
            }
        },
        -- progress bar
        {
            Type = "ProgressBar",
            SubType = "Standard",
            Args = {
                FieldName = "BoonProgressBar",
                X = ScreenCenterX + ScreenWidth / 6 - 480 * 0.75,
                Y = ScreenCenterY + ScreenHeight / 5,
                -- BackgroundColor = {0, 0, 0, 0},
                ScaleX = 1.5,
                ScaleY = 1.5,
            }
        },
        {
            -- TODO: fix this shit
            Type = "Button",
            SubType = "Close",
            Args = {
                -- OnPressedFunctionName = "GoToPageFromSource",
            },
            ComponentArgs = {
                PageIndex = 1,
            }
        },
    }
    Z.RenderComponents(screen, componentsToRender)
end

function ShowZyruProgressScreen()

    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            Args = {
                FieldName = "ProgressTitle",
                Text = "Incremental Progress",
            }
        },
        {
            Type = "Text",
            SubType = "Subtitle",
            Args = {
                FieldName = "ProgressSubtitle",
                Text = "Click on a God's portrait to see your progress with their gifts!",
            }
        },
        {
            Type = "Button",
            SubType = "Close",
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
        pages[name] = "ShowGodProgressScreen"
    end

    local screen = Z.CreateMenu("ProgressScreen", {
        PaginationStyle = "Keyed",
        Pages = pages,
        Components = {}
    })
end

function ShowZyruUpgradeScreen()
    DebugPrint { Text = "ShowZyruUpgradeScreen"}
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            Args = {
                FieldName = "UpgradeTitle",
                Text = "Olympian Upgrades",
            }
        },
        {
            Type = "Text",
            SubType = "Subtitle",
            Args = {
                FieldName = "UpgradeSubtitle",
                Text = "Click on a God's portrait to see additional gifts and bonuses they can offer!",
            }
        },
        {
            Type = "Button",
            SubType = "Close",
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

    local screen = Z.CreateMenu("UpgradeScreen", {
        PaginationStyle = "Keyed",
        Pages = pages,
        Components = {}
    })
end

function GetUpgradeGostText(upgrade)
    local costText = "Cost: "
    if upgrade.Sources ~= nil then
        local sourceCostTexts = {}
        for i, source in ipairs(upgrade.Sources) do 
            table.insert(sourceCostTexts, tostring(upgrade.Cost or 0) .. " " .. source .. " Points")
        end
        return costText .. ModUtil.String.Join(", ", sourceCostTexts)
    end
    return costText .. tostring(upgrade.Cost or 0) .. " " .. upgrade.Source .. " Points"
end

function UpdateUpgradeInfoScreen(screen, upgrade)
    -- UPDATE ICON
    Z.CreateOrUpdateComponent(screen, {
        Type = "Icon",
        SubType = "Standard",
        Args = {
            FieldName = "UpgradeIcon",
            Animation = GetTraitIcon( TraitData[upgrade.Name] or {} ),
            OffsetX = ScreenWidth / 6,
            OffsetY = -100,
            Scale = 4,
        }
    })
    Z.CreateOrUpdateComponent(screen, {
        Type = "Text",
        SubType = "Paragraph",
        Args = {
            FieldName = "UpgradeDescriptionText",
            Text = "",
            OffsetX = ScreenWidth / 6,
            OffsetY = 0,

        }
    })
    Z.CreateOrUpdateComponent(screen, {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = "UpgradeCostText",
            Text = GetUpgradeGostText(upgrade),
            OffsetX = ScreenWidth / 6,
            OffsetY = 110,
            Justification = "Center",
        }
    })
    -- Add Purchase Button
    Z.CreateOrUpdateComponent(screen, {
        Type = "Button",
        SubType = "Basic",
        Args = {
            FieldName = "PurchaseButton",
            OffsetX = ScreenWidth / 6,
            OffsetY = 200,
            Label = "Purchase Upgrade",
            ComponentArgs = {
                OnPressedFunctionName = "Z.AttemptPurchaseUpgrade",
                Upgrade = upgrade
            },
        },
    })
end

function GetUpgradeListItem(screen, upgrade)
    return {
        event = function () 
            UpdateUpgradeInfoScreen(screen, upgrade)
        end,
        Text = upgrade.Name,
        Description = "Unlock a new Boon from " .. upgrade.Source,
        ImageStyle = {
            Image = GetTraitIcon( TraitData[upgrade.Name] or {} ),
            Offset = {X = -225, Y = 0},
            Scale = 0.7, 
        },
    }
end

function ShowGodUpgradeScreen(screen, button)
    -- upgradesTodisplay
    local upgradesToDisplay = Z.GetAllUpgradesBySource(button.PageIndex)
    -- create scrolling list
    local upgradeItemsToDisplay = {}
    for i, upgrade in ipairs(upgradesToDisplay) do
        table.insert(upgradeItemsToDisplay, GetUpgradeListItem(screen, upgrade))
    end

    -- create title (god name)
    local componentsToRender = {
        {
            Type = "Text",
            SubType = "Title",
            Args = {
                FieldName = button.PageIndex .. "UpgradeTitle",
                Text = button.PageIndex, -- todo: generalize args or properties or something??
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
            Args = {
                FieldName = "UpgradeCurrency",
                OffsetX = ScreenWidth / 3,
                OffsetY = -450,
                Scale = 0.75,
                Animation = "BoonInfoSymbolZeusIcon",
            }
        },
        {
            Type = "Text",
            SubType = "Note",
            Args = {
                FieldName = "UpgradeCurrencyText",
                OffsetX = ScreenWidth / 3 - 50,
                OffsetY = -450,
                Justification = "Right",
                FontSize = 20,
                Text = "Available Zeus Points: " .. tostring(Z.Data.Currencies.Zeus or 0)
            }
        },
        {
            -- TODO: fix this shit
            Type = "Button",
            SubType = "Close",
            Args = {
                -- OnPressedFunctionName = "GoToPageFromSource",
            },
            -- ComponentArgs = {
            --     PageIndex = 1,
            -- }
        },
    }
    Z.RenderComponents(screen, componentsToRender)
end