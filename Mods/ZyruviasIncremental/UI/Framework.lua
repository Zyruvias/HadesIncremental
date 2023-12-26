Z.BaseComponents = {

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
            }
        },
        MenuLeft = {
            Name = "ButtonCodexDown",
            OffsetX = -1 * ScreenWidth / 2 + 50,
            ComponentArgs = {
                OnPressedFunctionName = "ScreenPageLeft",
            },
            Angle = -90
        },
        MenuRight = {
            Name = "ButtonCodexDown",
            OffsetX = ScreenWidth / 2 - 50,
            ComponentArgs = {
                OnPressedFunctionName = "ScreenPageRight",
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

function GetScreenIdsToDestroy(screen) 
    local idsToKeep = screen.PermanentComponents or {}
    -- DebugPrint { Text = ModUtil.ToString.Deep(idsToKeep)}
    local allIds = GetAllIds(screen.Components)
    local idsToDestroy = {}
    for _, id in ipairs(allIds) do
        if not Contains(idsToKeep, id) then
            table.insert(idsToDestroy, id)
        end
    end
    
    return idsToDestroy
end

function GoToPageFromSource(screen, button)
    if button.PageIndex == nil then
        DebugPrint { Text = "You need to set PageIndex on the button, you doofus."}
    end
    RenderScreenPage(screen, button, button.PageIndex)
end

-- Handles non-linear paging
function RenderScreenPage(screen, button, index)
    -- Get Non-permanent components and DESTROY them
    Destroy({Ids = GetScreenIdsToDestroy(screen, button)})

    -- then render it
    Z.RenderComponents(screen, screen.Pages[index], { Source = button })

end

function ScreenPageRight(screen, button)
    if screen.PageIndex == screen.PageCount then
        return
    end
    -- increment page
    screen.PageIndex = screen.PageIndex + 1
    RenderScreenPage(screen, button, screen.PageIndex)

end

function ScreenPageLeft(screen, button)
    if screen.PageIndex == 1 then
        return
    end
    screen.PageIndex = screen.PageIndex - 1
    RenderScreenPage(screen, button, screen.PageIndex)
end

-- Generates a component definition from either an existing screen component or the base definition
function GetComponentDefinition(screen, component)
    -- TODO: do I need to require a type and subtype all the time?
    local baseDefinition = DeepCopyTable(Z.BaseComponents[component.Type][component.SubType])
    if baseDefinition == nil then
        DebugPrint { Text = "bad baseDefinition generated for " .. tostring((component.Args or {}).FieldName)}
    end
    local fieldName = ModUtil.Path.Get("Args.FieldName", component)
    if fieldName ~= nil and ModUtil.Path.Get(fieldName, screen) ~= nil then
        DebugPrint { Text = "Reusing component definition for " .. fieldName }
        baseDefinition = screen[fieldName].Args
    end

    local componentDefinition = ModUtil.Table.Merge(
        baseDefinition,
        DeepCopyTable(component.Args or {})
    )
    return componentDefinition
end

function Z.CreateOrUpdateComponent(screen, component)
    local componentDefinition = GetComponentDefinition(screen, component)
    if screen[componentDefinition.FieldName] ~= nil then
        Z.UpdateComponent(screen, component)
    else
        Z.RenderComponent(screen, component)
    end
end

-- Create Menu
function Z.CreateMenu(name, args)
    -- Screen / Hades Framework Setup
    -- DebugPrint { Text = ModUtil.ToString.Deep(args)}
    args = args or {}
    local screen = { Components = {}, Name = name }
    ScreenAnchors[name] = screen

    local components = screen.Components

    if IsScreenOpen( screen.Name ) then
		return
	end
    OnScreenOpened({ Flag = screen.Name, PersistCombatUI = false })
    HideCombatUI(name)
    FreezePlayerUnit()
    EnableShopGamepadCursor()

    -- Initialize Background + Sounds
	PlaySound({ Name = args.OpenSound or "/SFX/Menu Sounds/DialoguePanelIn" })
    local background = args.Background or Z.BaseComponents.Background
    -- Generalize rendering components on the screen.
    Z.RenderBackground(screen, background)
    Z.RenderComponents(screen, args.Components)
    if args.Pages ~= nil then
        screen.Pages = args.Pages
        screen.PageIndex = args.InitialPageIndex or 1
        screen.PageCount = TableLength(args.Pages)
        -- Page Left button
        if (args.PaginationStyle or "Linear") == "Linear" then
            Z.RenderButton(screen, {
                Type = "Button",
                SubType = "MenuLeft",
                Args = { FieldName = "MenuLeft" }
            })
            -- Page Right button
            Z.RenderButton(screen, {
                Type = "Button", 
                SubType = "MenuRight",
                Args = { FieldName = "MenuRight" }
            })
        end
        -- assigns the "core" components to a placeholder ID set to not delete later
        screen.PermanentComponents = GetAllIds(screen.Components)

        -- Render first Page
        Z.RenderComponents(screen, args.Pages[screen.PageIndex])
    end


	HandleScreenInput( screen )
    return screen
end

function Z.RenderComponents(screen, componentsToRender, args)    
    -- Handle rendering overrides
    if type(componentsToRender) == "string" then
        if type(_G[componentsToRender]) == "function" then
            return _G[componentsToRender](screen, args.Source) -- TODO: do secondary args make sense here?
        end
    elseif type(componentsToRender) == "function" then
        return componentsToRender(screen, args.Source)
    end

    if componentsToRender == nil then
        DebugPrint { Text = "componentsToRender was nil, not rendering anything"}
    end

    -- default framework rendering
    for _, component in pairs(componentsToRender) do
        Z.RenderComponent(screen, component)
    end
end

function Z.RenderComponent(screen, component)
    if not component or component.Type == nil then
        DebugPrint { Text = "No component or no component Type property provided"}
        return
    end 
    if type(Z["Render" .. tostring(component.Type)]) == "function" then
        Z["Render" .. tostring(component.Type)](screen, component)

        -- establish definition on screen object for later access
        local fieldName = ModUtil.Path.Get("Args.FieldName", component)
        if fieldName ~= nil and ModUtil.Path.Get(fieldName, screen.Components) ~= nil then
            DebugPrint { Text = "Setting component definition for " .. fieldName }
            screen.Components[fieldName].Args = GetComponentDefinition(screen, component)
        end
    end
end

function Z.UpdateComponent(screen, component, args)
    if not component or component.Type == nil then
        DebugPrint { Text = "No component or no component Type property provided"}
        return
    end 
    if type(Z["Update" .. tostring(component.Type)]) == "function" then
        Z["Update" .. tostring(component.Type)](screen, component, args)

        -- reestablish definition on screen object for later access
        local fieldName = ModUtil.Path.Get("Args.FieldName", component)
        DebugPrint { Text = "Updating component definition for " .. fieldName }
        screen.Components[fieldName].Args = GetComponentDefinition(screen, component)
    end
end

function Z.RenderIcon(screen, component)
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
    Z.UpdateComponent(screen, component)
end

function Z.UpdateIcon(screen, component)
    local iconDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components
    if iconDefinition.Animation ~= nil then
        SetAnimation({ DestinationId = components[iconDefinition.FieldName].Id, Name = iconDefinition.Animation })
    end
    if iconDefinition.Scale ~= nil then
        SetScale({ Id = components[iconDefinition.FieldName].Id, Fraction = iconDefinition.Scale })
    end

    
    
end

-- Create Progress Bar
function Z.RenderProgressBar(screen, component)
    local barDefinition = GetComponentDefinition(screen, component)
    barDefinition.ScaleY = Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y * barDefinition.ScaleY
    barDefinition.ScaleX = Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * barDefinition.ScaleX
    local components = screen.Components
    local barName = barDefinition.FieldName or ""

    local barBackgroundDefinition = {
        Name = barDefinition.Name,
        X = barDefinition.X +  barDefinition.ScaleX * Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * Z.Constants.Components.RECTANGLE_01_WIDTH / 2,
        Y = barDefinition.Y,
    }

    components[barName .. "BarBackground"] = CreateScreenComponent(barBackgroundDefinition)
    if barDefinition.Label ~= nil then
        barDefinition.Label.Parent = barName
        Z.RenderText(screen, barDefinition.Label)
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

    -- -- DebugPrint { Text = ModUtil.ToString.Deep(components)}
    
    -- TODO: left text / right text
    local barText = {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = barName .. "BarText",
            Text = barDefinition.BarText or "",
            Parent = barName .. "BarBackground",
            
            X = barDefinition.X +  barDefinition.ScaleX * Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * Z.Constants.Components.RECTANGLE_01_WIDTH / 2,
            Y = barDefinition.Y,
            Justification = "Center"
        }
    }
    Z.RenderText(screen, barText)
    local leftText = {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = barName .. "LeftText",
            Text = barDefinition.LeftText or "",
            Parent = barName .. "BarBackground",
            X = barDefinition.X - 25,
            Y = barDefinition.Y,
            Justification = "Right"
        }
    }
    Z.RenderText(screen, leftText)
    local rightText = {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = barName .. "RightText",
            Text = barDefinition.RightText or "",
            Parent = barName .. "BarBackground",
            X = barDefinition.X +  barDefinition.ScaleX * Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * Z.Constants.Components.RECTANGLE_01_WIDTH + 25,
            Y = barDefinition.Y,
            Justification = "Left"
        }
    }
    Z.RenderText(screen, rightText)
end

function Z.UpdateProgressBar(screen, component, args)
    args = args or {}
    local barDefinition = GetComponentDefinition(screen, component)
    barDefinition.ScaleY = Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_Y * barDefinition.ScaleY
    barDefinition.ScaleX = Z.Constants.Components.PROGRESS_BAR_SCALE_PROPORTION_X * barDefinition.ScaleX
    local barName = barDefinition.FieldName or ""
    local components = screen.Components

    local oldProportion = components[barName .. "BarForeground"].Proportion
    local proportionDelta = barDefinition.Proportion - oldProportion
    Move({
        Id = components[barName .. "BarForeground"].Id,
        OffsetX = barDefinition.X + barDefinition.ScaleX * proportionDelta / 2 * Z.Constants.Components.RECTANGLE_01_WIDTH,
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
        Args = {
            FieldName = barName .. "BarText",
            Text = barDefinition.BarText or "",
            Parent = barName .. "BarBackground",
        }
    }
    Z.UpdateComponent(screen, barText)
    local leftText = {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = barName .. "LeftText",
            Text = barDefinition.LeftText or "",
            Parent = barName .. "BarBackground"
        }
    }
    Z.UpdateComponent(screen, leftText)
    local rightText = {
        Type = "Text",
        SubType = "Note",
        Args = {
            FieldName = barName .. "RightText",
            Text = barDefinition.RightText or "",
            Parent = barName .. "BarBackground"
        }
    }
    Z.UpdateComponent(screen, rightText)
    
end

function Z.RenderDropdown(screen, component)
    local dropdownDefinition = GetComponentDefinition(screen, component)
    dropdownDefinition.Name = dropdownDefinition.FieldName
    
    ErumiUILib.Dropdown.CreateDropdown(screen, dropdownDefinition)
end

function Z.RenderButton(screen, component)
    local buttonDefinition = GetComponentDefinition(screen, component)

    local components = screen.Components
    local buttonName = buttonDefinition.FieldName or buttonDefinition.Name
    local buttonComponentName = buttonDefinition.Name or "BaseInteractableButton"
    components[buttonName] = CreateScreenComponent({ Name = buttonComponentName, Scale = buttonDefinition.Scale or 1.0 })
    DebugPrint { Text = ModUtil.ToString.Deep(buttonDefinition)}

    if buttonDefinition.Animation ~= nil then
        SetAnimation({ DestinationId = components[buttonName].Id, Name = buttonDefinition.Animation })
    end


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
    -- HardCoded, not sure how to get around this
    if buttonDefinition.OnPressedFunctionName == nil and component.SubType == "Close" then
        local name = screen.Name
        components[buttonName].OnPressedFunctionName = "Close" .. name .. "Screen"
        if _G["Close" .. name .. "Screen"] == nil then
    
            _G["Close" .. name .. "Screen"] = function()
                CloseScreenByName ( name )
                if buttonDefinition.CloseScreenFunction then
                    buttonDefinition.CloseScreenFunction(buttonDefinition.CloseScreenFunctionArgs)
                elseif buttonDefinition.CloseScreenFunctionName ~= nil then
                    _G[buttonDefinition.CloseScreenFunctionName](buttonDefinition.CloseScreenFunctionArgs)
                end
            end
        end
    end

    -- LABELLED BUTTONS
    if buttonDefinition.Label then
        if type(buttonDefinition.Label) == "table" then
            buttonDefinition.Label.Parent = buttonName
            Z.RenderText(screen, buttonDefinition.Label)
        else
            local buttonLabel = {
                Type = "Text",
                SubType = "Note",
                Args = {
                    FieldName = buttonName.."Label",
                    Text = buttonDefinition.Label or "",
                    OffsetX = buttonDefinition.OffsetX,
                    OffsetY = buttonDefinition.OffsetY,
                    Justification = "Center",
                },
                Parent = buttonName
            }
            Z.RenderText(screen, buttonLabel)
        end
    end

    return components[buttonName]
end

-- Create Text Box
function Z.RenderText(screen, component)
    local textDefinition = GetComponentDefinition(screen, component)
    -- Create Text
    textDefinition.Name = "BlankObstacle"
    local parentName = component.Parent or "Background"
    textDefinition.DestinationId = screen.Components[parentName].Id

    screen.Components[textDefinition.FieldName] = CreateScreenComponent(textDefinition)
    textDefinition.Id = screen.Components[textDefinition.FieldName].Id
    return CreateTextBox(textDefinition)

end

function Z.UpdateText(screen, component)
    -- TODO: evaluate if this can even be simplified
    local textDefinition = GetComponentDefinition(screen, component)
    local components = screen.Components
    ModifyTextBox({
        Id = components[textDefinition.FieldName].Id, Text = textDefinition.Text
    })

end

function Z.RenderBackground(screen, component)
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

function Z.RenderList(screen, component)
    local listDefinition = GetComponentDefinition(screen, component)

    local scrollingList = ErumiUILib.ScrollingList.CreateScrollingList(
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