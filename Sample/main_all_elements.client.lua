local BASE = "https://raw.githubusercontent.com/xFract/FractHub-WindUI/refs/heads/main/"

local function get(path)
	return assert(loadstring(game:HttpGet(BASE .. path)))()
end

local WindUI = get("dist/main.lua")
local ConfigAddon = get("Addons/ConfigManager.lua")
local InterfaceAddon = get("Addons/InterfaceManager.lua")
local Maid = get("Addons/Maid.lua")

if getgenv().AllElements_Maid then
	pcall(function()
		getgenv().AllElements_Maid:Destroy()
	end)
end

local Window = WindUI:CreateWindow({
	Title = "WindUI All Elements",
	Author = "Example",
	Folder = "WindUI_AllElements",
	Icon = "layout-dashboard",
	Theme = "Dark",
	ToggleKey = Enum.KeyCode.RightShift,
	SidebarLogo = "rbxassetid://92450040427767",
	MinimizeIcon = "rbxassetid://133420557505582",
	SidebarLogoHeight = 120,
	OpenButton = {
		BackgroundTransparency = 1,
		StrokeThickness = 0,
		IconSize = UDim2.fromOffset(42, 42),
	},
})

local scriptMaid = Maid.new()
getgenv().AllElements_Maid = scriptMaid
scriptMaid:GiveTask(function()
	pcall(function()
		if Window then
			Window:Destroy()
		end
	end)
end)

local FOLDER_NAME = "WindUI_AllElements"
pcall(function()
	if not isfolder("WindUI") then
		makefolder("WindUI")
	end
	if not isfolder("WindUI/" .. FOLDER_NAME) then
		makefolder("WindUI/" .. FOLDER_NAME)
	end
end)

ConfigAddon:SetLibrary(WindUI)
ConfigAddon:SetWindow(Window)
ConfigAddon:SetDefaultConfigName("default")

InterfaceAddon:SetLibrary(WindUI)
InterfaceAddon:SetWindow(Window)
InterfaceAddon:SetFolder("WindUI/" .. FOLDER_NAME)

local MainSection = Window:Section({
	Title = "Examples",
})

local UtilitySection = Window:Section({
	Title = "Utility",
})

local BasicsTab = MainSection:Tab({
	Title = "Basics",
	Icon = "home",
})

BasicsTab:Section({
	Title = "Simple Elements",
	Desc = "Basic examples for each core element.",
	Box = true,
	BoxBorder = true,
	Opened = true,
})

BasicsTab:Button({
	Title = "Notify Button",
	Callback = function()
		WindUI:Notify({
			Title = "WindUI",
			Content = "Button callback fired.",
			Icon = "bell",
		})
	end,
})

BasicsTab:Space()

BasicsTab:Toggle({
	Title = "Example Toggle",
	Flag = "example_toggle",
	Value = false,
	Callback = function(state)
		print("Toggle:", state)
	end,
})

BasicsTab:Space()

BasicsTab:Slider({
	Title = "Example Slider",
	Flag = "example_slider",
	Step = 1,
	Value = { Min = 0, Max = 100, Default = 25 },
	Callback = function(value)
		print("Slider:", value)
	end,
})

BasicsTab:Space()

BasicsTab:Input({
	Title = "Example Input",
	Flag = "example_input",
	Placeholder = "Type here...",
	Callback = function(value)
		print("Input:", value)
	end,
})

BasicsTab:Space()

BasicsTab:Dropdown({
	Title = "Example Dropdown",
	Flag = "example_dropdown",
	Value = "Option 1",
	Values = { "Option 1", "Option 2", "Option 3" },
	Callback = function(value)
		print("Dropdown:", value)
	end,
})

BasicsTab:Space()

BasicsTab:Dropdown({
	Title = "Multi Dropdown",
	Flag = "example_multi_dropdown",
	Value = {},
	Values = { "Sword", "Shield", "Potion", "Bow" },
	Multi = true,
	SearchBarEnabled = true,
	Callback = function(values)
		for name, selected in pairs(values) do
			print("Multi Dropdown:", name, selected)
		end
	end,
})

BasicsTab:Space()

BasicsTab:Colorpicker({
	Title = "Example Colorpicker",
	Flag = "example_colorpicker",
	Default = Color3.fromRGB(0, 170, 255),
	Callback = function(color)
		print("Color:", color)
	end,
})

BasicsTab:Space()

BasicsTab:Keybind({
	Title = "UI Toggle Key",
	Flag = "ui_toggle_key",
	Value = "RightShift",
	Callback = function(key)
		local keyCode = Enum.KeyCode[key]
		if keyCode then
			Window:SetToggleKey(keyCode)
		end
	end,
})

local DisplayTab = MainSection:Tab({
	Title = "Display",
	Icon = "image",
})

DisplayTab:Paragraph({
	Title = "Paragraph",
	Desc = "Information text with an optional icon.",
	Image = "info",
})

DisplayTab:Divider()

DisplayTab:Code({
	Title = "Code",
	Code = "print('hello from WindUI')",
})

DisplayTab:Space()

DisplayTab:Image({
	Title = "Image",
	Image = "rbxassetid://92450040427767",
})

DisplayTab:Space()

DisplayTab:Paragraph({
	Title = "Space",
	Desc = "A spacer was inserted above this paragraph.",
	Image = "panel-top",
})

local LayoutTab = MainSection:Tab({
	Title = "Layout",
	Icon = "boxes",
	Columns = 2,
	MinColumnWidth = 180,
})

local Group = LayoutTab:Group()
Group:Button({
	Title = "Group Button",
	Callback = function()
		print("Group Button")
	end,
})
Group:Toggle({
	Title = "Group Toggle",
	Value = true,
	Callback = function(state)
		print("Group Toggle:", state)
	end,
})

LayoutTab:Space()

local BoxSection = LayoutTab:Section({
	Title = "Section A",
	Desc = "Box sections can now sit in two columns.",
	Box = true,
	BoxBorder = true,
	Opened = true,
	MinColumnWidth = 140,
})

BoxSection:Toggle({
	Title = "Section Toggle",
	Flag = "section_toggle",
	Value = false,
	Callback = function(state)
		print("Section Toggle:", state)
	end,
})

BoxSection:Space()

BoxSection:Dropdown({
	Title = "Section Dropdown",
	Flag = "section_dropdown",
	Value = "Above",
	Values = { "Above", "Below", "Behind" },
	Callback = function(value)
		print("Section Dropdown:", value)
	end,
})

BoxSection:Space()

BoxSection:Slider({
	Title = "Section Slider",
	Flag = "section_slider",
	Step = 1,
	Value = { Min = 0, Max = 10, Default = 5 },
	Callback = function(value)
		print("Section Slider:", value)
	end,
})

BoxSection:Space()

BoxSection:Input({
	Title = "Section Input",
	Flag = "section_input",
	Placeholder = "Box section A",
	Callback = function(value)
		print("Section Input:", value)
	end,
})

local BoxSectionTwo = LayoutTab:Section({
	Title = "Section B",
	Desc = "Placed beside Section A when the tab uses Columns = 2.",
	Box = true,
	BoxBorder = true,
	Opened = true,
	MinColumnWidth = 140,
})

BoxSectionTwo:Toggle({
	Title = "Second Toggle",
	Flag = "section_toggle_2",
	Value = true,
	Callback = function(state)
		print("Second Toggle:", state)
	end,
})

BoxSectionTwo:Space()

BoxSectionTwo:Dropdown({
	Title = "Second Dropdown",
	Flag = "section_dropdown_2",
	Value = "Left",
	Values = { "Left", "Right" },
	Callback = function(value)
		print("Second Dropdown:", value)
	end,
})

local LockTab = MainSection:Tab({
	Title = "Lock",
	Icon = "lock",
})

local LockedButton = LockTab:Button({
	Title = "Locked Button",
	Locked = true,
	LockedTitle = "This element is locked",
	Callback = function()
		print("Unlocked button clicked")
	end,
})

LockTab:Space()

LockTab:Toggle({
	Title = "Unlock Button",
	Value = false,
	Callback = function(state)
		if state then
			LockedButton:Unlock()
		else
			LockedButton:Lock()
		end
	end,
})

local SettingsTab = UtilitySection:Tab({
	Title = "Settings",
	Icon = "settings",
})

InterfaceAddon:BuildInterfaceSection(SettingsTab)

local ConfigTab = UtilitySection:Tab({
	Title = "Config",
	Icon = "save",
})

ConfigAddon:BuildConfigSection(ConfigTab, {
	SectionTitle = "Config Save",
	SectionDesc = "Save and restore Flag-based values.",
	DefaultConfigName = "default",
	AutoLoad = true,
})

local AboutTab = UtilitySection:Tab({
	Title = "About",
	Icon = "info",
})

AboutTab:Paragraph({
	Title = "Loaded Elements",
	Desc = "Button, Toggle, Slider, Input, Dropdown, Multi Dropdown, Keybind, Colorpicker, Paragraph, Divider, Space, Image, Code, Group, Section, Config, Lock sample.",
	Image = "badge-info",
})

AboutTab:Button({
	Title = "Destroy UI",
	Callback = function()
		scriptMaid:Destroy()
	end,
})

BasicsTab:Select()
