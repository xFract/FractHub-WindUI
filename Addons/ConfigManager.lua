local ConfigAddon = {}
ConfigAddon.__index = ConfigAddon

local HttpService = game:GetService("HttpService")

ConfigAddon.Folder = "WindUI"
ConfigAddon.DefaultConfigName = "default"
ConfigAddon.AutoLoad = true
ConfigAddon.MinimumConfigVersion = 1.2

function ConfigAddon:SetLibrary(library)
	self.Library = library
end

function ConfigAddon:SetWindow(window)
	self.Window = window
	self.ConfigManager = window and window.ConfigManager or nil
end

function ConfigAddon:SetDefaultConfigName(configName)
	if configName and configName ~= "" then
		self.DefaultConfigName = configName
	end
end

function ConfigAddon:IsSupportedConfigData(decoded)
	if type(decoded) ~= "table" then
		return false
	end

	local version = decoded.__version
	if type(version) ~= "number" then
		return false
	end

	return version >= self.MinimumConfigVersion
end

function ConfigAddon:IsSupportedConfigName(configName)
	if not self.ConfigManager or not self.ConfigManager.Path or not isfile or not readfile then
		return false
	end

	local path = self.ConfigManager.Path .. configName .. ".json"
	if not isfile(path) then
		return false
	end

	local readSuccess, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)

	return readSuccess and self:IsSupportedConfigData(decoded)
end

function ConfigAddon:GetConfigNames()
	if not self.ConfigManager or not self.ConfigManager.Path or not listfiles or not readfile then
		return {}
	end

	local names = {}
	local success, files = pcall(function()
		return listfiles(self.ConfigManager.Path)
	end)

	if not success or not files then
		return names
	end

	for _, file in ipairs(files) do
		if file:match("%.json$") then
			local readSuccess, decoded = pcall(function()
				return HttpService:JSONDecode(readfile(file))
			end)

			if readSuccess and self:IsSupportedConfigData(decoded) then
				local fileName = file:match("([^\\/]+)%.json$")
				if fileName then
					table.insert(names, fileName)
				end
			end
		end
	end

	table.sort(names)
	return names
end

function ConfigAddon:GetAutoLoadConfigName()
	if not self.ConfigManager or not self.ConfigManager.Path or not listfiles or not readfile then
		return nil
	end

	local success, files = pcall(function()
		return listfiles(self.ConfigManager.Path)
	end)

	if not success or not files then
		return nil
	end

	for _, file in ipairs(files) do
		if file:match("%.json$") then
			local readSuccess, decoded = pcall(function()
				return HttpService:JSONDecode(readfile(file))
			end)

			if readSuccess and self:IsSupportedConfigData(decoded) and decoded.__autoload then
				return file:match("([^\\/]+)%.json$")
			end
		end
	end

	return nil
end

function ConfigAddon:UpdateAutoLoadState(configName, enabled)
	if not self.ConfigManager then
		return
	end

	local targetName = (configName and configName ~= "") and configName or self.DefaultConfigName

	for existingName, config in pairs(self.ConfigManager.Configs or {}) do
		if config and type(config.SetAutoLoad) == "function" then
			config:SetAutoLoad(enabled and existingName == targetName or false)
		end
	end

	if not self.ConfigManager.Path or not listfiles or not readfile or not writefile then
		return
	end

	local success, files = pcall(function()
		return listfiles(self.ConfigManager.Path)
	end)

	if not success or not files then
		return
	end

	for _, file in ipairs(files) do
		if file:match("%.json$") then
			local readSuccess, decoded = pcall(function()
				return HttpService:JSONDecode(readfile(file))
			end)

			if readSuccess and type(decoded) == "table" then
				local fileName = file:match("([^\\/]+)%.json$")
				decoded.__autoload = enabled and fileName == targetName or false

				pcall(function()
					writefile(file, HttpService:JSONEncode(decoded))
				end)
			end
		end
	end
end

function ConfigAddon:EnsureConfig(configName, autoload)
	if not self.ConfigManager then
		return nil
	end

	local finalName = (configName and configName ~= "") and configName or self.DefaultConfigName
	local existing = self.ConfigManager:GetConfig(finalName)

	if existing then
		if autoload ~= nil then
			self:UpdateAutoLoadState(finalName, autoload)
		end
		existing:SetAsCurrent()
		self.CurrentConfig = existing
		self.DefaultConfigName = finalName
		return existing
	end

	self.CurrentConfig = self.ConfigManager:Config(finalName, autoload)
	self.DefaultConfigName = finalName
	return self.CurrentConfig
end

function ConfigAddon:Notify(title, content, icon)
	if self.Library and self.Library.Notify then
		self.Library:Notify({
			Title = title,
			Content = content,
			Icon = icon,
		})
	end
end

function ConfigAddon:BuildConfigSection(tab, options)
	assert(self.Library, "Must set ConfigAddon.Library")
	assert(self.Window, "Must set ConfigAddon.Window")

	options = options or {}
	self.AutoLoad = options.AutoLoad ~= false
	self.DefaultConfigName = self:GetAutoLoadConfigName() or options.DefaultConfigName or self.DefaultConfigName

	if self.ConfigManager then
		self:EnsureConfig(self.DefaultConfigName, self.AutoLoad)
	end

	tab:Section({
		Title = options.SectionTitle or "Config Save",
		Desc = options.SectionDesc or "Save and restore Flag-based values. Works outside Studio.",
	})

	tab:Paragraph({
		Title = options.StatusTitle or "Current Config",
		Desc = self.CurrentConfig and self.DefaultConfigName or "ConfigManager unavailable in this environment.",
		Image = options.StatusIcon or "save",
	})

	tab:Space()

	local configDropdown = tab:Dropdown({
		Title = options.DropdownTitle or "Config File",
		Value = self.DefaultConfigName,
		Values = self:GetConfigNames(),
		Callback = function(configName)
			if not configName or configName == "" or not self.ConfigManager then
				return
			end

			if not self:IsSupportedConfigName(configName) then
				self:Notify("Unsupported Config", "Old config versions are not restored.", "triangle-alert")
				return
			end

			self:EnsureConfig(configName, self.AutoLoad)
		end,
	})

	tab:Space()

	tab:Input({
		Title = options.NameTitle or "Config Name",
		Placeholder = options.NamePlaceholder or "default",
		Callback = function(value)
			if not value or value == "" then
				return
			end

			self.DefaultConfigName = value
		end,
	})

	tab:Space()

	tab:Toggle({
		Title = options.AutoLoadTitle or "Auto Load",
		Value = self.AutoLoad,
		Callback = function(state)
			self.AutoLoad = state
			if self.CurrentConfig then
				self:UpdateAutoLoadState(self.DefaultConfigName, state)
			end
		end,
	})

	tab:Space()

	tab:Button({
		Title = options.CreateTitle or "Create Config",
		Callback = function()
			if not self.ConfigManager then
				self:Notify("Config", "ConfigManager is not available here.", "triangle-alert")
				return
			end

			local config = self:EnsureConfig(self.DefaultConfigName, self.AutoLoad)
			local success, result = config:Save()
			if success == false then
				self:Notify("Create Failed", tostring(result), "triangle-alert")
				return
			end

			if configDropdown and configDropdown.Refresh then
				configDropdown:Refresh(self:GetConfigNames())
				configDropdown:Select(self.DefaultConfigName)
			end

			self:Notify("Config Created", self.DefaultConfigName, "file-plus")
		end,
	})

	tab:Space()

	tab:Button({
		Title = options.SaveTitle or "Save Config",
		Callback = function()
			if not self.ConfigManager then
				self:Notify("Config", "ConfigManager is not available here.", "triangle-alert")
				return
			end

			local config = self:EnsureConfig(self.DefaultConfigName, self.AutoLoad)
			config:Save()

			if configDropdown and configDropdown.Refresh then
				configDropdown:Refresh(self:GetConfigNames())
				configDropdown:Select(self.DefaultConfigName)
			end

			self:Notify("Config Saved", self.DefaultConfigName, "save")
		end,
	})

	tab:Space()

	tab:Button({
		Title = options.LoadTitle or "Load Config",
		Callback = function()
			if not self.ConfigManager then
				self:Notify("Config", "ConfigManager is not available here.", "triangle-alert")
				return
			end

			if not self:IsSupportedConfigName(self.DefaultConfigName) then
				self:Notify("Unsupported Config", "Old config versions are not restored.", "triangle-alert")
				return
			end

			local config = self:EnsureConfig(self.DefaultConfigName, self.AutoLoad)
			local success, result = config:Load()
			if success == false then
				self:Notify("Load Failed", tostring(result), "triangle-alert")
				return
			end

			self:Notify("Config Loaded", self.DefaultConfigName, "folder-open")
		end,
	})

	tab:Space()

	tab:Button({
		Title = options.DeleteTitle or "Delete Config",
		Callback = function()
			if not self.ConfigManager then
				self:Notify("Config", "ConfigManager is not available here.", "triangle-alert")
				return
			end

			local success, result = self.ConfigManager:DeleteConfig(self.DefaultConfigName)
			if not success then
				self:Notify("Delete Failed", tostring(result), "triangle-alert")
				return
			end

			self.CurrentConfig = nil
			if configDropdown and configDropdown.Refresh then
				configDropdown:Refresh(self:GetConfigNames())
			end

			self:Notify("Config Deleted", self.DefaultConfigName, "trash-2")
		end,
	})
end

return ConfigAddon
