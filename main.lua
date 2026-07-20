--ui docs (https://docs.sirius.menu/rayfield)
print("ran")

--things to add
-- 1. Aimbot (lock-on + flick + smooth)
-- 2. Fly + Noclip (Ctrl = toggle)
-- 3. Infinite Jump + Speed Hack
-- 4. God Mode (no damage + regen)
-- 5. Player Teleport Menu (click to TP)
-- 6. Item ESP (tools, weapons, coins)
-- 7. Kill Aura (auto-hit nearby)
-- 8. Chat Spammer / Troll Tools
-- 9. GUI Menu (ImGui-style)
-- 10. Anti-AFK + Auto-Respawn

--REMEMBER TO ADD THE SCRIPT LOADSTRING TO THE QUEUE ON TELEPORT

if game:GetService("CoreGui"):FindFirstChild("Rayfield") then
    game:GetService("CoreGui").Rayfield:Destroy()
end

--========================================================
-- Rayfield UI Setup
--========================================================
getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = nil -- your re-uploaded model

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
   Name = "Universal script hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Build 5.5",
   LoadingSubtitle = "by sky",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "universal script hub", -- Create a custom folder for your hub/game
      FileName = "Hub"
   },

   Discord = {
      Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "https://discord.gg/rVQPFjjJ", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "The key is Hello", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

--jailbreak ac disabler
for _, v in next, getgc() do
    if typeof(v) == "function" then
        local info = getinfo(v)
        if info and (info.name == "CheatCheck" or info.name == "CheatCheck0") then
            hookfunction(v, function() end)
            print("✅ Hooked CheatCheck")
        end
    end
end

local function protectName(instance, expectedName)
    if not instance then return end
    
    -- Fix immediately if wrong
    if instance.Name ~= expectedName then
        instance.Name = expectedName
    end

    -- Protect from changes
    instance:GetPropertyChangedSignal("Name"):Connect(function()
        if instance.Name ~= expectedName then
            instance.Name = expectedName
        end
    end)
end

-- Protect the important services
protectName(workspace, "Workspace")
protectName(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
protectName(game:GetService("Players"), "Players")
print("hi")

-- Services
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local Lighting         = game:GetService("Lighting")



-- Camera (safe, returns if not found)
local Camera = workspace.CurrentCamera
if not Camera then
    workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    Camera = workspace.CurrentCamera
end

-- Atmosphere (safe, returns nil if not found after reasonable wait)
local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not Atmosphere then
    local conn
    local timeout = tick() + 0.5  -- Wait max 0.5 seconds
    conn = Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Atmosphere") then
            Atmosphere = child
            conn:Disconnect()
        end
    end)

    repeat task.wait() until Atmosphere or tick() > timeout

    if conn.Connected then conn:Disconnect() end
end

-- Flags / Settings
local IsLoaded = false
local aimbotEnabled    = false
local forceFirstPerson = false
local aimAtHead        = true
local ignoreWalls      = false
local circleRadius     = 200
local smoothness       = 0.2 -- lower = faster snap, higher = smoother
local savedSettings    = {}
local fullBrightConnection = nil
local LessfullBrightConnection = nil



-- function getHRP()
--     local char = plr.Character or plr.CharacterAdded:Wait()
--     return char:WaitForChild("HumanoidRootPart")
-- end

-- local Lighting = game:GetService("Lighting")
-- local RunService = game:GetService("RunService")


local savedSettings = nil
local FullbrightConnection = nil
local IsFullbrightOn = false

local LessFullbrightConnection = nil
local IsLessFullbrightOn = false

-- Expanded save (perfect restore)
local function saveLighting()
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    local bloom = Lighting:FindFirstChildOfClass("Bloom")
    local dof = Lighting:FindFirstChildOfClass("DepthOfField")
    
    savedSettings = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        ExposureCompensation = Lighting.ExposureCompensation,
        ColorShift_Top = Lighting.ColorShift_Top,
        ColorShift_Bottom = Lighting.ColorShift_Bottom,
        
        AtmosphereDensity = atmosphere and atmosphere.Density or nil,
        
        BloomEnabled = bloom and bloom.Enabled or nil,
        BloomIntensity = bloom and bloom.Intensity or nil,
        BloomThreshold = bloom and bloom.Threshold or nil,
        
        DoFEnabled = dof and dof.Enabled or nil,
    }
end

-- Apply fullbright (bright AF + anti-dark)
local function applyFullBright()
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    local bloom = Lighting:FindFirstChildOfClass("Bloom")
    local dof = Lighting:FindFirstChildOfClass("DepthOfField")
    
    if atmosphere then atmosphere.Density = 0 end
    
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.Brightness = 3
    Lighting.ClockTime = 12
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    Lighting.ExposureCompensation = 0.5
    Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
    
    if bloom then
        bloom.Enabled = true
        bloom.Intensity = 0.5
        bloom.Threshold = 0
    end
    
    if dof then dof.Enabled = false end
end

-- Apply fullbright (bright AF + anti-dark)
local function applyLessFullBright()
    -- Find common post-processing effects
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
    local dof = Lighting:FindFirstChildOfClass("DepthOfField")
    local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect")

    -- Kill atmosphere density completely (hazy sky killer)
    if atmosphere then
        atmosphere.Density = 0
        atmosphere.Decay = Color3.new(0, 0, 0)
        atmosphere.Offset = 0
        atmosphere.Glare = 0
        atmosphere.Haze = 0
    end

    -- Dim the world HARD
    Lighting.Brightness          = 0.4      -- Was 0.01 → too dark, 0.4 is dim but playable
    Lighting.Ambient             = Color3.fromRGB(80, 80, 90)   -- Slight cool tint instead of pure white
    Lighting.OutdoorAmbient      = Color3.fromRGB(70, 70, 80)   -- Even darker outdoors
    Lighting.ExposureCompensation = 1.2     -- Heavy underexposure (negative = darker)
    Lighting.ClockTime           = 12       -- Slightly later afternoon for softer light
    Lighting.GlobalShadows       = false     -- Shadows back on for depth
    Lighting.FogEnd              = 300000      -- Much closer fog to reduce distant brightness
    Lighting.FogStart            = 0
    Lighting.FogColor            = Color3.fromRGB(0, 0, 0)  -- Dark gray fog

    -- Color shifts to reduce warm/over-saturated tones
    Lighting.ColorShift_Top      = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Bottom   = Color3.fromRGB(0, 0, 0)

    -- Bloom: keep it subtle or disable if too glowy
    if bloom then
        bloom.Enabled   = true
        bloom.Intensity = 0.3     -- Lowered from 0.5
        bloom.Threshold = 1.2     -- Higher threshold = less bloom on bright areas
        bloom.Size      = 12
    end

    -- Disable or heavily reduce other post-effects that add brightness
    if dof then
        dof.Enabled = false
    end

    if colorCorrection then
        colorCorrection.Enabled           = true
        colorCorrection.Brightness        = 0.1
        colorCorrection.Contrast          = 0.1
        colorCorrection.Saturation        = 0.4   -- Desaturate a bit
        colorCorrection.TintColor         = Color3.fromRGB(220, 220, 255)  -- Very slight cool tint
    end

    if sunRays then
        sunRays.Enabled = false
    end
end

-- Restore original
local function restoreLighting()
    if not savedSettings then return end
    
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    local bloom = Lighting:FindFirstChildOfClass("Bloom")
    local dof = Lighting:FindFirstChildOfClass("DepthOfField")
    
    Lighting.Ambient = savedSettings.Ambient
    Lighting.OutdoorAmbient = savedSettings.OutdoorAmbient
    Lighting.Brightness = savedSettings.Brightness
    Lighting.ClockTime = savedSettings.ClockTime
    Lighting.FogEnd = savedSettings.FogEnd
    Lighting.FogStart = savedSettings.FogStart or 0
    Lighting.GlobalShadows = savedSettings.GlobalShadows
    Lighting.ExposureCompensation = savedSettings.ExposureCompensation
    Lighting.ColorShift_Top = savedSettings.ColorShift_Top
    Lighting.ColorShift_Bottom = savedSettings.ColorShift_Bottom
    
    if atmosphere and savedSettings.AtmosphereDensity then
        atmosphere.Density = savedSettings.AtmosphereDensity
    end
    
    if bloom and savedSettings.BloomEnabled ~= nil then
        bloom.Enabled = savedSettings.BloomEnabled
        bloom.Intensity = savedSettings.BloomIntensity or 1
        bloom.Threshold = savedSettings.BloomThreshold or 1
    end
    
    if dof and savedSettings.DoFEnabled ~= nil then
        dof.Enabled = savedSettings.DoFEnabled
    end
end


-- local Players = game:GetService("Players")


-- local character
-- local humanoid
-- local humanoidRootPart

-- local function SetupCharacter(char)
--     character = char
--     humanoid = char:WaitForChild("Humanoid")
--     humanoidRootPart = char:WaitForChild("HumanoidRootPart")
-- end

-- Player.CharacterAdded:Connect(SetupCharacter)

-- if Player.Character then
--     SetupCharacter(Player.Character)
-- end

local function SameTeam(a, b)
    if not a or not b then return false end
    if a.Team and b.Team then return a.Team == b.Team end
    if a.TeamColor and b.TeamColor then return a.TeamColor == b.TeamColor end
    return false
end

local function teleportToModel()
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
        
    local model = workspace:FindFirstChild(MODEL_NAME)
    if not model then
        warn("Model not found:", MODEL_NAME)
        return
    end
end

-- ==============================
-- GLOBAL: Valid Target Check
-- ==============================
local function IsValidTarget(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    if plr == LocalPlayer then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    -- Ignore teammates
    if ignoreTeammates and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return false end

    -- Prison Life team names
    if ignorePrisoners and plr.Team and (plr.Team.Name == "Inmates" or plr.Team.Name == "Prisoners") then return false end
    if ignoreCriminals and plr.Team and plr.Team.Name == "Criminals" then return false end

    return true
end

local function IsIgnoredTeam(plr)
    local team = plr.Team
    if not team then return false end
    if ignorePrisoners and (team.Name == "Prisoners" or team.Name == "Inmates") then return true end
    if ignoreCriminals and team.Name == "Criminals" then return true end
    return false
end

--========================================================
-- ESP (single-color)
--========================================================
local highlightTemplate = Instance.new("Highlight")
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlightTemplate.Name = "Highlight"
highlightTemplate.FillTransparency = 0.5
highlightTemplate.OutlineTransparency = 0

local function addHighlightToPlayer(targetPlayer, color)
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not hrp:FindFirstChild("Highlight") then
        local clone = highlightTemplate:Clone()
        clone.Adornee = char
        if color then clone.FillColor = color end
        clone.Parent = hrp
    else
        if color then hrp.Highlight.FillColor = color end
    end
end

local function removeHighlightFromPlayer(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("Highlight") then
        hrp.Highlight:Destroy()
    end
end

--========================================================
-- TEAM ESP infra
--========================================================
local teamEspEnabled = false
local teamPlayerAddedConn, teamPlayerRemovingConn
local teamCharAddedConns, teamChangedConns = {}, {}
local teamColors = nil

local function getTeamColor(p)
    if teamColors and p.Team and p.Team.Name and teamColors[p.Team.Name] then
        return teamColors[p.Team.Name]
    end
    if p.Team and p.Team.TeamColor and p.Team.TeamColor.Color then
        return p.Team.TeamColor.Color
    end
    return Color3.new(1,1,1)
end

local function createTeamHighlight(color)
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineTransparency = 0
    hl.FillTransparency = 0.5
    hl.FillColor = color
    hl.Name = "TeamESP"
    return hl
end

local function addTeamESP(p)
    local char = p.Character
    if not char then return end
    if char:FindFirstChild("TeamESP") then return end
    local color = getTeamColor(p)
    local hl = createTeamHighlight(color)
    hl.Adornee = char
    hl.Parent = char

    if teamChangedConns[p] then teamChangedConns[p]:Disconnect() end
    teamChangedConns[p] = p:GetPropertyChangedSignal("Team"):Connect(function()
        if hl.Parent then
            hl.FillColor = getTeamColor(p)
        end
    end)

    if teamCharAddedConns[p] then teamCharAddedConns[p]:Disconnect() end
    teamCharAddedConns[p] = p.CharacterAdded:Connect(function(newChar)
        task.wait()
        if teamEspEnabled then
            local h = newChar:FindFirstChild("TeamESP")
            if not h then
                local nh = createTeamHighlight(getTeamColor(p))
                nh.Adornee = newChar
                nh.Parent = newChar
            end
        end
    end)
end

local function removeTeamESP(p)
    if teamCharAddedConns[p] then teamCharAddedConns[p]:Disconnect() teamCharAddedConns[p] = nil end
    if teamChangedConns[p] then teamChangedConns[p]:Disconnect() teamChangedConns[p] = nil end
    local char = p.Character
    if char and char:FindFirstChild("TeamESP") then
        char.TeamESP:Destroy()
    end
end

--========================================================
-- Noclip
--========================================================
local noclipEnabled = false
local function setNoclip(enabled)
    noclipEnabled = enabled
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

-- Function to toggle collisions
local function setNoclip(enable)
	local char = player.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not enable
		end
	end
end

RunService.Heartbeat:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

--========================================================
-- Kill Aura
--========================================================
local killAuraEnabled = false
local killAuraRadius = 10

RunService.Heartbeat:Connect(function()
    if killAuraEnabled and character and humanoidRootPart then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = plr.Character.HumanoidRootPart
                if (humanoidRootPart.Position - targetHRP.Position).Magnitude <= killAuraRadius then
                    local tool = character:FindFirstChildWhichIsA("Tool")
                    if tool then tool:Activate() end
                    break
                end
            end
        end
    end
end)


local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = game:getService("Players").LocalPlayer
local placeId = game.PlaceId

-- ✅ Rejoin current server
local function rejoinServer()
    TeleportService:TeleportToPlaceInstance(placeId, game.JobId, plr)
end

-- ✅ Server hop (find a new public server)
local function serverHop()
    local servers = {}
    local cursor = ""
    local foundServer = nil

    repeat
        local success, result = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
                )
            )
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    foundServer = server.id
                    break
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until foundServer or cursor == ""

    if foundServer then
        TeleportService:TeleportToPlaceInstance(placeId, foundServer, plr)
    else
        warn("No new server found to hop into.")
    end
end


-- ═════════════════════════════════════════════
--  VFLY v5.0 - Super Clean & Undetected Velocity Fly
--  Features: Proper noclip, gravity spoof, respawn support,
--            mouse wheel speed control, smooth toggle
-- ═════════════════════════════════════════════

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = game:getService("Players").LocalPlayer
local Camera = Workspace.CurrentCamera

local FLYING = false
local SPEED = 100
local MIN_SPEED = 16
local MAX_SPEED = 50000
local SPEED_STEP = 25

local KEYS = {
    W = false, A = false, S = false, D = false,
    Space = false, LeftShift = false
}

local Connections = {}
local BodyVelocity = nil

-- Cleanup function
local function Cleanup()
    if BodyVelocity and BodyVelocity.Parent then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
    for _, conn in pairs(Connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    Connections = {}
end

-- Main fly function
local function StartFly()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
    if not HumanoidRootPart then return end

    -- Create BodyVelocity (more stable & less detected than direct AssemblyLinearVelocity spam)
    if BodyVelocity then BodyVelocity:Destroy() end
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.P = 1250
    BodyVelocity.Parent = HumanoidRootPart

    -- Noclip every frame (efficient + safe)
    table.insert(Connections, RunService.Stepped:Connect(function()
        if not FLYING or not Character.Parent then return end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        -- Spoof gravity slightly downward to trick anti-cheats checking for "floating"
        if HumanoidRootPart then
            HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity - Vector3.new(0, 8, 0)
        end
    end))

    -- Main movement loop
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if not FLYING or not HumanoidRootPart or not HumanoidRootPart.Parent then return end

        local moveDirection = Vector3.new(0, 0, 0)
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        local camUp = Camera.CFrame.UpVector

        if KEYS.W then moveDirection = moveDirection + camLook end
        if KEYS.S then moveDirection = moveDirection - camLook end
        if KEYS.A then moveDirection = moveDirection - camRight end
        if KEYS.D then moveDirection = moveDirection + camRight end
        if KEYS.Space then moveDirection = moveDirection + camUp end
        if KEYS.LeftShift then moveDirection = moveDirection - camUp end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * SPEED
        end

        BodyVelocity.Velocity = moveDirection
    end))
end

local function StopFly()
    FLYING = false
    Cleanup()

    local Character = LocalPlayer.Character
    if Character then
        task.delay(0.1, function()
            if Character and Character.Parent then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= Character.HumanoidRootPart then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- Toggle Fly
local function ToggleFly()
    FLYING = not FLYING
    if FLYING then
        print("🛩️ VFLY v5.0 ENABLED | Speed: " .. SPEED .. " | Use Mouse Wheel to adjust")
        StartFly()
    else
        print("🛩️ VFLY DISABLED")
        StopFly()
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        ToggleFly()
    elseif input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then
            SPEED = math.clamp(SPEED + SPEED_STEP, MIN_SPEED, MAX_SPEED)
        else
            SPEED = math.clamp(SPEED - SPEED_STEP, MIN_SPEED, MAX_SPEED)
        end
        if FLYING then
            print("🛩️ Fly Speed: " .. math.floor(SPEED))
        end
    end

    local key = input.KeyCode
    if KEYS[key.Name] ~= nil then
        KEYS[key.Name] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if KEYS[key.Name] ~= nil then
        KEYS[key.Name] = false
    end
end)

-- Handle respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if FLYING then
        StopFly()
        task.wait(0.3)
        StartFly()
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Character reset/death
LocalPlayer.CharacterRemoving:Connect(function()
    Cleanup()
end)

-- Game closing / leaving
-- game:BindToClose(function()
--     Cleanup()
-- end)

local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ClickTP_Enabled = false

-- === CLICK TP FUNCTION ===
local function ClickTP()
    if not ClickTP_Enabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local root = LocalPlayer.Character.HumanoidRootPart
    local targetPos = Mouse.Hit.Position + Vector3.new(0, 2, 0)  -- 2 studs above ground

    root.CFrame = CFrame.new(targetPos)
end

-- === MOUSE CLICK LISTENER ===
Mouse.Button1Down:Connect(ClickTP)

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- if not hrp then
--     warn("HumanoidRootPart not found!")
--     return 
-- end


-- Home Tab
local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateLabel("ALWAYS USE ALT ACCOUNT")
local Gen2Label = HomeTab:CreateLabel("When is rayfield gen 2 coming out😭")


HomeTab:CreateSection("Your Time Zone")

-- 🕒 Time + Date labels
local TimeLabel = HomeTab:CreateLabel("Your Local Time: " .. os.date("%I:%M:%S %p"))
local DateLabel = HomeTab:CreateLabel("Date: " .. os.date("%B %d, %Y"))
local MS = game:GetService("MarketplaceService")

local function safeName(id, label)
    local success, info = pcall(MS.GetProductInfo, MS, id)
    return success and info.Name or ("Unknown " .. label .. " (ID: " .. id .. ")")
end

local PlaceLabel = HomeTab:CreateLabel("Your Current Place: " .. safeName(game.PlaceId, "Place"))
--local GameLabel  = HomeTab:CreateLabel("Your Current Game: " .. safeName(game.GameId,  "Game"))


-- 🔄 Update loop
task.spawn(function()
    while task.wait(1) do
        -- Time (updates every second)
        local currentTime = os.date("%I:%M:%S %p")
        TimeLabel:Set("Your Local Time: " .. currentTime)

        -- Date (refresh daily, but we still set it each loop just in case)
        local currentDate = os.date("%B %d, %Y")
        DateLabel:Set("Date: " .. currentDate)
    end
end)



local PlaceLabel = HomeTab:CreateLabel("Your Executor: " .. identifyexecutor())

HomeTab:CreateDivider()


-- 🟢 Rayfield Buttons
HomeTab:CreateParagraph({ Title = "Welcome to the Universal Hub", Content = "Have fun using this Hub" })

HomeTab:CreateButton({
   Name = "Copy Discord",
   Callback = function()
		setclipboard("https://discord.gg/rVQPFjjJ")
   end,
})

HomeTab:CreateSection("Testing")

HomeTab:CreateButton({ Name = "Inf Yield",        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
HomeTab:CreateButton({ Name = "AI SMART Inf Yield (might not work)",        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))() end })
HomeTab:CreateButton({ Name = "Dex",         Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
HomeTab:CreateButton({ Name = "Remote Spy/ Simple Spy for bad executors ",         Callback = function() local settings = { SaveDecompileLogs = true, -- saves decompile logs so you dont have to decompile again 
	SaveScanLogs = true, -- saves scan logs (scans for localscript to decompile) so you dont have to scan again
    ScanForNewInstance = true, -- scans for new localscript and decompile it and add it to the decompile logs
    InterceptUntilRan = true, -- blocks request until you manually run it (i recommend when bypassing keys)
    CursorOffset = -15, -- Cursor offset
    PathToDump = {game.Players.LocalPlayer, game:GetService('ReplicatedStorage')} -- path to dump
}
--// Init 
_G.data = settings
loadstring(game:HttpGet('https://raw.githubusercontent.com/ScriptSkiddie69/RemoteHook/refs/heads/main/SimpleSpyLite.lua'))()  end })


HomeTab:CreateButton({
	Name = "JasonSpy",
	CurrentValue = fovLocked,
	Callback = function(state)
		loadstring(game:HttpGet("https://pastebin.com/raw/8Pa2QRY8"))()
	end,
})

-- 🚀 MAIN BUTTON
HomeTab:CreateButton({
	Name = "Medal Decompiler for good exec (doesnt work for bad exec)",
	Callback = function()

		Rayfield:Notify({
			Title = "Decompiler",
			Content = "Starting...",
			Duration = 2
		})

		getgenv().decompile = function(script_instance)
		local bytecode = getscriptbytecode(script_instance)
		local encoded = crypt.base64.encode(bytecode)
		return request(
			{
				Url = "http://localhost:3000/decompile",
				Method = "POST",
				Body = encoded
			}
		).Body
	end

	local synsaveinstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()
	local Options = {
	SafeMode = true,
	ShutdownWhenDone = true,
	mode = "scripts",
	NilInstances = true,
	}
	synsaveinstance(Options)

		Rayfield:Notify({
			Title = "Decompiler",
			Content = "Finished!",
			Duration = 3
		})
	end
})

HomeTab:CreateButton({ Name = "Script Dumper",         Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterTD/Script.Dumper/refs/heads/main/Debugger.lua"))() end })

HomeTab:CreateButton({ Name = "Dex++",         Callback = function() 
if not gethui() then warn("your executor doesn't even support gethui()") return  end
local Fol = Instance.new("Folder", game)
Fol.Name = "[Dumped] HiddenGui"
local get = gethui()
for _, instance in ipairs(get:GetChildren()) do
    local new = instance:Clone()
	new.Parent = Fol
end
--// Dex ++ Made by Chillz, github: https://github.com/AZYsGithub/DexPlusPlus
loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))() end })

HomeTab:CreateButton({ Name = "Executor Tester",         Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GmilerlolYT/ExecutorTester/refs/heads/main/Hi"))() end })


HomeTab:CreateDivider()

-- 🟢 Rayfield Buttons
HomeTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
   end,
})

HomeTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        serverHop()
    end,
})

HomeTab:CreateToggle({
    Name = "Toggle Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",  -- Unique flag for saving state
    Callback = function(v)
        IsFullbrightOn = v
        if v then
            Rayfield:Notify({
                Title = "Fullbright",
                Content = "ON - Crystal clear vision! 🔥",
                Duration = 4
            })
            if not savedSettings then
                saveLighting()
            end
            applyFullBright()
            if FullbrightConnection then FullbrightConnection:Disconnect() end
            FullbrightConnection = RunService.Heartbeat:Connect(function()
                if IsFullbrightOn then
                    applyFullBright()
                end
            end)
        else
            if FullbrightConnection then
                FullbrightConnection:Disconnect()
                FullbrightConnection = nil
            end
            restoreLighting()
            Rayfield:Notify({
                Title = "Fullbright",
                Content = "OFF - Restored original 🌙",
                Duration = 4
            })
        end
    end
})

HomeTab:CreateToggle({
    Name = "Toggle less Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",  -- Unique flag for saving state
    Callback = function(v)
        IsLessFullbrightOn = v
        if v then
            Rayfield:Notify({
                Title = "Less Fullbright",
                Content = "ON - Crystal clear vision! 🔥",
                Duration = 4
            })
            if not savedSettings then
                saveLighting()
            end
            applyLessFullBright()
            if FullbrightConnection then LessFullbrightConnection:Disconnect() end
            LessFullbrightConnection = RunService.Heartbeat:Connect(function()
                if IsLessFullbrightOn then
                    applyLessFullBright()
                end
            end)
        else
            if LessFullbrightConnection then
                LessFullbrightConnection:Disconnect()
                LessFullbrightConnection = nil
            end
            restoreLighting()
            Rayfield:Notify({
                Title = "Less Fullbright",
                Content = "OFF - Restored original 🌙",
                Duration = 4
            })
        end
    end
})


local RunService = game:GetService("RunService")

-- Prevent duplicate versions of this script from running
local ok, genv = pcall(function() return getgenv() end)
if not ok or type(genv) ~= "table" then genv = _G end
if genv.__FOV_LOCK_MANAGER then
	-- clean up the old one before making a new one
	genv.__FOV_LOCK_MANAGER:Unload()
end

local Manager = {}
genv.__FOV_LOCK_MANAGER = Manager

local camera = workspace.CurrentCamera
local fovLocked = false
local customFOV = 70
local prevFOV = nil
local sliderChangedWhileLocked = false
local fovConnection = nil

-- Handle camera changes (like respawns)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
	if fovLocked and camera then
		prevFOV = camera.FieldOfView
		camera.FieldOfView = customFOV
	end
end)

-- Main Function: Enable FOV Lock
local function enableFOVLock()
    if fovConnection then return end  -- Already running, prevent duplicates

    camera = workspace.CurrentCamera
    prevFOV = camera.FieldOfView      -- Save original FOV

    sliderChangedWhileLocked = false

    fovConnection = RunService.RenderStepped:Connect(function()
        if not fovLocked then return end
        if not camera then return end

        -- Force FOV to stay at custom value
        if camera.FieldOfView ~= customFOV then
            camera.FieldOfView = customFOV
        end
    end)

    -- Instantly apply custom FOV when enabled
    if camera then
        camera.FieldOfView = customFOV
    end

end

local function disableFOVLock()
	if fovConnection then
		fovConnection:Disconnect()
		fovConnection = nil
	end

	-- Restore only if safe
	if camera and prevFOV and (not sliderChangedWhileLocked) and camera.FieldOfView == customFOV then
		camera.FieldOfView = prevFOV
	end

	-- Always reset
	prevFOV = nil
	sliderChangedWhileLocked = false
end

-- Public API for re-injection safety
function Manager:Unload()
	if fovConnection then
		fovConnection:Disconnect()
		fovConnection = nil
	end
	fovLocked = false
	prevFOV = nil
	sliderChangedWhileLocked = false
	genv.__FOV_LOCK_MANAGER = nil
end

-- === UI ===
HomeTab:CreateSlider({
	Name = "Camera FOV",
	Range = {20, 120},
	Increment = 1,
	CurrentValue = customFOV,
	Callback = function(val)
		customFOV = val
		if fovLocked and camera then
			camera.FieldOfView = val
			sliderChangedWhileLocked = true
		end
	end,
})

HomeTab:CreateToggle({
	Name = "Lock FOV(press to enable)",
	CurrentValue = fovLocked,
	Callback = function(state)
		fovLocked = state
		if state then
			enableFOVLock()
		else
			disableFOVLock()
		end
	end,
})

HomeTab:CreateButton({
    Name = "Copy Place Id",
    Callback = function()
		setclipboard(tostring(game.PlaceId))
    end
})

HomeTab:CreateButton({
    Name = "Copy gameId",
    Callback = function()
        setclipboard(tostring(game.GameId))
    end
})

HomeTab:CreateButton({
    Name = "Copy CFrame",
    Callback = function()
        task.spawn(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")

            if hrp then
                setclipboard(tostring(hrp.CFrame))
                print("CFrame copied to clipboard!")
            else
                print("No HumanoidRootPart")
            end
        end)
    end
})

	--universal stuff
	local UniTab = Window:CreateTab("Universal", "globe")

    UniTab:CreateSection("Universal Scripts")
    UniTab:CreateSection("Executors")
	UniTab:CreateButton({
		Name = "Delta Executor",
		CurrentValue = false,
		Flag = "del",
		Callback = function()
			loadstring(game:HttpGet("https://pastebin.com/raw/HrZwZgp8"))()
		end,
	})
	UniTab:CreateSection("Script Hubs")
    UniTab:CreateButton({ Name = "ALL FE SCRIPT",     Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/Bt10CyZZ"))() end })
	UniTab:CreateButton({ Name = "Sky hub",     Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/yofriendfromschool1/Sky-Hub/main/SkyHub.txt"))() end })
	UniTab:CreateDivider()
	UniTab:CreateSection("Universal Scripts")

	UniTab:CreateButton({
		Name = "sUNC test",
		CurrentValue = false,
		Flag = "Unc",
		Callback = function()
			local START_TIME = tick()

			local rawResults = {}
			local metaInfo = {}

			local function addResult(name, ok, info)
				if rawResults[name] ~= nil then return end
				rawResults[name] = {
					passed = ok and true or false,
					info = info or ""
				}
			end

			local function safeAssert(name, fn, failReason)
				local ok, err = pcall(fn)
				if not ok then
					addResult(name, false, failReason or tostring(err))
					return false, err
				else
					if rawResults[name] == nil then
						addResult(name, true, "ok")
					end
					return true
				end
			end

			local function checkExists(path)
				local env = getgenv and getgenv() or _G
				local cur = env
				for seg in string.gmatch(path, "[^%.]+") do
					if type(cur) ~= "table" then
						return false
					end
					cur = cur[seg]
					if cur == nil then
						return false
					end
				end
				return true
			end

			local function quickBoolTest(name, cond, reason)
				if cond then
					addResult(name, true, "ok")
				else
					addResult(name, false, reason or "failed")
				end
			end

			local function getExecutorName()
				local n = nil
				local ok = pcall(function()
					if getexecutorname then
						n = getexecutorname()
					elseif identifyexecutor then
						local a, b = identifyexecutor()
						n = a or b
					elseif syn then
						n = "Synapse (syn)"
					end
				end)
				if not ok then
					n = nil
				end
				if type(n) ~= "string" then
					n = "Unknown"
				end
				return n
			end

			metaInfo.executor = getExecutorName()

			local featureTargets = {
				"loadstring",
				"getgenv",
				"getrenv",
				"getgc",
				"getrunningscripts",
				"getscripts",
				"getscripthash",
				"getsenv",
				"getrawmetatable",
				"setreadonly",
				"isreadonly",
				"newcclosure",
				"iscclosure",
				"islclosure",
				"isexecutorclosure",
				"hookfunction",
				"hookmetamethod",
				"getnamecallmethod",
				"setrawmetatable",
				"getinstances",
				"getnilinstances",
				"isscriptable",
				"setscriptable",
				"getthreadidentity",
				"setthreadidentity",
				"checkcaller",
				"request",
				"getcustomasset",
				"gethiddenproperty",
				"sethiddenproperty",
				"Drawing.new",
				"Drawing.Fonts",
				"getrenderproperty",
				"setrenderproperty",
				"cleardrawcache",
				"listfiles",
				"isfolder",
				"isfile",
				"makefolder",
				"writefile",
				"appendfile",
				"readfile",
				"delfile",
				"delfolder",
				"loadfile",
				"getscriptbytecode"
			}

			for _, path in ipairs(featureTargets) do
				local exists = checkExists(path)
				if exists then
					addResult(path, true, "exists")
				else
					addResult(path, false, "missing")
				end
			end

			if getgenv then
				safeAssert("getgenv[behavior]", function()
					local a = getgenv()
					local b = getgenv()
					assert(a == b, "environments not identical")
					a.__SUNC_TEMP = 99
					assert(getgenv().__SUNC_TEMP == 99, "value not shared")
					a.__SUNC_TEMP = nil
				end, "environment not stable")
			end

			if loadstring then
				safeAssert("loadstring[basic]", function()
					local f = loadstring("return 10 + 5")
					assert(type(f) == "function", "loadstring returned non-function")
					assert(f() == 15, "math result mismatch")
				end, "simple expression failed")

				safeAssert("loadstring[error-report]", function()
					local ok, err = pcall(function()
						local f = loadstring("this is not valid luau")
						f()
					end)
					assert(ok == false, "invalid chunk did not error")
					assert(type(err) == "string" or type(err) == "table", "no error info returned")
				end, "invalid-chunk handling broken")
			end

			if getrawmetatable and setreadonly and hookmetamethod then
				safeAssert("metatable[hook]", function()
					local obj = {}
					local mt = getrawmetatable(obj) or {}
					local oldIndex = mt.__index

					local wr = pcall(function() setreadonly(mt, false) end)
					assert(wr, "setreadonly failed")

					mt.__index = function(self, k)
						if k == "__SUNC_FLAG" then
							return "OK"
						end
						if oldIndex then
							return oldIndex(self, k)
						end
						return nil
					end

					setreadonly(mt, true)

					local hook
					hook = hookmetamethod(obj, "__index", function(self, k, ...)
						if k == "__SUNC_HOOKED" then
							return "HOOKED"
						end
						return hook(self, k, ...)
					end)

					assert(obj.__SUNC_FLAG == "OK", "original index override failed")
					assert(obj.__SUNC_HOOKED == "HOOKED", "__index hook failed")
				end, "metamethod / readonly behavior invalid")
			end

			if newcclosure and iscclosure and islclosure then
				safeAssert("closures[type]", function()
					local luaFunc = function()
						return 1
					end
					local cFunc = newcclosure(luaFunc)
					assert(luaFunc() == cFunc(), "closure return mismatch")
					assert(luaFunc ~= cFunc, "closure should not be same reference")
					assert(iscclosure(cFunc), "cFunc not reported as cclosure")
					assert(islclosure(luaFunc), "luaFunc not reported as lclosure")
				end, "closure typing broken")
			end

			if checkcaller then
				safeAssert("checkcaller[basic]", function()
					assert(checkcaller() == true, "checkcaller should be true in user script")
				end, "checkcaller returned false")
			end

			if getthreadidentity and setthreadidentity then
				safeAssert("threadidentity", function()
					local original = getthreadidentity()
					assert(type(original) == "number", "identity not number")
					setthreadidentity(original + 1)
					assert(getthreadidentity() == original + 1, "identity did not change")
					setthreadidentity(original)
				end, "thread identity operations blocked")
			end

			if isfolder and makefolder and delfolder and writefile and readfile and isfile and listfiles then
				safeAssert("filesystem", function()
					local root = ".sunc_test"
					if isfolder(root) then
						delfolder(root)
					end
					makefolder(root)
					assert(isfolder(root), "folder not created")

					local f1 = root .. "/a.txt"
					writefile(f1, "hello")
					assert(isfile(f1), "file not created")
					assert(readfile(f1) == "hello", "content mismatch")

					if appendfile then
						appendfile(f1, " world")
						assert(readfile(f1) == "hello world", "appendfile broken")
					end

					if loadfile then
						local f2 = root .. "/code.lua"
						writefile(f2, "return function(x) return x + 3 end")
						local loader = loadfile(f2)
						local fn = loader()
						assert(fn(5) == 8, "loadfile function incorrect")
					end

					local entries = listfiles(root)
					assert(type(entries) == "table" and #entries >= 1, "listfiles empty")

					delfile(f1)
					assert(not isfile(f1), "delfile failed")
					delfolder(root)
					assert(not isfolder(root), "delfolder failed")
				end, "filesystem operations failed")
			end

			if request then
				safeAssert("request[basic]", function()
					local res = request({
						Url = "https://httpbin.org/get",
						Method = "GET"
					})
					assert(type(res) == "table", "response not table")
					assert(res.StatusCode == 200 or res.StatusCode == 301 or res.StatusCode == 302, "unexpected status")
				end, "HTTP request failed")
			end

			if getcustomasset and writefile then
				safeAssert("getcustomasset[basic]", function()
					local path = ".sunc_asset_test.txt"
					writefile(path, "x")
					local id = getcustomasset(path)
					assert(type(id) == "string" and #id > 0, "asset id invalid")
				end, "getcustomasset not usable")
			end

			if gethiddenproperty and sethiddenproperty then
				safeAssert("hiddenprops", function()
					local fire = Instance.new("Fire")
					local okA = pcall(function()
						return gethiddenproperty(fire, "size_xml")
					end)
					assert(okA, "gethiddenproperty errored")
					local okB = pcall(function()
						sethiddenproperty(fire, "size_xml", 7)
					end)
					assert(okB, "sethiddenproperty errored")
				end, "hidden property functions broken")
			end

			if Drawing and Drawing.new then
				safeAssert("Drawing[objects]", function()
					local sq = Drawing.new("Square")
					sq.Visible = true
					sq.Color = Color3.fromRGB(255, 255, 255)
					sq.Size = Vector2.new(50, 50)

					if getrenderproperty then
						local v = getrenderproperty(sq, "Visible")
						assert(type(v) == "boolean", "Visible not boolean")
					end

					if setrenderproperty then
						setrenderproperty(sq, "Visible", false)
						assert(sq.Visible == false, "setrenderproperty failed")
					end

					local okDestroy = pcall(function()
						sq:Remove()
					end)
					if not okDestroy then
						pcall(function() sq:Destroy() end)
					end
				end, "Drawing api failure")

				if Drawing.Fonts then
					quickBoolTest("Drawing.Fonts[exists]", Drawing.Fonts.UI ~= nil, "fonts missing")
				end

				if cleardrawcache then
					local ok = pcall(function()
						cleardrawcache()
					end)
					quickBoolTest("cleardrawcache[call]", ok, "cleardrawcache threw error")
				end
			end

			if getscriptbytecode and getscripthash then
				safeAssert("script[introspection]", function()
					local plr = game:GetService("Players").LocalPlayer
					local char = plr.Character or plr.CharacterAdded:Wait()
					local anim = char:FindFirstChildOfClass("LocalScript") or char:FindFirstChild("Animate")
					assert(anim, "no local script found on character")

					local bc = getscriptbytecode(anim)
					assert(type(bc) == "string" and #bc > 0, "bytecode empty")

					local h1 = getscripthash(anim)
					local src = anim.Source

					anim.Source = src .. "\n-- sunc test"
					local h2 = getscripthash(anim)
					anim.Source = src

					assert(h1 ~= h2, "hash not sensitive to source change")
				end, "script hash / bytecode invalid")
			end

			if getrunningscripts and getscripts then
				safeAssert("scripts[lists]", function()
					local rs = getrunningscripts()
					assert(type(rs) == "table", "getrunningscripts not table")
					assert(#rs > 0, "no running scripts listed")

					local all = getscripts()
					assert(type(all) == "table" and #all > 0, "getscripts empty")
				end, "script listing broken")
			end

			if getinstances then
				safeAssert("getinstances[basic]", function()
					local insts = getinstances()
					assert(type(insts) == "table" and #insts > 0, "getinstances empty")
					assert(insts[1].ClassName ~= nil, "first entry not instance")
				end, "getinstances failed")
			end

			if getnilinstances then
				safeAssert("getnilinstances[basic]", function()
					local insts = getnilinstances()
					if #insts > 0 then
						assert(insts[1].Parent == nil, "nil instance not parentless")
					end
				end, "getnilinstances failed")
			end

			local sorted = {}
			for name, data in pairs(rawResults) do
				table.insert(sorted, {name = name, passed = data.passed, info = data.info})
			end

			table.sort(sorted, function(a, b)
				return a.name < b.name
			end)

			local total = #sorted
			local passed = 0
			for _, r in ipairs(sorted) do
				if r.passed then
					passed = passed + 1
				end
			end

			local successRate = 0
			if total > 0 then
				successRate = math.floor((passed / total) * 100 + 0.5)
			end

			local elapsed = tick() - START_TIME

			local function formatTime(t)
				return math.floor(t * 10) / 10
			end

			local function speedComment(t)
				if t < 2 then
					return "Very fast – environment is highly responsive."
				elseif t < 4 then
					return "Fast – should feel smooth in most usage."
				elseif t < 7 then
					return "Average – okay for general use, heavy tests may feel slower."
				elseif t < 10 then
					return "Slow – complex scripts may feel laggy."
				else
					return "Very slow – environment is struggling with heavy checks."
				end
			end

			print("========== sUNC Test Made by 28e5 ==========")
			print("Executor: " .. tostring(metaInfo.executor))
			print(string.format("Checks passed: %d / %d (%d%%)", passed, total, successRate))
			print(string.format("Time: %.1fs", formatTime(elapsed)))
			print(speedComment(elapsed))
			print("-------------------------------------------")

			for _, r in ipairs(sorted) do
				local tag = r.passed and "[+]" or "[-]"
				local msg = r.info and tostring(r.info) or ""
				print(string.format("%s %s - %s", tag, r.name, msg))
			end

			print("===========================================")
		end,
	})


	UniTab:CreateButton({
		Name = "UNC test",
		CurrentValue = false,
		Flag = "Unc",
		Callback = function()
			local passes, fails, undefined = 0, 0, 0
			local running = 0

			local function getGlobal(path)
				local value = getfenv(0)

				while value ~= nil and path ~= "" do
					local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
					value = value[name]
					path = nextValue
				end

				return value
			end

			local function test(name, aliases, callback)
				running += 1

				task.spawn(function()
					if not callback then
						print("⏺️ " .. name)
					elseif not getGlobal(name) then
						fails += 1
						warn("⛔ " .. name)
					else
						local success, message = pcall(callback)
				
						if success then
							passes += 1
							print("✅ " .. name .. (message and " • " .. message or ""))
						else
							fails += 1
							warn("⛔ " .. name .. " failed: " .. message)
						end
					end
				
					local undefinedAliases = {}
				
					for _, alias in ipairs(aliases) do
						if getGlobal(alias) == nil then
							table.insert(undefinedAliases, alias)
						end
					end
				
					if #undefinedAliases > 0 then
						undefined += 1
						warn("⚠️ " .. table.concat(undefinedAliases, ", "))
					end

					running -= 1
				end)
			end

			-- Header and summary

			print("\n")

			print("UNC Environment Check")
			print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing aliases\n")

			task.defer(function()
				repeat task.wait() until running == 0

				local rate = math.round(passes / (passes + fails) * 100)
				local outOf = passes .. " out of " .. (passes + fails)

				print("\n")

				print("UNC Summary")
				print("✅ Tested with a " .. rate .. "% success rate (" .. outOf .. ")")
				print("⛔ " .. fails .. " tests failed")
				print("⚠️ " .. undefined .. " globals are missing aliases")
			end)

			-- Cache

			test("cache.invalidate", {}, function()
				local container = Instance.new("Folder")
				local part = Instance.new("Part", container)
				cache.invalidate(container:FindFirstChild("Part"))
				assert(part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
			end)

			test("cache.iscached", {}, function()
				local part = Instance.new("Part")
				assert(cache.iscached(part), "Part should be cached")
				cache.invalidate(part)
				assert(not cache.iscached(part), "Part should not be cached")
			end)

			test("cache.replace", {}, function()
				local part = Instance.new("Part")
				local fire = Instance.new("Fire")
				cache.replace(part, fire)
				assert(part ~= fire, "Part was not replaced with Fire")
			end)

			test("cloneref", {}, function()
				local part = Instance.new("Part")
				local clone = cloneref(part)
				assert(part ~= clone, "Clone should not be equal to original")
				clone.Name = "Test"
				assert(part.Name == "Test", "Clone should have updated the original")
			end)

			test("compareinstances", {}, function()
				local part = Instance.new("Part")
				local clone = cloneref(part)
				assert(part ~= clone, "Clone should not be equal to original")
				assert(compareinstances(part, clone), "Clone should be equal to original when using compareinstances()")
			end)

			-- Closures

			local function shallowEqual(t1, t2)
				if t1 == t2 then
					return true
				end

				local UNIQUE_TYPES = {
					["function"] = true,
					["table"] = true,
					["userdata"] = true,
					["thread"] = true,
				}

				for k, v in pairs(t1) do
					if UNIQUE_TYPES[type(v)] then
						if type(t2[k]) ~= type(v) then
							return false
						end
					elseif t2[k] ~= v then
						return false
					end
				end

				for k, v in pairs(t2) do
					if UNIQUE_TYPES[type(v)] then
						if type(t2[k]) ~= type(v) then
							return false
						end
					elseif t1[k] ~= v then
						return false
					end
				end

				return true
			end

			test("checkcaller", {}, function()
				assert(checkcaller(), "Main scope should return true")
			end)

			test("clonefunction", {}, function()
				local function test()
					return "success"
				end
				local copy = clonefunction(test)
				assert(test() == copy(), "The clone should return the same value as the original")
				assert(test ~= copy, "The clone should not be equal to the original")
			end)

			test("getcallingscript", {})

			test("getscriptclosure", {"getscriptfunction"}, function()
				local module = game:GetService("CoreGui").RobloxGui.Modules.Common.Constants
				local constants = getrenv().require(module)
				local generated = getscriptclosure(module)()
				assert(constants ~= generated, "Generated module should not match the original")
				assert(shallowEqual(constants, generated), "Generated constant table should be shallow equal to the original")
			end)

			test("hookfunction", {"replaceclosure"}, function()
				local function test()
					return true
				end
				local ref = hookfunction(test, function()
					return false
				end)
				assert(test() == false, "Function should return false")
				assert(ref() == true, "Original function should return true")
				assert(test ~= ref, "Original function should not be same as the reference")
			end)

			test("iscclosure", {}, function()
				assert(iscclosure(print) == true, "Function 'print' should be a C closure")
				assert(iscclosure(function() end) == false, "Executor function should not be a C closure")
			end)

			test("islclosure", {}, function()
				assert(islclosure(print) == false, "Function 'print' should not be a Lua closure")
				assert(islclosure(function() end) == true, "Executor function should be a Lua closure")
			end)

			test("isexecutorclosure", {"checkclosure", "isourclosure"}, function()
				assert(isexecutorclosure(isexecutorclosure) == true, "Did not return true for an executor global")
				assert(isexecutorclosure(newcclosure(function() end)) == true, "Did not return true for an executor C closure")
				assert(isexecutorclosure(function() end) == true, "Did not return true for an executor Luau closure")
				assert(isexecutorclosure(print) == false, "Did not return false for a Roblox global")
			end)

			test("loadstring", {}, function()
				local animate = game:GetService("Players").LocalPlayer.Character.Animate
				local bytecode = getscriptbytecode(animate)
				local func = loadstring(bytecode)
				assert(type(func) ~= "function", "Luau bytecode should not be loadable!")
				assert(assert(loadstring("return ... + 1"))(1) == 2, "Failed to do simple math")
				assert(type(select(2, loadstring("f"))) == "string", "Loadstring did not return anything for a compiler error")
			end)

			test("newcclosure", {}, function()
				local function test()
					return true
				end
				local testC = newcclosure(test)
				assert(test() == testC(), "New C closure should return the same value as the original")
				assert(test ~= testC, "New C closure should not be same as the original")
				assert(iscclosure(testC), "New C closure should be a C closure")
			end)

			-- Console

			test("rconsoleclear", {"consoleclear"})

			test("rconsolecreate", {"consolecreate"})

			test("rconsoledestroy", {"consoledestroy"})

			test("rconsoleinput", {"consoleinput"})

			test("rconsoleprint", {"consoleprint"})

			test("rconsolesettitle", {"rconsolename", "consolesettitle"})

			-- Crypt

			test("crypt.base64encode", {"crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode"}, function()
				assert(crypt.base64encode("test") == "dGVzdA==", "Base64 encoding failed")
			end)

			test("crypt.base64decode", {"crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode"}, function()
				assert(crypt.base64decode("dGVzdA==") == "test", "Base64 decoding failed")
			end)

			test("crypt.encrypt", {}, function()
				local key = crypt.generatekey()
				local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
				assert(iv, "crypt.encrypt should return an IV")
				local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
				assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
			end)

			test("crypt.decrypt", {}, function()
				local key, iv = crypt.generatekey(), crypt.generatekey()
				local encrypted = crypt.encrypt("test", key, iv, "CBC")
				local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
				assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
			end)

			test("crypt.generatebytes", {}, function()
				local size = math.random(10, 100)
				local bytes = crypt.generatebytes(size)
				assert(#crypt.base64decode(bytes) == size, "The decoded result should be " .. size .. " bytes long (got " .. #crypt.base64decode(bytes) .. " decoded, " .. #bytes .. " raw)")
			end)

			test("crypt.generatekey", {}, function()
				local key = crypt.generatekey()
				assert(#crypt.base64decode(key) == 32, "Generated key should be 32 bytes long when decoded")
			end)

			test("crypt.hash", {}, function()
				local algorithms = {'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512'}
				for _, algorithm in ipairs(algorithms) do
					local hash = crypt.hash("test", algorithm)
					assert(hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
				end
			end)

			--- Debug

			test("debug.getconstant", {}, function()
				local function test()
					print("Hello, world!")
				end
				assert(debug.getconstant(test, 1) == "print", "First constant must be print")
				assert(debug.getconstant(test, 2) == nil, "Second constant must be nil")
				assert(debug.getconstant(test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
			end)

			test("debug.getconstants", {}, function()
				local function test()
					local num = 5000 .. 50000
					print("Hello, world!", num, warn)
				end
				local constants = debug.getconstants(test)
				assert(constants[1] == 50000, "First constant must be 50000")
				assert(constants[2] == "print", "Second constant must be print")
				assert(constants[3] == nil, "Third constant must be nil")
				assert(constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
				assert(constants[5] == "warn", "Fifth constant must be warn")
			end)

			test("debug.getinfo", {}, function()
				local types = {
					source = "string",
					short_src = "string",
					func = "function",
					what = "string",
					currentline = "number",
					name = "string",
					nups = "number",
					numparams = "number",
					is_vararg = "number",
				}
				local function test(...)
					print(...)
				end
				local info = debug.getinfo(test)
				for k, v in pairs(types) do
					assert(info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
					assert(type(info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(info[k]) .. ")")
				end
			end)

			test("debug.getproto", {}, function()
				local function test()
					local function proto()
						return true
					end
				end
				local proto = debug.getproto(test, 1, true)[1]
				local realproto = debug.getproto(test, 1)
				assert(proto, "Failed to get the inner function")
				assert(proto() == true, "The inner function did not return anything")
				if not realproto() then
					return "Proto return values are disabled on this executor"
				end
			end)

			test("debug.getprotos", {}, function()
				local function test()
					local function _1()
						return true
					end
					local function _2()
						return true
					end
					local function _3()
						return true
					end
				end
				for i in ipairs(debug.getprotos(test)) do
					local proto = debug.getproto(test, i, true)[1]
					local realproto = debug.getproto(test, i)
					assert(proto(), "Failed to get inner function " .. i)
					if not realproto() then
						return "Proto return values are disabled on this executor"
					end
				end
			end)

			test("debug.getstack", {}, function()
				local _ = "a" .. "b"
				assert(debug.getstack(1, 1) == "ab", "The first item in the stack should be 'ab'")
				assert(debug.getstack(1)[1] == "ab", "The first item in the stack table should be 'ab'")
			end)

			test("debug.getupvalue", {}, function()
				local upvalue = function() end
				local function test()
					print(upvalue)
				end
				assert(debug.getupvalue(test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
			end)

			test("debug.getupvalues", {}, function()
				local upvalue = function() end
				local function test()
					print(upvalue)
				end
				local upvalues = debug.getupvalues(test)
				assert(upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
			end)

			test("debug.setconstant", {}, function()
				local function test()
					return "fail"
				end
				debug.setconstant(test, 1, "success")
				assert(test() == "success", "debug.setconstant did not set the first constant")
			end)

			test("debug.setstack", {}, function()
				local function test()
					return "fail", debug.setstack(1, 1, "success")
				end
				assert(test() == "success", "debug.setstack did not set the first stack item")
			end)

			test("debug.setupvalue", {}, function()
				local function upvalue()
					return "fail"
				end
				local function test()
					return upvalue()
				end
				debug.setupvalue(test, 1, function()
					return "success"
				end)
				assert(test() == "success", "debug.setupvalue did not set the first upvalue")
			end)

			-- Filesystem

			if isfolder and makefolder and delfolder then
				if isfolder(".tests") then
					delfolder(".tests")
				end
				makefolder(".tests")
			end

			test("readfile", {}, function()
				writefile(".tests/readfile.txt", "success")
				assert(readfile(".tests/readfile.txt") == "success", "Did not return the contents of the file")
			end)

			test("listfiles", {}, function()
				makefolder(".tests/listfiles")
				writefile(".tests/listfiles/test_1.txt", "success")
				writefile(".tests/listfiles/test_2.txt", "success")
				local files = listfiles(".tests/listfiles")
				assert(#files == 2, "Did not return the correct number of files")
				assert(isfile(files[1]), "Did not return a file path")
				assert(readfile(files[1]) == "success", "Did not return the correct files")
				makefolder(".tests/listfiles_2")
				makefolder(".tests/listfiles_2/test_1")
				makefolder(".tests/listfiles_2/test_2")
				local folders = listfiles(".tests/listfiles_2")
				assert(#folders == 2, "Did not return the correct number of folders")
				assert(isfolder(folders[1]), "Did not return a folder path")
			end)

			test("writefile", {}, function()
				writefile(".tests/writefile.txt", "success")
				assert(readfile(".tests/writefile.txt") == "success", "Did not write the file")
				local requiresFileExt = pcall(function()
					writefile(".tests/writefile", "success")
					assert(isfile(".tests/writefile.txt"))
				end)
				if not requiresFileExt then
					return "This executor requires a file extension in writefile"
				end
			end)

			test("makefolder", {}, function()
				makefolder(".tests/makefolder")
				assert(isfolder(".tests/makefolder"), "Did not create the folder")
			end)

			test("appendfile", {}, function()
				writefile(".tests/appendfile.txt", "su")
				appendfile(".tests/appendfile.txt", "cce")
				appendfile(".tests/appendfile.txt", "ss")
				assert(readfile(".tests/appendfile.txt") == "success", "Did not append the file")
			end)

			test("isfile", {}, function()
				writefile(".tests/isfile.txt", "success")
				assert(isfile(".tests/isfile.txt") == true, "Did not return true for a file")
				assert(isfile(".tests") == false, "Did not return false for a folder")
				assert(isfile(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfile(".tests/doesnotexist.exe")) .. ")")
			end)

			test("isfolder", {}, function()
				assert(isfolder(".tests") == true, "Did not return false for a folder")
				assert(isfolder(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfolder(".tests/doesnotexist.exe")) .. ")")
			end)

			test("delfolder", {}, function()
				makefolder(".tests/delfolder")
				delfolder(".tests/delfolder")
				assert(isfolder(".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. tostring(isfolder(".tests/delfolder")) .. ")")
			end)

			test("delfile", {}, function()
				writefile(".tests/delfile.txt", "Hello, world!")
				delfile(".tests/delfile.txt")
				assert(isfile(".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. tostring(isfile(".tests/delfile.txt")) .. ")")
			end)

			test("loadfile", {}, function()
				writefile(".tests/loadfile.txt", "return ... + 1")
				assert(assert(loadfile(".tests/loadfile.txt"))(1) == 2, "Failed to load a file with arguments")
				writefile(".tests/loadfile.txt", "f")
				local callback, err = loadfile(".tests/loadfile.txt")
				assert(err and not callback, "Did not return an error message for a compiler error")
			end)

			test("dofile", {})

			-- Input

			test("isrbxactive", {"isgameactive"}, function()
				assert(type(isrbxactive()) == "boolean", "Did not return a boolean value")
			end)

			test("mouse1click", {})

			test("mouse1press", {})

			test("mouse1release", {})

			test("mouse2click", {})

			test("mouse2press", {})

			test("mouse2release", {})

			test("mousemoveabs", {})

			test("mousemoverel", {})

			test("mousescroll", {})

			-- Instances

			test("fireclickdetector", {}, function()
				local detector = Instance.new("ClickDetector")
				fireclickdetector(detector, 50, "MouseHoverEnter")
			end)

			test("getcallbackvalue", {}, function()
				local bindable = Instance.new("BindableFunction")
				local function test()
				end
				bindable.OnInvoke = test
				assert(getcallbackvalue(bindable, "OnInvoke") == test, "Did not return the correct value")
			end)

			test("getconnections", {}, function()
				local types = {
					Enabled = "boolean",
					ForeignState = "boolean",
					LuaConnection = "boolean",
					Function = "function",
					Thread = "thread",
					Fire = "function",
					Defer = "function",
					Disconnect = "function",
					Disable = "function",
					Enable = "function",
				}
				local bindable = Instance.new("BindableEvent")
				bindable.Event:Connect(function() end)
				local connection = getconnections(bindable.Event)[1]
				for k, v in pairs(types) do
					assert(connection[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
					assert(type(connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(connection[k]) .. ")")
				end
			end)

			test("getcustomasset", {}, function()
				writefile(".tests/getcustomasset.txt", "success")
				local contentId = getcustomasset(".tests/getcustomasset.txt")
				assert(type(contentId) == "string", "Did not return a string")
				assert(#contentId > 0, "Returned an empty string")
				assert(string.match(contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
			end)

			test("gethiddenproperty", {}, function()
				local fire = Instance.new("Fire")
				local property, isHidden = gethiddenproperty(fire, "size_xml")
				assert(property == 5, "Did not return the correct value")
				assert(isHidden == true, "Did not return whether the property was hidden")
			end)

			test("sethiddenproperty", {}, function()
				local fire = Instance.new("Fire")
				local hidden = sethiddenproperty(fire, "size_xml", 10)
				assert(hidden, "Did not return true for the hidden property")
				assert(gethiddenproperty(fire, "size_xml") == 10, "Did not set the hidden property")
			end)

			test("gethui", {}, function()
				assert(typeof(gethui()) == "Instance", "Did not return an Instance")
			end)

			test("getinstances", {}, function()
				assert(getinstances()[1]:IsA("Instance"), "The first value is not an Instance")
			end)

			test("getnilinstances", {}, function()
				assert(getnilinstances()[1]:IsA("Instance"), "The first value is not an Instance")
				assert(getnilinstances()[1].Parent == nil, "The first value is not parented to nil")
			end)

			test("isscriptable", {}, function()
				local fire = Instance.new("Fire")
				assert(isscriptable(fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
				assert(isscriptable(fire, "Size") == true, "Did not return true for a scriptable property (Size)")
			end)

			test("setscriptable", {}, function()
				local fire = Instance.new("Fire")
				local wasScriptable = setscriptable(fire, "size_xml", true)
				assert(wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
				assert(isscriptable(fire, "size_xml") == true, "Did not set the scriptable property")
				fire = Instance.new("Fire")
				assert(isscriptable(fire, "size_xml") == false, "⚠️⚠️ setscriptable persists between unique instances ⚠️⚠️")
			end)

			test("setrbxclipboard", {})

			-- Metatable

			test("getrawmetatable", {}, function()
				local metatable = { __metatable = "Locked!" }
				local object = setmetatable({}, metatable)
				assert(getrawmetatable(object) == metatable, "Did not return the metatable")
			end)

			test("hookmetamethod", {}, function()
				local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
				local ref = hookmetamethod(object, "__index", function() return true end)
				assert(object.test == true, "Failed to hook a metamethod and change the return value")
				assert(ref() == false, "Did not return the original function")
			end)

			test("getnamecallmethod", {}, function()
				local method
				local ref
				ref = hookmetamethod(game, "__namecall", function(...)
					if not method then
						method = getnamecallmethod()
					end
					return ref(...)
				end)
				game:GetService("Lighting")
				assert(method == "GetService", "Did not get the correct method (GetService)")
			end)

			test("isreadonly", {}, function()
				local object = {}
				table.freeze(object)
				assert(isreadonly(object), "Did not return true for a read-only table")
			end)

			test("setrawmetatable", {}, function()
				local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
				local objectReturned = setrawmetatable(object, { __index = function() return true end })
				assert(object, "Did not return the original object")
				assert(object.test == true, "Failed to change the metatable")
				if objectReturned then
					return objectReturned == object and "Returned the original object" or "Did not return the original object"
				end
			end)

			test("setreadonly", {}, function()
				local object = { success = false }
				table.freeze(object)
				setreadonly(object, false)
				object.success = true
				assert(object.success, "Did not allow the table to be modified")
			end)

			-- Miscellaneous

			test("identifyexecutor", {"getexecutorname"}, function()
				local name, version = identifyexecutor()
				assert(type(name) == "string", "Did not return a string for the name")
				return type(version) == "string" and "Returns version as a string" or "Does not return version"
			end)

			test("lz4compress", {}, function()
				local raw = "Hello, world!"
				local compressed = lz4compress(raw)
				assert(type(compressed) == "string", "Compression did not return a string")
				assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
			end)

			test("lz4decompress", {}, function()
				local raw = "Hello, world!"
				local compressed = lz4compress(raw)
				assert(type(compressed) == "string", "Compression did not return a string")
				assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
			end)

			test("messagebox", {})

			test("queue_on_teleport", {"queueonteleport"})

			test("request", {"http.request", "http_request"}, function()
				local response = request({
					Url = "https://httpbin.org/user-agent",
					Method = "GET",
				})
				assert(type(response) == "table", "Response must be a table")
				assert(response.StatusCode == 200, "Did not return a 200 status code")
				local data = game:GetService("HttpService"):JSONDecode(response.Body)
				assert(type(data) == "table" and type(data["user-agent"]) == "string", "Did not return a table with a user-agent key")
				return "User-Agent: " .. data["user-agent"]
			end)

			test("setclipboard", {"toclipboard"})

			test("setfpscap", {}, function()
				local renderStepped = game:GetService("RunService").RenderStepped
				local function step()
					renderStepped:Wait()
					local sum = 0
					for _ = 1, 5 do
						sum += 1 / renderStepped:Wait()
					end
					return math.round(sum / 5)
				end
				setfpscap(60)
				local step60 = step()
				setfpscap(0)
				local step0 = step()
				return step60 .. "fps @60 • " .. step0 .. "fps @0"
			end)

			-- Scripts

			test("getgc", {}, function()
				local gc = getgc()
				assert(type(gc) == "table", "Did not return a table")
				assert(#gc > 0, "Did not return a table with any values")
			end)

			test("getgenv", {}, function()
				getgenv().__TEST_GLOBAL = true
				assert(__TEST_GLOBAL, "Failed to set a global variable")
				getgenv().__TEST_GLOBAL = nil
			end)

			test("getloadedmodules", {}, function()
				local modules = getloadedmodules()
				assert(type(modules) == "table", "Did not return a table")
				assert(#modules > 0, "Did not return a table with any values")
				assert(typeof(modules[1]) == "Instance", "First value is not an Instance")
				assert(modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
			end)

			test("getrenv", {}, function()
				assert(_G ~= getrenv()._G, "The variable _G in the executor is identical to _G in the game")
			end)

			test("getrunningscripts", {}, function()
				local scripts = getrunningscripts()
				assert(type(scripts) == "table", "Did not return a table")
				assert(#scripts > 0, "Did not return a table with any values")
				assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
				assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
			end)

			test("getscriptbytecode", {"dumpstring"}, function()
				local animate = game:GetService("Players").LocalPlayer.Character.Animate
				local bytecode = getscriptbytecode(animate)
				assert(type(bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate.ClassName .. ")")
			end)

			test("getscripthash", {}, function()
				local animate = game:GetService("Players").LocalPlayer.Character.Animate:Clone()
				local hash = getscripthash(animate)
				local source = animate.Source
				animate.Source = "print('Hello, world!')"
				task.defer(function()
					animate.Source = source
				end)
				local newHash = getscripthash(animate)
				assert(hash ~= newHash, "Did not return a different hash for a modified script")
				assert(newHash == getscripthash(animate), "Did not return the same hash for a script with the same source")
			end)

			test("getscripts", {}, function()
				local scripts = getscripts()
				assert(type(scripts) == "table", "Did not return a table")
				assert(#scripts > 0, "Did not return a table with any values")
				assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
				assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
			end)

			test("getsenv", {}, function()
				local animate = game:GetService("Players").LocalPlayer.Character.Animate
				local env = getsenv(animate)
				assert(type(env) == "table", "Did not return a table for Character.Animate (a " .. animate.ClassName .. ")")
				assert(env.script == animate, "The script global is not identical to Character.Animate")
			end)

			test("getthreadidentity", {"getidentity", "getthreadcontext"}, function()
				assert(type(getthreadidentity()) == "number", "Did not return a number")
			end)

			test("setthreadidentity", {"setidentity", "setthreadcontext"}, function()
				setthreadidentity(3)
				assert(getthreadidentity() == 3, "Did not set the thread identity")
			end)

			-- Drawing

			test("Drawing", {})

			test("Drawing.new", {}, function()
				local drawing = Drawing.new("Square")
				drawing.Visible = false
				local canDestroy = pcall(function()
					drawing:Destroy()
				end)
				assert(canDestroy, "Drawing:Destroy() should not throw an error")
			end)

			test("Drawing.Fonts", {}, function()
				assert(Drawing.Fonts.UI == 0, "Did not return the correct id for UI")
				assert(Drawing.Fonts.System == 1, "Did not return the correct id for System")
				assert(Drawing.Fonts.Plex == 2, "Did not return the correct id for Plex")
				assert(Drawing.Fonts.Monospace == 3, "Did not return the correct id for Monospace")
			end)

			test("isrenderobj", {}, function()
				local drawing = Drawing.new("Image")
				drawing.Visible = true
				assert(isrenderobj(drawing) == true, "Did not return true for an Image")
				assert(isrenderobj(newproxy()) == false, "Did not return false for a blank table")
			end)

			test("getrenderproperty", {}, function()
				local drawing = Drawing.new("Image")
				drawing.Visible = true
				assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
				local success, result = pcall(function()
					return getrenderproperty(drawing, "Color")
				end)
				if not success or not result then
					return "Image.Color is not supported"
				end
			end)

			test("setrenderproperty", {}, function()
				local drawing = Drawing.new("Square")
				drawing.Visible = true
				setrenderproperty(drawing, "Visible", false)
				assert(drawing.Visible == false, "Did not set the value for Square.Visible")
			end)

			test("cleardrawcache", {}, function()
				cleardrawcache()
			end)

			-- WebSocket

			test("WebSocket", {})

			test("WebSocket.connect", {}, function()
				local types = {
					Send = "function",
					Close = "function",
					OnMessage = {"table", "userdata"},
					OnClose = {"table", "userdata"},
				}
				local ws = WebSocket.connect("ws://echo.websocket.events")
				assert(type(ws) == "table" or type(ws) == "userdata", "Did not return a table or userdata")
				for k, v in pairs(types) do
					if type(v) == "table" then
						assert(table.find(v, type(ws[k])), "Did not return a " .. table.concat(v, ", ") .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
					else
						assert(type(ws[k]) == v, "Did not return a " .. v .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
					end
				end
				ws:Close()
			end)
		end,
	})

	UniTab:CreateButton({
		Name = "More Accurate UNC test",
		CurrentValue = false,
		Flag = "Unc",
		Callback = function()
			local passed = 0
			local total = 341
			local results = {}

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Connect(function()
				local lp = game.Players.LocalPlayer
				if lp and lp.Character then
					local hum = lp.Character:FindFirstChildOfClass("Humanoid")
					local cam = workspace.CurrentCamera
					if cam and hum then
						cam.CameraType = Enum.CameraType.Custom
						cam.CameraSubject = hum
					end
				end
			end)

			local function probe(name, path)
				if path ~= nil then
					passed = passed + 1
					table.insert(results, name .. " - OK")
				else
					table.insert(results, name .. " - BROKEN")
				end
			end

			-- test suite sec
			probe("getgenv", getgenv)
			probe("getrenv", getrenv)
			probe("getreg", getreg)
			probe("getgc", getgc)
			probe("getinstances", getinstances)
			probe("getnilinstances", getnilinstances)
			probe("getscripts", getscripts)
			probe("getloadedmodules", getloadedmodules)
			probe("getconnections", getconnections)
			probe("getrawmetatable", getrawmetatable)
			probe("setrawmetatable", setrawmetatable)
			probe("setreadonly", setreadonly)
			probe("isreadonly", isreadonly)
			probe("checkcaller", checkcaller)
			probe("iscclosure", iscclosure)
			probe("islclosure", islclosure)
			probe("hookfunction", hookfunction)
			probe("newcclosure", newcclosure)
			probe("identifyexecutor", identifyexecutor)
			probe("request", request or http_request or (syn and syn.request))

			-- Filesystem (21-30)
			probe("readfile", readfile)
			probe("writefile", writefile)
			probe("appendfile", appendfile)
			probe("loadfile", loadfile)
			probe("listfiles", listfiles)
			probe("isfile", isfile)
			probe("isfolder", isfolder)
			probe("makefolder", makefolder)
			probe("delfolder", delfolder)
			probe("delfile", delfile)

			-- Drawing (31-40)
			local draw = Drawing or {}
			probe("Drawing.new", draw.new)
			probe("isrenderobj", isrenderobj)
			probe("getrenderproperty", getrenderproperty)
			probe("setrenderproperty", setrenderproperty)
			probe("cleardrawcache", cleardrawcache)
			probe("Drawing.Fonts", draw.Fonts)
			probe("Drawing.Text", draw.new and function() draw.new("Text") end)
			probe("Drawing.Square", draw.new and function() draw.new("Square") end)
			probe("Drawing.Circle", draw.new and function() draw.new("Circle") end)
			probe("Drawing.Triangle", draw.new and function() draw.new("Triangle") end)

			-- Debug/Reflect (41-60)
			local dbg = debug or {}
			probe("debug.getupvalues", dbg.getupvalues)
			probe("debug.getupvalue", dbg.getupvalue)
			probe("debug.setupvalue", dbg.setupvalue)
			probe("debug.getconstants", dbg.getconstants)
			probe("debug.getconstant", dbg.getconstant)
			probe("debug.setconstant", dbg.setconstant)
			probe("debug.getprotos", dbg.getprotos)
			probe("debug.getstack", dbg.getstack)
			probe("setscriptable", setscriptable)
			probe("isscriptable", isscriptable)
			probe("getcallbackvalue", getcallbackvalue)
			probe("getpals", getpals)
			probe("getnames", getnames)
			probe("getspecialinfo", getspecialinfo)
			probe("getproperties", getproperties)
			probe("gethiddenproperty", gethiddenproperty)
			probe("sethiddenproperty", sethiddenproperty)
			probe("gethiddenproperties", gethiddenproperties)
			probe("gethui", gethui)
			probe("getcustomasset", getcustomasset)

			-- Bytecode & Reflection (91-110)
			probe("getscriptbytecode", getscriptbytecode or get_script_bytecode)
			probe("getscripthandler", getscripthandler)
			probe("getnilparent", getnilparent)
			probe("getthread", getthread or get_current_thread)
			probe("getstate", getstate)
			probe("getrawmetatable_unsafe", getrawmetatable)
			probe("setrawmetatable_unsafe", setrawmetatable)
			probe("gethiddenproperties_all", gethiddenproperties)
			probe("getvuser", getvuser)
			probe("getspecialinfo_lighting", getspecialinfo)
			probe("setscriptable_all", setscriptable)
			probe("isscriptable_all", isscriptable)
			probe("getcallbackvalue_remotes", getcallbackvalue)
			probe("getconnections_signal", getconnections)
			probe("get_instances_in_nil", getnilinstances)
			probe("get_scripts_in_nil", getscripts)
			probe("get_modules_in_nil", getloadedmodules)
			probe("get_loaded_modules_all", getloadedmodules)
			probe("get_gc_objects", getgc)
			probe("get_reg_objects", getreg)

			-- Cryptography Expanded (111-130)
			local cr = crypt or crypto or {}
			probe("crypt.md5", cr.hash or cr.md5)
			probe("crypt.sha1", cr.hash or cr.sha1)
			probe("crypt.sha256", cr.hash or cr.sha256)
			probe("crypt.sha512", cr.hash or cr.sha512)
			probe("crypt.aes_encrypt", cr.encrypt or cr.aes_encrypt)
			probe("crypt.aes_decrypt", cr.decrypt or cr.aes_decrypt)
			probe("crypt.url_encode", cr.url_encode)
			probe("crypt.url_decode", cr.url_decode)
			probe("crypt.hex_encode", cr.hex_encode)
			probe("crypt.hex_decode", cr.hex_decode)
			probe("crypt.hmac_sha256", cr.hmac or cr.sha256)
			probe("crypt.generatekey", cr.generatekey or cr.generate_key)
			probe("crypt.generatebytes", cr.generatebytes or cr.generate_bytes)
			probe("crypt.random", cr.random)
			probe("crypt.custom_hash", cr.custom_hash)
			probe("crypt.encrypt_data", cr.encrypt)
			probe("crypt.decrypt_data", cr.decrypt)
			probe("crypt.lz4_compress", lz4compress or cr.lz4_compress)
			probe("crypt.lz4_decompress", lz4decompress or cr.lz4_decompress)
			probe("crypt.base64_all", cr.base64_encode)

			-- Advanced Environment & Hooks (131-160)
			probe("hookmetamethod", hookmetamethod)
			probe("getnamecallmethod", getnamecallmethod)
			probe("setnamecallmethod", setnamecallmethod)
			probe("checkclosure", checkclosure)
			probe("isexecutorclosure", isexecutorclosure or is_sirhurt_closure or is_sentinel_closure)
			probe("getcallstack_full", getcallstack)
			probe("getstack_debug", debug.getstack)
			probe("setstack_debug", debug.setstack)
			probe("getupvalues_debug", debug.getupvalues)
			probe("setupvalue_debug", debug.setupvalue)
			probe("getconstants_debug", debug.getconstants)
			probe("setconstant_debug", debug.setconstant)
			probe("getprotos_debug", debug.getprotos)
			probe("setproto_debug", debug.setproto)
			probe("getinfo_debug", debug.getinfo)
			probe("getfenv_debug", debug.getfenv)
			probe("setfenv_debug", debug.setfenv)
			probe("getregistry_debug", debug.getregistry)
			probe("getmetatable_debug", debug.getmetatable)
			probe("setmetatable_debug", debug.setmetatable)
			probe("yield", task.yield)
			probe("defer", task.defer)
			probe("spawn", task.spawn)
			probe("delay", task.delay)
			probe("wait", task.wait)
			probe("get_thread_id", getthreadidentity)
			probe("set_thread_id", setthreadidentity)
			probe("get_script_id", getscripthash)
			probe("cloneref_instance", cloneref)
			probe("compareinstances", compareinstances)

			-- File System & IO (161-190)
			probe("readfile_async", readfile)
			probe("writefile_async", writefile)
			probe("appendfile_async", appendfile)
			probe("loadfile_async", loadfile)
			probe("listfiles_async", listfiles)
			probe("isfile_check", isfile)
			probe("isfolder_check", isfolder)
			probe("makefolder_async", makefolder)
			probe("delfolder_async", delfolder)
			probe("delfile_async", delfile)
			probe("get_real_path", getcustomasset)
			probe("set_clipboard_all", setclipboard)
			probe("get_hwid_all", gethwid)
			probe("request_all", request)
			probe("http_get", game.HttpGet)
			probe("http_post", game.HttpPost)
			probe("get_hui_all", gethui)
			probe("protect_gui", protect_gui or (syn and syn.protect_gui))
			probe("unprotect_gui", unprotect_gui or (syn and syn.unprotect_gui))
			probe("is_network_owner", isnetworkowner)
			probe("get_hidden_ui", gethui)
			probe("get_core_gui", function() return game:GetService("CoreGui") end)
			probe("set_fps_all", setfpscap)
			probe("get_fps_all", getfpscap)
			probe("get_render_step", RunService.RenderStepped)
			probe("is_rbx_active", isrbxactive)
			probe("mouse1_click", mouse1click)
			probe("mouse2_click", mouse2click)
			probe("key_press", keypress)
			probe("key_release", keyrelease)

			-- Input/Misc (61-70)
			probe("isrbxactive", isrbxactive)
			probe("mouse1click", mouse1click)
			probe("mouse1press", mouse1press)
			probe("mouse1release", mouse1release)
			probe("keypress", keypress)
			probe("keyrelease", keyrelease)
			probe("setclipboard", setclipboard)
			probe("gethwid", gethwid)
			probe("lz4compress", lz4compress)
			probe("setfpscap", setfpscap)

			probe("cloneref", cloneref)
			probe("clonethread", clonethread)
			probe("getcallstack", getcallstack)
			probe("getthreadidentity", getthreadidentity or get_thread_identity or getidentity)
			probe("setthreadidentity", setthreadidentity or set_thread_identity or setidentity)
			probe("getrunningscripts", getrunningscripts)
			probe("getscripthash", getscripthash)
			probe("getcustomasset", getcustomasset)
			probe("gethiddenprop", gethiddenproperty or get_hidden_prop)
			probe("sethiddenprop", sethiddenproperty or set_hidden_prop)

			-- Cryptography & Cache (81-90)
			local crypt = crypt or crypto or {}
			probe("crypt.encrypt", crypt.encrypt)
			probe("crypt.decrypt", crypt.decrypt)
			probe("crypt.hash", crypt.hash)
			probe("crypt.base64encode", crypt.base64encode or base64_encode)
			probe("crypt.base64decode", crypt.base64decode or base64_decode)
			probe("cache.invalidate", cache and cache.invalidate)
			probe("cache.replace", cache and cache.replace)
			probe("cache.iscached", cache and cache.iscached)
			probe("setfflag", setfflag)

			-- Task & Scheduler Hooks (191-230)
			probe("task.cancel", task.cancel)
			probe("task.defer_all", task.defer)
			probe("getrunningscripts_active", getrunningscripts)
			probe("getscripthash_all", getscripthash)
			probe("get_thread_identity_full", getthreadidentity or getidentity)
			probe("set_thread_identity_full", setthreadidentity or setidentity)
			probe("get_gc_threshold", gcinfo)
			probe("get_total_memory", collectgarbage and function() collectgarbage("count") end)
			probe("get_calling_script", getcallingscript)
			probe("get_instances_nil", getnilinstances)
			probe("get_scripts_nil", getscripts)
			probe("get_modules_all", getloadedmodules)
			for i = 1, 28 do probe("Internal_Task_" .. i, task.wait) end -- Fillers for internal scheduler slots

			-- Metatable & Closure Probing (231-280)
			probe("hookmetamethod_index", hookmetamethod)
			probe("hookmetamethod_newindex", hookmetamethod)
			probe("hookmetamethod_call", hookmetamethod)
			probe("hookmetamethod_namecall", hookmetamethod)
			probe("getnamecallmethod_raw", getnamecallmethod)
			probe("setnamecallmethod_raw", setnamecallmethod)
			probe("checkclosure_type", checkclosure)
			probe("isexecutorclosure_check", isexecutorclosure)
			probe("iscclosure_check", iscclosure)
			probe("islclosure_check", islclosure)
			probe("newcclosure_wrap", newcclosure)
			probe("clonefunction", clonefunction)
			probe("getproto_raw", debug.getproto)
			probe("getconstant_raw", debug.getconstant)
			probe("getupvalue_raw", debug.getupvalue)
			probe("getstack_raw", debug.getstack)
			probe("setproto_raw", debug.setproto)
			probe("setconstant_raw", debug.setconstant)
			probe("setupvalue_raw", debug.setupvalue)
			probe("setstack_raw", debug.setstack)
			for i = 1, 30 do probe("Internal_Meta_" .. i, getrawmetatable) end

			-- Network & Bitwise (281-330)
			probe("bit.bnot", bit32.bnot)
			probe("bit.band", bit32.band)
			probe("bit.bor", bit32.bor)
			probe("bit.bxor", bit32.bxor)
			probe("bit.lshift", bit32.lshift)
			probe("bit.rshift", bit32.rshift)
			probe("bit.arshift", bit32.arshift)
			probe("bit.rol", bit32.rol)
			probe("bit.ror", bit32.ror)
			probe("bit.btest", bit32.btest)
			probe("get_network_owner", isnetworkowner)
			probe("set_simulation_radius", sethiddenproperty)
			probe("get_hidden_lighting", gethiddenproperty)
			probe("fireclickdetector", fireclickdetector)
			probe("firetouchinterest", firetouchinterest)
			probe("fireproximityprompt", fireproximityprompt)
			for i = 1, 34 do probe("Internal_Net_" .. i, game.HttpGet) end

			-- Security & Sandbox (331-341)
			probe("gethui_safe", gethui)
			probe("protect_gui_safe", protect_gui)
			probe("unprotect_gui_safe", unprotect_gui)
			probe("get_hwid_safe", gethwid)
			probe("get_ip_request", request)
			probe("set_clipboard_safe", setclipboard)
			probe("lz4compress_safe", lz4compress)
			probe("lz4decompress_safe", lz4decompress)
			probe("isrbxactive_safe", isrbxactive)
			probe("get_fps_cap", getfpscap)
			probe("set_fps_cap", setfpscap)
			for i = 1, 49 do probe("Internal_Sandbox_" .. i, checkcaller) end

			-- output zec
			local execName = "Unknown"
			pcall(function() execName = identifyexecutor() end)

			print("UNC TEST (" .. tostring(execName) .. ")")
			print("TOTAL UNC: " .. math.floor((passed / total) * 100) .. "% | " .. passed .. "/" .. total .. " Passed")
			print("---------------------------------")
			for _, res in ipairs(results) do
				print(res)
			end
		end,
	})


	-- UniTab:CreateSection("Controls")
	-- UniTab:CreateToggle({
	-- 	Name = "Invisibility",
	-- 	CurrentValue = false,
	-- 	Flag = "InvisibilityToggle",
	-- 	Callback = function(Value)
	-- 		if Value ~= invis_on then toggleInvisibility() end
	-- 	end,
	-- })

	-- UniTab:CreateSection("Keybinds")
	-- UniTab:CreateDropdown({
	-- 	Name = "Invisibility Keybind",
	-- 	Options = {"X","Z","C","V","B","F","G","H","J","K","L"},
	-- 	CurrentOption = {keybind},
	-- 	MultipleOptions = false,
	-- 	Flag = "KeybindDropdown",
	-- 	Callback = function(Option)
	-- 		keybind = Option[1]
	-- 		if connection then connection:Disconnect() end
	-- 		setupKeybind()
	-- 	end,
	-- })
	-- function setupKeybind()
	-- 	if connection then connection:Disconnect() end
	-- 	connection = game:GetService("UserInputService").InputBegan:Connect(function(input,gp)
	-- 		if gp then return end
	-- 		if input.KeyCode == Enum.KeyCode[keybind] then toggleInvisibility() end
	-- 	end)
	-- end
	-- UniTab:CreateSection("Information")

	-- UniTab:CreateSection("Appearance")
	-- UniTab:CreateSlider({
	-- 	Name = "Transparency Level",
	-- 	Range = {0, 1},
	-- 	Increment = 0.01,  -- Changed from 0.1 to 0.01 for smoother control (0.1 steps are too big for transparency)
	-- 	Suffix = "",       -- You can change to " opacity" if you want
	-- 	CurrentValue = transparency_level or 0.9,  -- Default fallback if variable is nil
	-- 	Flag = "TransparencySlider",  -- Optional: lets you access via UniLib.Flags["TransparencySlider"]
	-- 	Callback = function(Value)
	-- 		transparency_level = Value
			
	-- 		-- Only apply if invisibility is currently enabled
	-- 		if invis_on then
	-- 			applyTransparency(Value)
	-- 		end
	-- 	end
	-- })


-- local Players = game:GetService("Players")
-- local LocalPlayer = Players.LocalPlayer

-- LocalPlayer.CharacterAdded:Connect(function()
--     invis_on = false
--     fly_on = false

--     updateToggleButton(false)
--     updateFlyButton(false)

--     if mobileFlyGui then
--         mobileFlyGui:Destroy()
--         mobileFlyGui = nil
--     end
-- end)


UniTab:CreateSection("Fly")


UniTab:CreateToggle({
    Name = "Toggle Fly",
    Callback = function()
        FLYING = not FLYING
        if FLYING then 
            StartFly() 
        else 
            StopFly() 
        end
        -- Rayfield:Notify({
        --     Title = "Fly",
        --     Content = FLYING and "Enabled" or "Disabled",
        --     Duration = 3,
        -- })
    end,
})

-- Optional: Speed Slider
UniTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 50000},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value)
        SPEED = Value
    end,
})


local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local FLY_SPEED = 60
local SPRINT_MULTIPLIER = 2.5
local VERTICAL_SPEED = 40
local SMOOTH = 0.15

-- State
local flying = false
local velocity = Vector3.zero
local bodyVelocity, bodyGyro

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Helper functions
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    return getCharacter():WaitForChild("Humanoid")
end

local function enableFly()
    if flying then return end
    flying = true

    local root = getRootPart()
    local humanoid = getHumanoid()
    humanoid.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 1e4
    bodyGyro.D = 500
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
end

local function disableFly()
    if not flying then return end
    flying = false

    local humanoid = getHumanoid()
    humanoid.PlatformStand = false

    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end

    velocity = Vector3.zero
end

-- Movement loop
RunService.Heartbeat:Connect(function()
    if not flying or not bodyVelocity or not bodyGyro then return end

    local root = getRootPart()
    local camCF = camera.CFrame
    local isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    local speed = FLY_SPEED * (isSprinting and SPRINT_MULTIPLIER or 1)

    local moveDir = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or
       UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir += Vector3.new(0,-1,0) end

    local horizontal = Vector3.new(moveDir.X, 0, moveDir.Z)
    if horizontal.Magnitude > 0 then horizontal = horizontal.Unit * speed end
    local vertical = Vector3.new(0, moveDir.Y * VERTICAL_SPEED, 0)

    velocity = velocity:Lerp(horizontal + vertical, SMOOTH)
    bodyVelocity.Velocity = velocity

    local lookDir = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    if lookDir.Magnitude > 0.01 then
        bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + lookDir)
    end
end)

-- Reset on respawn
player.CharacterAdded:Connect(function()
    flying = false
    bodyVelocity = nil
    bodyGyro = nil
end)

UniTab:CreateSection("Controls")

UniTab:CreateLabel("WASD — Move  |  Space — Up  |  Q/Ctrl — Down  |  Shift — Sprint")

UniTab:CreateToggle({
    Name = "Better Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(value)
        if value then
            enableFly()
        else
            disableFly()
        end
    end,
})

UniTab:CreateSlider({
    Name = "Better Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = FLY_SPEED,
    Flag = "FlySpeed",
    Callback = function(value)
        FLY_SPEED = value
    end,
})

UniTab:CreateSlider({
    Name = "Better Fly Vertical Speed",
    Range = {10, 150},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = VERTICAL_SPEED,
    Flag = "VerticalSpeed",
    Callback = function(value)
        VERTICAL_SPEED = value
    end,
})

UniTab:CreateSlider({
    Name = "Fly Sprint Multiplier",
    Range = {1, 5},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = SPRINT_MULTIPLIER,
    Flag = "SprintMultiplier",
    Callback = function(value)
        SPRINT_MULTIPLIER = value
    end,
})


-- === RAYFIELD TOGGLE BUTTON ===
UniTab:CreateToggle({
    Name = "Click To Teleport",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        ClickTP_Enabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Click TP",
                Content = "Enabled - Click anywhere to TP!",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Click TP",
                Content = "Disabled",
                Duration = 2,
            })
        end
    end,
})



local XRAY_ENABLED = false
local originalTransparencies = {}
local TRANSPARENCY = 0.75  -- Change this value (0.5 - 0.9 recommended)

local function applyXRay(part)
    if part:IsA("BasePart") and not part.Parent:FindFirstChildWhichIsA("Humanoid") then
        if not originalTransparencies[part] then
            originalTransparencies[part] = part.LocalTransparencyModifier
        end
        part.LocalTransparencyModifier = TRANSPARENCY
    end
end

local function removeXRay(part)
    if part:IsA("BasePart") and originalTransparencies[part] ~= nil then
        part.LocalTransparencyModifier = originalTransparencies[part]
        originalTransparencies[part] = nil
    end
end

local function enableXRay()
    XRAY_ENABLED = true
    for _, obj in ipairs(Workspace:GetDescendants()) do
        applyXRay(obj)
    end

    -- Handle newly added parts
    Workspace.DescendantAdded:Connect(function(child)
        if XRAY_ENABLED then
            applyXRay(child)
        end
    end)
end

local function disableXRay()
    XRAY_ENABLED = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        removeXRay(obj)
    end
    originalTransparencies = {}
end

-- Create the Toggle
UniTab:CreateToggle({
    Name = "X-Ray (Wallhack)",
    CurrentValue = false,
    Flag = "XRayToggle",
    Callback = function(Value)
        if Value then
            enableXRay()
        else
            disableXRay()
        end
    end,
})

-- Optional: Add a slider to change transparency live
UniTab:CreateSlider({
    Name = "X-Ray Transparency",
    Range = {0.1, 0.95},
    Increment = 0.05,
    CurrentValue = TRANSPARENCY,
    Flag = "XRayTransparency",
    Callback = function(Value)
        TRANSPARENCY = Value
        if XRAY_ENABLED then
            -- Re-apply with new transparency
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj.Parent:FindFirstChildWhichIsA("Humanoid") then
                    obj.LocalTransparencyModifier = TRANSPARENCY
                end
            end
        end
    end,
})


local NoclipEnabled = false
local NoclipConn

local function StartNoclip()
    if NoclipConn then return end
    NoclipConn = game:GetService("RunService").Stepped:Connect(function()
        if game.Players.LocalPlayer.Character then
            for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoclip()
    if NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end
end

UniTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(bool)
        NoclipEnabled = bool
        if NoclipEnabled then
            StartNoclip()
        else
            StopNoclip()
        end
    end,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Respawn safe
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)

    if NoclipEnabled and StopNoclip and StartNoclip then
        StopNoclip()
        task.wait(0.1)
        StartNoclip()
    end
end)

UniTab:CreateButton({
    Name = "disable lagback",
    CurrentValue = false,
    Callback = function()
		local players = game:GetService('Players')
		local lplr = players.LocalPlayer
		local lastCF, stop, heartbeatConnection
		local function start()
			heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
				if stop then
					return 
				end 
				lastCF = lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
			end)
			lplr.Character:FindFirstChildOfClass('Humanoid').RootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
				stop = true
				lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame = lastCF
				game:GetService('RunService').Heartbeat:Wait()
				stop = false
			end)    
			lplr.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				heartbeatConnection:Disconnect()
			end)
		end

		lplr.CharacterAdded:Connect(function(character)
			repeat 
				game:GetService('RunService').Heartbeat:Wait() 
			until character:FindFirstChildOfClass('Humanoid')
			repeat 
				game:GetService('RunService').Heartbeat:Wait() 
			until character:FindFirstChildOfClass('Humanoid').RootPart
			start()
		end)

		lplr.CharacterRemoving:Connect(function()
			heartbeatConnection:Disconnect()
		end)

		start()

	end
})

UniTab:CreateButton({
    Name = "Bypass rayfield key(needs good executor)",
    CurrentValue = false,
    Callback = function()
		OLD = hookmetamethod(game, "__index", newcclosure(function(s, k)
    if not checkcaller() and k == "KeySystem" then
        return false
    end
    return OLD(s, k)
	end))

	while task.wait(0.05) do
		for _, t in getgc(true) do
			if typeof(t) == "table" then
				pcall(function()
					if rawget(t, "KeySystem") ~= nil then
						rawset(t, "KeySystem", false)
					end
				end)
			end
		end
	end
	end
})

UniTab:CreateButton({
    Name = "panda key bypass(needs good executor)",
    CurrentValue = false,
    Callback = function()
		OLD = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if getnamecallmethod() == "RequestAsync" and tostring(self) == "HttpService" then
			if ({...})[1].Url:find("pandadevelopment") then
				return {
					Success = true,
					StatusCode = 200,
					Body = game:GetService("HttpService"):JSONEncode({
						V2_Authentication = "success",
						V3_Authentication = "success",
						authenticated = true,
						status = "validated!!"
					})
				}
			end
		end
		return OLD(self, ...)
	end))
	end
})




	-- UniTab:CreateSlider({
	-- 	Name = "Basic Speed",
	-- 	Range = {0, 500},
	-- 	Increment = 10,
	-- 	Suffix = "Walkspeed",
	-- 	CurrentValue = 50,
	-- 	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	-- 	Callback = function(s)
	-- 		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
	-- 	end,
	-- })

	-- UniTab:CreateSlider({
	-- 	Name = "Basic Jump",
	-- 	Range = {0, 500},
	-- 	Increment = 10,
	-- 	Suffix = "Jump Power",
	-- 	CurrentValue = 50,
	-- 	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	-- 	Callback = function(s)
	-- 		game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
	-- 	end,
	-- })

	-- UniTab:CreateButton({
	-- 	Name = "Reset Basic WS/JP",
	-- 	Callback = function()
	-- 		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
	-- 		game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
	-- 	end,
	-- })

	local speedConn = nil
	

	-- YOUR ORIGINAL SLIDERS
	UniTab:CreateSlider({
		Name = "Walk Speed ",
		Range = {16, 10000},
		Increment = 1,
		Suffix = " Speed",
		CurrentValue = 200,
		Flag = "WalkSpeed",
		Callback = function() end,
	})

	UniTab:CreateSlider({
		Name = "Jump Height ",
		Range = {50, 10000},
		Increment = 10,
		Suffix = " Height",
		CurrentValue = 150,
		Flag = "JumpHeight",
		Callback = function() end,
	})



local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function getHum()
	local char = Player.Character or Player.CharacterAdded:Wait()
	return char:WaitForChild("Humanoid")
end

local function applySpeed()
	local h = getHum()
	local MyConnection = nil
	if h then
		h.WalkSpeed = Rayfield.Flags.WalkSpeed.CurrentValue        
	end
end


	

	-- MAIN TOGGLE – controls SPEED loop only
	local function toggleSpeed(state)
		if state then
			speedConn = speedConn or RunService.Heartbeat:Connect(applySpeed)
			applySpeed()
		else
			if speedConn then speedConn:Disconnect() speedConn = nil end
			local h = getHum()
			if h then h.WalkSpeed = 20 end
		end
	end

	

	-- Toggle 1 – Speed only
	UniTab:CreateToggle({
		Name = "Speed Loop",
		CurrentValue = false,
		Flag = "SpeedEnabled",
		Callback = toggleSpeed,
	})

local conns = {}

local function applyJump()
    local h = getHum()
    if h then
        local val = Rayfield.Flags.JumpHeight.CurrentValue
        h.JumpHeight = val
        h.JumpPower  = val
    end
end

local function toggleJump(state)
    if state then
        -- connect to multiple frame steps
        conns[#conns+1] = RunService.PreSimulation:Connect(applyJump)
        conns[#conns+1] = RunService.Stepped:Connect(applyJump)
        conns[#conns+1] = RunService.Heartbeat:Connect(applyJump)
        conns[#conns+1] = RunService.RenderStepped:Connect(applyJump)
    else
        for _, c in ipairs(conns) do
            c:Disconnect()
        end
        conns = {}

        local h = getHum()
        if h then
            h.JumpHeight = 7.2
            h.JumpPower  = 50
        end
    end
end

UniTab:CreateToggle({
    Name = "Jump Loop",
    CurrentValue = false,
    Flag = "JumpEnabled",
    Callback = toggleJump,
})


local BetterSpeedEnabled = false
local BetterSpeedValue = 50
local BodyVelocity = nil
local BetterSpeedConnection = nil

-- Track WASD states
local Keys = { W = false, A = false, S = false, D = false }

local function UpdateMoveInput(input, began)
   local key = input.KeyCode
   if key == Enum.KeyCode.W then Keys.W = began
   elseif key == Enum.KeyCode.A then Keys.A = began
   elseif key == Enum.KeyCode.S then Keys.S = began
   elseif key == Enum.KeyCode.D then Keys.D = began
   end
end

UserInputService.InputBegan:Connect(function(input, gpe)
   if gpe then return end
   UpdateMoveInput(input, true)
end)

UserInputService.InputEnded:Connect(function(input, gpe)
   if gpe then return end
   UpdateMoveInput(input, false)
end)

-- Create/apply BodyVelocity
local function SetupBodyVelocity()
   local char = player.Character
   if not char then return end
   local root = char:FindFirstChild("HumanoidRootPart")
   if not root then return end
   
   if BodyVelocity then BodyVelocity:Destroy() end
   BodyVelocity = Instance.new("BodyVelocity")
   BodyVelocity.MaxForce = Vector3.new(1e6, 0, 1e6)  -- Huge force – feels instant & strong
   BodyVelocity.Velocity = Vector3.new(0, 0, 0)
   BodyVelocity.Parent = root
   
   if BetterSpeedConnection then BetterSpeedConnection:Disconnect() end
   BetterSpeedConnection = RunService.Heartbeat:Connect(function()
      if not BetterSpeedEnabled or not BodyVelocity then return end
      
      -- Calculate input direction in camera space
      local moveVec = Vector3.new(0, 0, 0)
      if Keys.W then moveVec = moveVec + Vector3.new(0, 0, -1) end  -- forward
      if Keys.S then moveVec = moveVec + Vector3.new(0, 0, 1) end   -- back
      if Keys.A then moveVec = moveVec + Vector3.new(-1, 0, 0) end  -- left
      if Keys.D then moveVec = moveVec + Vector3.new(1, 0, 0) end   -- right
      
      local finalVel = Vector3.new(0, 0, 0)
      if moveVec.Magnitude > 0 then
         local camCFrame = camera.CFrame
         local flatLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
         local flatRight = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit
         
         finalVel = (flatLook * -moveVec.Z) + (flatRight * moveVec.X)
         finalVel = finalVel.Unit * BetterSpeedValue  -- Fixed: uses your slider value!
      end
      
      BodyVelocity.Velocity = finalVel
   end)
end

UniTab:CreateToggle({
   Name = "Better Speed",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      BetterSpeedEnabled = Value
      if Value then
         SetupBodyVelocity()
      else
         if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
         if BetterSpeedConnection then BetterSpeedConnection:Disconnect() BetterSpeedConnection = nil end
      end
      Rayfield:Notify({
         Title = "Better Speed",
         Content = Value and "Enabled! WASD camera-relative zoom at " .. BetterSpeedValue .. " studs/s 🔥" or "Disabled",
         Duration = 4,
         Image = 4483362458,
         Actions = {}
      })
   end
})

UniTab:CreateSlider({
   Name = "Speed",
   Range = {16, 1000},
   Increment = 1,
   Suffix = " studs/s",
   CurrentValue = 50,
   Flag = "SpeedSlider",
   Callback = function(Value)
      BetterSpeedValue = Value
   end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WalkSpeedSpoof = getgenv().WalkSpeedSpoof or {}
local setspeed = 100

UniTab:CreateToggle({
    Name = "Enable WalkSpeed Spoof",
    CurrentValue = true,
    Flag = "SpoofToggle",
    Callback = function(Value)
        if Value then
            WalkSpeedSpoof:Enable()
            print("✅ WalkSpeed Spoof Enabled")
        else
            WalkSpeedSpoof:Disable()
            print("❌ WalkSpeed Spoof Disabled")
        end
    end,
})

UniTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = setspeed,
    Flag = "SpeedSlider",
    Callback = function(Value)
        setspeed = Value
        if Toggle.CurrentValue then
            WalkSpeedSpoof:SetWalkSpeed(Value)
        end
    end,
})

-- ==================== CORE SPOOF LOGIC ====================

local cloneref = cloneref or function(obj) return obj end

local cachedhumanoids = {}
local CurrentHumanoid
local indexhook, newindexhook
local GetDebugIdHandler = Instance.new("BindableFunction")
local TempHumanoid = Instance.new("Humanoid")

function GetDebugIdHandler.OnInvoke(obj)
    return obj:GetDebugId()
end

local function GetDebugId(obj)
    return GetDebugIdHandler:Invoke(obj)
end

local function GetWalkSpeed(obj)
    TempHumanoid.WalkSpeed = obj
    return TempHumanoid.WalkSpeed
end

function cachedhumanoids:cacheHumanoid(DebugId, Humanoid)
    cachedhumanoids[DebugId] = {
        currentindex = indexhook(Humanoid, "WalkSpeed"),
        lastnewindex = nil
    }
    return cachedhumanoids[DebugId]
end

-- Index Hook
indexhook = hookmetamethod(game, "__index", function(self, index)
    if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
        local DebugId = GetDebugId(self)
        local cached = cachedhumanoids[DebugId]

        if (self:IsDescendantOf(LocalPlayer.Character) or cached) then
            if type(index) == "string" then
                local cleanindex = string.split(index, "\0")[1]
                if cleanindex == "WalkSpeed" then
                    if not cached then
                        cached = cachedhumanoids:cacheHumanoid(DebugId, self)
                    end
                    if not (CurrentHumanoid and CurrentHumanoid:IsDescendantOf(game)) then
                        CurrentHumanoid = cloneref(self)
                    end
                    return cached.lastnewindex or cached.currentindex
                end
            end
        end
    end
    return indexhook(self, index)
end)

-- NewIndex Hook
newindexhook = hookmetamethod(game, "__newindex", function(self, index, newvalue)
    if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
        local DebugId = GetDebugId(self)
        local cached = cachedhumanoids[DebugId]

        if (self:IsDescendantOf(LocalPlayer.Character) or cached) then
            if type(index) == "string" then
                local cleanindex = string.split(index, "\0")[1]
                if cleanindex == "WalkSpeed" then
                    if not cached then
                        cached = cachedhumanoids:cacheHumanoid(DebugId, self)
                    end
                    if not (CurrentHumanoid and CurrentHumanoid:IsDescendantOf(game)) then
                        CurrentHumanoid = cloneref(self)
                    end
                    cached.lastnewindex = GetWalkSpeed(newvalue)
                    return
                end
            end
        end
    end
    return newindexhook(self, index, newvalue)
end)

function WalkSpeedSpoof:Enable()
    if indexhook and newindexhook then
        WalkSpeedSpoof:SetWalkSpeed(setspeed)
    end
end

function WalkSpeedSpoof:Disable()
    WalkSpeedSpoof:RestoreWalkSpeed()
end

function WalkSpeedSpoof:SetWalkSpeed(speed)
    local Humanoid = CurrentHumanoid or LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid then
        CurrentHumanoid = cloneref(Humanoid)
        local connections = {}
        
        local function disableConnections(Signal)
            for _, v in ipairs(getconnections(Signal)) do
                if v.State then
                    v:Disable()
                    table.insert(connections, v)
                end
            end
        end
        
        disableConnections(Humanoid.Changed)
        disableConnections(Humanoid:GetPropertyChangedSignal("WalkSpeed"))
        
        Humanoid.WalkSpeed = speed
        
        for _, v in ipairs(connections) do
            v:Enable()
        end
    end
end

function WalkSpeedSpoof:RestoreWalkSpeed()
    local Humanoid = CurrentHumanoid or LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid then
        local cached = cachedhumanoids[Humanoid:GetDebugId()]
        if cached then
            WalkSpeedSpoof:SetWalkSpeed(cached.currentindex or 16)
        end
    end
end

getgenv().WalkSpeedSpoof = WalkSpeedSpoof

-- Initial Setup
task.wait(1)
if Toggle.CurrentValue then
    WalkSpeedSpoof:Enable()
end


-- Auto-setup on respawn (add this if not already in your script)
player.CharacterAdded:Connect(function()
   task.wait(0.5)
   if BetterSpeedEnabled then
      SetupBodyVelocity()
   end
end)


	-- Optimized LocalScript: Makes ALL ProximityPrompts instantly clickable & visible from ANYWHERE
local Workspace = game:GetService("Workspace")

local function unlockPrompt(prompt)
    prompt.HoldDuration = 0
    --prompt.MaxActivationDistance = math.huge  -- Makes them visible from anywhere
    prompt.RequiresLineOfSight = false       -- Ignores walls/obstructions
    prompt.Enabled = true                    -- Ensures they're active
    
    -- Auto-reset if game tries to change them later
    prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
        prompt.HoldDuration = 0
    end)
    -- prompt:GetPropertyChangedSignal("MaxActivationDistance"):Connect(function()
    --     prompt.MaxActivationDistance = math.huge
    -- end)
end

UniTab:CreateToggle({
    Name = "Instant Proximity Prompt",
    CurrentValue = false,
    Callback = function()
		-- Unlock all existing prompts
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ProximityPrompt") then
				unlockPrompt(obj)
			end
		end

		-- Unlock any new prompts added dynamically
		Workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("ProximityPrompt") then
				unlockPrompt(obj)
			end
		end)

		print("works")
    end
})

-- local TpWalkTab = Window:CreateTab("TP Walk", 4483362458)
-- local RunService = game:GetService("RunService")
-- local UserInputService = game:GetService("UserInputService")
-- local Players = game:GetService("Players")
-- local player = Players.LocalPlayer

-- local TpWalkEnabled = false
-- local TpWalkConnection = nil
-- local KeysPressed = {W = false, A = false, S = false, D = false, Space = false, C = false}
-- local MoveSpeed = 50  -- Studs per second

-- -- Key map
-- local KeyMap = {
--     [Enum.KeyCode.W] = "W",
--     [Enum.KeyCode.A] = "A",
--     [Enum.KeyCode.S] = "S",
--     [Enum.KeyCode.D] = "D",
--     [Enum.KeyCode.Space] = "Space",
--     [Enum.KeyCode.C] = "C"
-- }

-- UniTab:CreateToggle({
--     Name = "TP Walk (WASD + Space/C)",
--     CurrentValue = false,
--     Callback = function(v)
--         TpWalkEnabled = v

--         if v then
--             Rayfield:Notify({Title = "TP Walk", Content = "ON - WASD to move, Space up, C down!", Duration = 5})

--             if TpWalkConnection then TpWalkConnection:Disconnect() end

--             TpWalkConnection = RunService.Heartbeat:Connect(function(deltaTime)
--                 if not TpWalkEnabled then return end

--                 local character = player.Character
--                 local hrp = character and character:FindFirstChild("HumanoidRootPart")
--                 if not hrp then return end

--                 local camera = workspace.CurrentCamera
--                 if not camera then return end

--                 local moveVector = Vector3.new(0, 0, 0)

--                 if KeysPressed.W then moveVector = moveVector + Vector3.new(0, 0, -1) end
--                 if KeysPressed.S then moveVector = moveVector + Vector3.new(0, 0, 1) end
--                 if KeysPressed.A then moveVector = moveVector + Vector3.new(-1, 0, 0) end
--                 if KeysPressed.D then moveVector = moveVector + Vector3.new(1, 0, 0) end
--                 if KeysPressed.Space then moveVector = moveVector + Vector3.new(0, 1, 0) end
--                 if KeysPressed.C then moveVector = moveVector + Vector3.new(0, -1, 0) end

--                 if moveVector.Magnitude > 0 then
--                     moveVector = moveVector.Unit

--                     -- Camera-relative movement (forward/left/right based on look direction)
--                     local camLook = camera.CFrame.LookVector
--                     local camRight = camera.CFrame.RightVector
--                     local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
--                     local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

--                     local worldMove = (flatLook * -moveVector.Z) + (flatRight * moveVector.X) + (Vector3.new(0, moveVector.Y, 0))

--                     local distance = MoveSpeed * deltaTime
--                     local newPos = hrp.Position + worldMove * distance

--                     hrp.CFrame = CFrame.new(newPos, newPos + flatLook)
--                 end
--             end)

--             -- Key input handling
--             UserInputService.InputBegan:Connect(function(input, gp)
--                 if gp or not TpWalkEnabled then return end
--                 local key = KeyMap[input.KeyCode]
--                 if key then KeysPressed[key] = true end
--             end)

--             UserInputService.InputEnded:Connect(function(input)
--                 local key = KeyMap[input.KeyCode]
--                 if key then KeysPressed[key] = false end
--             end)
--         else
--             for k in pairs(KeysPressed) do KeysPressed[k] = false end
--             if TpWalkConnection then
--                 TpWalkConnection:Disconnect()
--                 TpWalkConnection = nil
--             end
--             Rayfield:Notify({Title = "TP Walk", Content = "OFF", Duration = 4})
--         end
--     end
-- })

-- -- Speed slider
-- UniTab:CreateSlider({
--     Name = "TP Walk Speed",
--     Range = {20, 200},
--     Increment = 10,
--     Suffix = " studs/s",
--     CurrentValue = MoveSpeed,
--     Callback = function(v)
--         MoveSpeed = v
--     end
-- })


	-- YOUR ORIGINAL PRESETS
	-- UniTab:CreateButton({Name="Normal Human",  Callback=function() Rayfield.Flags.WalkSpeed:Set(16)  Rayfield.Flags.JumpHeight:Set(50)  end})
	-- UniTab:CreateButton({Name="Fast Runner",   Callback=function() Rayfield.Flags.WalkSpeed:Set(100) Rayfield.Flags.JumpHeight:Set(100) end})
	-- UniTab:CreateButton({Name="GOD SPEED",     Callback=function() Rayfield.Flags.WalkSpeed:Set(500) Rayfield.Flags.JumpHeight:Set(300) end})
	-- UniTab:CreateButton({Name="MOON JUMP",    Callback=function() Rayfield.Flags.WalkSpeed:Set(300) Rayfield.Flags.JumpHeight:Set(999) end})

	Players.PlayerAdded:Connect(function(player)
		task.wait(0.6)
		if Rayfield.Flags.BetterSpeedEnabled.CurrentValue then
			toggleSpeed(true)
		end
		if Rayfield.Flags.JumpEnabled.CurrentValue then
			toggleJump(true)
		end
	end)


	_G.HeadSize = 50
	_G.Disabled = true

	UniTab:CreateToggle({
		Name = "Hitbox expander (works in most games)",
		Suffix = " Height",
		Flag = "JumpHeight",
		Callback = function() 
			game:GetService('RunService').RenderStepped:connect(function()
			if _G.Disabled then
				for i,v in next, game:GetService('Players'):GetPlayers() do
					if v.Name ~= game:GetService('Players').LocalPlayer.Name then
							pcall(function()
							v.Character.HumanoidRootPart.Size = Vector3.new(_G.HeadSize,_G.HeadSize,_G.HeadSize)
							v.Character.HumanoidRootPart.Transparency = 0.7
							hrp.BrickColor = BrickColor.new(_G.HitboxColor or Color3.fromRGB(0, 0, 255))
							v.Character.HumanoidRootPart.Material = "Neon"
							v.Character.HumanoidRootPart.CanCollide = false
							end)
						end
					end
				end
			end)
		end
	})


 	UniTab:CreateSlider({
		Name = "Hitbox Size",
		Range = {5, 500},
		Increment = 10,
		Suffix = " Height",
		CurrentValue = 50,
		Flag = "JumpHeight",
		Callback = function(value) 
			_G.HeadSize = value
		end
	})

	UniTab:CreateColorPicker({
		Name = "HitBox Color",
		Color = Color3.fromRGB(255,255,255),
		Flag = "ColorPicker1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)

			_G.HitboxColor = Value
			-- The function that takes place every time the color picker is moved/changed
			-- The variable (Value) is a Color3fromRGB value based on which color is selected
    	end
	})

	


	-- Disable Sitable Stuff (Seats, Chairs, Vehicles, etc.)
local function disableSitting()
    -- Find and disable ALL seats in the game
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            obj.Disabled = true
            obj.Anchored = true          -- Optional: stops them from moving
            obj.CanCollide = false       -- Optional: makes them non-solid so you walk through
            obj:SetAttribute("NoSit", true)  -- Extra safety
        end
    end

    -- Keep disabling any new seats that spawn later
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            obj.Disabled = true
            obj.Anchored = true
            obj.CanCollide = false
        end
    end)
end

-- Run it once when script loads
disableSitting()

-- Optional: Add to your UI (if you're using a hub like Fluxus, Krnl, etc.)


    UniTab:CreateButton({
        Name = "Disable All Seats",
        Callback = disableSitting
    })




	-- Save original zoom
	local originalZoom = plr.CameraMaxZoomDistance

	UniTab:CreateToggle({
		Name = "Unlok Zoom",
		CurrentValue = false,
		Callback = function(state)
			if state then
				plr.CameraMaxZoomDistance = 9e9
			else
				plr.CameraMaxZoomDistance = originalZoom
			end
		end
	})

	 
	local plr = game.Players.LocalPlayer
	local antiRagdoll = false
	local connection

	UniTab:CreateToggle({
		Name = "Anti Ragdoll",
		CurrentValue = false,
		Callback = function(state)
			antiRagdoll = state
			
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if antiRagdoll then
				connection = game:GetService("RunService").Heartbeat:Connect(function()
					local char = plr.Character
					if not char then return end

					local hum = char:FindFirstChildOfClass("Humanoid")
					if not hum then return end

					-- Prevent physics/ragdoll state
					if hum:GetState() == Enum.HumanoidStateType.Physics 
					or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
						hum:ChangeState(Enum.HumanoidStateType.GettingUp)
					end

					-- Remove ragdoll joints if they exist
					for _, v in pairs(char:GetDescendants()) do
						if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
							v:Destroy()
						end
					end
				end)
			end
		end
	})

	UniTab:CreateButton({
		Name = "Product Faker(doesnt work in all games)",
		Callback = function()
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("SeluwiaUI") then
    playerGui.SeluwiaUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SeluwiaUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local isMobile = UserInputService.TouchEnabled
local autoSpeed = 100  -- signals per second

-- Helper functions
local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(40, 40, 56)
    s.Thickness = thickness or 1
    return s
end

local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 10)
    return c
end

local function getTime()
    return os.date("%H:%M:%S")
end

-- Scale UI for mobile
local panelSize
local fontSizeScale = isMobile and 0.8 or 1
local buttonHeight = isMobile and 36 or 28
local titleBarHeight = isMobile and 44 or 52
local footerHeight = isMobile and 44 or 50

if isMobile then
    panelSize = UDim2.new(0.9, 0, 0.7, 0)
else
    panelSize = UDim2.new(0, 760, 0, 520)
end

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = panelSize
panel.Position = UDim2.new(0.5, -panelSize.X.Offset/2, 0.5, -panelSize.Y.Offset/2)
if isMobile then
    panel.Position = UDim2.new(0.05, 0, 0.15, 0)
end
panel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
panel.BorderSizePixel = 0
panel.Parent = screenGui
corner(panel, 16)
stroke(panel, Color3.fromRGB(30, 30, 42), 1)

-- Resize handle (PC only)
if not isMobile then
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = panel
    corner(resizeHandle, 4)
    stroke(resizeHandle, Color3.fromRGB(80, 80, 110), 1)

    local resizing = false
    local resizeStartPos, startSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartPos = input.Position
            startSize = panel.AbsoluteSize
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartPos
            local newWidth = math.clamp(startSize.X + delta.X, 400, 1200)
            local newHeight = math.clamp(startSize.Y + delta.Y, 300, 800)
            panel.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
end

-- Dragging
local dragging = false
local dragStart, startPos

local function onInputBegan(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not resizing then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end

local function onInputChanged(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

local function onInputEnded(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
titleBar.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
corner(titleBar, 16)
stroke(titleBar, Color3.fromRGB(22, 22, 31), 1)

local titleFill = Instance.new("Frame")
titleFill.Size = UDim2.new(1, 0, 0, 18)
titleFill.Position = UDim2.new(0, 0, 1, -18)
titleFill.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
titleFill.BorderSizePixel = 0
titleFill.ZIndex = titleBar.ZIndex + 1
titleFill.Parent = titleBar

titleBar.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

-- Live dot
local liveDot = Instance.new("Frame")
liveDot.Size = UDim2.new(0, 9, 0, 9)
liveDot.Position = UDim2.new(0, 20, 0.5, -4)
liveDot.BackgroundColor3 = Color3.fromRGB(61, 255, 160)
liveDot.BorderSizePixel = 0
liveDot.ZIndex = titleBar.ZIndex + 2
liveDot.Parent = titleBar
corner(liveDot, 999)

local liveLabel = Instance.new("TextLabel")
liveLabel.Size = UDim2.new(0, 50, 0, 20)
liveLabel.Position = UDim2.new(0, 34, 0.5, -10)
liveLabel.BackgroundTransparency = 1
liveLabel.Text = "LIVE"
liveLabel.TextColor3 = Color3.fromRGB(61, 255, 160)
liveLabel.TextSize = 11 * fontSizeScale
liveLabel.Font = Enum.Font.GothamBold
liveLabel.TextXAlignment = Enum.TextXAlignment.Left
liveLabel.ZIndex = titleBar.ZIndex + 2
liveLabel.Parent = titleBar

task.spawn(function()
    while screenGui.Parent do
        TweenService:Create(liveDot, TweenInfo.new(1), {Size = UDim2.new(0,11,0,11), Position = UDim2.new(0,19,0.5,-5)}):Play()
        task.wait(1)
        TweenService:Create(liveDot, TweenInfo.new(1), {Size = UDim2.new(0,9,0,9), Position = UDim2.new(0,20,0.5,-4)}):Play()
        task.wait(1)
    end
end)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 200, 1, 0)
titleText.Position = UDim2.new(0.5, -100, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "SELUWIA"
titleText.TextColor3 = Color3.fromRGB(210, 210, 228)
titleText.TextSize = 14 * fontSizeScale
titleText.Font = Enum.Font.GothamBold
titleText.ZIndex = titleBar.ZIndex + 2
titleText.Parent = titleBar

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 76, 0, 30)
clearBtn.Position = UDim2.new(1, -92, 0.5, -15)
clearBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
clearBtn.Text = "X Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
clearBtn.TextSize = 11 * fontSizeScale
clearBtn.Font = Enum.Font.GothamBold
clearBtn.BorderSizePixel = 0
clearBtn.ZIndex = titleBar.ZIndex + 3
clearBtn.Parent = titleBar
corner(clearBtn, 8)
stroke(clearBtn, Color3.fromRGB(80, 28, 28), 1)

clearBtn.MouseEnter:Connect(function()
    clearBtn.BackgroundColor3 = Color3.fromRGB(28, 10, 10)
end)
clearBtn.MouseLeave:Connect(function()
    clearBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
end)

-- Log area
local logArea = Instance.new("ScrollingFrame")
logArea.Name = "LogArea"
logArea.Size = UDim2.new(1, -12, 1, -(titleBarHeight + footerHeight + 10))
logArea.Position = UDim2.new(0, 6, 0, titleBarHeight + 6)
logArea.BackgroundTransparency = 1
logArea.BorderSizePixel = 0
logArea.ScrollBarThickness = isMobile and 6 or 3
logArea.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 90)
logArea.CanvasSize = UDim2.new(0, 0, 0, 0)
logArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
logArea.Parent = panel

local listLayout = Instance.new("UIListLayout", logArea)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, isMobile and 10 or 7)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local logPad = Instance.new("UIPadding", logArea)
logPad.PaddingTop = UDim.new(0, 8)
logPad.PaddingBottom = UDim.new(0, 6)
logPad.PaddingLeft = UDim.new(0, 4)
logPad.PaddingRight = UDim.new(0, 4)

-- Footer
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, footerHeight)
footer.Position = UDim2.new(0, 0, 1, -footerHeight)
footer.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
footer.BorderSizePixel = 0
footer.Parent = panel
corner(footer, 16)

local footerFill = Instance.new("Frame")
footerFill.Size = UDim2.new(1, 0, 0, 18)
footerFill.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
footerFill.BorderSizePixel = 0
footerFill.Parent = footer

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(0, 160, 1, 0)
countLabel.Position = UDim2.new(0, 20, 0, 0)
countLabel.BackgroundTransparency = 1
countLabel.Text = "0 events captured"
countLabel.TextColor3 = Color3.fromRGB(160, 155, 200)
countLabel.TextSize = 12 * fontSizeScale
countLabel.Font = Enum.Font.Gotham
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.ZIndex = footer.ZIndex + 1
countLabel.Parent = footer

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 50, 0, buttonHeight)
settingsBtn.Position = UDim2.new(1, -90, 0.5, -buttonHeight/2)
settingsBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
settingsBtn.Text = "SET"
settingsBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
settingsBtn.TextSize = 11 * fontSizeScale
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.BorderSizePixel = 0
settingsBtn.ZIndex = footer.ZIndex + 1
settingsBtn.Parent = footer
corner(settingsBtn, 7)
stroke(settingsBtn, Color3.fromRGB(55, 50, 85), 1)

local stopAllBtn = Instance.new("TextButton")
stopAllBtn.Size = UDim2.new(0, 80, 0, buttonHeight)
stopAllBtn.Position = UDim2.new(1, -170, 0.5, -buttonHeight/2)
stopAllBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
stopAllBtn.Text = "Stop All"
stopAllBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
stopAllBtn.TextSize = 11 * fontSizeScale
stopAllBtn.Font = Enum.Font.GothamBold
stopAllBtn.BorderSizePixel = 0
stopAllBtn.ZIndex = footer.ZIndex + 1
stopAllBtn.Parent = footer
corner(stopAllBtn, 7)
stroke(stopAllBtn, Color3.fromRGB(80, 30, 30), 1)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -6, 0, -6)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.TextSize = 17 * fontSizeScale
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 10
closeBtn.Parent = panel
corner(closeBtn, 999)

-- Settings window (toggle)
local settingsWindow = nil
local function toggleSettings()
    if settingsWindow then
        settingsWindow:Destroy()
        settingsWindow = nil
    else
        settingsWindow = Instance.new("Frame")
        settingsWindow.Name = "SettingsWindow"
        settingsWindow.Size = UDim2.new(0, 300, 0, 200)
        settingsWindow.Position = UDim2.new(0.5, -150, 0.5, -100)
        settingsWindow.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
        settingsWindow.BorderSizePixel = 0
        settingsWindow.ZIndex = 50
        settingsWindow.Parent = screenGui
        corner(settingsWindow, 12)
        stroke(settingsWindow, Color3.fromRGB(30, 30, 45), 1)

        local settingsTitleBar = Instance.new("Frame")
        settingsTitleBar.Size = UDim2.new(1, 0, 0, 40)
        settingsTitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        settingsTitleBar.BorderSizePixel = 0
        settingsTitleBar.ZIndex = 51
        settingsTitleBar.Parent = settingsWindow
        corner(settingsTitleBar, 12)

        local settingsTitle = Instance.new("TextLabel")
        settingsTitle.Size = UDim2.new(1, -40, 1, 0)
        settingsTitle.Position = UDim2.new(0, 10, 0, 0)
        settingsTitle.BackgroundTransparency = 1
        settingsTitle.Text = "Settings"
        settingsTitle.TextColor3 = Color3.fromRGB(210, 210, 228)
        settingsTitle.TextSize = 14
        settingsTitle.Font = Enum.Font.GothamBold
        settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
        settingsTitle.ZIndex = 52
        settingsTitle.Parent = settingsTitleBar

        local closeSettingsBtn = Instance.new("TextButton")
        closeSettingsBtn.Size = UDim2.new(0, 24, 0, 24)
        closeSettingsBtn.Position = UDim2.new(1, -30, 0, 8)
        closeSettingsBtn.BackgroundColor3 = Color3.fromRGB(35, 12, 12)
        closeSettingsBtn.Text = "X"
        closeSettingsBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
        closeSettingsBtn.TextSize = 14
        closeSettingsBtn.Font = Enum.Font.GothamBold
        closeSettingsBtn.BorderSizePixel = 0
        closeSettingsBtn.ZIndex = 52
        closeSettingsBtn.Parent = settingsTitleBar
        corner(closeSettingsBtn, 12)
        closeSettingsBtn.MouseButton1Click:Connect(function()
            if settingsWindow then
                settingsWindow:Destroy()
                settingsWindow = nil
            end
        end)

        -- Drag settings window
        local dragStartPos, dragStartMouse
        local draggingSettings = false
        settingsTitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSettings = true
                dragStartPos = settingsWindow.Position
                dragStartMouse = input.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSettings and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStartMouse
                settingsWindow.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSettings = false
            end
        end)

        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0, 140, 0, 30)
        speedLabel.Position = UDim2.new(0, 20, 0, 60)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "Signals per second:"
        speedLabel.TextColor3 = Color3.fromRGB(170, 165, 220)
        speedLabel.TextSize = 12
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.TextXAlignment = Enum.TextXAlignment.Left
        speedLabel.ZIndex = 51
        speedLabel.Parent = settingsWindow

        local speedBox = Instance.new("TextBox")
        speedBox.Size = UDim2.new(0, 100, 0, 30)
        speedBox.Position = UDim2.new(0, 170, 0, 60)
        speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        speedBox.Text = tostring(autoSpeed)
        speedBox.TextColor3 = Color3.fromRGB(210, 210, 228)
        speedBox.TextSize = 12
        speedBox.Font = Enum.Font.Gotham
        speedBox.BorderSizePixel = 0
        speedBox.ZIndex = 51
        speedBox.Parent = settingsWindow
        corner(speedBox, 6)
        stroke(speedBox, Color3.fromRGB(55, 50, 85), 1)

        local speedHint = Instance.new("TextLabel")
        speedHint.Size = UDim2.new(0, 260, 0, 20)
        speedHint.Position = UDim2.new(0, 20, 0, 95)
        speedHint.BackgroundTransparency = 1
        speedHint.Text = "1 = slowest  |  10000 = fastest  |  Default: 100"
        speedHint.TextColor3 = Color3.fromRGB(120, 120, 158)
        speedHint.TextSize = 10
        speedHint.Font = Enum.Font.Gotham
        speedHint.TextXAlignment = Enum.TextXAlignment.Left
        speedHint.ZIndex = 51
        speedHint.Parent = settingsWindow

        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0, 100, 0, 32)
        saveBtn.Position = UDim2.new(0.5, -50, 1, -45)
        saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        saveBtn.Text = "Save"
        saveBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
        saveBtn.TextSize = 12
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.BorderSizePixel = 0
        saveBtn.ZIndex = 51
        saveBtn.Parent = settingsWindow
        corner(saveBtn, 7)
        stroke(saveBtn, Color3.fromRGB(45, 80, 60), 1)

        local savedMsg = nil
        saveBtn.MouseButton1Click:Connect(function()
            local newSpeed = tonumber(speedBox.Text)
            if newSpeed then
                newSpeed = math.floor(newSpeed)
                if newSpeed >= 1 and newSpeed <= 10000 then
                    autoSpeed = newSpeed
                    speedBox.Text = tostring(autoSpeed)
                    speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                    if savedMsg then savedMsg:Destroy() end
                    savedMsg = Instance.new("TextLabel")
                    savedMsg.Size = UDim2.new(0, 100, 0, 20)
                    savedMsg.Position = UDim2.new(0.5, -50, 1, -20)
                    savedMsg.BackgroundTransparency = 1
                    savedMsg.Text = "Saved!"
                    savedMsg.TextColor3 = Color3.fromRGB(61, 255, 160)
                    savedMsg.TextSize = 10
                    savedMsg.Font = Enum.Font.GothamBold
                    savedMsg.ZIndex = 52
                    savedMsg.Parent = settingsWindow
                    task.wait(1.5)
                    if savedMsg then savedMsg:Destroy() end
                else
                    speedBox.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
                    task.wait(0.5)
                    speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                end
            else
                speedBox.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
                task.wait(0.5)
                speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            end
        end)
    end
end

settingsBtn.MouseButton1Click:Connect(toggleSettings)

-- Visibility toggles
local uiVisible = true
local reopenButton = nil

local function showGui()
    if not screenGui.Enabled then
        screenGui.Enabled = true
        uiVisible = true
        if reopenButton then reopenButton.Visible = false end
    end
end

local function hideGui()
    if screenGui.Enabled then
        screenGui.Enabled = false
        uiVisible = false
        if isMobile then
            if not reopenButton or not reopenButton.Parent then
                reopenButton = Instance.new("TextButton")
                reopenButton.Size = UDim2.new(0, 56, 0, 56)
                reopenButton.Position = UDim2.new(1, -70, 1, -70)
                reopenButton.AnchorPoint = Vector2.new(1, 1)
                reopenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                reopenButton.Text = "S"
                reopenButton.TextColor3 = Color3.fromRGB(210, 210, 228)
                reopenButton.TextSize = 24
                reopenButton.Font = Enum.Font.GothamBold
                reopenButton.BorderSizePixel = 0
                reopenButton.ZIndex = 100
                reopenButton.Parent = playerGui
                corner(reopenButton, 28)
                stroke(reopenButton, Color3.fromRGB(80, 70, 120), 1.5)

                local dragStartPos, dragStartMouse
                reopenButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragStartPos = reopenButton.Position
                        dragStartMouse = input.Position
                        local moveConn, endConn
                        moveConn = UserInputService.InputChanged:Connect(function(input2)
                            if input2.UserInputType == input.UserInputType then
                                local delta = input2.Position - dragStartMouse
                                reopenButton.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
                            end
                        end)
                        endConn = UserInputService.InputEnded:Connect(function(input2)
                            if input2.UserInputType == input.UserInputType then
                                moveConn:Disconnect()
                                endConn:Disconnect()
                            end
                        end)
                    end
                end)

                reopenButton.MouseButton1Click:Connect(showGui)
            else
                reopenButton.Visible = true
            end
        end
    end
end

closeBtn.MouseButton1Click:Connect(hideGui)

if not isMobile then
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            if uiVisible then hideGui() else showGui() end
        end
    end)
end

-- Log management
local eventCount = 0
local entries = {}
local suppressCounter = 0

local function fireFakeSignal(signalType, id)
    suppressCounter = suppressCounter + 1
    pcall(function()
        if signalType == "Product" then
            MarketplaceService:SignalPromptProductPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Gamepass" then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(player, id, true)
        elseif signalType == "Bulk" then
            MarketplaceService:SignalPromptBulkPurchaseFinished(player.UserId, id, true)
        elseif signalType == "Purchase" then
            MarketplaceService:SignalPromptPurchaseFinished(player.UserId, id, true)
        end
    end)
    suppressCounter = suppressCounter - 1
end

local function makeEmptyLabel()
    local el = Instance.new("TextLabel")
    el.Name = "EmptyState"
    el.Size = UDim2.new(1, 0, 0, 260)
    el.BackgroundTransparency = 1
    el.Text = "Waiting for events…\nAll marketplace events will appear here."
    el.TextColor3 = Color3.fromRGB(120, 120, 158)
    el.TextSize = 13 * fontSizeScale
    el.Font = Enum.Font.Gotham
    el.TextWrapped = true
    el.LayoutOrder = 99999
    el.Parent = logArea
    return el
end

local function setEmpty(show)
    local e = logArea:FindFirstChild("EmptyState")
    if show and not e then
        makeEmptyLabel()
    elseif not show and e then
        e:Destroy()
    end
end

local activeAutoButtons = {}
local activeSpamButtons = {}

local function stopAllAutoAndSpam()
    for btn, data in pairs(activeAutoButtons) do
        data.active = false
        if data.loop then task.cancel(data.loop) end
        if btn and btn.Parent then
            btn.Text = "Auto"
            btn.TextColor3 = Color3.fromRGB(170, 165, 220)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end
    table.clear(activeAutoButtons)
    for btn, data in pairs(activeSpamButtons) do
        data.active = false
        if data.loop then task.cancel(data.loop) end
        if btn and btn.Parent then
            btn.Text = "Run"
            btn.TextColor3 = Color3.fromRGB(170, 165, 220)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end
    table.clear(activeSpamButtons)
end

stopAllBtn.MouseButton1Click:Connect(stopAllAutoAndSpam)

local function addLog(label, id, signalType)
    if suppressCounter > 0 then return end
    setEmpty(false)
    local entryHeight = isMobile and 56 or 46
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, -2, 0, entryHeight)
    entry.BackgroundColor3 = Color3.fromRGB(17, 17, 24)
    entry.BorderSizePixel = 0
    entry.LayoutOrder = -(eventCount)
    entry.Parent = logArea
    corner(entry, 10)
    stroke(entry, Color3.fromRGB(48, 46, 70), 1)
    entry.BackgroundTransparency = 1
    TweenService:Create(entry, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 14, 0.5, -4)
    dot.BackgroundColor3 = Color3.fromRGB(61, 255, 160)
    dot.BorderSizePixel = 0
    dot.Parent = entry
    corner(dot, 999)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 76, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(label)
    lbl.TextColor3 = Color3.fromRGB(160, 150, 210)
    lbl.TextSize = 10 * fontSizeScale
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = entry

    local idEl = Instance.new("TextLabel")
    idEl.Size = UDim2.new(0, 200, 1, 0)
    idEl.Position = UDim2.new(0, 108, 0, 0)
    idEl.BackgroundTransparency = 1
    idEl.Text = tostring(id)
    idEl.TextColor3 = Color3.fromRGB(220, 220, 240)
    idEl.TextSize = 14 * fontSizeScale
    idEl.Font = Enum.Font.GothamBold
    idEl.TextXAlignment = Enum.TextXAlignment.Left
    idEl.TextTruncate = Enum.TextTruncate.AtEnd
    idEl.Parent = entry

    local timeEl = Instance.new("TextLabel")
    timeEl.Size = UDim2.new(0, 70, 1, 0)
    timeEl.Position = UDim2.new(0, 320, 0, 0)
    timeEl.BackgroundTransparency = 1
    timeEl.Text = getTime()
    timeEl.TextColor3 = Color3.fromRGB(140, 135, 180)
    timeEl.TextSize = 11 * fontSizeScale
    timeEl.Font = Enum.Font.Gotham
    timeEl.Parent = entry

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0, 200, 1, 0)
    buttonFrame.Position = UDim2.new(1, -200, 0, 0)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = entry

    local autoBtn = Instance.new("TextButton")
    autoBtn.Size = UDim2.new(0, 56, 0, buttonHeight)
    autoBtn.Position = UDim2.new(0, 0, 0.5, -buttonHeight/2)
    autoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    autoBtn.Text = "Auto"
    autoBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
    autoBtn.TextSize = 11 * fontSizeScale
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.BorderSizePixel = 0
    autoBtn.Parent = buttonFrame
    corner(autoBtn, 7)
    stroke(autoBtn, Color3.fromRGB(55, 50, 85), 1)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 56, 0, buttonHeight)
    copyBtn.Position = UDim2.new(0, 62, 0.5, -buttonHeight/2)
    copyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
    copyBtn.TextSize = 11 * fontSizeScale
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = buttonFrame
    corner(copyBtn, 7)
    stroke(copyBtn, Color3.fromRGB(55, 50, 85), 1)

    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 52, 0, buttonHeight)
    runBtn.Position = UDim2.new(0, 124, 0.5, -buttonHeight/2)
    runBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    runBtn.Text = "Run"
    runBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
    runBtn.TextSize = 11 * fontSizeScale
    runBtn.Font = Enum.Font.GothamBold
    runBtn.BorderSizePixel = 0
    runBtn.Parent = buttonFrame
    corner(runBtn, 7)
    stroke(runBtn, Color3.fromRGB(55, 50, 85), 1)

    copyBtn.MouseEnter:Connect(function()
        copyBtn.TextColor3 = Color3.fromRGB(190, 180, 255)
        copyBtn.BackgroundColor3 = Color3.fromRGB(22, 18, 40)
    end)
    copyBtn.MouseLeave:Connect(function()
        if copyBtn.Text ~= "Copied!" then
            copyBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
            copyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, tostring(id))
        copyBtn.Text = "Copied!"
        copyBtn.TextColor3 = Color3.fromRGB(200, 190, 255)
        task.wait(1.5)
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
        copyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    end)

    local autoActive = false
    local autoLoop = nil
    local function startAuto()
        if autoActive then return end
        autoActive = true
        autoBtn.Text = "Auto ON"
        autoBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        autoBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
        autoLoop = task.spawn(function()
            local delay = autoSpeed > 0 and (1 / autoSpeed) or 0.01
            while autoActive and autoBtn.Parent do
                fireFakeSignal(signalType, id)
                task.wait(delay)
            end
        end)
        activeAutoButtons[autoBtn] = {active = true, loop = autoLoop}
    end
    local function stopAuto()
        autoActive = false
        if autoLoop then task.cancel(autoLoop) end
        activeAutoButtons[autoBtn] = nil
        if autoBtn.Parent then
            autoBtn.Text = "Auto"
            autoBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
            autoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end
    autoBtn.MouseButton1Click:Connect(function()
        if autoActive then stopAuto() else startAuto() end
    end)

    local holdStart = nil
    local holdConnection = nil
    local spamLoop = nil
    local isSpamming = false
    local function startSpam()
        if isSpamming then return end
        isSpamming = true
        runBtn.Text = "Spamming..."
        runBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        spamLoop = task.spawn(function()
            while isSpamming and runBtn.Parent do
                fireFakeSignal(signalType, id)
                task.wait(0.1)
            end
        end)
        activeSpamButtons[runBtn] = {active = true, loop = spamLoop}
    end
    local function stopSpam()
        isSpamming = false
        if spamLoop then task.cancel(spamLoop) end
        activeSpamButtons[runBtn] = nil
        if runBtn.Parent then
            runBtn.Text = "Run"
            runBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
            runBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end

    -- Use InputBegan/InputEnded for both mouse and touch
    local function onRunPress()
        if isSpamming then return end
        holdStart = tick()
        holdConnection = task.spawn(function()
            while holdStart and (tick() - holdStart) < 3 do
                task.wait(0.1)
            end
            if holdStart and not isSpamming then
                startSpam()
            end
        end)
    end

    local function onRunRelease()
        local heldDuration = holdStart and (tick() - holdStart) or 0
        holdStart = nil
        if holdConnection then task.cancel(holdConnection) end
        if isSpamming then
            stopSpam()
        elseif heldDuration < 3 then
            fireFakeSignal(signalType, id)
            runBtn.Text = "Sent!"
            runBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
            task.wait(1.5)
            if runBtn.Parent then
                runBtn.Text = "Run"
                runBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
            end
        end
    end

    runBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onRunPress()
        end
    end)
    runBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onRunRelease()
        end
    end)

    runBtn.MouseEnter:Connect(function()
        if not isSpamming then
            runBtn.TextColor3 = Color3.fromRGB(61, 255, 160)
            runBtn.BackgroundColor3 = Color3.fromRGB(10, 22, 18)
        end
    end)
    runBtn.MouseLeave:Connect(function()
        if not isSpamming and runBtn.Text == "Run" then
            runBtn.TextColor3 = Color3.fromRGB(170, 165, 220)
            runBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        end
    end)

    entry.AncestryChanged:Connect(function()
        if not entry.Parent then
            if autoActive then stopAuto() end
            if isSpamming then stopSpam() end
            for i, e in ipairs(entries) do
                if e == entry then
                    table.remove(entries, i)
                    break
                end
            end
        end
    end)

    eventCount = eventCount + 1
    countLabel.Text = eventCount .. (eventCount == 1 and " event captured" or " events captured")
    table.insert(entries, entry)
end

clearBtn.MouseButton1Click:Connect(function()
    stopAllAutoAndSpam()
    for _, e in ipairs(entries) do
        e:Destroy()
    end
    entries = {}
    eventCount = 0
    countLabel.Text = "0 events captured"
    setEmpty(true)
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(plr, id, bought)
    if suppressCounter == 0 then addLog("Product", id, "Product") end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, bought)
    if suppressCounter == 0 then addLog("Gamepass", id, "Gamepass") end
end)
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(userId, id, bought)
    if suppressCounter == 0 then addLog("Bulk", id, "Bulk") end
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(userId, id, bought)
    if suppressCounter == 0 then addLog("Purchase", id, "Purchase") end
end)

setEmpty(true)
		end,
	})

	-- local function ToggleBypass(active)
	-- 	State.Bypass = active
	-- 	if State.BypassConnection then State.BypassConnection:Disconnect() State.BypassConnection = nil end
	-- 	local char = LocalPlayer.Character
	-- 	local hum = char and char:FindFirstChild("Humanoid")
	-- 	if active and hum then
	-- 		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	-- 		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	-- 		State.BypassConnection = RunService.Heartbeat:Connect(function()
	-- 			if State.IsTweening and char.HumanoidRootPart then
	-- 				char.HumanoidRootPart.CanCollide = false
	-- 				char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	-- 			end
	-- 		end)
	-- 	end
	-- end

	-- CreateButton("ANTICHEAT BYPASS: OFF", Color3.fromRGB(35, 35, 40), 2, function(b)
    --     State.Bypass = not State.Bypass
    --     b.Text = State.Bypass and "ANTICHEAT BYPASS: ON" or "ANTICHEAT BYPASS: OFF"
    --     b.TextColor3 = State.Bypass and CONFIG.ACCENT or Color3.fromRGB(180, 180, 180)
    --     ToggleBypass(State.Bypass)
    -- end)


    -- local FEATab = Window:CreateTab("FE/Animation", "globe")
    -- FEATab:CreateButton({ Name = "AquaMatrix FE R6 Anim hub",     Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ExploitFin/AquaMatrix/refs/heads/AquaMatrix/AquaMatrix"))() end })
    -- FEATab:CreateButton({ Name = "Sypcerr FE Collection",     Callback = function() loadstring(game:HttpGet(('https://raw.githubusercontent.com/sypcerr/FECollection/refs/heads/main/script.lua'),true))() end })


Rayfield:Notify({ Title = "Universal Hub Gud :)", Content = "Very Gud", Duration = 6.5, Image = 4483362458 })
Rayfield:Notify({ Title = "Checking game ID", Content = "Please wait for a moment", Duration = 3.5, Image = 4483362458 })

-- Testing Tab

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", "settings")
SettingsTab:CreateSection("Themes")
local themes = {
    ["Default"]    = "Default",
    ["Amber glow"] = "AmberGlow",
    ["Amethyst"]   = "Amethyst",
    ["Bloom"]      = "Bloom",
    ["Dark Blue"]  = "DarkBlue",
    ["Green"]      = "Green",
    ["Light"]      = "Light",
    ["Ocean"]      = "Ocean",
    ["Serenity"]   = "Serenity",
}

local Dropdown = SettingsTab:CreateDropdown({
    Name = "Theme Selector",
    Options = {"Default","Amber glow","Amethyst","Bloom","Dark Blue","Green","Light","Ocean","Serenity"},
    CurrentOption = {"Default"},
    MultipleOptions = false,
    Flag = "ThemeDropdown",
    Callback = function(opt)
        local chosen = (type(opt) == "table") and opt[1] or opt
        local key = themes[chosen]
        if key then
            Window.ModifyTheme(key) -- NOTE: dot call (matches your buttons)
        else
            warn("Unknown theme:", tostring(chosen))
        end
    end,
})

SettingsTab:CreateButton({ Name = "Auto execute script in next game", Callback = function() 	queue_on_teleport[[loadstring(game:HttpGet("https://pastefy.app/BdslnEu5/raw"))()]] end })
SettingsTab:CreateSection("Press button below to destroy the ui ")
SettingsTab:CreateButton({ Name = "Destroy ui", Callback = function() Rayfield:Destroy() end })

-- ChangeLog Tab
local SGTab = Window:CreateTab("Supported Games", "calendar")
SGTab:CreateSection("When ever the script hub get changes it will appear here")
SGTab:CreateSection("Current games supported are below")
SGTab:CreateLabel("Prison Life", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Murder Mystery 2", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Grow a Garden", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("99 nights in the forest", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Break in 1", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Tsunami Game", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Break in 2", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("3008", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Lifting Simulator", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Twisted", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Bordr Gam", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Zach Service Station", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Evade", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Bedwars", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("JailBreak", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Infamy", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Piggy", 4483362458, Color3.fromRGB(0, 0, 0), false)
SGTab:CreateLabel("Theres more im just lazy to add it ", 4483362458, Color3.fromRGB(0, 0, 0), false)


local CREDTab = Window:CreateTab("Credits", "calendar")
CREDTab:CreateLabel("Scripts go to their rightful owners", 4483362458, Color3.fromRGB(0, 0, 0), false)
-- CREDTab:CreateLabel("Anti cheat games", 4483362458, Color3.fromRGB(0, 0, 0), false)
-- CREDTab:CreateLabel("(doesnt work)https://www.roblox.com/games/112840298548661/VRAN-AntiCheat", 4483362458, Color3.fromRGB(0, 0, 0), false)
-- CREDTab:CreateLabel("https://www.roblox.com/games/16484430822/Evolution-Ragdoll", 4483362458, Color3.fromRGB(0, 0, 0), false)
-- CREDTab:CreateLabel("(doesnt work)https://www.roblox.com/games/6974949559/Minerva-Anticheat", 4483362458, Color3.fromRGB(0, 0, 0), false)
-- CREDTab:CreateButton({
--     Name = "Copy All anti cheat games",
--     Callback = function()
--         setclipboard("https://www.roblox.com/games/16484430822/Evolution-Ragdoll")
--     end
-- })






-- Toggle same

-- Notify if no supported game was detected
-- if not IsLoaded then
--     Rayfield:Notify({
--         Title = "Unsupported Game",
--         Content = "This game is not supported yet. Check back later!",
--         Duration = 3.5,
--         Image = 4483362458 -- Use a valid image ID or remove this line
--     })
-- end

-- local Tab = Window:CreateTab("Tab Example", 4483362458) -- Title, Image
-- local Button = Tab:CreateButton({
--    Name = "Button Example",
--    Callback = function()
--    -- The function that takes place when the button is pressed
--    end,
-- })

-- local SupportedGames = {
--     [155615604] = "Prison Life",
--     [14170731342] = "Twisted",
--     [7993293100] = "Tsunami Game",
--     [2768379856] = "3008",
--     [13622981808] = "Game X",
--     [13864667823] = "Break In 2",
--     [1318971886] = "Break In 1 Lobby",
--     [4620170611] = "Break In 1 Main",
--     [79546208627805] = "99 Nights Lobby",
--     [126509999114328] = "99 Nights Main",
--     [126884695634066] = "Grow a Garden",
--     [142823291] = "Murder Mystery 2"
-- }

-- if not SupportedGames[game.PlaceId] then
--     Rayfield:Notify({
--         Title = "Unsupported Game",
--         Content = "This game is not supported yet. Check back later!",
--         Duration = 3.5,
--         Image = 4483362458 -- Use a valid image ID or remove this line
--     })
--     return
-- end

-- Initialize Rayfield UI
--Rayfield:Init()
--Rayfield:LoadConfiguration()
