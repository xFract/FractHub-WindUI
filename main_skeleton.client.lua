--[[
    WindUI executor skeleton sample

    Minimal structure:
    - load WindUI
    - create window
    - create tabs
    - create a few basic controls
]]

local function loadWindUI()
	local localPaths = {
		"dist/main.lua",
		"FractHub-WindUI/dist/main.lua",
	}

	if readfile and loadstring then
		for _, path in ipairs(localPaths) do
			if isfile and isfile(path) then
				local ok, result = pcall(function()
					return loadstring(readfile(path))()
				end)

				if ok and result then
					return result
				end
			end
		end
	end

	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/xFract/FractHub-WindUI/refs/heads/main/dist/main.lua"))()
	end)

	if ok and result then
		return result
	end

	error("Failed to load WindUI")
end

local WindUI = loadWindUI()

local Window = WindUI:CreateWindow({
	Title = "WindUI Skeleton",
	Author = "Executor Sample",
	Folder = "WindUI_Skeleton",
	Icon = "layout-dashboard",
	Theme = "Dark",
	ToggleKey = Enum.KeyCode.RightShift,
	SidebarLogo = "rbxassetid://92450040427767",
	MinimizeIcon = "rbxassetid://73404955622861",
	SidebarLogoHeight = 120,
OpenButton = {
    Enabled = true,
    OnlyMobile = false,
    OnlyIcon = true,
    Icon = "rbxassetid://73404955622861",
    Title = "",
    Draggable = false,
    Scale = 0.9,
    StrokeThickness = 0,
    CornerRadius = UDim.new(0, 18),
}

})

local MainSection = Window:Section({
	Title = "Main Section",
})

local UtilitySection = Window:Section({
	Title = "Utility Section",
})

local MainTab = MainSection:Tab({
	Title = "Main",
	Icon = "home",
})

MainTab:Section({
	Title = "Basics",
	Desc = "Use this as a starting point.",
})

MainTab:Button({
	Title = "Notify",
	Callback = function()
		WindUI:Notify({
			Title = "WindUI",
			Content = "Skeleton is working.",
		})
	end,
})

MainTab:Space()

MainTab:Toggle({
	Title = "Example Toggle",
	Value = false,
	Callback = function(state)
		print("Toggle:", state)
	end,
})

MainTab:Space()

MainTab:Input({
	Title = "Example Input",
	Placeholder = "Type here...",
	Callback = function(value)
		print("Input:", value)
	end,
})

MainTab:Space()

MainTab:Slider({
	Title = "Example Slider",
	Step = 1,
	Value = {
		Min = 0,
		Max = 100,
		Default = 25,
	},
	Callback = function(value)
		print("Slider:", value)
	end,
})

MainTab:Space()

MainTab:Dropdown({
	Title = "Example Dropdown",
	Value = "Option 1",
	Values = { "Option 1", "Option 2", "Option 3" },
	Callback = function(value)
		print("Dropdown:", value)
	end,
})

MainTab:Space()

MainTab:Colorpicker({
	Title = "Example Colorpicker",
	Default = Color3.fromRGB(0, 170, 255),
	Callback = function(color)
		print("Color:", color)
	end,
})

MainTab:Space()

MainTab:Keybind({
	Title = "UI Toggle Key",
	Value = "RightShift",
	Callback = function(key)
		local keyCode = Enum.KeyCode[key]
		if keyCode then
			Window:SetToggleKey(keyCode)
		end
	end,
})

MainTab:Space()

local FarmSection = MainTab:Section({
	Title = "Farm Settings",
	Desc = "Section inside the Main tab.",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

FarmSection:Toggle({
	Title = "Auto Farm",
	Value = false,
	Callback = function(state)
		print("Auto Farm:", state)
	end,
})

FarmSection:Space()

FarmSection:Dropdown({
	Title = "Position",
	Value = "Above",
	Values = { "Above", "Below", "Behind" },
	Callback = function(value)
		print("Position:", value)
	end,
})

FarmSection:Space()

FarmSection:Slider({
	Title = "Damage Increment",
	Step = 1,
	Value = {
		Min = 0,
		Max = 10,
		Default = 5,
	},
	Callback = function(value)
		print("Damage Increment:", value)
	end,
})

MainTab:Space()

local LootSection = MainTab:Section({
	Title = "Loot Settings",
	Desc = "Another tab section example.",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

LootSection:Toggle({
	Title = "Auto Loot Chests",
	Value = true,
	Callback = function(state)
		print("Auto Loot Chests:", state)
	end,
})

LootSection:Space()

LootSection:Toggle({
	Title = "Auto Loot Drops",
	Value = true,
	Callback = function(state)
		print("Auto Loot Drops:", state)
	end,
})

local ExtrasTab = MainSection:Tab({
	Title = "Extras",
	Icon = "boxes",
})

ExtrasTab:Section({
	Title = "More Elements",
	Desc = "A few extra building blocks.",
})

ExtrasTab:Paragraph({
	Title = "Paragraph",
	Desc = "Use this for info, hints, or grouped text content.",
	Image = "info",
})

ExtrasTab:Space()

local Group = ExtrasTab:Group()

Group:Button({
	Title = "Group Button",
	Callback = function()
		print("Group button clicked")
	end,
})

Group:Space()

Group:Toggle({
	Title = "Group Toggle",
	Value = true,
	Callback = function(state)
		print("Group toggle:", state)
	end,
})

ExtrasTab:Space()

local BoxSection = ExtrasTab:Section({
	Title = "Box Section",
	Desc = "Section inside a section",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

BoxSection:Button({
	Title = "Section Button",
	Callback = function()
		WindUI:Notify({
			Title = "Section",
			Content = "Nested section button clicked.",
		})
	end,
})

local SettingsTab = UtilitySection:Tab({
	Title = "Settings",
	Icon = "settings",
})

SettingsTab:Section({
	Title = "Theme",
	Desc = "Basic theme switcher.",
})

SettingsTab:Dropdown({
	Title = "Select Theme",
	Value = "Dark",
	Values = { "Dark", "Light" },
	Callback = function(theme)
		WindUI:SetTheme(theme)
	end,
})

SettingsTab:Space()

SettingsTab:Toggle({
	Title = "Window Transparency",
	Value = false,
	Callback = function(state)
		Window:ToggleTransparency(state)
	end,
})

SettingsTab:Space()

SettingsTab:Button({
	Title = "Destroy UI",
	Callback = function()
		Window:Destroy()
	end,
})

local AboutTab = UtilitySection:Tab({
	Title = "About",
	Icon = "info",
})

AboutTab:Section({
	Title = "Window:Section Example",
	Desc = "These tabs are grouped in the sidebar by Window:Section.",
})

AboutTab:Paragraph({
	Title = "Sidebar Groups",
	Desc = "Main and Extras are inside Main Section. Settings and About are inside Utility Section.",
	Image = "folder-tree",
})

MainTab:Select()
