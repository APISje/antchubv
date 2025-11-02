--[[
    ANTC HUB - Feature Loader
    Memuat fitur-fitur secara dinamis tanpa perlu edit main.lua
]]

local Loader = {}
Loader.Features = {}
Loader.Config = {
    Version = "1.0.0",
    UpdateURL = "https://raw.githubusercontent.com/YOUR_USERNAME/antc-hub/main/features.lua",
    AutoUpdate = true,
    Cache = {},
    CheckInterval = 300
}

function Loader:Init(UI, config)
    self.UI = UI
    self.Initialized = true
    
    if config then
        if config.UpdateURL then
            self.Config.UpdateURL = config.UpdateURL
        end
        if config.AutoUpdate ~= nil then
            self.Config.AutoUpdate = config.AutoUpdate
        end
        if config.CheckInterval then
            self.Config.CheckInterval = config.CheckInterval
        end
    end
    
    print("[ANTC HUB] Loader initialized v" .. self.Config.Version)
    
    if self.Config.AutoUpdate then
        self:StartAutoUpdate()
    end
    
    return self
end

function Loader:StartAutoUpdate()
    print("[ANTC HUB] Auto-update enabled, checking for features...")
    
    spawn(function()
        while self.Config.AutoUpdate and wait(self.Config.CheckInterval) do
            self:CheckForUpdates()
        end
    end)
    
    self:CheckForUpdates()
end

function Loader:CheckForUpdates()
    local success, features = self:LoadFromURL(self.Config.UpdateURL)
    
    if success and features then
        print("[ANTC HUB] Features ditemukan, memuat...")
        
        if type(features) == "function" then
            local execSuccess, result = pcall(features, self)
            if execSuccess then
                print("[ANTC HUB] Features berhasil dimuat dan dieksekusi")
                self:Notify({
                    Title = "ANTC HUB",
                    Content = "Features berhasil dimuat!",
                    Duration = 3,
                    Icon = "check-circle"
                })
            else
                warn("[ANTC HUB] Error saat eksekusi features: " .. tostring(result))
            end
        elseif type(features) == "table" then
            for name, feature in pairs(features) do
                if type(feature) == "function" then
                    self:LoadFeature(name, feature)
                end
            end
        end
    end
end

function Loader:LoadFromURL(url)
    local HttpService = game:GetService("HttpService")
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        local loadSuccess, loadedFunc = pcall(loadstring, response)
        
        if loadSuccess and loadedFunc then
            local execSuccess, result = pcall(loadedFunc)
            if execSuccess then
                print("[ANTC HUB] Berhasil memuat dari URL")
                return true, result
            else
                warn("[ANTC HUB] Error eksekusi: " .. tostring(result))
            end
        else
            warn("[ANTC HUB] Error loadstring: " .. tostring(loadedFunc))
        end
    else
        warn("[ANTC HUB] Gagal HttpGet: " .. tostring(response))
    end
    
    return false, nil
end

function Loader:LoadFeature(featureName, featureFunc)
    if self.Features[featureName] then
        warn("[ANTC HUB] Feature '" .. featureName .. "' sudah dimuat, akan di-overwrite")
    end
    
    self.Features[featureName] = {
        Name = featureName,
        Func = featureFunc,
        Loaded = false,
        LastUpdate = os.time()
    }
    
    print("[ANTC HUB] Feature '" .. featureName .. "' didaftarkan")
    return self
end

function Loader:ExecuteFeature(featureName, ...)
    local feature = self.Features[featureName]
    
    if not feature then
        warn("[ANTC HUB] Feature '" .. featureName .. "' tidak ditemukan")
        return false
    end
    
    local success, result = pcall(feature.Func, self.UI, self, ...)
    
    if success then
        feature.Loaded = true
        print("[ANTC HUB] Feature '" .. featureName .. "' berhasil dijalankan")
        return true, result
    else
        warn("[ANTC HUB] Error pada feature '" .. featureName .. "': " .. tostring(result))
        return false, result
    end
end

function Loader:CreateTab(tabName, tabIcon)
    if not self.UI then
        warn("[ANTC HUB] UI belum diinisialisasi")
        return nil
    end
    
    local tab = self.UI:Tab({
        Title = tabName,
        Icon = tabIcon or "home"
    })
    
    print("[ANTC HUB] Tab '" .. tabName .. "' dibuat")
    return tab
end

function Loader:AddButton(tab, buttonConfig)
    if not tab then
        warn("[ANTC HUB] Tab tidak valid")
        return nil
    end
    
    local button = tab:Button({
        Title = buttonConfig.Title or "Button",
        Desc = buttonConfig.Desc or "",
        Callback = buttonConfig.Callback or function() end
    })
    
    return button
end

function Loader:AddToggle(tab, toggleConfig)
    if not tab then
        warn("[ANTC HUB] Tab tidak valid")
        return nil
    end
    
    local toggle = tab:Toggle({
        Title = toggleConfig.Title or "Toggle",
        Desc = toggleConfig.Desc or "",
        Default = toggleConfig.Default or false,
        Callback = toggleConfig.Callback or function(value) end
    })
    
    return toggle
end

function Loader:AddSlider(tab, sliderConfig)
    if not tab then
        warn("[ANTC HUB] Tab tidak valid")
        return nil
    end
    
    local slider = tab:Slider({
        Title = sliderConfig.Title or "Slider",
        Desc = sliderConfig.Desc or "",
        Min = sliderConfig.Min or 0,
        Max = sliderConfig.Max or 100,
        Default = sliderConfig.Default or 50,
        Callback = sliderConfig.Callback or function(value) end
    })
    
    return slider
end

function Loader:AddInput(tab, inputConfig)
    if not tab then
        warn("[ANTC HUB] Tab tidak valid")
        return nil
    end
    
    local input = tab:Input({
        Title = inputConfig.Title or "Input",
        Desc = inputConfig.Desc or "",
        Placeholder = inputConfig.Placeholder or "",
        Callback = inputConfig.Callback or function(value) end
    })
    
    return input
end

function Loader:AddDropdown(tab, dropdownConfig)
    if not tab then
        warn("[ANTC HUB] Tab tidak valid")
        return nil
    end
    
    local dropdown = tab:Dropdown({
        Title = dropdownConfig.Title or "Dropdown",
        Desc = dropdownConfig.Desc or "",
        Options = dropdownConfig.Options or {},
        Default = dropdownConfig.Default,
        Multi = dropdownConfig.Multi or false,
        Callback = dropdownConfig.Callback or function(value) end
    })
    
    return dropdown
end

function Loader:Notify(notifyConfig)
    if not self.UI then
        warn("[ANTC HUB] UI belum diinisialisasi")
        return
    end
    
    self.UI:Notify({
        Title = notifyConfig.Title or "ANTC HUB",
        Content = notifyConfig.Content or "",
        Duration = notifyConfig.Duration or 5,
        Icon = notifyConfig.Icon
    })
end

function Loader:GetAllFeatures()
    local featureList = {}
    for name, feature in pairs(self.Features) do
        table.insert(featureList, {
            Name = name,
            Loaded = feature.Loaded,
            LastUpdate = feature.LastUpdate
        })
    end
    return featureList
end

function Loader:UnloadFeature(featureName)
    if self.Features[featureName] then
        self.Features[featureName] = nil
        print("[ANTC HUB] Feature '" .. featureName .. "' dihapus")
        return true
    end
    return false
end

function Loader:ReloadFeature(featureName)
    local feature = self.Features[featureName]
    if feature then
        feature.Loaded = false
        return self:ExecuteFeature(featureName)
    end
    return false
end

function Loader:SetConfig(configKey, value)
    if self.Config[configKey] ~= nil then
        local oldValue = self.Config[configKey]
        self.Config[configKey] = value
        print("[ANTC HUB] Config '" .. configKey .. "' diupdate")
        
        if configKey == "UpdateURL" and oldValue ~= value and self.Initialized then
            print("[ANTC HUB] UpdateURL changed, checking for updates...")
            self:CheckForUpdates()
        end
        
        if configKey == "AutoUpdate" and value == true and not oldValue and self.Initialized then
            print("[ANTC HUB] AutoUpdate enabled, starting...")
            self:StartAutoUpdate()
        end
        
        return true
    end
    return false
end

function Loader:ManualRefresh()
    print("[ANTC HUB] Manual refresh triggered")
    return self:CheckForUpdates()
end

function Loader:GetUI()
    return self.UI
end

function Loader:CreateHub(WindUI, config)
    config = config or {}
    
    local Window = WindUI:Create({
        Title = config.Title or "ANTC HUB",
        Author = config.Author or "ANTC",
        Subtitle = config.Subtitle or "Advanced Script Hub v" .. self.Config.Version,
        Icon = config.Icon or "shield",
        Size = config.Size or UDim2.new(0, 560, 0, 580),
        SizeTabbed = config.SizeTabbed or UDim2.new(0, 560, 0, 560),
        Theme = config.Theme or "Dark",
        Folder = config.Folder or "ANTC_HUB",
        ShowOnStart = config.ShowOnStart or true,
    })
    
    local loaderConfig = {
        UpdateURL = config.LoaderURL,
        AutoUpdate = config.AutoUpdate,
        CheckInterval = config.CheckInterval
    }
    
    self:Init(Window, loaderConfig)
    
    Window:Notify({
        Title = "ANTC HUB",
        Content = "Berhasil dimuat! Version " .. self.Config.Version,
        Duration = 5,
        Icon = "check-circle"
    })
    
    return {
        Window = Window,
        Loader = self,
        WindUI = WindUI,
        Version = self.Config.Version,
        
        CreateTab = function(_, tabConfig)
            return self:CreateTab(tabConfig.Title, tabConfig.Icon)
        end,
        
        Notify = function(_, notifyConfig)
            return self:Notify(notifyConfig)
        end,
        
        LoadFeature = function(_, name, func)
            return self:LoadFeature(name, func)
        end,
        
        ExecuteFeature = function(_, name, ...)
            return self:ExecuteFeature(name, ...)
        end,
        
        GetFeatures = function(_)
            return self:GetAllFeatures()
        end,
        
        RefreshFeatures = function(_)
            return self:ManualRefresh()
        end,
        
        SetConfig = function(_, key, value)
            return self:SetConfig(key, value)
        end,
        
        SetTheme = function(_, theme)
            Window:SetTheme(theme)
        end,
        
        Destroy = function(_)
            Window:Destroy()
        end
    }
end

print("[ANTC HUB] Loader module dimuat v" .. Loader.Config.Version)
return Loader
