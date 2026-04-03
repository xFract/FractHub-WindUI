--[[
    WindUI executor settings example

    Priority:
    1. local dist/main.lua
    2. GitHub fallback

    Note:
    This sample builds the Settings tab manually so it works
    even when the executor is loading the bundled dist build.
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
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
	end)

	if ok and result then
		return result
	end

	error("Failed to load WindUI from local dist/main.lua or GitHub")
end

local WindUI = loadWindUI()

local ThemeName = "Dark"

local Window = WindUI:CreateWindow({
	Title = "WindUI Executor Settings Example",
	Author = "Local/Executor Sample",
	Folder = "WindUI_ExecutorSettingsExample",
	Icon = "settings",
	Theme = ThemeName,
	NewElements = true,
	Transparent = true,
	ToggleKey = Enum.KeyCode.RightShift,
})

local MainTab = Window:Tab({
	Title = "Main",
	Icon = "home",
})

MainTab:Section({
	Title = "Quick Test",
	Desc = "Open the Settings tab to switch themes.",
})

MainTab:Paragraph({
	Title = "How to use",
	Desc = "This executor sample creates the Settings tab manually, so it works with the current dist build too.",
	Image = "palette",
})

MainTab:Button({
	Title = "Show Current Theme",
	Icon = "sun-moon",
	Callback = function()
		WindUI:Notify({
			Title = "Current Theme",
			Content = WindUI:GetCurrentTheme(),
			Icon = "palette",
		})
	end,
})

MainTab:Space()

MainTab:Button({
	Title = "Switch Dark / Light",
	Icon = "refresh-cw",
	Callback = function()
		local NextTheme = WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark"
		ThemeName = NextTheme
		Window:SetTitle("WindUI Executor Settings Example")
		WindUI:SetTheme(NextTheme)
	end,
})

local SettingsTab = Window:Tab({
	Title = "Settings",
	Icon = "settings",
})

local Themes = {}
for name, _ in pairs(WindUI:GetThemes()) do
	table.insert(Themes, name)
end
table.sort(Themes)

SettingsTab:Section({
	Title = "Appearance",
	Desc = "Change the theme from inside the UI",
})

SettingsTab:Dropdown({
	Title = "Select Theme",
	Value = ThemeName,
	Values = Themes,
	SearchBarEnabled = true,
	Callback = function(value)
		ThemeName = value
		WindUI:SetTheme(value)
		WindUI:Notify({
			Title = "Theme Applied",
			Content = value,
			Icon = "palette",
		})
	end,
})

SettingsTab:Space()

SettingsTab:Toggle({
	Title = "Window Transparency",
	Value = Window.Transparent,
	Callback = function(state)
		Window:ToggleTransparency(state)
	end,
})

local InfoTab = Window:Tab({
	Title = "Info",
	Icon = "info",
})

InfoTab:Paragraph({
	Title = "Notes",
	Desc = "Toggle the UI with RightShift. If local dist/main.lua is not found, the script falls back to GitHub.",
	Image = "monitor",
})
