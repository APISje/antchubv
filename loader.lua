
local ANTC HUB
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        ANTCUI = result
    else 
        ANTCUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/antchubv/refs/heads/main/main.lua"))()
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local autoFarmEnabled = false
local antiAFKEnabled = false
local antiAdminEnabled = false
local antiTrollEnabled = false
local unlimitedJumpEnabled = false
local flyEnabled = false
local safetyZoneEnabled = false
local godModeEnabled = false
local antiDetectEnabled = false
local antiKickEnabled = false
local autoFarm0msEnabled = false
local autoLikerEnabled = false
local protectNameEnabled = false
local securityMonitorEnabled = false
local hideCursorEnabled = false
local afkInVisitEnabled = false

local devUnlocked = false
local success, savedData = pcall(function()
    return readfile("ANTCHUB/dev_unlock.txt")
end)
if success and savedData == "UNLOCKED" then
    devUnlocked = true
end

local autoFarmConnection = nil
local antiAFKConnection = nil
local antiAdminConnection = nil
local antiTrollConnection = nil
local flyConnection = nil
local safetyZoneConnection = nil
local godModeConnection = nil
local antiKickConnection = nil
local autoFarm0msConnection = nil
local autoLikerConnection = nil
local securityMonitorConnection = nil
local antiDetectConnection = nil
local rgbNameConnection = nil
local nameBillboard = nil

local initialPosition = nil
local savedPositions = {}
local currentCategory = "Default"
local walkSpeed = 16
local selectedPlayer = nil
local currentSound = nil
local boomboxID = ""
local originalName = LocalPlayer.Name
local cursorGui = nil
local cursorHideCount = 0

local userStatus = "Free"

local HUB_LOGO = "https://cdn.discordapp.com/attachments/1425521853467856906/1425920720629797057/Black_White_Simple_Fashion_Promotion_Banner_20251009_223549_0000.png"

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled

local function hideMouse(hide)
    if hide then
        cursorHideCount = cursorHideCount + 1
        if cursorHideCount == 1 then
            if not cursorGui then
                cursorGui = Instance.new("ScreenGui")
                cursorGui.Name = "CursorHider"
                cursorGui.ResetOnSpawn = false
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.Parent = cursorGui
                
                cursorGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            end
            UserInputService.MouseIconEnabled = false
        end
    else
        cursorHideCount = math.max(0, cursorHideCount - 1)
        if cursorHideCount == 0 then
            if cursorGui then
                cursorGui:Destroy()
                cursorGui = nil
            end
            UserInputService.MouseIconEnabled = true
        end
    end
end

local function flyControls()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    
    local speed = 50
    local verticalInput = 0
    local jumpConnection = nil
    
    if isMobile and humanoid then
        jumpConnection = humanoid.Jumping:Connect(function()
            if flyEnabled then
                verticalInput = 1
                task.wait(0.3)
                verticalInput = 0
            end
        end)
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlyControls"
        gui.ResetOnSpawn = false
        
        local downButton = Instance.new("TextButton")
        downButton.Size = UDim2.new(0, 80, 0, 80)
        downButton.Position = UDim2.new(0.9, 0, 0.7, 0)
        downButton.Text = "↓"
        downButton.TextSize = 40
        downButton.TextColor3 = Color3.new(1, 1, 1)
        downButton.BackgroundColor3 = Color3.fromHex("#ff4444")
        downButton.BackgroundTransparency = 0.3
        downButton.Parent = gui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = downButton
        
        downButton.MouseButton1Down:Connect(function()
            verticalInput = -1
        end)
        
        downButton.MouseButton1Up:Connect(function()
            verticalInput = 0
        end)
        
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then
            bg:Destroy()
            bv:Destroy()
            if jumpConnection then jumpConnection:Disconnect() end
            if humanoid then humanoid.PlatformStand = false end
            
            local gui = LocalPlayer.PlayerGui:FindFirstChild("FlyControls")
            if gui then gui:Destroy() end
            return
        end
        
        if humanoid then humanoid.PlatformStand = true end
        
        local cam = workspace.CurrentCamera
        bg.CFrame = cam.CFrame
        
        local moveVector = Vector3.new(0, 0, 0)
        
        if isPC then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + (cam.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - (cam.CFrame.LookVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - (cam.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + (cam.CFrame.RightVector * speed)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, speed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, speed, 0)
            end
        elseif isMobile then
            local moveThumbstick = humanoid.MoveDirection
            if moveThumbstick.Magnitude > 0 then
                local forward = (cam.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
                local right = (cam.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit
                moveVector = moveVector + (forward * moveThumbstick.Z * speed)
                moveVector = moveVector + (right * moveThumbstick.X * speed)
            end
            
            moveVector = moveVector + Vector3.new(0, verticalInput * speed, 0)
        end
        
        bv.Velocity = moveVector
    end)
end

local function playMusic(soundId)
    if currentSound then
        pcall(function()
            currentSound:Stop()
            currentSound:Destroy()
        end)
        currentSound = nil
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://135774953997104" .. soundId
    sound.Volume = 0.5
    sound.Looped = true
    sound.Parent = workspace
    
    local success, err = pcall(function()
        sound.Loaded:Wait()
        sound:Play()
    end)
    
    if success and sound.IsPlaying then
        currentSound = sound
        return true
    else
        local fallbackSuccess = pcall(function()
            sound:Play()
        end)
        if fallbackSuccess then
            currentSound = sound
            return true
        else
            sound:Destroy()
            return false
        end
    end
end

WindUI:Popup({
    Title = "Welcome to .ANTC HUB",
    Icon = "star",
    Content = "Hi " .. LocalPlayer.Name .. "! Selamat datang di premium script.",
    Buttons = {
        {
            Title = "Start",
            Icon = "check",
        }
    }
})

local Window = WindUI:CreateWindow({
    Title = "ANTC HUB",
    Author = "Hi " .. LocalPlayer.Name,
    Folder = "ANTCHUB",
    NewElements = true,
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open ANTC HUB",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    }
})

Window:Tag({
    Title = "v" .. WindUI.Version,
    Icon = "github",
    Color = Color3.fromHex("#6b31ff")
})

task.spawn(function()
    WindUI:Notify({
        Title = "Music Loading",
        Content = "Tunggu 5 detik sebelum auto-play music...",
        Icon = "clock",
    })
    
    task.wait(5)
    
    local musicID = "135774953997104"
    local success = playMusic(musicID)
    
    if success then
        WindUI:Notify({
            Title = "Music Player",
            Content = "Auto-play music started! Enjoy!",
            Icon = "music",
        })
    else
        WindUI:Notify({
            Title = "Music Player",
            Content = "Failed to play music. ID might be invalid.",
            Icon = "volume-x",
        })
    end
end)

local AboutScriptTab = Window:Tab({
    Title = "About Script",
    Icon = "info",
})

AboutScriptTab:Image({
    Image = "https://raw.githubusercontent.com/APISje/antchubv/main/Black_White_Simple_Fashion_Promotion_Banner_20251009_223549_0000.png",
    AspectRatio = "16:9",
    Radius = 9,
})

AboutScriptTab:Space({ Columns = 3 })

AboutScriptTab:Section({
    Title = ".ANTC HUB - Advanced Premium Script",
    TextSize = 24,
    FontWeight = Enum.FontWeight.Bold,
    Icon = "star",
})

AboutScriptTab:Space()

AboutScriptTab:Section({
    Title = [[Script premium dengan fitur-fitur canggih untuk meningkatkan pengalaman bermain Anda.

📱 SUPPORT DEVICE: PC & MOBILE
- PC: Control dengan WASD, Space, Shift
- Mobile: Control dengan Analog touchscreen & tombol on-screen

⚡ FITUR AUTO FARMING:
- Auto Farming 1ms dengan cursor tersembunyi
- Auto Farming 0ms (Premium) - kecepatan maksimal
- Force Stop untuk emergency shutdown

🛡️ FITUR PROTECTION:
- Anti AFK untuk mencegah kick
- Anti Admin dengan auto server hop
- Anti Troll perlindungan posisi
- Protect Name - sembunyikan nama asli
- Security Monitor - deteksi mass ban & bandwidth

🚀 FITUR MOVEMENT:
- Fly Mode (PC & Mobile support)
- Unlimited Jump
- Speed Control unlimited
- Position Lock & Save System

💎 PREMIUM DEVELOPER FEATURES:
- Safety Zone dengan Force Field
- God Mode - invincible
- Anti Detect & Anti Kick
- Auto Liker - ProximityPrompt automation
- Position Tracker dengan koordinat real-time

🎵 EXTRA FEATURES:
- Spotify Music Player
- Teleportasi dengan kategori save
- ESP dan Visual Features (Coming Soon)

Dibuat untuk performa terbaik.
Support PC & Mobile - Cursor management - Reference counting system]],
    TextSize = 14,
    TextTransparency = 0.2,
    FontWeight = Enum.FontWeight.Medium,
    Icon = "file-text",
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

MainTab:Image({
    Image = "https://cdn.discordapp.com/attachments/1425521853467856906/1425920720629797057/Black_White_Simple_Fashion_Promotion_Banner_20251009_223549_0000.png",
    AspectRatio = "16:9",
    Radius = 9,
})

MainTab:Space({ Columns = 3 })

MainTab:Section({
    Title = "Auto Farming",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "zap",
})

MainTab:Space()

MainTab:Toggle({
    Title = "Auto Farming",
    Desc = "Auto kliker layar dengan kecepatan 1ms - cursor tersembunyi tapi tetap fungsional",
    Icon = "mouse-pointer-click",
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        
        if autoFarmEnabled then
            if autoFarmConnection then 
                autoFarmConnection:Disconnect() 
            end
            
            hideMouse(true)
            
            autoFarmConnection = RunService.Heartbeat:Connect(function()
                if autoFarmEnabled then
                    local camera = workspace.CurrentCamera
                    local viewportSize = camera.ViewportSize
                    local centerX = viewportSize.X / 2
                    local centerY = viewportSize.Y / 2
                    
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                end
            end)
            
            WindUI:Notify({
                Title = "Auto Farming",
                Content = "Auto Farming AKTIF - Cursor disembunyikan, auto kliker berjalan 1ms",
                Icon = "check-circle",
                Image = HUB_LOGO,
            })
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            
            hideMouse(false)
            
            WindUI:Notify({
                Title = "Auto Farming",
                Content = "Auto Farming NONAKTIF - Cursor kembali normal",
                Icon = "x-circle",
                Image = HUB_LOGO,
            })
        end
    end
})

MainTab:Space()

MainTab:Button({
    Title = "Force Stop Auto Farming",
    Desc = "Matikan auto farming secara paksa dan restore cursor",
    Icon = "shield-off",
    Color = Color3.fromHex("#ff0000"),
    Callback = function()
        autoFarmEnabled = false
        autoFarm0msEnabled = false
        
        if autoFarmConnection then
            autoFarmConnection:Disconnect()
            autoFarmConnection = nil
        end
        
        if autoFarm0msConnection then
            autoFarm0msConnection:Disconnect()
            autoFarm0msConnection = nil
        end
        
        cursorHideCount = 0
        if cursorGui then
            cursorGui:Destroy()
            cursorGui = nil
        end
        UserInputService.MouseIconEnabled = true
        
        WindUI:Notify({
            Title = "Force Stop",
            Content = "Auto Farming / Auto Kliker dihentikan secara PAKSA! Cursor restored.",
            Icon = "shield-alert",
            Image = HUB_LOGO,
        })
    end
})

MainTab:Space({ Columns = 2 })

MainTab:Section({
    Title = "Protection Features",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "shield",
})

MainTab:Space()

MainTab:Toggle({
    Title = "Anti AFK",
    Desc = "Mencegah kick karena AFK",
    Icon = "shield",
    Default = false,
    Callback = function(state)
        antiAFKEnabled = state
        
        if antiAFKEnabled then
            if antiAFKConnection then 
                antiAFKConnection:Disconnect() 
            end
            
            antiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            
            WindUI:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK AKTIF - Anda tidak akan di-kick",
                Icon = "shield-check",
            })
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            
            WindUI:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK NONAKTIF",
                Icon = "shield-off",
            })
        end
    end
})

MainTab:Space()

MainTab:Toggle({
    Title = "Anti Admin",
    Desc = "Auto server hop jika admin masuk, posisi awal tetap",
    Icon = "user-x",
    Default = false,
    Callback = function(state)
        antiAdminEnabled = state
        
        if antiAdminEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                initialPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            
            if antiAdminConnection then 
                antiAdminConnection:Disconnect() 
            end
            
            antiAdminConnection = Players.PlayerAdded:Connect(function(player)
                if antiAdminEnabled then
                    local name = player.Name:lower()
                    
                    if name:find("admin") or name:find("mod") or name:find("owner") or name:find("developer") then
                        WindUI:Notify({
                            Title = "Anti Admin",
                            Content = "ADMIN DETECTED: " .. player.Name .. " - Server hopping...",
                            Icon = "alert-triangle",
                        })
                        
                        task.wait(0.5)
                        
                        if initialPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = initialPosition
                        end
                        
                        task.wait(0.5)
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "Anti Admin",
                Content = "Anti Admin AKTIF - Posisi awal tersimpan",
                Icon = "shield-check",
            })
        else
            if antiAdminConnection then
                antiAdminConnection:Disconnect()
                antiAdminConnection = nil
            end
            
            WindUI:Notify({
                Title = "Anti Admin",
                Content = "Anti Admin NONAKTIF",
                Icon = "shield-off",
            })
        end
    end
})

MainTab:Space()

MainTab:Toggle({
    Title = "Anti Troll",
    Desc = "Otomatis kembali ke posisi awal jika badan karakter tergeser",
    Icon = "rotate-ccw",
    Default = false,
    Callback = function(state)
        antiTrollEnabled = state
        
        if antiTrollEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                initialPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            
            if antiTrollConnection then 
                antiTrollConnection:Disconnect() 
            end
            
            antiTrollConnection = RunService.Heartbeat:Connect(function()
                if antiTrollEnabled and initialPosition then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                        local distance = (currentPos.Position - initialPosition.Position).Magnitude
                        
                        if distance > 3 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = initialPosition
                        end
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "Anti Troll",
                Content = "Anti Troll AKTIF - Posisi terkunci",
                Icon = "lock",
            })
        else
            if antiTrollConnection then
                antiTrollConnection:Disconnect()
                antiTrollConnection = nil
            end
            
            WindUI:Notify({
                Title = "Anti Troll",
                Content = "Anti Troll NONAKTIF",
                Icon = "unlock",
            })
        end
    end
})

MainTab:Space({ Columns = 3 })

MainTab:Section({
    Title = "AFK Mode",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "coffee",
})

MainTab:Space()

MainTab:Toggle({
    Title = "AFK in Visit",
    Desc = "Auto-enable: Auto Clicker 0ms + Protect Name RGB + Anti AFK + Anti Troll",
    Icon = "coffee",
    Default = false,
    Callback = function(state)
        afkInVisitEnabled = state
        
        if afkInVisitEnabled then
            autoFarm0msEnabled = true
            protectNameEnabled = true
            antiAFKEnabled = true
            antiTrollEnabled = true
            
            if autoFarm0msConnection then
                autoFarm0msConnection:Disconnect()
            end
            hideMouse(true)
            autoFarm0msConnection = RunService.RenderStepped:Connect(function()
                if autoFarm0msEnabled then
                    local camera = workspace.CurrentCamera
                    local viewportSize = camera.ViewportSize
                    local centerX = viewportSize.X / 2
                    local centerY = viewportSize.Y / 2
                    
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                end
            end)
            
            local fakeName = "ANTC HUB"
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldIndex = mt.__index
            mt.__index = newcclosure(function(self, key)
                if key == "Name" or key == "DisplayName" then
                    if self == LocalPlayer then
                        return fakeName
                    end
                end
                return oldIndex(self, key)
            end)
            setreadonly(mt, true)
            
            local function createRGBNameTag()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    if LocalPlayer.Character.Head:FindFirstChild("RGBNameTag") then
                        LocalPlayer.Character.Head:FindFirstChild("RGBNameTag"):Destroy()
                    end
                    
                    nameBillboard = Instance.new("BillboardGui")
                    nameBillboard.Name = "RGBNameTag"
                    nameBillboard.Size = UDim2.new(0, 200, 0, 50)
                    nameBillboard.StudsOffset = Vector3.new(0, 2, 0)
                    nameBillboard.AlwaysOnTop = true
                    nameBillboard.Parent = LocalPlayer.Character.Head
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = "ANTC HUB"
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 18
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.Parent = nameBillboard
                    
                    local hue = 0
                    if rgbNameConnection then
                        rgbNameConnection:Disconnect()
                    end
                    
                    rgbNameConnection = RunService.RenderStepped:Connect(function()
                        if protectNameEnabled and nameLabel then
                            hue = (hue + 0.01) % 1
                            nameLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        end
                    end)
                end
            end
            
            createRGBNameTag()
            
            LocalPlayer.CharacterAdded:Connect(function()
                if protectNameEnabled then
                    task.wait(0.5)
                    createRGBNameTag()
                end
            end)
            
            if antiAFKConnection then 
                antiAFKConnection:Disconnect() 
            end
            antiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                initialPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
            
            if antiTrollConnection then 
                antiTrollConnection:Disconnect() 
            end
            antiTrollConnection = RunService.Heartbeat:Connect(function()
                if antiTrollEnabled and initialPosition then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local currentPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                        local distance = (currentPos.Position - initialPosition.Position).Magnitude
                        
                        if distance > 3 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = initialPosition
                        end
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "AFK in Visit",
                Content = "AFK MODE AKTIF!\n✓ Auto Clicker 0ms\n✓ Protect Name RGB: ANTC HUB\n✓ Anti AFK\n✓ Anti Troll",
                Icon = "coffee",
                Image = HUB_LOGO,
            })
        else
            autoFarm0msEnabled = false
            protectNameEnabled = false
            antiAFKEnabled = false
            antiTrollEnabled = false
            
            if autoFarm0msConnection then
                autoFarm0msConnection:Disconnect()
                autoFarm0msConnection = nil
            end
            hideMouse(false)
            
            if rgbNameConnection then
                rgbNameConnection:Disconnect()
                rgbNameConnection = nil
            end
            
            if nameBillboard then
                nameBillboard:Destroy()
                nameBillboard = nil
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                local existingTag = LocalPlayer.Character.Head:FindFirstChild("RGBNameTag")
                if existingTag then
                    existingTag:Destroy()
                end
            end
            
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__index = nil
            setreadonly(mt, true)
            
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            
            if antiTrollConnection then
                antiTrollConnection:Disconnect()
                antiTrollConnection = nil
            end
            
            WindUI:Notify({
                Title = "AFK in Visit",
                Content = "AFK MODE NONAKTIF - Semua fitur dimatikan",
                Icon = "x-circle",
                Image = HUB_LOGO,
            })
        end
    end
})

MainTab:Space({ Columns = 2 })

MainTab:Section({
    Title = "Visual & Movement Features",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "eye",
})

MainTab:Space()

MainTab:Toggle({
    Title = "Fly",
    Desc = "Enable fly mode",
    Icon = "plane",
    Locked = true,
})

MainTab:Space()

MainTab:Toggle({
    Title = "ESP Name",
    Desc = "Show player names through walls",
    Icon = "eye",
    Locked = true,
})

MainTab:Space()

MainTab:Toggle({
    Title = "ESP Body RGB",
    Desc = "RGB body ESP untuk player",
    Icon = "palette",
    Locked = true,
})

MainTab:Space()

MainTab:Toggle({
    Title = "God Mode",
    Desc = "PREMIUM USER ONLY - Unlock di menu Development",
    Icon = "crown",
    Locked = true,
})

MainTab:Space({ Columns = 2 })

MainTab:Section({
    Title = "Movement Settings",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "move",
})

MainTab:Space()

MainTab:Toggle({
    Title = "Unlimited Jump",
    Desc = "Jump tanpa batas",
    Icon = "arrow-up",
    Default = false,
    Callback = function(state)
        unlimitedJumpEnabled = state
        
        if unlimitedJumpEnabled then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 120
                LocalPlayer.Character.Humanoid.UseJumpPower = true
            end
            
            WindUI:Notify({
                Title = "Unlimited Jump",
                Content = "Unlimited Jump AKTIF",
                Icon = "arrow-up-circle",
            })
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = 50
            end
            
            WindUI:Notify({
                Title = "Unlimited Jump",
                Content = "Unlimited Jump NONAKTIF",
                Icon = "arrow-down-circle",
            })
        end
    end
})

MainTab:Space({ Columns = 2 })

MainTab:Section({
    Title = "Walk Speed Control",
    TextSize = 16,
    Icon = "gauge",
})

MainTab:Space()

MainTab:Slider({
    Title = "Walk Speed",
    Desc = "Atur kecepatan berjalan pakai garis seperti volume",
    Step = 1,
    Value = {
        Min = 16,
        Max = 500,
        Default = 16,
    },
    Callback = function(value)
        walkSpeed = value
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
        end
    end
})

MainTab:Space()

MainTab:Button({
    Title = "Reset Speed",
    Desc = "Reset kecepatan ke normal (16)",
    Icon = "refresh-ccw",
    Color = Color3.fromHex("#ff9500"),
    Callback = function()
        walkSpeed = 16
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        
        WindUI:Notify({
            Title = "Walk Speed",
            Content = "Speed direset ke default (16)",
            Icon = "check",
        })
    end
})

local TeleportTab = Window:Tab({
    Title = "Teleportation",
    Icon = "map-pin",
})

TeleportTab:Section({
    Title = "Teleport to Player",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "users",
})

TeleportTab:Space()

local function updatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

TeleportTab:Dropdown({
    Title = "Select Player",
    Desc = "Pilih player dari category list",
    Values = updatePlayerList(),
    Callback = function(value)
        selectedPlayer = value
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Teleport to Player",
    Desc = "Klik tombol mouse untuk teleport",
    Icon = "mouse-pointer",
    Color = Color3.fromHex("#00d4ff"),
    Justify = "Center",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                    
                    WindUI:Notify({
                        Title = "Teleport Success",
                        Content = "Teleported ke: " .. selectedPlayer,
                        Icon = "check",
                    })
                end
            else
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = "Player tidak ditemukan atau tidak ada character",
                    Icon = "x",
                })
            end
        else
            WindUI:Notify({
                Title = "Teleport Failed",
                Content = "Pilih player terlebih dahulu",
                Icon = "alert-circle",
            })
        end
    end
})

TeleportTab:Space({ Columns = 2 })

TeleportTab:Section({
    Title = "Lock Position",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "lock",
})

TeleportTab:Space()

TeleportTab:Toggle({
    Title = "Lock Position",
    Desc = "Kunci posisi saat ini",
    Icon = "lock",
    Default = false,
    Callback = function(state)
        if state then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                initialPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
                
                WindUI:Notify({
                    Title = "Position Locked",
                    Content = "Posisi saat ini terkunci",
                    Icon = "lock",
                })
            end
        else
            initialPosition = nil
            
            WindUI:Notify({
                Title = "Position Unlocked",
                Content = "Posisi tidak terkunci",
                Icon = "unlock",
            })
        end
    end
})

TeleportTab:Space({ Columns = 2 })

TeleportTab:Section({
    Title = "Save Position System",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "bookmark",
})

TeleportTab:Space()

local positionName = "MyPosition"

TeleportTab:Input({
    Title = "Position Name",
    Desc = "Nama untuk save posisi",
    Placeholder = "Masukkan nama posisi...",
    Value = "MyPosition",
    Icon = "edit",
    Callback = function(value)
        positionName = value
    end
})

TeleportTab:Space()

TeleportTab:Dropdown({
    Title = "Category",
    Desc = "Pilih category untuk save posisi",
    Values = {"Default", "Farming", "Grinding", "Secret", "Custom"},
    Value = "Default",
    Callback = function(value)
        currentCategory = value
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Save Position",
    Desc = "Simpan posisi saat ini",
    Icon = "bookmark-plus",
    Color = Color3.fromHex("#30ff6a"),
    Justify = "Center",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not savedPositions[currentCategory] then
                savedPositions[currentCategory] = {}
            end
            
            savedPositions[currentCategory][positionName] = LocalPlayer.Character.HumanoidRootPart.CFrame
            
            if currentCategory == selectedTeleportCategory then
                updatePositionDropdown()
            end
            
            WindUI:Notify({
                Title = "Position Saved",
                Content = "Posisi '" .. positionName .. "' tersimpan di category: " .. currentCategory,
                Icon = "bookmark-check",
            })
        else
            WindUI:Notify({
                Title = "Save Failed",
                Content = "Character tidak ditemukan",
                Icon = "alert-circle",
            })
        end
    end
})

TeleportTab:Space({ Columns = 2 })

TeleportTab:Section({
    Title = "Category List Save Position",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "folder",
})

TeleportTab:Space()

local selectedTeleportCategory = "Default"
local selectedTeleportPosition = nil
local positionDropdownRef = nil

local function getPositionsInCategory(category)
    local positions = {}
    if savedPositions[category] then
        for name, _ in pairs(savedPositions[category]) do
            table.insert(positions, name)
        end
    end
    return #positions > 0 and positions or {"Tidak ada posisi"}
end

local function updatePositionDropdown()
    if positionDropdownRef then
        local newPositions = getPositionsInCategory(selectedTeleportCategory)
        positionDropdownRef:SetValues(newPositions)
        selectedTeleportPosition = nil
    end
end

TeleportTab:Dropdown({
    Title = "Select Category",
    Desc = "Pilih category untuk teleport",
    Values = {"Default", "Farming", "Grinding", "Secret", "Custom"},
    Value = "Default",
    Callback = function(value)
        selectedTeleportCategory = value
        updatePositionDropdown()
    end
})

TeleportTab:Space()

positionDropdownRef = TeleportTab:Dropdown({
    Title = "Select Position",
    Desc = "Pilih posisi yang sudah disave",
    Values = getPositionsInCategory(selectedTeleportCategory),
    Callback = function(value)
        if value ~= "Tidak ada posisi" then
            selectedTeleportPosition = value
        else
            selectedTeleportPosition = nil
        end
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "Teleport to Saved Position",
    Desc = "Teleport ke posisi yang dipilih",
    Icon = "navigation",
    Color = Color3.fromHex("#00d4ff"),
    Justify = "Center",
    Callback = function()
        if selectedTeleportPosition and selectedTeleportPosition ~= "Tidak ada posisi" then
            if savedPositions[selectedTeleportCategory] and savedPositions[selectedTeleportCategory][selectedTeleportPosition] then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = savedPositions[selectedTeleportCategory][selectedTeleportPosition]
                    
                    WindUI:Notify({
                        Title = "Teleport Success",
                        Content = "Teleported ke: " .. selectedTeleportPosition .. " (Category: " .. selectedTeleportCategory .. ")",
                        Icon = "check-circle",
                    })
                else
                    WindUI:Notify({
                        Title = "Teleport Failed",
                        Content = "Character tidak ditemukan",
                        Icon = "alert-circle",
                    })
                end
            else
                WindUI:Notify({
                    Title = "Teleport Failed",
                    Content = "Posisi tidak ditemukan di category ini",
                    Icon = "x-circle",
                })
            end
        else
            WindUI:Notify({
                Title = "Teleport Failed",
                Content = "Pilih posisi terlebih dahulu atau save posisi baru",
                Icon = "alert-circle",
            })
        end
    end
})

TeleportTab:Space()

TeleportTab:Button({
    Title = "View Saved Positions",
    Desc = "Lihat semua posisi yang tersimpan",
    Icon = "folder-open",
    Color = Color3.fromHex("#ffaa00"),
    Justify = "Center",
    Callback = function()
        local positionList = "SAVED POSITIONS:\n\n"
        local hasPositions = false
        
        for category, positions in pairs(savedPositions) do
            positionList = positionList .. "Category: " .. category .. "\n"
            
            for name, cframe in pairs(positions) do
                positionList = positionList .. "  - " .. name .. "\n"
                hasPositions = true
            end
            
            positionList = positionList .. "\n"
        end
        
        if not hasPositions then
            positionList = "Belum ada posisi yang tersimpan.\nSave posisi untuk mulai menggunakan fitur ini."
        end
        
        WindUI:Notify({
            Title = "Saved Positions",
            Content = positionList,
            Icon = "folder",
        })
    end
})

local SpotifyTab = Window:Tab({
    Title = "Spotify",
    Icon = "music",
})

SpotifyTab:Section({
    Title = "Music Player Control",
    TextSize = 20,
    FontWeight = Enum.FontWeight.Bold,
    Icon = "music",
})

SpotifyTab:Space({ Columns = 2 })

SpotifyTab:Section({
    Title = "Masukkan ID boombox untuk memutar musik.\nKontrol musik dengan tombol Play, Stop, dan Skip.",
    TextSize = 14,
    TextTransparency = 0.2,
    Icon = "info",
})

SpotifyTab:Space({ Columns = 2 })

SpotifyTab:Input({
    Title = "Boombox ID",
    Desc = "Masukkan ID musik/boombox",
    Placeholder = "Contoh: 1234567890",
    Icon = "hash",
    Callback = function(value)
        boomboxID = value
    end
})

SpotifyTab:Space({ Columns = 2 })

SpotifyTab:Button({
    Title = "Play",
    Desc = "Putar musik dengan ID yang dimasukkan",
    Icon = "play",
    Color = Color3.fromHex("#30ff6a"),
    Justify = "Center",
    Callback = function()
        if boomboxID == "" or boomboxID == nil then
            WindUI:Notify({
                Title = "Music Player",
                Content = "Masukkan ID boombox terlebih dahulu!",
                Icon = "alert-circle",
            })
            return
        end
        
        local success = playMusic(boomboxID)
        
        if success then
            WindUI:Notify({
                Title = "Music Player",
                Content = "Musik sedang diputar! ID: " .. boomboxID,
                Icon = "music",
            })
        else
            WindUI:Notify({
                Title = "Music Player",
                Content = "Musik tidak support atau ID salah! Coba ID lain.",
                Icon = "volume-x",
            })
        end
    end
})

SpotifyTab:Space()

SpotifyTab:Button({
    Title = "Stop",
    Desc = "Hentikan musik yang sedang diputar",
    Icon = "square",
    Color = Color3.fromHex("#ff4830"),
    Justify = "Center",
    Callback = function()
        if currentSound then
            currentSound:Stop()
            currentSound:Destroy()
            currentSound = nil
            
            WindUI:Notify({
                Title = "Music Player",
                Content = "Musik dihentikan!",
                Icon = "square",
            })
        else
            WindUI:Notify({
                Title = "Music Player",
                Content = "Tidak ada musik yang sedang diputar!",
                Icon = "info",
            })
        end
    end
})

SpotifyTab:Space()

SpotifyTab:Button({
    Title = "Skip",
    Desc = "Skip ke musik berikutnya (stop current)",
    Icon = "skip-forward",
    Color = Color3.fromHex("#ffaa00"),
    Justify = "Center",
    Callback = function()
        if currentSound then
            currentSound:Stop()
            currentSound:Destroy()
            currentSound = nil
            
            WindUI:Notify({
                Title = "Music Player",
                Content = "Musik di-skip! Masukkan ID baru untuk play.",
                Icon = "skip-forward",
            })
        else
            WindUI:Notify({
                Title = "Music Player",
                Content = "Tidak ada musik yang sedang diputar!",
                Icon = "info",
            })
        end
    end
})

local DevelopmentTab = Window:Tab({
    Title = "Development",
    Icon = "code",
})

if devUnlocked then
    DevelopmentTab:Section({
        Title = "Premium Features Unlocked",
        TextSize = 24,
        FontWeight = Enum.FontWeight.Bold,
        Icon = "unlock",
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Section({
        Title = "Selamat! Anda telah membuka akses ke fitur premium. Gunakan dengan bijak!",
        TextSize = 14,
        TextTransparency = 0.2,
        Icon = "check-circle",
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Toggle({
        Title = "Safety Zone",
        Desc = "Zona aman dari bahaya dan damage - Force Field aktif",
        Icon = "shield-check",
        Default = false,
        Callback = function(state)
            safetyZoneEnabled = state
            
            if safetyZoneEnabled then
                if safetyZoneConnection then
                    safetyZoneConnection:Disconnect()
                end
                
                safetyZoneConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character then
                        local ff = LocalPlayer.Character:FindFirstChildOfClass("ForceField")
                        if not ff then
                            local newFF = Instance.new("ForceField")
                            newFF.Visible = true
                            newFF.Parent = LocalPlayer.Character
                        end
                        
                        if LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                        end
                    end
                end)
                
                WindUI:Notify({
                    Title = "Safety Zone",
                    Content = "Safety Zone AKTIF - Force Field dan auto heal aktif!",
                    Icon = "shield",
                    Image = HUB_LOGO,
                })
            else
                if safetyZoneConnection then
                    safetyZoneConnection:Disconnect()
                    safetyZoneConnection = nil
                end
                
                if LocalPlayer.Character then
                    local ff = LocalPlayer.Character:FindFirstChildOfClass("ForceField")
                    if ff then ff:Destroy() end
                end
                
                WindUI:Notify({
                    Title = "Safety Zone",
                    Content = "Safety Zone NONAKTIF",
                    Icon = "shield-off",
                    Image = HUB_LOGO,
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "God Mode",
        Desc = "Invincible mode - tidak bisa mati",
        Icon = "crown",
        Default = false,
        Callback = function(state)
            if state then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.MaxHealth = math.huge
                    LocalPlayer.Character.Humanoid.Health = math.huge
                end
                
                WindUI:Notify({
                    Title = "God Mode",
                    Content = "God Mode AKTIF - Anda invincible",
                    Icon = "zap",
                })
            else
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.MaxHealth = 100
                    LocalPlayer.Character.Humanoid.Health = 100
                end
                
                WindUI:Notify({
                    Title = "God Mode",
                    Content = "God Mode NONAKTIF",
                    Icon = "x",
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "Fly (PC & Mobile)",
        Desc = "Fly mode untuk PC (WASD+Space) dan Mobile (Analog+Jump)",
        Icon = "plane",
        Default = false,
        Callback = function(state)
            flyEnabled = state
            
            if flyEnabled then
                flyControls()
                
                local controlInfo = isMobile and "Mobile (Analog + Jump)" or "PC (WASD + Space/Shift)"
                WindUI:Notify({
                    Title = "Fly Mode",
                    Content = "Fly mode AKTIF untuk " .. controlInfo,
                    Icon = "plane",
                    Image = HUB_LOGO,
                })
            else
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
                
                WindUI:Notify({
                    Title = "Fly Mode",
                    Content = "Fly mode NONAKTIF",
                    Icon = "x",
                    Image = HUB_LOGO,
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "Anti Detect",
        Desc = "Hindari deteksi dengan menyembunyikan connection tracking",
        Icon = "eye-off",
        Default = false,
        Callback = function(state)
            antiDetectEnabled = state
            
            if antiDetectEnabled then
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                setreadonly(mt, false)
                
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" then
                        return
                    end
                    return oldNamecall(self, ...)
                end)
                
                setreadonly(mt, true)
                antiDetectConnection = true
                
                WindUI:Notify({
                    Title = "Anti Detect",
                    Content = "Anti Detect AKTIF - Namecall protection enabled",
                    Icon = "shield",
                    Image = HUB_LOGO,
                })
            else
                if antiDetectConnection then
                    antiDetectConnection = nil
                end
                
                WindUI:Notify({
                    Title = "Anti Detect",
                    Content = "Anti Detect NONAKTIF",
                    Icon = "eye",
                    Image = HUB_LOGO,
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "Anti Kick",
        Desc = "Mencegah kick dari server - Hook kick events",
        Icon = "shield-alert",
        Default = false,
        Callback = function(state)
            antiKickEnabled = state
            
            if antiKickEnabled then
                if antiKickConnection then
                    antiKickConnection:Disconnect()
                end
                
                local oldKick
                oldKick = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" then
                        WindUI:Notify({
                            Title = "Anti Kick",
                            Content = "Kick attempt blocked!",
                            Icon = "shield-check",
                            Image = HUB_LOGO,
                        })
                        return
                    end
                    return oldKick(self, ...)
                end)
                
                antiKickConnection = true
                
                WindUI:Notify({
                    Title = "Anti Kick",
                    Content = "Anti Kick AKTIF - Kick protection enabled",
                    Icon = "shield",
                    Image = HUB_LOGO,
                })
            else
                if antiKickConnection then
                    antiKickConnection = nil
                end
                
                WindUI:Notify({
                    Title = "Anti Kick",
                    Content = "Anti Kick NONAKTIF",
                    Icon = "shield-off",
                    Image = HUB_LOGO,
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "Anti AFK Premium",
        Desc = "Versi premium - lebih baik dari free version",
        Icon = "shield-plus",
        Default = false,
        Callback = function(state)
            if state then
                game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)
                
                WindUI:Notify({
                    Title = "Anti AFK Premium",
                    Content = "Anti AFK Premium AKTIF",
                    Icon = "star",
                })
            else
                WindUI:Notify({
                    Title = "Anti AFK Premium",
                    Content = "Anti AFK Premium NONAKTIF",
                    Icon = "star-off",
                })
            end
        end
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Section({
        Title = "Speed Settings Unlimited",
        TextSize = 16,
        Icon = "gauge",
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Slider({
        Title = "Speed Unlimited",
        Desc = "Atur kecepatan hingga unlimited (bisa sampai 1000)",
        Step = 10,
        Value = {
            Min = 16,
            Max = 1000,
            Default = 16,
        },
        Callback = function(value)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
            
            WindUI:Notify({
                Title = "Speed Unlimited",
                Content = "Speed diatur ke: " .. value,
                Icon = "zap",
            })
        end
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Toggle({
        Title = "Auto Farming 0ms",
        Desc = "Auto farming dengan kecepatan maksimal (0ms) - super cepat, cursor disembunyikan",
        Icon = "zap",
        Default = false,
        Callback = function(state)
            autoFarm0msEnabled = state
            
            if autoFarm0msEnabled then
                if autoFarm0msConnection then
                    autoFarm0msConnection:Disconnect()
                end
                
                hideMouse(true)
                
                autoFarm0msConnection = RunService.RenderStepped:Connect(function()
                    if autoFarm0msEnabled then
                        local camera = workspace.CurrentCamera
                        local viewportSize = camera.ViewportSize
                        local centerX = viewportSize.X / 2
                        local centerY = viewportSize.Y / 2
                        
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
                        task.wait()
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
                    end
                end)
                
                WindUI:Notify({
                    Title = "Auto Farming 0ms",
                    Content = "Auto Farming 0ms AKTIF - Kecepatan maksimal! Cursor disembunyikan",
                    Icon = "zap",
                    Image = HUB_LOGO,
                })
            else
                if autoFarm0msConnection then
                    autoFarm0msConnection:Disconnect()
                    autoFarm0msConnection = nil
                end
                
                hideMouse(false)
                
                WindUI:Notify({
                    Title = "Auto Farming 0ms",
                    Content = "Auto Farming 0ms NONAKTIF",
                    Icon = "x",
                    Image = HUB_LOGO,
                })
            end
        end
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Section({
        Title = "Position Tracker - Koordinat Akurat",
        TextSize = 18,
        FontWeight = Enum.FontWeight.SemiBold,
        Icon = "map",
    })
    
    DevelopmentTab:Space()
    
    local positionTrackingEnabled = false
    local positionTrackingConnection = nil
    local currentPositionText = "X: 0, Y: 0, Z: 0"
    
    DevelopmentTab:Section({
        Title = "Tracking posisi real-time in-game/map dengan akurat.\nKoordinat akan terus update saat tracking aktif.",
        TextSize = 14,
        TextTransparency = 0.2,
        Icon = "info",
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Toggle({
        Title = "Track Position Real-Time",
        Desc = "Aktifkan tracking koordinat real-time",
        Icon = "crosshair",
        Default = false,
        Callback = function(state)
            positionTrackingEnabled = state
            
            if positionTrackingEnabled then
                if positionTrackingConnection then
                    positionTrackingConnection:Disconnect()
                end
                
                positionTrackingConnection = RunService.Heartbeat:Connect(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = LocalPlayer.Character.HumanoidRootPart.Position
                        currentPositionText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
                    end
                end)
                
                WindUI:Notify({
                    Title = "Position Tracker",
                    Content = "Position tracking AKTIF - Koordinat terupdate real-time",
                    Icon = "crosshair",
                })
            else
                if positionTrackingConnection then
                    positionTrackingConnection:Disconnect()
                    positionTrackingConnection = nil
                end
                
                WindUI:Notify({
                    Title = "Position Tracker",
                    Content = "Position tracking NONAKTIF",
                    Icon = "x-circle",
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Button({
        Title = "Show Current Position",
        Desc = "Tampilkan koordinat saat ini",
        Icon = "map-pin",
        Color = Color3.fromHex("#00d4ff"),
        Justify = "Center",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                local posText = string.format("X: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
                
                WindUI:Notify({
                    Title = "Current Position",
                    Content = "Koordinat saat ini:\n" .. posText,
                    Icon = "map-pin",
                })
            else
                WindUI:Notify({
                    Title = "Position Error",
                    Content = "Character tidak ditemukan",
                    Icon = "alert-circle",
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Button({
        Title = "Copy Coordinates",
        Desc = "Copy koordinat persis ke clipboard",
        Icon = "copy",
        Color = Color3.fromHex("#30ff6a"),
        Justify = "Center",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                local coordText = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
                
                setclipboard(coordText)
                
                WindUI:Notify({
                    Title = "Coordinates Copied",
                    Content = "Koordinat tersalin: " .. coordText,
                    Icon = "check-circle",
                })
            else
                WindUI:Notify({
                    Title = "Copy Failed",
                    Content = "Character tidak ditemukan",
                    Icon = "alert-circle",
                })
            end
        end
    })
    
    DevelopmentTab:Space()
    
    DevelopmentTab:Button({
        Title = "Copy CFrame",
        Desc = "Copy CFrame lengkap untuk scripting",
        Icon = "code",
        Color = Color3.fromHex("#ff9500"),
        Justify = "Center",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
                local cfText = string.format("CFrame.new(%.2f, %.2f, %.2f)", cf.X, cf.Y, cf.Z)
                
                setclipboard(cfText)
                
                WindUI:Notify({
                    Title = "CFrame Copied",
                    Content = "CFrame tersalin ke clipboard!",
                    Icon = "check-circle",
                })
            else
                WindUI:Notify({
                    Title = "Copy Failed",
                    Content = "Character tidak ditemukan",
                    Icon = "alert-circle",
                })
            end
        end
    })
else
    DevelopmentTab:Section({
        Title = "DEVELOPMENT MENU LOCKED",
        TextSize = 24,
        FontWeight = Enum.FontWeight.Bold,
        Icon = "lock",
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Section({
        Title = "Menu ini khusus untuk PREMIUM USER.\n\nMasukkan kode akses untuk membuka semua fitur premium.\nKode ini RAHASIA dan TIDAK BOLEH DISEBARKAN!",
        TextSize = 14,
        TextTransparency = 0.2,
        FontWeight = Enum.FontWeight.Medium,
        Icon = "alert-triangle",
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Input({
        Title = "Access Code",
        Desc = "Masukkan kode APIS lalu tekan Enter",
        Placeholder = "Ketik kode akses...",
        Icon = "key",
        Callback = function(value)
            if value == "APIS" then
                pcall(function()
                    if not isfolder("ANTCHUB") then
                        makefolder("ANTCHUB")
                    end
                    writefile("ANTCHUB/dev_unlock.txt", "UNLOCKED")
                end)
                
                WindUI:Notify({
                    Title = "ACCESS GRANTED",
                    Content = "Kode benar! Restart UI untuk melihat fitur Development.",
                    Icon = "unlock",
                })
                
                devUnlocked = true
                userStatus = "Development"
                
                task.wait(1)
                
                WindUI:Notify({
                    Title = "Reloading",
                    Content = "UI akan di-reload untuk membuka fitur Development...",
                    Icon = "refresh-cw",
                })
                
                task.wait(2)
                Window:Destroy()
                
                task.wait(0.5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/antchubv/refs/heads/main/main.lua"))()
            else
                WindUI:Notify({
                    Title = "ACCESS DENIED",
                    Content = "Kode salah! Hubungi admin untuk mendapatkan kode.",
                    Icon = "x-circle",
                })
            end
        end
    })
    
    DevelopmentTab:Space({ Columns = 2 })
    
    DevelopmentTab:Section({
        Title = "PENTING:\n- Kode hanya diberikan untuk premium user\n- Jangan bagikan kode ke orang lain\n- Kode dapat berubah sewaktu-waktu",
        TextSize = 12,
        TextTransparency = 0.4,
        Icon = "info",
    })
end

local SecurityTab = Window:Tab({
    Title = "Security & Advanced",
    Icon = "shield",
})

SecurityTab:Image({
    Image = HUB_LOGO,
    AspectRatio = "16:9",
    Radius = 9,
})

SecurityTab:Space({ Columns = 2 })

SecurityTab:Section({
    Title = "Security & Protection Features",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "shield-check",
})

SecurityTab:Space()

SecurityTab:Toggle({
    Title = "Protect Name",
    Desc = "Sembunyikan nama asli dengan 'ANTC HUB' RGB - warna berubah otomatis",
    Icon = "user-check",
    Default = false,
    Callback = function(state)
        protectNameEnabled = state
        
        if protectNameEnabled then
            local fakeName = "ANTC HUB"
            
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldIndex = mt.__index
            
            mt.__index = newcclosure(function(self, key)
                if key == "Name" or key == "DisplayName" then
                    if self == LocalPlayer then
                        return fakeName
                    end
                end
                return oldIndex(self, key)
            end)
            
            setreadonly(mt, true)
            
            local function createRGBNameTag()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    if LocalPlayer.Character.Head:FindFirstChild("RGBNameTag") then
                        LocalPlayer.Character.Head:FindFirstChild("RGBNameTag"):Destroy()
                    end
                    
                    nameBillboard = Instance.new("BillboardGui")
                    nameBillboard.Name = "RGBNameTag"
                    nameBillboard.Size = UDim2.new(0, 200, 0, 50)
                    nameBillboard.StudsOffset = Vector3.new(0, 2, 0)
                    nameBillboard.AlwaysOnTop = true
                    nameBillboard.Parent = LocalPlayer.Character.Head
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = "ANTC HUB"
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.TextSize = 18
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.Parent = nameBillboard
                    
                    local hue = 0
                    if rgbNameConnection then
                        rgbNameConnection:Disconnect()
                    end
                    
                    rgbNameConnection = RunService.RenderStepped:Connect(function()
                        if protectNameEnabled and nameLabel then
                            hue = (hue + 0.01) % 1
                            nameLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        end
                    end)
                end
            end
            
            createRGBNameTag()
            
            LocalPlayer.CharacterAdded:Connect(function()
                if protectNameEnabled then
                    task.wait(0.5)
                    createRGBNameTag()
                end
            end)
            
            WindUI:Notify({
                Title = "Protect Name",
                Content = "Nama Anda dilindungi! Display RGB: ANTC HUB",
                Icon = "user-check",
                Image = HUB_LOGO,
            })
        else
            if rgbNameConnection then
                rgbNameConnection:Disconnect()
                rgbNameConnection = nil
            end
            
            if nameBillboard then
                nameBillboard:Destroy()
                nameBillboard = nil
            end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                local existingTag = LocalPlayer.Character.Head:FindFirstChild("RGBNameTag")
                if existingTag then
                    existingTag:Destroy()
                end
            end
            
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__index = nil
            setreadonly(mt, true)
            
            WindUI:Notify({
                Title = "Protect Name",
                Content = "Protect name NONAKTIF - Nama asli ditampilkan: " .. originalName,
                Icon = "user",
                Image = HUB_LOGO,
            })
        end
    end
})

SecurityTab:Space()

SecurityTab:Toggle({
    Title = "Security Monitor",
    Desc = "Monitor bandwidth & deteksi mass ban - auto server hop jika terdeteksi",
    Icon = "activity",
    Default = false,
    Callback = function(state)
        securityMonitorEnabled = state
        
        if securityMonitorEnabled then
            if securityMonitorConnection then
                securityMonitorConnection:Disconnect()
            end
            
            local joinCount = 0
            local joinTimer = tick()
            local bandwidthWarned = false
            
            securityMonitorConnection = Players.PlayerAdded:Connect(function(player)
                joinCount = joinCount + 1
                
                if tick() - joinTimer < 5 and joinCount > 10 then
                    WindUI:Notify({
                        Title = "⚠️ SECURITY ALERT",
                        Content = "Mass join detected! Possible ban wave. Server hopping...",
                        Icon = "alert-triangle",
                        Image = HUB_LOGO,
                    })
                    
                    task.wait(0.5)
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
                
                if tick() - joinTimer > 10 then
                    joinCount = 0
                    joinTimer = tick()
                end
            end)
            
            task.spawn(function()
                while securityMonitorEnabled do
                    local stats = game:GetService("Stats")
                    if stats then
                        local sent = stats:FindFirstChild("DataSentKbps")
                        local received = stats:FindFirstChild("DataReceivedKbps")
                        
                        if sent and received then
                            local totalBandwidth = sent.Value + received.Value
                            
                            if totalBandwidth > 1000 and not bandwidthWarned then
                                WindUI:Notify({
                                    Title = "⚠️ Bandwidth Alert",
                                    Content = string.format("High bandwidth: %.2f Kbps - Possible monitoring", totalBandwidth),
                                    Icon = "wifi",
                                    Image = HUB_LOGO,
                                })
                                bandwidthWarned = true
                                task.wait(30)
                                bandwidthWarned = false
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
            
            WindUI:Notify({
                Title = "Security Monitor",
                Content = "Security monitoring AKTIF - Mass ban & bandwidth detection enabled",
                Icon = "shield-check",
                Image = HUB_LOGO,
            })
        else
            if securityMonitorConnection then
                securityMonitorConnection:Disconnect()
                securityMonitorConnection = nil
            end
            
            WindUI:Notify({
                Title = "Security Monitor",
                Content = "Security monitoring NONAKTIF",
                Icon = "shield-off",
                Image = HUB_LOGO,
            })
        end
    end
})

SecurityTab:Space({ Columns = 2 })

SecurityTab:Section({
    Title = "Auto Liker - Interaksi Otomatis",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
    Icon = "heart",
})

SecurityTab:Space()

SecurityTab:Toggle({
    Title = "Auto Liker",
    Desc = "Otomatis trigger ProximityPrompt & like game secara berkala",
    Icon = "heart",
    Default = false,
    Callback = function(state)
        autoLikerEnabled = state
        
        if autoLikerEnabled then
            if autoLikerConnection then
                autoLikerConnection:Disconnect()
            end
            
            task.spawn(function()
                pcall(function()
                    local SocialService = game:GetService("SocialService")
                    if SocialService and SocialService.PromptGameInvite then
                        SocialService:PromptGameInvite(LocalPlayer)
                    end
                end)
            end)
            
            autoLikerConnection = RunService.Heartbeat:Connect(function()
                if autoLikerEnabled then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Enabled then
                            pcall(function()
                                if (LocalPlayer.Character.HumanoidRootPart.Position - v.Parent.Position).Magnitude <= v.MaxActivationDistance then
                                    fireproximityprompt(v)
                                end
                            end)
                        end
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "Auto Liker",
                Content = "Auto Liker AKTIF - ProximityPrompt auto-triggered!",
                Icon = "heart",
                Image = HUB_LOGO,
            })
        else
            if autoLikerConnection then
                autoLikerConnection:Disconnect()
                autoLikerConnection = nil
            end
            
            WindUI:Notify({
                Title = "Auto Liker",
                Content = "Auto Liker NONAKTIF",
                Icon = "heart-off",
                Image = HUB_LOGO,
            })
        end
    end
})

SecurityTab:Space()

SecurityTab:Section({
    Title = "CATATAN:\n- Auto Liker akan otomatis trigger semua ProximityPrompt di sekitar\n- Security Monitor mendeteksi mass join & high bandwidth\n- Protect Name menyembunyikan nama asli Anda dari player lain",
    TextSize = 12,
    TextTransparency = 0.4,
    Icon = "info",
})

local DiscordTab = Window:Tab({
    Title = "Discord",
    Icon = "message-circle",
})

local InviteCode = "antchub"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local ok, Response = pcall(function()
    return game:GetService("HttpService"):JSONDecode(WindUI.Creator.Request({
        Url = DiscordAPI,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "WindUI/ANTCHUB",
            ["Accept"] = "application/json"
        }
    }).Body)
end)

if ok and Response and Response.guild then
    DiscordTab:Section({
        Title = "Join our Discord server!",
        TextSize = 20,
        Icon = "users",
    })
    
    DiscordTab:Paragraph({
        Title = tostring(Response.guild.name),
        Desc = tostring(Response.guild.description),
        Image = "https://cdn.discordapp.com/icons/" .. Response.guild.id .. "/" .. Response.guild.icon .. ".png?size=1024",
        Thumbnail = "https://cdn.discordapp.com/attachments/1425521853467856906/1425920720629797057/Black_White_Simple_Fashion_Promotion_Banner_20251009_223549_0000.png?ex=6908fba8&is=6907aa28&hm=6a0d5efa08f6a339ca02b115686bdc0aa0d3c748aa37669b50fc0a8113dd3ddd&",
        ImageSize = 48,
        Buttons = {
            {
                Title = "Copy link",
                Icon = "link",
                Callback = function()
                    setclipboard("https://discord.gg/" .. InviteCode)
                    
                    WindUI:Notify({
                        Title = "Discord",
                        Content = "Discord link copied to clipboard!",
                        Icon = "check-circle",
                    })
                end
            }
        }
    })
else
    DiscordTab:Section({
        Title = "Join our Discord Community",
        TextSize = 24,
        FontWeight = Enum.FontWeight.Bold,
        Icon = "message-circle",
    })
    
    DiscordTab:Space({ Columns = 2 })
    
    DiscordTab:Section({
        Title = "Bergabunglah dengan komunitas kami!\n\nDapatkan:\n- Update script terbaru\n- Support 24/7\n- Tutorial lengkap\n- Premium codes\n- Event & giveaway",
        TextSize = 14,
        TextTransparency = 0.2,
        Icon = "info",
    })
    
    DiscordTab:Space({ Columns = 3 })
    
    DiscordTab:Button({
        Title = "Copy Discord Link",
        Desc = "Klik untuk copy link Discord server",
        Icon = "link",
        Color = Color3.fromHex("#5865F2"),
        Justify = "Center",
        Callback = function()
            setclipboard("https://discord.gg/" .. InviteCode)
            
            WindUI:Notify({
                Title = "Discord",
                Content = "Discord link copied!",
                Icon = "check-circle",
            })
        end
    })
end

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if autoFarmConnection then autoFarmConnection:Disconnect() end
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        if antiAdminConnection then antiAdminConnection:Disconnect() end
        if antiTrollConnection then antiTrollConnection:Disconnect() end
        if currentSound then currentSound:Destroy() end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    if unlimitedJumpEnabled then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.JumpPower = 120
        humanoid.UseJumpPower = true
    end
    
    if walkSpeed ~= 16 then
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = walkSpeed
    end
end)

WindUI:Notify({
    Title = ".ANTC HUB Loaded",
    Content = "Script berhasil dimuat! Hi " .. LocalPlayer.Name .. ", selamat bermain!",
    Icon = "check-circle",
})
