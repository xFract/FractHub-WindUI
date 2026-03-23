local BASE = "https://raw.githubusercontent.com/xFract/FractHub-WindUI/refs/heads/main/"

local function get(path)
	return assert(loadstring(game:HttpGet(BASE .. path)))()
end

local WindUI = get("dist/main.lua")
local ConfigAddon = get("Addons/ConfigManager.lua")
local InterfaceAddon = get("Addons/InterfaceManager.lua")
local Maid = get("Addons/Maid.lua")

if getgenv().Script_Maid then
	pcall(function()
		getgenv().Script_Maid:Destroy()
	end)
end

local Window = WindUI:CreateWindow({
	Title = "WindUI Skeleton",
	Author = "Executor Sample",
	Folder = "WindUI_Skeleton",
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
getgenv().Script_Maid = scriptMaid
scriptMaid:GiveTask(function()
	pcall(function()
		if Window then
			Window:Destroy()
		end
	end)
end)

local FOLDER_NAME = "WindUI_Skeleton"
getgenv().Script_FolderName = FOLDER_NAME
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
	Flag = "example_toggle",
	Value = false,
	Callback = function(state)
		print("Toggle:", state)
	end,
})

MainTab:Space()

MainTab:Input({
	Title = "Example Input",
	Flag = "example_input",
	Placeholder = "Type here...",
	Callback = function(value)
		print("Input:", value)
	end,
})

MainTab:Space()

MainTab:Slider({
	Title = "Example Slider",
	Flag = "example_slider",
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
	Flag = "example_dropdown",
	Value = "Option 1",
	Values = { "Option 1", "Option 2", "Option 3" },
	Callback = function(value)
		print("Dropdown:", value)
	end,
})

MainTab:Space()

MainTab:Colorpicker({
	Title = "Example Colorpicker",
	Flag = "example_colorpicker",
	Default = Color3.fromRGB(0, 170, 255),
	Callback = function(color)
		print("Color:", color)
	end,
})

MainTab:Space()

MainTab:Keybind({
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
	Flag = "auto_farm",
	Value = false,
	Callback = function(state)
		print("Auto Farm:", state)
	end,
})

FarmSection:Space()

FarmSection:Dropdown({
	Title = "Position",
	Flag = "farm_position",
	Value = "Above",
	Values = { "Above", "Below", "Behind" },
	Callback = function(value)
		print("Position:", value)
	end,
})

FarmSection:Space()

FarmSection:Slider({
	Title = "Damage Increment",
	Flag = "damage_increment",
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
	Flag = "auto_loot_chests",
	Value = true,
	Callback = function(state)
		print("Auto Loot Chests:", state)
	end,
})

LootSection:Space()

LootSection:Toggle({
	Title = "Auto Loot Drops",
	Flag = "auto_loot_drops",
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

local ConfigTab = UtilitySection:Tab({
	Title = "Config",
	Icon = "save",
})

InterfaceAddon:BuildInterfaceSection(SettingsTab)

SettingsTab:Button({
	Title = "Destroy UI",
	Callback = function()
		scriptMaid:Destroy()
	end,
})

ConfigAddon:BuildConfigSection(ConfigTab, {
	SectionTitle = "Config Save",
	SectionDesc = "Save and restore Flag-based values. Works outside Studio.",
	DefaultConfigName = "default",
	AutoLoad = true,
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
