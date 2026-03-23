local ConfigAddon = {}
ConfigAddon.__index = ConfigAddon

ConfigAddon.Folder = "WindUI"
ConfigAddon.DefaultConfigName = "default"
ConfigAddon.AutoLoad = true

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

function ConfigAddon:GetConfigNames()
	if not self.ConfigManager then
		return {}
	end

	local names = self.ConfigManager:AllConfigs()
	table.sort(names)
	return names
end

function ConfigAddon:EnsureConfig(configName, autoload)
	if not self.ConfigManager then
		return nil
	end

	local finalName = (configName and configName ~= "") and configName or self.DefaultConfigName
	local existing = self.ConfigManager:GetConfig(finalName)

	if existing then
		if autoload ~= nil then
			existing:SetAutoLoad(autoload)
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
	self.DefaultConfigName = options.DefaultConfigName or self.DefaultConfigName

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
				self.CurrentConfig:SetAutoLoad(state)
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
