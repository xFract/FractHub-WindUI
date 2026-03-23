local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

function OpenButton.New(Window)
	local OpenButtonMain = {
		Button = nil,
	}

	local UIScale = New("UIScale", {
		Scale = 1,
	})

	local IconImage = New("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		ScaleType = "Fit",
		ImageTransparency = 0,
	})

	local Button = New("ImageButton", {
		Name = "OpenButton",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(0.5, 0, 0, 28),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Window.Parent,
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.2,
		ImageTransparency = 1,
		Visible = false,
		ZIndex = 99,
		Active = true,
	}, {
		UIScale,
		New("UICorner", {
			CornerRadius = UDim.new(0, 14),
		}),
		New("UIStroke", {
			Thickness = 0,
			ApplyStrokeMode = "Border",
			Color = Color3.new(1, 1, 1),
			Transparency = 0,
		}, {
			New("UIGradient", {
				Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
			}),
		}),
		IconImage,
	})

	local DragModule = Creator.Drag(Button, { Button })

	OpenButtonMain.Button = Button

	function OpenButtonMain:SetIcon(newIcon)
		IconImage.Image = newIcon or ""
		IconImage.Visible = newIcon ~= nil and newIcon ~= ""
	end

	if Window.MinimizeIcon or Window.Icon then
		OpenButtonMain:SetIcon(Window.MinimizeIcon or Window.Icon)
	end

	Creator.AddSignal(Button.MouseEnter, function()
		Tween(Button, 0.1, { BackgroundTransparency = 0.05 }):Play()
	end)

	Creator.AddSignal(Button.MouseLeave, function()
		Tween(Button, 0.1, { BackgroundTransparency = 0.2 }):Play()
	end)

	function OpenButtonMain:Visible(v)
		Button.Visible = v
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
			Draggable = OpenButtonConfig.Draggable,
			OnlyMobile = OpenButtonConfig.OnlyMobile,
			CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(0, 14),
			StrokeThickness = OpenButtonConfig.StrokeThickness or 0,
			Scale = OpenButtonConfig.Scale or 1,
			Color = OpenButtonConfig.Color or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
			Size = OpenButtonConfig.Size or UDim2.fromOffset(50, 50),
			IconSize = OpenButtonConfig.IconSize or UDim2.fromOffset(28, 28),
			BackgroundTransparency = OpenButtonConfig.BackgroundTransparency,
		}

		if OpenButtonModule.Enabled == false then
			Window.IsOpenButtonEnabled = false
		end

		if OpenButtonModule.OnlyMobile ~= false then
			OpenButtonModule.OnlyMobile = true
		else
			Window.IsPC = false
		end

		if OpenButtonModule.Position then
			Button.Position = OpenButtonModule.Position
		end

		Button.Size = OpenButtonModule.Size
		IconImage.Size = OpenButtonModule.IconSize
		Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
		Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness
		Button.UIStroke.UIGradient.Color = OpenButtonModule.Color
		Button.BackgroundTransparency = OpenButtonModule.BackgroundTransparency or 0.2

		if OpenButtonModule.Icon then
			OpenButtonMain:SetIcon(OpenButtonModule.Icon)
		end

		if DragModule then
			DragModule:Set(OpenButtonModule.Draggable ~= false)
		end

		OpenButtonMain:SetScale(OpenButtonModule.Scale)
	end

	return OpenButtonMain
end

return OpenButton
