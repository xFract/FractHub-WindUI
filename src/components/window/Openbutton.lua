local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween


local cloneref = (cloneref or clonereference or function(instance) return instance end)


local UserInputService = cloneref(game:GetService("UserInputService"))


function OpenButton.New(Window)
    local OpenButtonMain = {
        Button = nil
    }
    
    local Icon
    
    
    
    -- Icon = New("ImageLabel", {
    --     Image = "",
    --     Size = UDim2.new(0,22,0,22),
    --     Position = UDim2.new(0.5,0,0.5,0),
    --     LayoutOrder = -1,
    --     AnchorPoint = Vector2.new(0.5,0.5),
    --     BackgroundTransparency = 1,
    --     Name = "Icon"
    -- })

    local Title = New("TextLabel", {
        Text = Window.Title,
        TextSize = 17,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
    })

    local Drag = New("Frame", {
        Size = UDim2.new(0,44-8,0,44-8),
        BackgroundTransparency = 1, 
        Name = "Drag",
    }, {
        New("ImageLabel", {
            Image = Creator.Icon("move")[1],
            ImageRectOffset = Creator.Icon("move")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("move")[2].ImageRectSize,
            Size = UDim2.new(0,18,0,18),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = .3,
        })
    })
    local Divider = New("Frame", {
        Size = UDim2.new(0,1,1,0),
        Position = UDim2.new(0,20+16,0.5,0),
        AnchorPoint = Vector2.new(0,0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = .9,
    })

    local Container = New("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0,6+44/2),
        AnchorPoint = Vector2.new(0.5,0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
    })


    local UIScale = New("UIScale", {
        Scale = 1,
    })

    local ButtonLayout
    local TextButtonLayout

    local Button = New("Frame", {
        Size = UDim2.new(0,0,0,44),
        AutomaticSize = "X",
        Parent = Container,
        Active = false,
        BackgroundTransparency = .25,
        ZIndex = 99,
        BackgroundColor3 = Color3.new(0,0,0),
    }, {
        UIScale,
	    New("UICorner", {
            CornerRadius = UDim.new(1,0)
        }),
        New("UIStroke", {
            Thickness = 1,
            ApplyStrokeMode = "Border",
            Color = Color3.new(1,1,1),
            Transparency = 0,
        }, {
            New("UIGradient", {
                Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff"))
            })
        }),
        Drag,
        Divider,
        
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center",
            HorizontalAlignment = "Left",
            Name = "ButtonLayout",
        }),
        
        New("TextButton",{
            AutomaticSize = "XY",
            Active = true,
            BackgroundTransparency = 1, -- .93
            Size = UDim2.new(0,0,0,44-(4*2)),
            --Position = UDim2.new(0,20+16+16+1,0,0),
            BackgroundColor3 = Color3.new(1,1,1),
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(1,-4)
            }),
            Icon,
            New("UIListLayout", {
                Padding = UDim.new(0, Window.UIPadding),
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
                HorizontalAlignment = "Left",
                Name = "TextButtonLayout",
            }),
            Title,
            New("UIPadding", {
                PaddingLeft = UDim.new(0,7+4),
                PaddingRight = UDim.new(0,7+4),
            }),
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0,4),
            PaddingRight = UDim.new(0,4),
        })
    })
    
    OpenButtonMain.Button = Button
    ButtonLayout = Button:FindFirstChild("ButtonLayout")
    TextButtonLayout = Button.TextButton:FindFirstChild("TextButtonLayout")

    local function applyVisualMode(isOnlyIcon)
        if isOnlyIcon then
            Button.AutomaticSize = "None"
            Button.Size = UDim2.new(0, 44, 0, 44)
            Button.UIPadding.PaddingLeft = UDim.new(0, 0)
            Button.UIPadding.PaddingRight = UDim.new(0, 0)
            Button.TextButton.AutomaticSize = "None"
            Button.TextButton.Size = UDim2.new(1, 0, 1, 0)
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0, 0)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0, 0)
            Button.TextButton.UICorner.CornerRadius = UDim.new(0, 14)
            Button.UICorner.CornerRadius = UDim.new(0, 14)
            if ButtonLayout then
                ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            end
            if TextButtonLayout then
                TextButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                TextButtonLayout.Padding = UDim.new(0, 0)
            end
            if Icon then
                Icon.Size = UDim2.new(0, 26, 0, 26)
                Icon.AnchorPoint = Vector2.new(0, 0)
                Icon.Position = UDim2.new(0, 0, 0, 0)
            end
        else
            Button.AutomaticSize = "X"
            Button.Size = UDim2.new(0, 0, 0, 44)
            Button.UIPadding.PaddingLeft = UDim.new(0, 4)
            Button.UIPadding.PaddingRight = UDim.new(0, 4)
            Button.TextButton.AutomaticSize = "XY"
            Button.TextButton.Size = UDim2.new(0, 0, 0, 36)
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0, 11)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0, 11)
            Button.TextButton.UICorner.CornerRadius = UDim.new(1, -4)
            Button.UICorner.CornerRadius = UDim.new(1, 0)
            if ButtonLayout then
                ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            end
            if TextButtonLayout then
                TextButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                TextButtonLayout.Padding = UDim.new(0, Window.UIPadding)
            end
            if Icon then
                Icon.Size = UDim2.new(0,22,0,22)
                Icon.AnchorPoint = Vector2.new(0, 0)
                Icon.Position = UDim2.new(0, 0, 0, 0)
            end
        end
    end
    
    
    
    function OpenButtonMain:SetIcon(newIcon)
        if Icon then
            Icon:Destroy()
        end
        if newIcon then
            Icon = Creator.Image(
                newIcon,
                Window.Title,
                0,
                Window.Folder,
                "OpenButton",
                true,
                Window.IconThemed
            )
            Icon.Size = UDim2.new(0,22,0,22)
            Icon.LayoutOrder = -1
            Icon.Parent = OpenButtonMain.Button.TextButton
            applyVisualMode(Title and not Title.Visible)
        end
    end
    
    if Window.MinimizeIcon or Window.Icon then
        OpenButtonMain:SetIcon(Window.MinimizeIcon or Window.Icon)
    end
    
    
    
    Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
        Container.Size = UDim2.new(
            0, Button.AbsoluteSize.X,
            0, Button.AbsoluteSize.Y
        )
    end)
    
    Creator.AddSignal(Button.TextButton.MouseEnter, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = .93}):Play()
    end)
    Creator.AddSignal(Button.TextButton.MouseLeave, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = 1}):Play()
    end)
    
    local DragModule = Creator.Drag(Container)
    
    
    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end
    
    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end
    
    function OpenButtonMain:Edit(OpenButtonConfig)
        local OpenButtonModule = {
            Title = OpenButtonConfig.Title,
            Icon = OpenButtonConfig.Icon,
            Enabled = OpenButtonConfig.Enabled,
            Position = OpenButtonConfig.Position,
            OnlyIcon = OpenButtonConfig.OnlyIcon or false,
            Draggable = OpenButtonConfig.Draggable or nil,
            OnlyMobile = OpenButtonConfig.OnlyMobile,
            CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(1, 0),
            StrokeThickness = OpenButtonConfig.StrokeThickness or 2,
            Scale = OpenButtonConfig.Scale or 1,
            Color = OpenButtonConfig.Color 
                or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
        }
        
        -- wtf lol
        
        if OpenButtonModule.Enabled == false then
            Window.IsOpenButtonEnabled = false
        end
        
        if OpenButtonModule.OnlyMobile ~= false then
            OpenButtonModule.OnlyMobile = true
        else
            Window.IsPC = false
        end
        
        
        if Drag and Divider then
            local isDraggable = OpenButtonModule.Draggable ~= false
            Drag.Visible = isDraggable and not OpenButtonModule.OnlyIcon
            Divider.Visible = isDraggable and not OpenButtonModule.OnlyIcon
            Drag.Size = UDim2.new(0, (isDraggable and not OpenButtonModule.OnlyIcon) and 36 or 0, 0, 36)
            Divider.Size = UDim2.new(0, (isDraggable and not OpenButtonModule.OnlyIcon) and 1 or 0, 1, 0)

            if DragModule then
                DragModule:Set(isDraggable)
            end
        end
        
        if OpenButtonModule.Position and Container then
            Container.Position = OpenButtonModule.Position
        end
        
        if OpenButtonModule.OnlyIcon == true and Title then
            Title.Visible = false
        elseif OpenButtonModule.OnlyIcon == false then
            Title.Visible = true
        end
        applyVisualMode(OpenButtonModule.OnlyIcon == true)
        
        --OpenButtonMain:Visible((not OpenButtonModule.OnlyMobile) or (not Window.IsPC))
        
        --if not OpenButton.Visible then return end
        
        if Title then
            if OpenButtonModule.Title then
                Title.Text = OpenButtonModule.Title
                Creator:ChangeTranslationKey(Title, OpenButtonModule.Title)
            elseif OpenButtonModule.Title == nil then
                --Title.Visible = false
            end
        end
        
        if OpenButtonModule.Icon then
            OpenButtonMain:SetIcon(OpenButtonModule.Icon)
        end

        Button.UIStroke.UIGradient.Color = OpenButtonModule.Color
        if Glow then
            Glow.UIGradient.Color = OpenButtonModule.Color
        end

        Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
        if OpenButtonModule.OnlyIcon ~= true then
            Button.TextButton.UICorner.CornerRadius =
                UDim.new(OpenButtonModule.CornerRadius.Scale, OpenButtonModule.CornerRadius.Offset - 4)
        end
        Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness
        
        OpenButtonMain:SetScale(OpenButtonModule.Scale)
    end

    return OpenButtonMain
end



return OpenButton
