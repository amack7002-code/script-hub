
local Window = getgenv().RayfieldWindow
local Rayfield = getgenv().RayfieldLib

if not Window then
    warn("RayfieldWindow not found! Make sure to run the loader first.")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =========================================================
-- LIGHTS OUT
-- =========================================================

if game.PlaceId == 101421882323748 then
    _G.NotGames2 = false

    local mTab = Window:CreateTab("main", "compass")

    local level0 = workspace:WaitForChild("Level0")
    local facelings = level0:WaitForChild("Facelings")

    local espEnabled = false
    local espConnection = nil
    local modelConnections = {}

    local function removeESP(model)
        local connections = modelConnections[model]

        if connections then
            for _, connection in ipairs(connections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end

            modelConnections[model] = nil
        end

        if model and model.Parent then
            local highlight = model:FindFirstChild("esp")
            local billboard = model:FindFirstChild("state")

            if highlight then
                highlight:Destroy()
            end

            if billboard then
                billboard:Destroy()
            end
        end
    end

    local function clearESP()
        for model in pairs(modelConnections) do
            removeESP(model)
        end

        for _, model in ipairs(facelings:GetChildren()) do
            if model:IsA("Model") then
                removeESP(model)
            end
        end
    end

    local function applyESP(model)
        if not espEnabled then
            return
        end

        if not model:IsA("Model") or not model.Parent then
            return
        end

        if model:FindFirstChild("esp") then
            return
        end

        local adornee = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head")
            or model.PrimaryPart
            or model:FindFirstChildWhichIsA("BasePart")

        local highlight = Instance.new("Highlight")
        highlight.Name = "esp"
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model

        local connections = {}
        modelConnections[model] = connections

        if adornee then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "state"
            billboard.Adornee = adornee
            billboard.Size = UDim2.fromOffset(120, 40)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = model

            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeTransparency = 0.5
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = billboard

            local function updateText()
                if not model.Parent or not label.Parent then
                    return
                end

                local state = model:GetAttribute("State")
                label.Text = state ~= nil and tostring(state) or "Unknown"
            end

            updateText()

            table.insert(
                connections,
                model:GetAttributeChangedSignal("State"):Connect(updateText)
            )
        end

        table.insert(
            connections,
            model.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    removeESP(model)
                end
            end)
        )
    end

    local function startESP()
        clearESP()

        for _, model in ipairs(facelings:GetChildren()) do
            applyESP(model)
        end

        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end

        espConnection = facelings.ChildAdded:Connect(function(model)
            task.defer(function()
                if espEnabled and model.Parent == facelings then
                    applyESP(model)
                end
            end)
        end)
    end

    local function stopESP()
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end

        clearESP()
    end

    mTab:CreateToggle({
        Name = "Monster ESP (Toggle)",
        CurrentValue = false,

        Callback = function(value)
            espEnabled = value

            if value then
                startESP()
                print("[ESP] Monster ESP Enabled")
            else
                stopESP()
                print("[ESP] Monster ESP Disabled")
            end
        end
    })
end

-- =========================================================
-- STEAL OR DIE
-- =========================================================

if game.PlaceId == 119925538689885 then
    _G.NotGames2 = false

    local mTab = Window:CreateTab("main", "compass")

    local monsterESPEnabled = false
    local connections = {}
    local characterConnections = {}

    local function disconnectConnections(connectionList)
        for _, connection in ipairs(connectionList) do
            if connection.Connected then
                connection:Disconnect()
            end
        end

        table.clear(connectionList)
    end

    local function applyMonsterESP(character)
        if not monsterESPEnabled then
            return
        end

        if not character or not character.Parent then
            return
        end

        if not character:GetAttribute("EntityKind") then
            return
        end

        if character:FindFirstChild("MonsterESP") then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "MonsterESP"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = true
        highlight.Parent = character
    end

    local function watchCharacter(character)
        if not monsterESPEnabled or not character then
            return
        end

        applyMonsterESP(character)

        if character:GetAttribute("EntityKind") then
            return
        end

        local connection

        connection = character:GetAttributeChangedSignal("EntityKind"):Connect(function()
            if not monsterESPEnabled then
                connection:Disconnect()
                return
            end

            if character:GetAttribute("EntityKind") then
                applyMonsterESP(character)
                connection:Disconnect()
            end
        end)

        table.insert(characterConnections, connection)
    end

    local function watchPlayer(player)
        if player.Character then
            watchCharacter(player.Character)
        end

        table.insert(
            connections,
            player.CharacterAdded:Connect(function(character)
                watchCharacter(character)
            end)
        )
    end

    local function clearMonsterESP()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character

            if character then
                local highlight = character:FindFirstChild("MonsterESP")

                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end

    local function startMonsterESP()
        disconnectConnections(connections)
        disconnectConnections(characterConnections)

        for _, player in ipairs(Players:GetPlayers()) do
            watchPlayer(player)
        end

        table.insert(
            connections,
            Players.PlayerAdded:Connect(function(player)
                watchPlayer(player)
            end)
        )
    end

    local function stopMonsterESP()
        disconnectConnections(connections)
        disconnectConnections(characterConnections)

        clearMonsterESP()
    end

    mTab:CreateToggle({
        Name = "Monster ESP (Toggle)",
        CurrentValue = false,

        Callback = function(value)
            monsterESPEnabled = value

            if value then
                startMonsterESP()
                print("[ESP] Monster ESP Enabled")
            else
                stopMonsterESP()
                print("[ESP] Monster ESP Disabled")
            end
        end
    })
end

-- =========================================================
-- STRAFEX
-- =========================================================

if game.PlaceId == 129861507977954 then
    _G.NotGames2 = false

    local player = Players.LocalPlayer

    local function detectOffhand(item)
        return player:GetAttribute("Offhand") == item
    end

    local hasTotem = detectOffhand("Totem")

    if hasTotem then
        print("[Strafex] Totem detected in offhand")
    else
        print("[Strafex] No Totem in offhand")
    end
end

-- =========================================================
-- DING DONG DITCH
-- =========================================================

if game.PlaceId == 92551591080135 then
    _G.NotGames2 = false

    local mTab = Window:CreateTab("main", "compass")

    local player = Players.LocalPlayer
    local houses = workspace:WaitForChild("Map"):WaitForChild("Houses")

    local getknocked = false
    local autoescape = true
    local partyRoomPriority = false
    local autoFarm = false

    local partTransparency = 0

    local matchInfo = ReplicatedStorage:WaitForChild("MatchInfo")
    local exitopen = matchInfo:WaitForChild("ExitOpen")

    local escape = workspace
        :WaitForChild("Map")
        :WaitForChild("Environment")
        :WaitForChild("NorthStairs")
        :WaitForChild("StreetDoor")

    local totalPrompts = {}

    -- Stop an older copy if the script is executed again.

    if shared.DingDongDitchState then
        shared.DingDongDitchState.running = false

        local oldSafeSpot = shared.DingDongDitchState.safeSpot

        if oldSafeSpot and oldSafeSpot.Parent then
            oldSafeSpot:Destroy()
        end
    end

    local runState = {
        running = true,
        safeSpot = nil
    }

    shared.DingDongDitchState = runState

    -- SAFE SPOT

    local safeSpot = Instance.new("Part")
    safeSpot.Name = "safe"
    safeSpot.Size = Vector3.new(1000, 1, 1000)
    safeSpot.Anchored = true
    safeSpot.CFrame = CFrame.new(0, 200, 0)
    safeSpot.Transparency = partTransparency
    safeSpot.Parent = workspace

    runState.safeSpot = safeSpot

    -- RAYFIELD UI

    mTab:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Flag = "AutoFarm",

        Callback = function(value)
            autoFarm = value
        end
    })

    mTab:CreateToggle({
        Name = "Get already Knocked",
        CurrentValue = false,
        Flag = "GetKnocked",

        Callback = function(value)
            getknocked = value
        end
    })

    mTab:CreateToggle({
        Name = "Auto Escape",
        CurrentValue = true,
        Flag = "AutoEscape",

        Callback = function(value)
            autoescape = value
        end
    })

    mTab:CreateToggle({
        Name = "Party Room Priority",
        CurrentValue = false,
        Flag = "PartyRoomPriority",

        Callback = function(value)
            partyRoomPriority = value
        end
    })

    mTab:CreateSlider({
        Name = "Safe Spot Transparency",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = 0,
        Flag = "SafeSpotTransparency",

        Callback = function(value)
            partTransparency = value

            if safeSpot and safeSpot.Parent then
                safeSpot.Transparency = value
            end
        end
    })

    -- PROMPT FINDER

    local function getdoorProxPrompt()
        table.clear(totalPrompts)

        local partyPrompts = {}
        local normalPrompts = {}

        for _, prompt in ipairs(houses:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Name == "KnockPrompt" then
                local knocked = prompt:GetAttribute("Knocked") == true
                local party = prompt:GetAttribute("Party") == true

                if not getknocked or knocked then
                    if partyRoomPriority and party then
                        table.insert(partyPrompts, prompt)
                    else
                        table.insert(normalPrompts, prompt)
                    end
                end
            end
        end

        for _, prompt in ipairs(partyPrompts) do
            table.insert(totalPrompts, prompt)
        end

        for _, prompt in ipairs(normalPrompts) do
            table.insert(totalPrompts, prompt)
        end

        return totalPrompts
    end

    -- CHARACTER

    local function getRoot()
        local character = player.Character or player.CharacterAdded:Wait()

        return character:WaitForChild("HumanoidRootPart")
    end

    -- TELEPORT

    local function teleportTo(part)
        if not part or not part.Parent then
            return
        end

        local root = getRoot()

        if part:IsA("BasePart") then
            root.CFrame = part.CFrame + Vector3.new(0, 1, 0)
        elseif part:IsA("Model") then
            root.CFrame = part:GetPivot() + Vector3.new(0, 1, 0)
        end
    end

    -- PROMPT ACTIVATION

    local function activatePrompt(prompt)
        if not prompt or not prompt.Parent then
            return
        end

        if not prompt.Enabled then
            return
        end

        fireproximityprompt(prompt)
    end

    -- AUTO FARM LOOP

    task.spawn(function()
        while runState.running do
            if not autoFarm then
                task.wait(0.2)
                continue
            end

            if autoescape and exitopen.Value == true then
                teleportTo(escape)
                task.wait(0.5)
                continue
            end

            local prompts = getdoorProxPrompt()

            for _, prompt in ipairs(prompts) do
                if not runState.running or not autoFarm then
                    break
                end

                if autoescape and exitopen.Value == true then
                    break
                end

                if not prompt.Parent or not prompt.Enabled then
                    continue
                end

                local door = prompt.Parent.Parent

                if door then
                    teleportTo(door)

                    task.wait(0.2)

                    activatePrompt(prompt)

                    task.wait(0.2)

                    teleportTo(safeSpot)

                    task.wait(5)
                end
            end

            task.wait(0.5)
        end
    end)
end
