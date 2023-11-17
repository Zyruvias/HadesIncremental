Z.BaseComponents = {

    Text = {
        Title = {
            Font = "SpectralSCLightTitling",
            FontSize = "36",
            Color = Color.White,
            Justification = "Center",
        },
        Subtitle = {
            Font = "AlegreyaSansSCLight",
            FontSize = "22",
            Color = Color.White,
            Justification = "Center",
        },
        Paragraph = {
            FontSize = 18,
            Color = {159, 159, 159, 255},
            Font = "AlegreyaSansSCRegular",
            Justification = "Left",
        },
        Note = {
            FontSize = 12,
            Color = {159, 159, 159, 255},
            Font = "AlegreyaSansSCRegular",
            Justification = "Left",
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
        Basic = {

        }
    },
    ProgressBar = {
        
    }

}
-- Create Menu
function Z.CreateMenu(name, args)
    -- Screen / Hades Framework Setup
    DebugPrint { Text = ModUtil.ToString.Deep(args)}
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
	PlaySound({ Name = "/SFX/Menu Sounds/DialoguePanelIn" })

    components.Background = CreateScreenComponent({ Name = "rectangle01", X = ScreenCenterX, Y = ScreenCenterY })
	SetScale({ Id = components.Background.Id, Fraction = 10 })
	SetColor({ Id = components.Background.Id, Color = Color.Black })
	SetAlpha({ Id = components.Background.Id, Fraction = 0 })
	SetAlpha({ Id = components.Background.Id, Fraction = 0.85, Duration = 0.5 })

    -- Close Button

    -- Generalize rendering components on the screen.
    -- TODO: Figure out paging
    Z.RenderComponents(screen, args.Components)


	HandleScreenInput( screen )
    return screen
end

function Z.RenderComponents(screen, componentsToRender)
    DebugPrint { Text = "Rendering components... " .. ModUtil.ToString.Deep(componentsToRender)}
    for _, component in pairs(componentsToRender) do
        Z.RenderComponent(screen, component)
    end
end

function Z.RenderComponent(screen, component)
    if component.Type == "Text" then
        Z.RenderText(screen, component)
    elseif component.Type == "Button" then
        Z.RenderButton(screen, component)
    end
end

function Z.RenderButton(screen, component)
    -- Get Subtype Defaults abnd Merge
    local defaults = DeepCopyTable(Z.BaseComponents.Button[component.SubType])
    local buttonArgs = ModUtil.Table.Merge(defaults, component.Args)

    local components = screen.Components
    components[component.Args.Name or component.Name] = CreateScreenComponent(buttonArgs)

    local componentArgs = ModUtil.Table.Merge(
        {
            Id = components[component.Args.Name].Id,
            DestinationId = components.Background.Id
        },
        component.Args
    )

	Attach(componentArgs)
    if component.Args.ComponentArgs then
        ModUtil.Table.Merge(components[components.Args.Name], components.Args.ComponentArgs)
    end

    -- HardCoded, not sure how to get around this
    if component.Args.OnPressedFunctionName == nil and component.SubType == "Close" then
        local name = screen.Name
        components[component.Args.Name or component.Name].OnPressedFunctionName = "Close" .. name .. "Screen"
        if _G["Close" .. name .. "Screen"] == nil then
    
            _G["Close" .. name .. "Screen"] = function()
                CloseScreenByName ( name )
                if component.Args.CloseScreenFunction then
                    component.Args.CloseScreenFunction(component.Args.CloseScreenFunctionArgs)
                elseif component.Args.CloseScreenFunctionName ~= nil then
                    _G[component.Args.CloseScreenFunctionName](component.Args.CloseScreenFunctionArgs)
                end
            end
        end
    end
end

-- Create Text Box
function Z.RenderText(screen, component)
    -- Get Subtype Defaults abnd Merge
    local defaults = DeepCopyTable(Z.BaseComponents.Text[component.SubType])
    local textArgs = ModUtil.Table.Merge(defaults, component.Args)
    -- Create Text
    textArgs.Name = "BlankObstacle"
    screen.Components[component.Args.Name] = CreateScreenComponent(textArgs)
    return CreateTextBox({
        Id = screen.Components.Background.Id,
        Text = textArgs.Text
    })

end
-- Create Progress Bar
function Z.CreateProgressBar(screen, args)
    local RECTANGLE_01_HEIGHT = 270
    local RECTANGLE_01_WIDTH = 480
    local background = CreateScreenComponent({
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
end