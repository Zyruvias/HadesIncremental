--[[
    Author: Zyruvias
    Originating Inspiration:
        - SleepSoul for simple component config notation
        - ErumiUILib as I've appropriated the Dropdown and Sliding list to minimize dependencies

    TODOs:
        - Extract out into reusable library
        - Fix ErumiUILib.Dropdown appropriation bugs
        - Pub/sub component update system instead of consumer-sourced functions
]]

ZyruIncremental.BaseComponents = {

    Text = {
        Title = {
            Font = "SpectralSCLightTitling",
            FontSize = "36",
            Color = Color.White,
            Justification = "Center",
            OffsetY = -450,
            ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0,  2 },
        },
        Subtitle = {
            Font = "AlegreyaSansSCLight",
            FontSize = "30",
            Color = Color.White,
            Justification = "Center",
            OffsetY = -375,
            ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0,  2 },
        },
        Paragraph = {
            FontSize = 24,
            Color = {159, 159, 159, 255},
            Font = "AlegreyaSansSCRegular",
            Justification = "Left",
            Width = ScreenWidth * 0.8,
            VerticalJustification = "Top",
            OffsetX = -ScreenWidth * 0.4,
            OffsetY = -300,
            ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0,  2 },
        },
        Note = {
            FontSize = 16,
            Color = {159, 159, 159, 255},
            Font = "AlegreyaSansSCRegular",
            Justification = "Left",
            ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0,  2 },
        },
            
    },
    Button = {
        -- Name is the animation attached to the button
        Close = {
            Name = "ButtonClose",
            Scale = 0.7,
            OffsetY = 480,
            ComponentArgs = {
                ControlHotkey = "Cancel",
                OnPressedFunctionName = "CloseScreenFully",
            }
        },
        Back = {
            Name = "ButtonClose",
            Scale = 0.7,
            OffsetY = 480,
            ComponentArgs = {
                ControlHotkey = "Cancel",
                OnPressedFunctionName = "ScreenPageBack",
            }
        },
        MenuLeft = {
            Name = "ButtonCodexDown",
            OffsetX = -1 * ScreenWidth / 2 + 50,
            ComponentArgs = {
                OnPressedFunctionName = "ScreenPageLeft",
                ControlHotkeys = { "MenuLeft", "Left" }
            },
            Angle = -90
        },
        MenuRight = {
            Name = "ButtonCodexDown",
            OffsetX = ScreenWidth / 2 - 50,
            ComponentArgs = {
                OnPressedFunctionName = "ScreenPageRight",
                ControlHotkeys = { "MenuRight", "RightLeft" }
            },
            Angle = 90
        },
        Basic = {
            Name = "BoonSlot1",
            Scale = 0.5,
        },
        Icon = {
            Name = "BaseInteractableButton",
        },
    },
    ProgressBar = {
        Standard = {
            Name = "rectangle01",
            Proportion = 0,
            BackgroundColor = {96, 96, 96, 255},
            ForegroundColor = Color.White,
            ScaleY = 1.0,
            ScaleX = 1.0,
            X = ScreenCenterX - 240,
            Y = ScreenCenterY,
        },
    },
    Distribution = {
        Standard = {
            Name = "rectangle01",
            BackgroundColor = {96, 96, 96, 255},
            ForegroundColor = Color.White,
            ScaleY = 1.0,
            ScaleX = 1.0,
            X = ScreenCenterX - 240,
            Y = ScreenCenterY,
        }
    },
    Background = {
        Name = "rectangle01",
        X = ScreenCenterX,
        Y = ScreenCenterY,
        Scale = 10,
        Color = Color.Black,
        Alpha = 0.85,
        FadeInDuration = 0.5,
    },
    Dropdown = {
        Standard = {
            Name = "MyDropdown",
            Scale = {X = .25, Y = .5},
            Padding = {X = 0, Y = 2},
            GeneralFontSize = 16,
            Font = "AlegrayaSansSCRegular",
        }
    },
    -- ErumiUI's Scrolling List wrapper
    List = {
        Standard = {
            Name = "MyScrollingList", 
            Group = "GardenBoxGroup",
            Scale = {X = 0.6, Y = 1},
            Padding = {X = 0, Y = 5},
            X = 300, Y = 200,
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
        }
    },
    Icon = {
        Standard = {
            Name = "BlankObstacle",
        },
    },

}

-- holdover pattern from absorbing ErumiUILib
ZyruIncremental.Dropdown = {}
ZyruIncremental.ScrollingList = {}

ZyruIncremental.PauseBlockScreens = {}
ModUtil.Path.Wrap("IsPauseBlocked", function (base)
	for name  in pairs( ZyruIncremental.PauseBlockScreens ) do
		if ActiveScreens[name] then
			return true
		end
	end
    return base()
end, ZyruIncremental)

function GetScreenIdsToDestroy(screen) 
    local idsToKeep = screen.PermanentComponents or {}
    local allIds = GetAllIds(screen.Components)
    local idsToDestroy = {}
    for componentName, component in pairs(screen.Components) do
        local id = component.Id
        if not Contains(idsToKeep, id) then
            table.insert(idsToDestroy, component.Id)
            -- remove the definition from the screen -- normally this is done
            -- by just deleting the whole screen on close
            screen.Components[componentName] = nil
        end
    end
    
    return idsToDestroy
end

function GoToPageFromSource(screen, button, args)
    args = args or {}
    if button.PageIndex == nil then
        DebugPrint { Text = "You need to set PageIndex on the button, you doofus."}
    end
    if not args.Back then
        -- insert current Page into history context before it's erased
        table.insert(screen.PageStack, screen.PageIndex)
    end
    RenderScreenPage(screen, button, button.PageIndex)
end

function DestroyTemporaryScreenComponents(screen)

    Destroy({Ids = GetScreenIdsToDestroy(screen)})
end

-- Handles non-linear paging
function RenderScreenPage(screen, button, index)
    -- Get Non-permanent components and DESTROY them
    screen.PageIndex = index
    DestroyTemporaryScreenComponents(screen)

    -- then render it
    ZyruIncremental.RenderComponents(screen, screen.Pages[index], { Source = button })

end

function ScreenPageRight(screen, button)
    -- todo PageStack makes sense here?
    if screen.PageIndex == screen.PageCount then
        return
    end
    -- increment page
    screen.PageIndex = screen.PageIndex + 1
    RenderScreenPage(screen, button, screen.PageIndex)

end

function ScreenPageLeft(screen, button)
    -- todo PageStack makes sense here?
    if screen.PageIndex == 1 then
        return
    end
    screen.PageIndex = screen.PageIndex - 1
    RenderScreenPage(screen, button, screen.PageIndex)
end

function ScreenPageBack(screen, button)
    if screen.PageStack == nil then
        return
    end
    if #screen.PageStack == 0 then
        -- close function??
        CloseScreenFully(screen, button)
        return
    end
    local previousScreenContext = table.remove(screen.PageStack)
    GoToPageFromSource(screen, { PageIndex = previousScreenContext }, { Back = true })

end

function CloseScreenFully(screen, button)
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
    -- todo: screen args??
    if button.CloseScreenFunction then
        button.CloseScreenFunction(button.CloseScreenFunctionArgs)
    elseif button.CloseScreenFunctionName ~= nil then
        _G[button.CloseScreenFunctionName](button.CloseScreenFunctionArgs)
    end
end

function SetComponentDefinitionProperty(screen, component, property, value)
    local fieldName = component.FieldName
    if fieldName == nil then
        return
    end
    if ModUtil.Path.Get(fieldName, screen.Components) ~= nil then
        screen.Components[fieldName].Args = screen.Components[fieldName].Args or {}
        -- DebugPrint { Text = "setting " .. tostring(property) .. " on " .. fieldName .. " to " .. tostring(value)}
        screen.Components[fieldName].Args[property] = value
    end

end

-- Generates a component definition from either an existing screen component or the base definition
function GetComponentDefinition(screen, component)
    -- TODO: do I need to require a type and subtype all the time?

    if not component or not component.Type or not component.SubType then
        DebugPrint { Text = "Bad component received .. " .. ModUtil.ToString.Shallow(component)}
        return
    end
    local baseDefinition = DeepCopyTable(ZyruIncremental.BaseComponents[component.Type][component.SubType])
    if baseDefinition == nil then
        DebugPrint { Text = "bad baseDefinition generated for " .. tostring((component.Args or {}).FieldName)}
    end
    local groupToUse = ModUtil.Path.Get("Args.Group", component)
        or baseDefinition.Group
        or ModUtil.Path.Get("Pages[" .. tostring(screen.PageIndex) .. "].Group", screen)
        or screen.Group
    baseDefinition.Group = groupToUse
    local fieldName = component.FieldName
    -- DebugPrint { Text = "accessing definition for " .. fieldName }
    baseDefinition.FieldName = fieldName
    if fieldName ~= nil and ModUtil.Path.Get(fieldName, screen.Components) ~= nil then
        local cachedDefinition = screen.Components[fieldName].Args or {}
        -- DebugPrint { Text = ModUtil.ToString.Shallow(cachedDefinition)}
        baseDefinition = ModUtil.Table.Merge(
            baseDefinition,
            cachedDefinition
        )
    end

    local componentDefinition = ModUtil.Table.Merge(
        baseDefinition,
        DeepCopyTable(component.Args or {})
    )
    -- DebugPrint { Text = tostring(fieldName) .. ": " .. ModUtil.ToString.Shallow(componentDefinition)}
    return componentDefinition
end
local forbiddenprops = {
    "ShadowColor",
    "Color",
    "ShadowOffset",
}
function  prettyprintcomponent(component, offset)
    offset = offset or ""
    for prop, value in pairs(component) do
        if type(value) == "table" and not Contains(forbiddenprops, prop) then
            DebugPrint { Text = offset .. prop .. " {"}
            prettyprintcomponent(value, offset .. "  ")
            DebugPrint { Text = offset .. "}"}

        else
            DebugPrint { Text = offset .. prop .. " " .. tostring(value)}
        end
    end
end

function ZyruIncremental.CreateOrUpdateComponent(screen, component)
    local componentDefinition = GetComponentDefinition(screen, component)
    -- prettyprintcomponent(component)
    if screen.Components[componentDefinition.FieldName] ~= nil then
        ZyruIncremental.UpdateComponent(screen, component)
    else
        ZyruIncremental.RenderComponent(screen, component)
    end
end

-- Create Menu
function ZyruIncremental.CreateMenu(name, args)
    -- Screen / Hades Framework Setup
    args = args or {}
    local screen = { Components = {}, Name = name }
    ScreenAnchors[name] = screen

    local components = screen.Components

    -- initialize group if provided
    -- screen.Group = screen.Group or "Combat_Menu_TraitTray_Overlay"
    -- initialize screen page history
    screen.PageStack = { }

    if IsScreenOpen( screen.Name ) then
		return
	end
    OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true })
    if args.SkipMeta == nil then
        HideCombatUI(name)
        FreezePlayerUnit()
        EnableShopGamepadCursor()
    end

    -- Lets users use escape / cancel to exit the menu
    if args.PauseBlock then
        ZyruIncremental.PauseBlockScreens[screen.Name] = true
    end
    -- TODO: what the fuck do these do
	-- SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
	-- SetConfigOption({ Name = "FreeFormSelectGridLock", Value = true })
	-- SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 8 })
	-- SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 2 })
	-- SetConfigOption({ Name = "FreeFormSelectRepeatDelay", Value = 0.6 })
	-- SetConfigOption({ Name = "FreeFormSelectRepeatInterval", Value = 0.1 })

    -- Initialize Background + Sounds
	PlaySound({ Name = args.OpenSound or "/SFX/Menu Sounds/DialoguePanelIn" })
    local background = args.Background or ZyruIncremental.BaseComponents.Background
    -- Generalize rendering components on the screen.
    ZyruIncremental.RenderBackground(screen, background)
    ZyruIncremental.RenderComponents(screen, args.Components)
    if args.Pages ~= nil then
        screen.Pages = args.Pages
        screen.PageIndex = args.InitialPageIndex or 1
        screen.PageCount = TableLength(args.Pages)
        -- Page Left button
        if (args.PaginationStyle or "Linear") == "Linear" then
            ZyruIncremental.RenderButton(screen, {
                Type = "Button",
                SubType = "MenuLeft",
                FieldName = "MenuLeft",
            })
            -- Page Right button
            ZyruIncremental.RenderButton(screen, {
                Type = "Button", 
                SubType = "MenuRight",
                FieldName = "MenuRight",
            })
        end
        -- assigns the "core" components to a placeholder ID set to not delete later
        screen.PermanentComponents = GetAllIds(screen.Components)

        -- Render first Page
        ZyruIncremental.RenderComponents(screen, args.Pages[screen.PageIndex])
    end


    -- local exclusionGroup = GetConfigOptionValue({ Name = "ExclusiveInteractGroup"})
    -- if exclusionGroup ~= nil then
    --     screen.PreviousExclusionGroup = exclusionGroup
    -- end
    -- SetConfigOption({ Name = "ExclusiveInteractGroup", Value = screenGroup })
	screen.KeepOpen = true
	thread( HandleWASDInput, ScreenAnchors[name] )
	HandleScreenInput( screen )
    return screen
end

function ZyruIncremental.RenderComponents(screen, componentsToRender, args) 
    args = args or {}
    if componentsToRender == nil then
        DebugPrint { Text = "componentsToRender was nil, not rendering anything"}
    end
    -- Handle rendering overrides
    if type(componentsToRender) == "string" then
        if type(_G[componentsToRender]) == "function" then
            return _G[componentsToRender](screen, args.Source) -- TODO: do secondary args make sense here?
        end
    elseif type(componentsToRender) == "function" then
        return componentsToRender(screen, args.Source)
    end

    -- default framework rendering
    for _, component in pairs(componentsToRender) do
        ZyruIncremental.RenderComponent(screen, component)
    end
end

function ZyruIncremental.RenderComponent(screen, component)
    if not component or component.Type == nil then
        DebugPrint { Text = "No component or no component Type property provided"}
        return
    end 
    if type(ZyruIncremental["Render" .. tostring(component.Type)]) == "function" then
        local updateArgs = ZyruIncremental["Render" .. tostring(component.Type)](screen, component)

        -- establish definition on screen object for later access
        local fieldName = component.FieldName
        if fieldName ~= nil and ModUtil.Path.Get(fieldName, screen.Components) ~= nil then
            -- DebugPrint { Text = "storing component definition for " .. fieldName}
            screen.Components[fieldName].Args = updateArgs or GetComponentDefinition(screen, component)
            -- prettyprintcomponent(screen.Components[fieldName].Args)
        end
    end
end

function ZyruIncremental.UpdateComponent(screen, component, args)
    if not component or component.Type == nil then
        DebugPrint { Text = "No component or no component Type property provided"}
        return
    end 
    if type(ZyruIncremental["Update" .. tostring(component.Type)]) == "function" then
        -- DebugPrint { Text = "calling ZyruIncrenmental." .. "Update" .. tostring(component.Type)}
        local updateArgs = ZyruIncremental["Update" .. tostring(component.Type)](screen, component, args)

        -- reestablish definition on screen object for later access
        local fieldName = component.FieldName
        screen.Components[fieldName].Args = updateArgs or GetComponentDefinition(screen, component)
    end
end

function ZyruIncremental.RenderIcon(screen, component)
    local iconDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components
    
    local iconName = iconDefinition.FieldName

    components[iconName] = CreateScreenComponent(iconDefinition)
    -- TODO - Move call after attach for parity with update?
	Attach({
        Id = components[iconName].Id,
        DestinationId = components.Background.Id,
        OffsetX = iconDefinition.OffsetX,
        OffsetY = iconDefinition.OffsetY,
    })
    ZyruIncremental.UpdateComponent(screen, component)
end

function ZyruIncremental.UpdateIcon(screen, component)
    local iconDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components
    if iconDefinition.Animation ~= nil then
        SetAnimation({ DestinationId = components[iconDefinition.FieldName].Id, Name = iconDefinition.Animation })
    end
    if iconDefinition.Scale ~= nil then
        SetScale({ Id = components[iconDefinition.FieldName].Id, Fraction = iconDefinition.Scale })
    end

    
    
end

local CHUNK_MIN_WIDTH = 5
local CHUNK_WIDTH_TO_FLIP_OFFSET = 100
-- Create DistributionBar
function ZyruIncremental.RenderDistribution(screen, component)
    local barDefinition = GetComponentDefinition(screen, component)
    barDefinition.ScaleY = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y * barDefinition.ScaleY
    barDefinition.ScaleX = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * barDefinition.ScaleX
    local components = screen.Components
    local barName = barDefinition.FieldName or ""

    local barBackgroundDefinition = {
        Name = barDefinition.Name,
        X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
        Y = barDefinition.Y,
    }

    components[barName .. "BarBackground"] = CreateScreenComponent(barBackgroundDefinition)
    if barDefinition.Label ~= nil then
        local label = {
            Type = "Text",
            SubType = "Note",
            FieldName = barName .. "BarLabel",
            Args = {
                Text = barDefinition.label or "",
                Parent = barName .. "BarBackground",
                X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
                Y = barDefinition.Y,
                Justification = "Center"
            }
        }
        barDefinition.Label.Parent = barName
        ZyruIncremental.RenderText(screen, barDefinition.Label)
    end
    SetColor{ Id = components[barName .. "BarBackground"].Id, Color = barDefinition.BackgroundColor}
    SetScaleX{ Id = components[barName .. "BarBackground"].Id, Fraction = barDefinition.ScaleX }
    SetScaleY{ Id = components[barName .. "BarBackground"].Id, Fraction = barDefinition.ScaleY }

    -- createForeground bars
    -- barDefinition.ScaleX *
    -- ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X
    -- * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
    local cumulativeProportion = 0
    local backgroundBarWidth = barDefinition.ScaleX
        * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X *
        ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH
    local sign = 1
    local previousChunkWidth
    for i, data in ipairs(barDefinition.DistributionData) do
        local chunkName = data.Name or tostring(i)
        local chunkComponentName = barName .. "BarForeground" .. chunkName
        local chunkWidth = barDefinition.ScaleX
            * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X *
            ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH * data.Value
        if chunkWidth >= CHUNK_MIN_WIDTH then
            local chunkDefinition = {
                X = barDefinition.X + chunkWidth / 2 + cumulativeProportion * backgroundBarWidth,
                Y = barDefinition.Y,
            }
            components[chunkComponentName] = CreateScreenComponent({
                Name = "rectangle01",
                -- add offset based on proportion and cumulative proportion
                X = chunkDefinition.X,
                Y = chunkDefinition.Y,
            })
            cumulativeProportion = cumulativeProportion + data.Value
            components[chunkComponentName].Proportion = barDefinition.Proportion
            SetColor{ Id = components[chunkComponentName].Id, Color = data.Color or barDefinition.ForegroundColor}
            SetScaleX{ Id = components[chunkComponentName].Id, Fraction = data.Value * barDefinition.ScaleX}
            SetScaleY{ Id = components[chunkComponentName].Id, Fraction = barDefinition.ScaleY }

            -- TEXT to render


            local chunkText = 
                (sign == 1 and "^ \\n " or "") ..
                data.Name .. " - " .. tonumber(string.format("%.1f", data.Value * 100)) .. "%" ..
                (sign == -1 and "\\n  v" or "")
            local text = {
                Type = "Text",
                SubType = "Note",
                FieldName = chunkComponentName .. "Text",
                Args = {
                    Text = chunkText,
                    Parent = chunkComponentName .. "BarBackground",
                    X = chunkDefinition.X,
                    Y = chunkDefinition.Y + (ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y *
                        ZyruIncremental.Constants.Components.RECTANGLE_01_HEIGHT + 20) * sign,
                    Justification = "Center",
                    Color = Color.White
                }
            }            
            -- if chunkWidth < CHUNK_WIDTH_TO_FLIP_OFFSET and previousChunkWidth ~= nil or (previousChunkWidth or 999999999999) < CHUNK_WIDTH_TO_FLIP_OFFSET then
            sign = -1 * sign
            previousChunkWidth = chunkWidth
            -- end
            ZyruIncremental.RenderComponent(screen, text)
        end
        
    end


    
    -- TODO: left text / right text
    -- local barText = {
    --     Type = "Text",
    --     SubType = "Note",
    --         FieldName = barName .. "BarText",
    --     Args = {
    --         Text = barDefinition.BarText or "",
    --         Parent = barName .. "BarBackground",
            
    --         X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
    --         Y = barDefinition.Y,
    --         Justification = "Center"
    --     }
    -- }
    -- ZyruIncremental.RenderText(screen, barText)
end

function ZyruIncremental.UpdateDistribution(screen, component)

end

-- Create Progress Bar
function ZyruIncremental.RenderProgressBar(screen, component)
    local barDefinition = GetComponentDefinition(screen, component)
    barDefinition.ScaleY = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y * barDefinition.ScaleY
    barDefinition.ScaleX = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * barDefinition.ScaleX
    local components = screen.Components
    local barName = barDefinition.FieldName or ""

    local barBackgroundDefinition = {
        Name = barDefinition.Name,
        X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
        Y = barDefinition.Y,
    }

    components[barName .. "BarBackground"] = CreateScreenComponent(barBackgroundDefinition)
    if barDefinition.Label ~= nil then
        if type(barDefinition.Label) == "table" then
            barDefinition.Label.Parent = barName .. "BarBackground"
        else
            barDefinition.Label = {
                Type = "Text",
                SubType = "Note",
                FieldName = barName .. "BarLabel",
                Args = {
                    Text = barDefinition.Label,
                    Parent = barName .. "BarBackground",
                    X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
                    Y = barDefinition.Y - 25,
                    Justification = "Center"
                }
            }
        end
        ZyruIncremental.RenderText(screen, barDefinition.Label)
    end
    SetColor{ Id = components[barName .. "BarBackground"].Id, Color = barDefinition.BackgroundColor}
    SetScaleX{ Id = components[barName .. "BarBackground"].Id, Fraction = barDefinition.ScaleX }
    SetScaleY{ Id = components[barName .. "BarBackground"].Id, Fraction = barDefinition.ScaleY }

    components[barName .. "BarForeground"] = CreateScreenComponent({
        Name = "rectangle01",
        -- add offset based on proportion
        X = barBackgroundDefinition.X,
        Y = barBackgroundDefinition.Y,
    })
    components[barName .. "BarForeground"].Proportion = barDefinition.Proportion
    SetColor{ Id = components[barName .. "BarForeground"].Id, Color = barDefinition.ForegroundColor}
    SetScaleX{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.Proportion }
    SetScaleY{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.ScaleY }

    
    -- TODO: left text / right text
    local barText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "BarText",
        Args = {
            Text = barDefinition.BarText or "",
            Parent = barName .. "BarBackground",
            
            X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH / 2,
            Y = barDefinition.Y,
            Justification = "Center"
        }
    }
    ZyruIncremental.RenderText(screen, barText)
    local leftText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "LeftText",
        Args = {
            Text = barDefinition.LeftText or "",
            Parent = barName .. "BarBackground",
            X = barDefinition.X - 25,
            Y = barDefinition.Y,
            Justification = "Right"
        }
    }
    ZyruIncremental.RenderText(screen, leftText)
    local rightText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "RightText",
        Args = {
            Text = barDefinition.RightText or "",
            Parent = barName .. "BarBackground",
            X = barDefinition.X +  barDefinition.ScaleX * ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH + 25,
            Y = barDefinition.Y,
            Justification = "Left"
        }
    }
    ZyruIncremental.RenderText(screen, rightText)
    ZyruIncremental.UpdateProgressBar(screen, component, args)
end

function ZyruIncremental.UpdateProgressBar(screen, component, args)
    args = args or {}
    local barDefinition = GetComponentDefinition(screen, component)
    barDefinition.ScaleY = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y * barDefinition.ScaleY
    barDefinition.ScaleX = ZyruIncremental.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * barDefinition.ScaleX
    local barName = barDefinition.FieldName or ""
    local components = screen.Components

    local oldProportion = components[barName .. "BarForeground"].Proportion
    local proportionDelta = barDefinition.Proportion - oldProportion
    Move({
        Id = components[barName .. "BarForeground"].Id,
        OffsetX = barDefinition.X + barDefinition.ScaleX * proportionDelta / 2 * ZyruIncremental.Constants.Components.RECTANGLE_01_WIDTH,
        OffsetY = barDefinition.Y,
        Duration = barDefinition.UpdateDuration
    })
    SetScaleX{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.ScaleX * barDefinition.Proportion, Duration = barDefinition.UpdateDuration }
    if args.WaitForUpdate then
        wait(barDefinition.UpdateDuration or 0)
    end

    -- update texts if provided
    local barText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "BarText",
        Args = {
            Text = barDefinition.BarText or "",
            Parent = barName .. "BarBackground",
        }
    }
    ZyruIncremental.UpdateComponent(screen, barText)
    local leftText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "LeftText",
        Args = {
            Text = barDefinition.LeftText or "",
            Parent = barName .. "BarBackground"
        }
    }
    ZyruIncremental.UpdateComponent(screen, leftText)
    local rightText = {
        Type = "Text",
        SubType = "Note",
        FieldName = barName .. "RightText",
        Args = {
            Text = barDefinition.RightText or "",
            Parent = barName .. "BarBackground"
        }
    }
    ZyruIncremental.UpdateComponent(screen, rightText)
    
end

function ZyruIncremental.RenderDropdown(screen, component)
    local dropdownDefinition = GetComponentDefinition(screen, component)
    dropdownDefinition.Name = dropdownDefinition.FieldName
    
    ZyruIncremental.Dropdown.CreateDropdown(screen, dropdownDefinition)
end

function ZyruIncremental.RenderButton(screen, component)
    local buttonDefinition = GetComponentDefinition(screen, component)

    local components = screen.Components
    local buttonName = buttonDefinition.FieldName or buttonDefinition.Name
    local buttonComponentName = buttonDefinition.Name or "BaseInteractableButton"
    components[buttonName] = CreateScreenComponent({ Name = buttonComponentName, Scale = buttonDefinition.Scale or 1.0  })

    if buttonDefinition.Animation ~= nil then
        SetAnimation({ DestinationId = components[buttonName].Id, Name = buttonDefinition.Animation })
    end
    components[buttonName .. "HighlightTarget"] = CreateScreenComponent { Name = "BaseInteractableButton", DestinationId = components[buttonName].Id }
    -- SetInteractProperty({ DestinationId = components[buttonName .. "HighlightTarget"].Id, Property = "HighlightOnAnimation", Value = "PortraitEmoteSparkly" })
    -- SetInteractProperty({ DestinationId = components[buttonName].Id, Property = "HighlightOnAnimation", Value = "Portrait_Base_01_Exit" })




	Attach({
        Id = components[buttonName].Id,
        DestinationId = components.Background.Id,
        OffsetX = buttonDefinition.OffsetX,
        OffsetY = buttonDefinition.OffsetY,
    })
    if buttonDefinition.ComponentArgs then
        ModUtil.Table.Merge(components[buttonName], buttonDefinition.ComponentArgs)
    end
    if buttonDefinition.Angle ~= nil then
        SetAngle({ Id = components[buttonName].Id, Angle = buttonDefinition.Angle})
    end

    -- LABELLED BUTTONS
    if buttonDefinition.Label then
        if type(buttonDefinition.Label) == "table" then
            buttonDefinition.Label.Parent = buttonName
            ZyruIncremental.RenderText(screen, buttonDefinition.Label)
        else
            local buttonLabel = {
                Type = "Text",
                SubType = "Note",
                FieldName = buttonName.."Label",
                Args = {
                    Text = buttonDefinition.Label or "",
                    OffsetX = buttonDefinition.OffsetX,
                    OffsetY = buttonDefinition.OffsetY,
                    Justification = "Center",
                },
                Parent = buttonName
            }
            ZyruIncremental.RenderText(screen, buttonLabel)
        end
    end

    return components[buttonName]
end

function ZyruIncremental.UpdateButton(screen, component)

    local buttonDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components

    local button = components[buttonDefinition.FieldName]

    -- NOTE: this is a shallow merge because button.Upgrade needs to
    -- be fully replaced in the case PurchaseButton usage...
    -- TODO: generalize with a meta field or something idk
    
    -- ModUtil.Table.Merge(button, buttonDefinition.ComponentArgs)
    for setKey, setVal in pairs( buttonDefinition.ComponentArgs ) do
		button[setKey] = setVal
	end

end

-- Create Text Box
function ZyruIncremental.RenderText(screen, component)
    local textDefinition = GetComponentDefinition(screen, component)
    -- prettyprintcomponent(textDefinition)
    -- Create Text
    textDefinition.Name = "BlankObstacle"
    local parentName = textDefinition.Parent or "Background"
    textDefinition.Parent = parentName
    -- update a computed property on the object definition
    DebugPrint { Text = parentName }
    if screen.Components[parentName] == nil then
        textDefinition.Parent = "Background"
    end
    textDefinition.DestinationId = screen.Components[textDefinition.Parent].Id


    screen.Components[textDefinition.FieldName] = CreateScreenComponent(textDefinition)
    textDefinition.Id = screen.Components[textDefinition.FieldName].Id
    CreateTextBox(textDefinition)
    return textDefinition
end

function ZyruIncremental.UpdateText(screen, component)
    -- TODO: evaluate if this can even be simplified
    local textDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components
    -- DebugPrint { Text = textDefinition.Text }
    ModifyTextBox({
        Id = components[textDefinition.FieldName].Id, Text = textDefinition.Text
    })
    return textDefinition
end

function ZyruIncremental.RenderBackground(screen, component)
    screen.Components.Background = CreateScreenComponent({ Name = component.Name, X = component.X, Y = component.Y })
    if component.Scale ~= nil then
        SetScale({ Id = screen.Components.Background.Id, Fraction = component.Scale })
    end
    if component.Color ~= nil then
        SetColor({ Id = screen.Components.Background.Id, Color = component.Color })
    end
    if component.Alpha ~= nil then
        if component.FadeInDuration ~= nil then
            SetAlpha({ Id = screen.Components.Background.Id, Fraction = 0 })
            SetAlpha({ Id = screen.Components.Background.Id, Fraction = component.Alpha, Duration = component.FadeInDuration })
        else
            SetAlpha({ Id = screen.Components.Background.Id, Fraction = component.Alpha })
        end
    end
    return screen.Components.Background
end

function ZyruIncremental.RenderList(screen, component)
    local listDefinition = GetComponentDefinition(screen, component)

    local scrollingList = ZyruIncremental.ScrollingList.CreateScrollingList(
		screen, listDefinition
    )
end

--[[

    TODO: 
    1) Make most functions create/update where create calls update after initialization of components
    to minimize code duplication and mistakes\
    2) more options for fields
    3) Make labels on components more ubiquotious and add support for either object or plain text
    4) Make the generic component hooks work for multi-element things...
]]

function ZyruIncremental.ScrollingList.CreateScrollingList(screen, args)
    local xPos = (args.X or 0)
    local yPos = (args.Y or 0)
    local components = screen.Components
    local Name = (args.Name or "UnnamedScrollingList")
    --Create base default text and backingKey
    local scrollingListTopBackingKey = Name .. "BaseBacking"
    components[scrollingListTopBackingKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = args.Group, Scale = 1, X = xPos, Y = yPos })

    components[scrollingListTopBackingKey].isEnabled = true
    components[scrollingListTopBackingKey].Children = {}
    components[scrollingListTopBackingKey].screen = screen
    components[scrollingListTopBackingKey].CurrentPage = 0
    components[scrollingListTopBackingKey].args = args

    ZyruIncremental.ScrollingList.Update(components[scrollingListTopBackingKey])
    return components[scrollingListTopBackingKey]
end
function ZyruIncremental.ScrollingList.Update(scrollingList)
    local args = scrollingList.args
    local screen = scrollingList.screen
    local xPos = (args.X or 0)
    local yPos = (args.Y or 0)
    local components = screen.Components
    local Name = (args.Name or "UnnamedScrollingList")
    --Create base default text and backingKey
    local scrollingListTopBackingKey = Name .. "BaseBacking"
    local currentPageItems = {}

    for _,v in pairs(scrollingList.Children) do
        Destroy({Id = v.Id})
    end

    for i = 1, args.ItemsPerPage do
        local curItem = args.Items[i + (scrollingList.CurrentPage * args.ItemsPerPage)]
        if curItem == nil then
            break
        end
            table.insert(currentPageItems, curItem)
        
    end
    for k,v in pairs(currentPageItems) do
        local scrollingListItemBackingKey = args.Name .. "ScrollingListBacking" .. k
        local ySpaceAmount = 102* (k - 1) * args.Scale.Y + (args.Padding.Y * k)
        components[scrollingListItemBackingKey] = CreateScreenComponent({ Name = "MarketSlot", Group = args.Group .. "ScrollingList", Scale = 1, X = (args.X or 0), Y = (args.Y or 0) + ySpaceAmount})
        components[scrollingListItemBackingKey].scrollingListPressedArgs = {Args = args, parent = scrollingList, Index = k + (scrollingList.CurrentPage * args.ItemsPerPage)}

        SetScaleY({ Id = components[scrollingListItemBackingKey].Id , Fraction = args.Scale.Y or 1 })
        SetScaleX({ Id = components[scrollingListItemBackingKey].Id , Fraction = args.Scale.X or 1 })
        local offsetX = (args.GeneralOffset or {X = 0}).X
        if v.Offset ~= nil then
            offsetX = v.Offset.X
        end
        local offsetY = (args.GeneralOffset or {Y = 0}).Y
        if v.Offset ~= nil then
            offsetY = v.Offset.Y
        end
        local textColor = Color.White
        CreateTextBox({ Id = components[scrollingListItemBackingKey].Id, Text = v.Text,
            FontSize = v.FontSize or args.GeneralFontSize,
            OffsetX = offsetX, OffsetY = offsetY,
            Width = 665,
            Justification = (v.Justification or args.Justification) or "Center",
            VerticalJustification = (v.VerticalJustification or args.VerticalJustification) or "Center",
            LineSpacingBottom = 8,
            Font = (v.Font or args.Font) or "AlegreyaSansSCBold",
            Color = textColor,
            ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
            TextSymbolScale = 0.8,
        })
        if v.Description then
            local descriptionDefinition = { 
                Id = components[scrollingListItemBackingKey].Id, Text = v.Description,
                FontSize = v.DescriptionFontSize or args.DescriptionFontSize or 10,
                OffsetX = (v.DescriptionOffset or args.DescriptionOffset).X or 0, OffsetY = (v.DescriptionOffset or args.DescriptionOffset).Y or 0,
                Width = 665,
                Justification = (v.Justification or args.Justification) or "Center",
                VerticalJustification = (v.VerticalJustification or args.VerticalJustification) or "Center",
                LineSpacingBottom = 8,
                Font = (v.Font or args.Font) or "AlegreyaSansSCBold",
                Color = args.DescriptionColor,
                ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
                TextSymbolScale = 0.8,
            }
            if v.DescriptionArgs ~= nil then
                ModUtil.Table.Merge(
                    descriptionDefinition,
                    v.DescriptionArgs
                )
            end
            CreateTextBox(descriptionDefinition)
        end
        if v.ImageStyle ~= nil and v.ImageStyle.Image ~= nil then
            local scrollingListItemImageBackingKey = args.Name .. "ScrollingListIcon" .. k
            components[scrollingListItemImageBackingKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = args.Group .. "Image", Scale = v.ImageStyle.Scale or 1 })
            SetAnimation({ Name = v.ImageStyle.Image  , DestinationId = components[scrollingListItemImageBackingKey].Id, Scale = 1 })
            Attach({ Id = components[scrollingListItemImageBackingKey].Id, DestinationId = components[scrollingListItemBackingKey].Id, OffsetX = v.ImageStyle.Offset.X or 0, OffsetY = v.ImageStyle.Offset.Y or 0})
            components[scrollingListTopBackingKey].Children[components[scrollingListItemImageBackingKey].Id] = components[scrollingListItemImageBackingKey]
        elseif args.ImageStyle ~= nil and args.ImageStyle.Image ~= nil then
            local scrollingListItemImageBackingKey = args.Name .. "ScrollingListIcon" .. k
            components[scrollingListItemImageBackingKey] = CreateScreenComponent({ Name = "BlankObstacle", Group = args.Group .. "Image", Scale = args.ImageStyle.Scale or 1 })
            SetAnimation({ Name = args.ImageStyle.Image, DestinationId = components[scrollingListItemImageBackingKey].Id, Scale = 1 })
            Attach({ Id = components[scrollingListItemImageBackingKey].Id, DestinationId = components[scrollingListItemBackingKey].Id, OffsetX = args.ImageStyle.Offset.X or 0, OffsetY = args.ImageStyle.Offset.Y or 0})
            scrollingList.Children[scrollingListItemImageBackingKey] = components[scrollingListItemImageBackingKey]
        end
        if v.IsEnabled ~= false then
            components[scrollingListItemBackingKey].OnPressedFunctionName = "ZyruIncremental.ScrollingList.ButtonPressed"
        else
            SetColor({ Id = components[scrollingListItemBackingKey].Id , Color = args.DeEnabledColor or {1,1,1,0.33} })
        end
        scrollingList.Children[scrollingListItemBackingKey] = components[scrollingListItemBackingKey]
        local createUpArrow = function()
            local scrollingListItemArrowKey = args.Name .. "ScrollingListArrowUp" .. k
            components[scrollingListItemArrowKey] = CreateScreenComponent({ Name = "ButtonCodexUp", X = (args.X or 0) + (args.ArrowStyle.Offset.X or 0), Y = (args.Y or 0) + ySpaceAmount + (args.ArrowStyle.Offset.Y or 0), Scale = args.ArrowStyle.Scale, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = args.Group .. "Arrows" })
            components[scrollingListItemArrowKey].OnPressedFunctionName = "ZyruIncremental.ScrollingList.PreviousPage"
            components[scrollingListItemArrowKey].args = args
            components[scrollingListItemArrowKey].Parent = scrollingList
            
            scrollingList.Children[components[scrollingListItemArrowKey].Id] = components[scrollingListItemArrowKey]
            
        end
        local createDownArrow = function()
            local scrollingListItemArrowKey = args.Name .. "ScrollingListArrowDown" .. k
            components[scrollingListItemArrowKey] = CreateScreenComponent({ Name = "ButtonCodexDown", X = (args.X or 0) + (args.ArrowStyle.Offset.X or 0), Y = (args.Y or 0) + ySpaceAmount + (args.ArrowStyle.Offset.Y or 0), Scale = args.ArrowStyle.Scale, Sound = "/SFX/Menu Sounds/GeneralWhooshMENU", Group = args.Group .. "Arrows" })
            scrollingList.Children[components[scrollingListItemArrowKey].Id] = components[scrollingListItemArrowKey]
            components[scrollingListItemArrowKey].OnPressedFunctionName = "ZyruIncremental.ScrollingList.NextPage"
            components[scrollingListItemArrowKey].args = args
            components[scrollingListItemArrowKey].Parent = scrollingList
            
            scrollingList.Children[components[scrollingListItemArrowKey].Id] = components[scrollingListItemArrowKey]
        end
        if args.ArrowStyle.CreationPositions.Style == "First" then
            if k == 1 and args.ArrowStyle ~= nil then
                createUpArrow()
            elseif k == 2 and args.ArrowStyle ~= nil then
                createDownArrow()    
            end
        elseif args.ArrowStyle.CreationPositions.Style == "TB" or args.ArrowStyle.CreationPositions.Style == "Top-Bottom" then
            if k == 1 and args.ArrowStyle ~= nil then
                createUpArrow()            
            elseif k == #currentPageItems and args.ArrowStyle ~= nil then
                createDownArrow()
            end
        elseif args.ArrowStyle.CreationPositions.Style == "Custom" then
            if args.ArrowStyle ~= nil and k == args.ArrowStyle.CreationPositions.Positions[1] then
                createUpArrow()
            elseif args.ArrowStyle ~= nil and k == args.ArrowStyle.CreationPositions.Positions[2] then
                createDownArrow()
            end
        end
    end
end
function ZyruIncremental.ScrollingList.PreviousPage(screen, button)
    local parent = button.Parent
    local args = button.args
    if parent.CurrentPage - 1 >= 0 then
        parent.CurrentPage = parent.CurrentPage - 1
        ZyruIncremental.ScrollingList.Update(parent)
    end
    
end
function ZyruIncremental.ScrollingList.NextPage(screen, button)
    local parent = button.Parent
    local args = button.args
    if #args.Items > (parent.CurrentPage + 1) * args.ItemsPerPage then
        parent.CurrentPage = parent.CurrentPage + 1
        ZyruIncremental.ScrollingList.Update(parent)
    end
    
end

function ZyruIncremental.ScrollingList.ButtonPressed(screen, button)
  local args = button.scrollingListPressedArgs.Args
  local components = screen.Components
  local itemToSwapTo = args.Items[button.scrollingListPressedArgs.Index]
  local parentButton = button.scrollingListPressedArgs.parent

  if itemToSwapTo.event ~= nil then
      itemToSwapTo.event(parentButton, itemToSwapTo)
  elseif args.GeneralEvent ~= nil then
      args.GeneralEvent(parentButton, itemToSwapTo)
  end
end
function ZyruIncremental.ScrollingList.GetEntries(scrollingList)
  local returnItems = {}
  for k,v in pairs(scrollingList.scrollingListPressedArgs.Items)do
      if v.IsEnabled == true or v.IsEnabled == nil then
          table.insert(returnItems, v)
      end
  end
  return returnItems
end
function ZyruIncremental.ScrollingList.NewEntry(scrollingList, value)
  table.insert(scrollingList.scrollingListPressedArgs.Items, value)
  local screen = scrollingList.screen
  ZyruIncremental.ScrollingList.Update(scrollingList)
end
function ZyruIncremental.ScrollingList.DelEntry(scrollingList, value)
  local itemToRemove = nil
  local itemToRemoveIndex = nil
  local items = scrollingList.scrollingListPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToRemove = items[value]
          itemToRemoveIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToRemove = v
              itemToRemoveIndex = k
              break
          end
      end
  end
  if itemToRemove ~= nil and itemToRemove ~= scrollingList.currentItem then
      table.remove(scrollingList.scrollingListPressedArgs.Items, itemToRemoveIndex)
      local screen = scrollingList.screen
      ZyruIncremental.ScrollingList.Update(scrollingList)
  end
end
function ZyruIncremental.ScrollingList.DisableEntry(scrollingList, value)
  local itemToDisable = nil
  local itemToDisableIndex = nil
  local items = scrollingList.scrollingListPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToDisable = items[value]
          itemToDisableIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToDisable = v
              itemToDisableIndex = k
              break
          end
      end
  end
  if itemToDisable ~= nil and itemToDisable ~= scrollingList.currentItem then
      items[itemToDisableIndex].IsEnabled = false
      ZyruIncremental.ScrollingList.Update(scrollingList)
  end
end
function ZyruIncremental.ScrollingList.EnableEntry(scrollingList, value)
  local itemToDisable = nil
  local itemToDisableIndex = nil
  local items = scrollingList.scrollingListPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToDisable = items[value]
          itemToDisableIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToDisable = v
              itemToDisableIndex = k
              break
          end
      end
  end
  if itemToDisable ~= nil and itemToDisable ~= scrollingList.currentItem then
    items[itemToDisableIndex].IsEnabled = true
    ZyruIncremental.ScrollingList.Update(scrollingList)
end
end
function ZyruIncremental.ScrollingList.Destroy(scrollingList)
  local components = scrollingList.screen.components
  for _,v in pairs(scrollingList.Children) do
      if components[v.Id] ~= nil then
          Destroy({Id = v.Id})
      end
  end
  Destroy({Id = scrollingList.Id})
end

--#region Dropdowns
function ZyruIncremental.Dropdown.CreateDropdown(screen, args)
    local xPos = (args.X or 0)
  local yPos = (args.Y or 0)
  local components = screen.Components
  local Name = (args.Name or "UnnamedDropdown")
  --Create base default text and backingKey
  local dropDownTopBackingKey = Name .. "BaseBacking"
  components[dropDownTopBackingKey] = CreateScreenComponent({ Name = "MarketSlot", Group = args.Group, Scale = 1, X = xPos, Y = yPos })

  SetScaleY({ Id = components[dropDownTopBackingKey].Id , Fraction = args.Scale.Y or 1 })
  SetScaleX({ Id = components[dropDownTopBackingKey].Id , Fraction = args.Scale.X or 1 })

  components[dropDownTopBackingKey].OnPressedFunctionName = "ZyruIncrementalToggleDropdown"
  components[dropDownTopBackingKey].dropDownPressedArgs = args
  components[dropDownTopBackingKey].isExpanded = false
  components[dropDownTopBackingKey].isEnabled = true
  components[dropDownTopBackingKey].Children = {}

  components[dropDownTopBackingKey].currentItem = args.Items.Default
  components[dropDownTopBackingKey].screen = screen

  ZyruIncremental.Dropdown.UpdateBaseText(screen, components[dropDownTopBackingKey])

  if args.Items.Default.event ~= nil then
      args.Items.Default.event(components[dropDownTopBackingKey])
  end
  return components[dropDownTopBackingKey]
end

function ZyruIncrementalToggleDropdown(screen, button)
  if not button.isEnabled then
    return
  end
  button.isExpanded = not button.isExpanded
  if button.isExpanded then
      ZyruIncremental.Dropdown.Expand(screen, button)
  else
      ZyruIncremental.Dropdown.Collapse(screen, button)
  end
end
function ZyruIncremental.Dropdown.Expand(screen, button)
  local args = button.dropDownPressedArgs
  local components = screen.Components
  ModifyTextBox({Id = components[args.Name .. "BaseTextbox"].Id, Color = {1, 1, 1, 0.2}})
  for k,v in pairs(args.Items) do
      if k ~= "Default" then
          local dropDownItemBackingKey = args.Name .. "DropdownBacking" .. k
          local ySpaceAmount = 102* k * args.Scale.Y + (args.Padding.Y * k)
          components[dropDownItemBackingKey] = CreateScreenComponent({ Name = "MarketSlot", Group = args.Group .. "Dropdown", Scale = 1, X = (args.X or 0), Y = (args.Y or 0) + ySpaceAmount})
          components[dropDownItemBackingKey].dropDownPressedArgs = {Args = args, parent = button, Index = k}
          components[dropDownItemBackingKey].OnPressedFunctionName = "ZyruIncrementalDropdownButtonPressed"

          SetScaleY({ Id = components[dropDownItemBackingKey].Id , Fraction = args.Scale.Y or 1 })
          SetScaleX({ Id = components[dropDownItemBackingKey].Id , Fraction = args.Scale.X or 1 })
          local offsetX = (args.GeneralOffset or {X = 0}).X
          if v.Offset ~= nil then
              offsetX = v.Offset.X
          end
          local offsetY = (args.GeneralOffset or {Y = 0}).Y
          if v.Offset ~= nil then
              offsetY = v.Offset.Y
          end
          local textColor = Color.White
          if v.IsEnabled == false then
              textColor = {255, 255, 255, .2}
              components[dropDownItemBackingKey].OnPressedFunctionName = nil
              textColor = {1, 1, 1, 0.2}
          end
          CreateTextBox({ Id = components[dropDownItemBackingKey].Id, Text = v.Text,
              FontSize = v.FontSize or args.GeneralFontSize,
              OffsetX = offsetX, OffsetY = offsetY,
              Width = 665,
              Justification = (v.Justification or args.Justification) or "Center",
              VerticalJustification = (v.VerticalJustification or args.VerticalJustification) or "Center",
              LineSpacingBottom = 8,
              Font = (v.Font or args.Font) or "AlegreyaSansSCBold",
              Color = textColor,
              ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
              TextSymbolScale = 0.8,
      })
      button.Children[dropDownItemBackingKey] = components[dropDownItemBackingKey]
      end
  end
end
function ZyruIncrementalDropdownButtonPressed(screen, button)
  local args = button.dropDownPressedArgs.Args
  local components = screen.Components
  local itemToSwapTo = args.Items[button.dropDownPressedArgs.Index]
  local parentButton = button.dropDownPressedArgs.parent

  parentButton.isExpanded = not parentButton.isExpanded
  parentButton.currentItem = itemToSwapTo

  ZyruIncremental.Dropdown.UpdateBaseText(screen, parentButton)
  ZyruIncremental.Dropdown.Collapse(screen, parentButton)

  if itemToSwapTo.event ~= nil then
      itemToSwapTo.event(parentButton, itemToSwapTo)
  elseif args.GeneralEvent ~= nil then
      args.GeneralEvent(parentButton, itemToSwapTo)
  end
end
function ZyruIncremental.Dropdown.Collapse(screen, button)
  local components = screen.Components
  for k,v in pairs(components) do
      if string.find(k, button.dropDownPressedArgs.Name .. "DropdownBacking") then
          Destroy({Id = v.Id})
      end
  end
  ModifyTextBox({ Id = components[button.dropDownPressedArgs.Name .. "BaseTextbox"].Id, Color = {1, 1, 1, 1}})
end
function ZyruIncremental.Dropdown.UpdateBaseText(screen, dropdown)
  local args = dropdown.dropDownPressedArgs
  local components = screen.Components
  local itemToSwapTo = dropdown.currentItem

  local offsetX = (args.GeneralOffset or {X = 0}).X
  if itemToSwapTo.Offset ~= nil then
      offsetX = itemToSwapTo.Offset.X
  end
  local offsetY = (args.GeneralOffset or {Y = 0}).Y
  if itemToSwapTo.Offset ~= nil then
      offsetY = itemToSwapTo.Offset.Y
  end

  local textboxContainerName = args.Name .. "BaseTextbox"
  local textboxContainer = components[textboxContainerName]
  if textboxContainer == nil then
    textboxContainer = CreateScreenComponent({ Name = "BlankObstacle", Group = args.Group, Scale = 1, X = args.X or 0, Y = args.Y or 0})
    SetScaleY({ Id = textboxContainer.Id , Fraction = args.Scale.Y or 1 })
    SetScaleX({ Id = textboxContainer.Id , Fraction = args.Scale.X or 1 })
    CreateTextBox({ Id = textboxContainer.Id, Text = itemToSwapTo.Text,
        FontSize = itemToSwapTo.FontSize or args.GeneralFontSize,
        OffsetX = offsetX, OffsetY = offsetY,
        Width = 665,
        Justification = (itemToSwapTo.Justification or args.Justification) or "Center",
        VerticalJustification = (itemToSwapTo.VerticalJustification or args.VerticalJustification) or "Center",
        LineSpacingBottom = 8,
        Font = (itemToSwapTo.Font or args.Font) or "AlegreyaSansSCBold",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
        TextSymbolScale = 0.8,
    })
  else
    ModifyTextBox({ Id = textboxContainer.Id, Text = itemToSwapTo.Text, Color = {1, 1, 1, 1}})
  end
  components[textboxContainerName] = textboxContainer
end
function ZyruIncremental.Dropdown.GetValue(dropdown)
  return dropdown.currentItem
end
function ZyruIncremental.Dropdown.SetValue(dropdown, value)
  local itemToSet = nil
  local items = dropdown.dropDownPressedArgs.Items
  if type(value) == "number" then
      if value ~= -1 then
          itemToSet = items[value]
      else
          itemToSet = items.Default
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToSet = v
              break
          end
      end
  end
  if itemToSet ~= nil then
      dropdown.currentItem = itemToSet
      ZyruIncremental.Dropdown.UpdateBaseText(dropdown.screen, dropdown)
  end
end
function ZyruIncremental.Dropdown.GetEntries(dropdown)
  local returnItems = {}
  for k,v in pairs(dropdown.dropDownPressedArgs.Items)do
      if v.IsEnabled == true or v.IsEnabled == nil then
          table.insert(returnItems, v)
      end
  end
  return returnItems
end
function ZyruIncremental.Dropdown.NewEntry(dropdown, value)
  table.insert(dropdown.dropDownPressedArgs.Items, value)
  local screen = dropdown.screen
  if dropdown.isExpanded then
      ZyruIncremental.Dropdown.Collapse(screen, dropdown)
      ZyruIncremental.Dropdown.Expand(screen, dropdown)
  end
end
function ZyruIncremental.Dropdown.DelEntry(dropdown, value)
  local itemToRemove = nil
  local itemToRemoveIndex = nil
  local items = dropdown.dropDownPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToRemove = items[value]
          itemToRemoveIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToRemove = v
              itemToRemoveIndex = k
              break
          end
      end
  end
  if itemToRemove ~= nil and itemToRemove ~= dropdown.currentItem then
      table.remove(dropdown.dropDownPressedArgs.Items, itemToRemoveIndex)
      local screen = dropdown.screen
      if dropdown.isExpanded then
          ZyruIncremental.Dropdown.Collapse(screen, dropdown)
          ZyruIncremental.Dropdown.Expand(screen, dropdown)
      end
  end
end
function ZyruIncremental.Dropdown.DisableEntry(dropdown, value)
  local itemToDisable = nil
  local itemToDisableIndex = nil
  local items = dropdown.dropDownPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToDisable = items[value]
          itemToDisableIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToDisable = v
              itemToDisableIndex = k
              break
          end
      end
  end
  if itemToDisable ~= nil and itemToDisable ~= dropdown.currentItem then
      items[itemToDisableIndex].IsEnabled = false
      local screen = dropdown.screen
      if dropdown.isExpanded then
          ZyruIncremental.Dropdown.Collapse(screen, dropdown)
          ZyruIncremental.Dropdown.Expand(screen, dropdown)
      end
  end
end
function ZyruIncremental.Dropdown.EnableEntry(dropdown, value)
  local itemToDisable = nil
  local itemToDisableIndex = nil
  local items = dropdown.dropDownPressedArgs.Items
  if type(value) == "number" then
      if value > 0 then
          itemToDisable = items[value]
          itemToDisableIndex = value
      end
  elseif type(value) == "string" then
      for k,v in pairs(items) do
          if v.Text == value then
              itemToDisable = v
              itemToDisableIndex = k
              break
          end
      end
  end
  if itemToDisable ~= nil and itemToDisable ~= dropdown.currentItem then
      items[itemToDisableIndex].IsEnabled = true
      local screen = dropdown.screen
      if dropdown.isExpanded then
          ZyruIncremental.Dropdown.Collapse(screen, dropdown)
          ZyruIncremental.Dropdown.Expand(screen, dropdown)
      end
  end
end
function ZyruIncremental.Dropdown.EnableDropdown(dropdown)
  dropdown.isEnabled = false
  ModifyTextBox({ Id = dropdown.Id, Color = {1, 1, 1, 1}})
end
function ZyruIncremental.Dropdown.DisableDropdown(dropdown)
  dropdown.isEnabled = true
  ModifyTextBox({ Id = dropdown.Id, Color = {1, 1, 1, 0.2}})
end
function ZyruIncremental.Dropdown.Destroy(dropdown)
  local components = dropdown.screen.components
  for _,v in pairs(dropdown.Children) do
      if components[v.Id] ~= nil then
          Destroy({Id = v.Id})
      end
  end
  Destroy({Id = dropdown.Id})
end
--#endregion