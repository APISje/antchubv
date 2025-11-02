--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                     ANTC HUB LOADER                       ║
    ║              Discord: https://discord.gg/antchub          ║
    ╚═══════════════════════════════════════════════════════════╝
]]

print("🔄 Loading ANTC HUB...")

-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/APISje/antchubv/refs/heads/main/main.lua", true))()

print("✅ ANTC HUB Library Loaded!")

-- Buat Window
local Window = WindUI:CreateWindow({
    Title = "ANTC HUB",
    Icon = "rbxassetid://10723415766",
    Author = "ANTC Team",
    Folder = "ANTCHub_Data",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

print("✅ Window Created!")

-- ==================== FITUR HELPER FUNCTIONS ====================
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables untuk track fitur
local activeConnections = {}
local savedPosition = nil

-- Helper: Cleanup connection
local function cleanupConnection(name)
    if activeConnections[name] then
        activeConnections[name]:Disconnect()
        activeConnections[name] = nil
    end
end

-- ==================== TAB PLAYER ====================
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "rbxassetid://10734950309"
})

local PlayerSection = PlayerTab:Section({
    Title = "Movement"
})

-- WalkSpeed Slider
PlayerSection:Slider({
    Title = "WalkSpeed",
    Description = "Ubah kecepatan jalan",
    Default = 16,
    Min = 16,
    Max = 500,
    Callback = function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- JumpPower Slider
PlayerSection:Slider({
    Title = "JumpPower",
    Description = "Ubah kekuatan lompat",
    Default = 50,
    Min = 50,
    Max = 500,
    Callback = function(value)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.JumpPower = value
        end
    end
})

-- Fly Toggle
PlayerSection:Toggle({
    Title = "Fly",
    Description = "Mode terbang (WASD + Space/Shift)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            local char = Player.Character
            if not char then return end
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = rootPart
            
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.Parent = rootPart
            
            activeConnections.Fly = RunService.Heartbeat:Connect(function()
                local camera = workspace.CurrentCamera
                local moveDirection = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                bodyVelocity.Velocity = moveDirection.Unit * 50
                bodyGyro.CFrame = camera.CFrame
            end)
            
            Window:Notify({
                Title = "Fly Mode",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            cleanupConnection("Fly")
            
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local rootPart = char.HumanoidRootPart
                if rootPart:FindFirstChildOfClass("BodyVelocity") then
                    rootPart:FindFirstChildOfClass("BodyVelocity"):Destroy()
                end
                if rootPart:FindFirstChildOfClass("BodyGyro") then
                    rootPart:FindFirstChildOfClass("BodyGyro"):Destroy()
                end
            end
            
            Window:Notify({
                Title = "Fly Mode",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- Noclip Toggle
PlayerSection:Toggle({
    Title = "Noclip",
    Description = "Tembus tembok",
    Default = false,
    Callback = function(enabled)
        if enabled then
            activeConnections.Noclip = RunService.Stepped:Connect(function()
                local char = Player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
            Window:Notify({
                Title = "Noclip",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            cleanupConnection("Noclip")
            
            local char = Player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
            
            Window:Notify({
                Title = "Noclip",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- Infinite Jump Toggle
PlayerSection:Toggle({
    Title = "Infinite Jump",
    Description = "Lompat tanpa batas",
    Default = false,
    Callback = function(enabled)
        if enabled then
            activeConnections.InfJump = UserInputService.JumpRequest:Connect(function()
                if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                    Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            
            Window:Notify({
                Title = "Infinite Jump",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            cleanupConnection("InfJump")
            
            Window:Notify({
                Title = "Infinite Jump",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- Visual Section
local VisualSection = PlayerTab:Section({
    Title = "Visual"
})

-- ESP Toggle
local espHighlights = {}

VisualSection:Toggle({
    Title = "ESP",
    Description = "Lihat player lewat tembok",
    Default = false,
    Callback = function(enabled)
        if enabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                    espHighlights[player] = highlight
                end
            end
            
            Window:Notify({
                Title = "ESP",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            for _, highlight in pairs(espHighlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            espHighlights = {}
            
            Window:Notify({
                Title = "ESP",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- FullBright Toggle
local oldLighting = {}

VisualSection:Toggle({
    Title = "FullBright",
    Description = "Terang penuh tanpa bayangan",
    Default = false,
    Callback = function(enabled)
        local lighting = game:GetService("Lighting")
        
        if enabled then
            oldLighting.Brightness = lighting.Brightness
            oldLighting.Ambient = lighting.Ambient
            oldLighting.OutdoorAmbient = lighting.OutdoorAmbient
            
            lighting.Brightness = 2
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            
            Window:Notify({
                Title = "FullBright",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            lighting.Brightness = oldLighting.Brightness or 1
            lighting.Ambient = oldLighting.Ambient or Color3.fromRGB(0, 0, 0)
            lighting.OutdoorAmbient = oldLighting.OutdoorAmbient or Color3.fromRGB(0, 0, 0)
            
            Window:Notify({
                Title = "FullBright",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- ==================== TAB COMBAT ====================
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "rbxassetid://10747373176"
})

local CombatSection = CombatTab:Section({
    Title = "God Mode"
})

-- God Mode Toggle
local godModeFF = nil

CombatSection:Toggle({
    Title = "God Mode",
    Description = "HP unlimited (mungkin tidak work di semua game)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if Player.Character then
                godModeFF = Instance.new("ForceField")
                godModeFF.Visible = false
                godModeFF.Parent = Player.Character
                
                local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
            
            Window:Notify({
                Title = "God Mode",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            if godModeFF then
                godModeFF:Destroy()
                godModeFF = nil
            end
            
            local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
            
            Window:Notify({
                Title = "God Mode",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- ==================== TAB TELEPORT ====================
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "rbxassetid://10734896388"
})

local TeleportSection = TeleportTab:Section({
    Title = "Position Manager"
})

-- Save Position Button
TeleportSection:Button({
    Title = "Save Position",
    Description = "Simpan posisi sekarang",
    Callback = function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            savedPosition = Player.Character.HumanoidRootPart.CFrame
            Window:Notify({
                Title = "ANTC HUB",
                Description = "✅ Posisi tersimpan!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ Gagal simpan posisi!",
                Duration = 3
            })
        end
    end
})

-- Load Position Button
TeleportSection:Button({
    Title = "Load Position",
    Description = "Kembali ke posisi tersimpan",
    Callback = function()
        if savedPosition then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = savedPosition
                Window:Notify({
                    Title = "ANTC HUB",
                    Description = "✅ Teleport ke posisi tersimpan!",
                    Duration = 3
                })
            end
        else
            Window:Notify({
                Title = "ANTC HUB",
                Description = "❌ Belum ada posisi tersimpan!",
                Duration = 3
            })
        end
    end
})

-- ==================== TAB MISC ====================
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "rbxassetid://10734924532"
})

local MiscSection = MiscTab:Section({
    Title = "Utilities"
})

-- Anti AFK Toggle
MiscSection:Toggle({
    Title = "Anti AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(enabled)
        if enabled then
            local vu = game:GetService("VirtualUser")
            activeConnections.AntiAFK = Player.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
            
            Window:Notify({
                Title = "Anti AFK",
                Description = "✅ Enabled!",
                Duration = 3
            })
        else
            cleanupConnection("AntiAFK")
            
            Window:Notify({
                Title = "Anti AFK",
                Description = "❌ Disabled",
                Duration = 3
            })
        end
    end
})

-- Reset Character Button
MiscSection:Button({
    Title = "Reset Character",
    Description = "Reset karakter Anda",
    Callback = function()
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end
})

-- Discord Section
local DiscordSection = MiscTab:Section({
    Title = "Community"
})

DiscordSection:Button({
    Title = "Join Discord",
    Description = "discord.gg/antchub",
    Callback = function()
        Window:Notify({
            Title = "ANTC HUB",
            Description = "Discord: discord.gg/antchub",
            Duration = 5
        })
        
        if setclipboard then
            setclipboard("https://discord.gg/antchub")
        end
    end
})

-- Notification
Window:Notify({
    Title = "ANTC HUB",
    Description = "✅ Loaded successfully! Discord: discord.gg/antchub",
    Duration = 5
})

print("🎉 ANTC HUB Loaded Successfully!")
print("📢 Discord: discord.gg/antchub")
