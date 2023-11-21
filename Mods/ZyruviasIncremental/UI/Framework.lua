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
        }
    },
    ProgressBar = {
        Standard = {
            Name = "rectangle01",
            Proportion = 0,
            BackgroundColor = {96, 96, 96, 255},
            ForegroundColor = Color.White,
            ScaleY = 0.05,
            ScaleX = 0.5,
            X = ScreenCenterX,
            Y = ScreenCenterY,
            Justification = "Left",
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
    }

}

function GetScreenIdsToDestroy(screen, button) 
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

function ScreenPageRight(screen, button)
    if screen.PageIndex == screen.PageCount then
        return
    end

    -- Get Non-permanent components and DESTROY them
    Destroy({Ids = GetScreenIdsToDestroy(screen, button)})

    -- increment page
    screen.PageIndex = screen.PageIndex + 1
    -- then render it
    Z.RenderComponents(screen, screen.Pages[screen.PageIndex])


end

function ScreenPageLeft(screen, button)
    if screen.PageIndex == 1 then
        return
    end

    -- Get Non-permanent components
    local idsToDestroy = GetScreenIdsToDestroy(screen, button)
    -- and DESTROY them
    Destroy({Ids = idsToDestroy})

    -- increment page
    screen.PageIndex = screen.PageIndex - 1
    -- then render it
    Z.RenderComponents(screen, screen.Pages[screen.PageIndex])
end

-- Create Menu
function Z.CreateMenu(name, args)
    -- Screen / Hades Framework Setup
    -- DebugPrint { Text = ModUtil.ToString.Deep(args)}
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

    -- Initialize Background + Sounds
	PlaySound({ Name = args.OpenSound or "/SFX/Menu Sounds/DialoguePanelIn" })
    local background = args.Background or Z.BaseComponents.Background
    -- Generalize rendering components on the screen.
    Z.RenderBackground(screen, background)
    Z.RenderComponents(screen, args.Components)
    if args.Pages ~= nil then
        screen.Pages = args.Pages
        screen.PageIndex = 1
        screen.PageCount = TableLength(args.Pages)
        -- Page Left button
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
        -- assigns the "core" components to a placeholder ID set to not delete later
        screen.PermanentComponents = GetAllIds(screen.Components)

        -- Render first Page
        Z.RenderComponents(screen, args.Pages[1])
    end


	HandleScreenInput( screen )
    return screen
end

function Z.RenderComponents(screen, componentsToRender)
    -- -- DebugPrint { Text = "Rendering components... " .. ModUtil.ToString.Deep(componentsToRender)}
    for _, component in pairs(componentsToRender) do
        Z.RenderComponent(screen, component)
    end
end

function Z.RenderComponent(screen, component)
    if component.Type == "Text" then
        Z.RenderText(screen, component)
    elseif component.Type == "Button" then
        Z.RenderButton(screen, component)
    elseif component.Type == "Dropdown" then
        Z.RenderDropdown(screen, component)
    elseif component.Type == "ProgressBar" then
        Z.RenderProgressBar(screen, component)
    end
end

function Z.RenderProgressBar(screen, component)
    local RECTANGLE_01_HEIGHT = 270
    local RECTANGLE_01_WIDTH = 480

    local barDefinition = ModUtil.Table.Merge(
        DeepCopyTable(Z.BaseComponents.ProgressBar[component.SubType]),
        DeepCopyTable(component.Args)
    )
    local components = screen.Components
    local barName = barDefinition.FieldName or ""

    local barBackgroundDefinition = {
        Name = barDefinition.Name,
        X = barDefinition.X + RECTANGLE_01_WIDTH / 2,
        Y = barDefinition.Y,
    }

    -- components[barName .. "BarBackground"] = CreateScreenComponent({
    --     Name = "rectangle01",
    --     X = offset.X + 230 + RECTANGLE_01_WIDTH / 2,
    --     Y = offset.Y + 260,
    --     Color = {32, 32, 32, 255}
    --  })
    components[barName .. "BarBackground"] = CreateScreenComponent(barBackgroundDefinition)
    if barDefinition.Label ~= nil then
        barDefinition.Label.Parent = barName
        Z.RenderText(screen, barDefinition.Label)
    end
    SetColor{ Id = components[barName .. "BarBackground"].Id, Color = barDefinition.BackgroundColor}
    SetScaleY{ Id = components[barName .. "BarBackground"].Id, Fraction = barDefinition.ScaleY }

    components[barName .. "BarForeground"] = CreateScreenComponent({
        Name = "rectangle01",
        -- add offset based on proportion
        X = barDefinition.X,
        Y = barDefinition.Y,
    })
    components[barName .. "BarForeground"].Proportion = barDefinition.Proportion
    SetColor{ Id = components[barName .. "BarForeground"].Id, Color = barDefinition.ForegroundColor}
    SetScaleX{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.Proportion }
    SetScaleY{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.ScaleY }

    -- -- DebugPrint { Text = ModUtil.ToString.Deep(components)}
    
    -- TODO: left text / right text 
    -- -- currentLevel nextLevel text
    -- traitInfo.CurrentLevel = CreateScreenComponent({
    --     Id = component.Id,
    --     Name = "BlankObstacle",
    --     Group = group,
    --     X = offset.X + 20,
    --     Y = offset.Y + 170
    -- })
	-- CreateTextBox({
	-- 	Id = traitInfo.CurrentLevel.Id,
	-- 	FontSize = 14,
	-- 	OffsetX = 170,
	-- 	OffsetY = 90,
	-- 	Color = color,
    --     Group = group,
	-- 	Font = "AlegreyaSansSCLight",
    --     Text = "Lv. " .. boonData.Level,
	-- 	ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
	-- 	Justification = "Left",
	-- })

    -- traitInfo.NextLevel = CreateScreenComponent({
    --     Id = component.Id,
    --     Name = "BlankObstacle",
    --     Group = group,
    --     X = offset.X + 20,
    --     Y = offset.Y + 170
    -- })
	-- CreateTextBox({
	-- 	Id = traitInfo.NextLevel.Id,
	-- 	FontSize = 14,
	-- 	OffsetX = 170 + RECTANGLE_01_WIDTH + 50,
	-- 	OffsetY = 90,
	-- 	Color = color,
    --     Group = group,
	-- 	Font = "AlegreyaSansSCLight",
    --     Text = "Lv. " .. (boonData.Level + 1),
	-- 	ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
	-- 	Justification = "Left",
	-- })
end

function Z.UpdateProgressBar(screen, component, args)
    args = args or {}
    local RECTANGLE_01_HEIGHT = 270
    local RECTANGLE_01_WIDTH = 480
    local barDefinition = ModUtil.Table.Merge(
        DeepCopyTable(Z.BaseComponents.ProgressBar[component.SubType]),
        DeepCopyTable(component.Args)
    )
    local barName = barDefinition.FieldName
    local components = screen.Components

    local oldProportion = components[barName .. "BarForeground"].Proportion
    local proportionDelta = barDefinition.Proportion - oldProportion

    Move({
        Id = components[barName .. "BarForeground"].Id,
        OffsetX = barDefinition.X + proportionDelta / 2 * RECTANGLE_01_WIDTH,
        OffsetY = barDefinition.Y,
        Duration = barDefinition.UpdateDuration
    })
    SetScaleX{ Id = components[barName .. "BarForeground"].Id, Fraction = barDefinition.Proportion, Duration = barDefinition.UpdateDuration }
    if args.WaitForUpdate then
        DebugPrint { Text = "Updating from " .. tostring(oldProportion) .. " to " .. tostring(barDefinition.Proportion) .. " over " .. tostring(barDefinition.UpdateDuration)}
        wait(barDefinition.UpdateDuration or 0)
    end
    -- components[barName .. "BarForeground"].Proportion = barDefinition.Proportion
    
end

function Z.RenderDropdown(screen, component)
    local dropdownDefinition = ModUtil.Table.Merge(
        DeepCopyTable(Z.BaseComponents.Dropdown[component.SubType]),
        DeepCopyTable(component.Args)
    )
    dropdownDefinition.Name = dropdownDefinition.FieldName
    
    ErumiUILib.Dropdown.CreateDropdown(screen, dropdownDefinition)
end

function Z.RenderButton(screen, component)
    -- Get Subtype Defaults abnd Merge
    local defaults = DeepCopyTable(Z.BaseComponents.Button[component.SubType])
    local buttonDefinition = ModUtil.Table.Merge(defaults, component.Args or {})
    -- DebugPrint { Text = "buttonComponentArgs: " .. ModUtil.ToString.Deep(buttonDefinition)}

    local components = screen.Components
    local buttonName = buttonDefinition.FieldName or buttonDefinition.Name
    local buttonComponentName = buttonDefinition.Name or "BaseInteractableButton"
    components[buttonName] = CreateScreenComponent({ Name = buttonComponentName, Scale = buttonDefinition.Scale or 1.0 }) 

    -- TODO: attachment args? idk
    -- DebugPrint { Text = ModUtil.ToString.Deep(screen)}
	Attach({
        Id = components[buttonName].Id,
        DestinationId = screen.Components.Background.Id,
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
            -- DebugPrint { Text = "Button.Label definition not properly defined!"}
        end
    end

    return components[buttonName]
end

-- Create Text Box
function Z.RenderText(screen, component)
    -- Get Subtype Defaults abnd Merge
    local textDefinition = ModUtil.Table.Merge(
        DeepCopyTable(Z.BaseComponents.Text[component.SubType]),
        DeepCopyTable(component.Args)
    )
    -- Create Text
    textDefinition.Name = "BlankObstacle"
    local parentName = component.Parent or "Background"
    textDefinition.DestinationId = screen.Components[parentName].Id
    
    screen.Components[textDefinition.FieldName] = CreateScreenComponent(textDefinition)

    -- -- DebugPrint { Text = ModUtil.ToString.Deep(textDefinition)}
    -- -- DebugPrint { Text = parentName .. ": " .. ModUtil.ToString.Deep(screen.Components[parentName])}
    local finalTextDefinition = ModUtil.Table.Merge(textDefinition, {
        Id = screen.Components[textDefinition.FieldName].Id,
    })
    return CreateTextBox(finalTextDefinition)

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

-- Create Progress Bar
function Z.CreateProgressBar(screen, args)
    
end