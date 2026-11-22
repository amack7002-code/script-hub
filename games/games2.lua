
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
-- HOTEL + NEIGHBORHOOD
-- =========================================================

if game.PlaceId == 92551591080135 then
    _G.NotGames2 = false

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local map = workspace:WaitForChild("Map")

    print("[Ding Dong Ditch] Starting...")

    -- =====================================================
    -- PREVIOUS INSTANCE CLEANUP
    -- =====================================================

    if shared.DingDongDitchState then
        local oldState = shared.DingDongDitchState
        oldState.running = false

        for _, name in ipairs({"safeSpotHotel", "safeSpotNeighborhood"}) do
            local part = oldState[name]
            if part then
                pcall(function()
                    part:Destroy()
                end)
            end
        end
    end

    local runState = {
        running = true,
        safeSpotHotel = nil,
        safeSpotNeighborhood = nil
    }

    shared.DingDongDitchState = runState

    -- =====================================================
    -- SAFE SPOT
    -- =====================================================

    local function createSafeSpot(name)
        local part = Instance.new("Part")
        part.Name = name
        part.Size = Vector3.new(1000, 1, 1000)
        part.Anchored = true
        part.CanCollide = true
        part.Transparency = 0
        part.CFrame = CFrame.new(0, 200, 0)
        part.Parent = workspace
        return part
    end

    -- =====================================================
    -- SETTINGS
    -- =====================================================

    local hotelSettings = {
        autoFarm = false,
        getKnocked = false,
        autoEscape = true,
        partyRoomPriority = false,
        transparency = 0
    }

    local neighborhoodSettings = {
        autoFarm = false,
        getKnocked = false,
        autoEscape = true,
        partyRoomPriority = false,
        transparency = 0
    }

    -- =====================================================
    -- HOTEL REFERENCES
    -- =====================================================

    local hotelHouses
    local hotelExitOpen
    local escapeHotel

    local function setupHotel()
        local success, result = pcall(function()
            hotelHouses = map:FindFirstChild("Houses")

            local matchInfo = ReplicatedStorage:FindFirstChild("MatchInfo")
            hotelExitOpen = matchInfo and matchInfo:FindFirstChild("ExitOpen")

            local environment = map:FindFirstChild("Environment")
            local stairs = environment and environment:FindFirstChild("NorthStairs")
            escapeHotel = stairs and stairs:FindFirstChild("StreetDoor")

            if not hotelHouses then
                error("Hotel Houses folder not found")
            end

            if not hotelExitOpen then
                error("Hotel MatchInfo.ExitOpen not found")
            end

            if not escapeHotel then
                error("Hotel StreetDoor not found")
            end

            return true
        end)

        if not success then
            warn("[Ding Dong Ditch] Hotel skipped: " .. tostring(result))
            return false
        end

        print("[Ding Dong Ditch] Hotel references loaded")
        return true
    end

    local hotelFound = setupHotel()

    -- =====================================================
    -- NEIGHBORHOOD REFERENCES
    -- =====================================================

    local neighborhoodHouses = map:FindFirstChild("Houses")

    local escapeFolder = map:FindFirstChild("Escape")
    local escapeNeighborhood = escapeFolder
        and escapeFolder:FindFirstChild("EscapeZone")

    if not escapeNeighborhood then
        warn("[Ding Dong Ditch] Neighborhood EscapeZone not found")
    else
        print("[Ding Dong Ditch] Neighborhood exit found")
    end

    -- =====================================================
    -- CREATE SAFE SPOTS
    -- =====================================================

    local safeSpotHotel
    local safeSpotNeighborhood

    if hotelFound then
        local success, result = pcall(function()
            safeSpotHotel = createSafeSpot("safeHotel")
            runState.safeSpotHotel = safeSpotHotel
        end)

        if not success then
            warn("[Ding Dong Ditch] Hotel safe spot error: " .. tostring(result))
        end
    end

    local neighborhoodSafeSuccess, neighborhoodSafeError = pcall(function()
        safeSpotNeighborhood = createSafeSpot("safeNeighborhood")
        runState.safeSpotNeighborhood = safeSpotNeighborhood
    end)

    if not neighborhoodSafeSuccess then
        warn("[Ding Dong Ditch] Neighborhood safe spot error: " .. tostring(neighborhoodSafeError))
    end

    -- =====================================================
    -- TRANSPARENCY
    -- =====================================================

    local function updateHotelTransparency()
        if safeSpotHotel and safeSpotHotel.Parent then
            safeSpotHotel.Transparency = hotelSettings.transparency
        end
    end

    local function updateNeighborhoodTransparency()
        if safeSpotNeighborhood and safeSpotNeighborhood.Parent then
            safeSpotNeighborhood.Transparency = neighborhoodSettings.transparency
        end
    end

    -- =====================================================
    -- CREATE TABS INDEPENDENTLY
    -- =====================================================

    local HotelTab
    local NeighborhoodTab

    if hotelFound then
        local success, result = pcall(function()
            HotelTab = Window:CreateTab("Hotel", "compass")

            HotelTab:CreateToggle({
                Name = "Auto Farm",
                CurrentValue = false,
                Flag = "HotelAutoFarm",
                Callback = function(value)
                    hotelSettings.autoFarm = value
                end
            })

            HotelTab:CreateToggle({
                Name = "Get already Knocked",
                CurrentValue = false,
                Flag = "HotelGetKnocked",
                Callback = function(value)
                    hotelSettings.getKnocked = value
                end
            })

            HotelTab:CreateToggle({
                Name = "Auto Escape",
                CurrentValue = true,
                Flag = "HotelAutoEscape",
                Callback = function(value)
                    hotelSettings.autoEscape = value
                end
            })

            HotelTab:CreateToggle({
                Name = "Party Room Priority",
                CurrentValue = false,
                Flag = "HotelPartyRoomPriority",
                Callback = function(value)
                    hotelSettings.partyRoomPriority = value
                end
            })

            HotelTab:CreateSlider({
                Name = "Safe Spot Transparency",
                Range = {0, 1},
                Increment = 0.1,
                Suffix = "",
                CurrentValue = 0,
                Flag = "HotelSafeSpotTransparency",
                Callback = function(value)
                    hotelSettings.transparency = value
                    updateHotelTransparency()
                end
            })
        end)

        if not success then
            warn("[Ding Dong Ditch] Hotel UI error: " .. tostring(result))
        else
            print("[Ding Dong Ditch] Hotel UI loaded")
        end
    else
        print("[Ding Dong Ditch] Skipping Hotel and continuing...")
    end

    -- =====================================================
    -- NEIGHBORHOOD UI
    -- =====================================================

    do
        local success, result = pcall(function()
            NeighborhoodTab = Window:CreateTab("Neighborhood", "compass")

            NeighborhoodTab:CreateToggle({
                Name = "Auto Farm",
                CurrentValue = false,
                Flag = "NeighborhoodAutoFarm",
                Callback = function(value)
                    neighborhoodSettings.autoFarm = value
                end
            })

            NeighborhoodTab:CreateToggle({
                Name = "Get already Knocked",
                CurrentValue = false,
                Flag = "NeighborhoodGetKnocked",
                Callback = function(value)
                    neighborhoodSettings.getKnocked = value
                end
            })

            NeighborhoodTab:CreateToggle({
                Name = "Auto Escape",
                CurrentValue = true,
                Flag = "NeighborhoodAutoEscape",
                Callback = function(value)
                    neighborhoodSettings.autoEscape = value
                end
            })

            NeighborhoodTab:CreateToggle({
                Name = "Party Room Priority",
                CurrentValue = false,
                Flag = "NeighborhoodPartyRoomPriority",
                Callback = function(value)
                    neighborhoodSettings.partyRoomPriority = value
                end
            })

            NeighborhoodTab:CreateSlider({
                Name = "Safe Spot Transparency",
                Range = {0, 1},
                Increment = 0.1,
                Suffix = "",
                CurrentValue = 0,
                Flag = "NeighborhoodSafeSpotTransparency",
                Callback = function(value)
                    neighborhoodSettings.transparency = value
                    updateNeighborhoodTransparency()
                end
            })
        end)

        if not success then
            warn("[Ding Dong Ditch] Neighborhood UI error: " .. tostring(result))
        else
            print("[Ding Dong Ditch] Neighborhood UI loaded")
        end
    end

    -- =====================================================
    -- HOTEL PROMPT FINDER
    -- =====================================================

    local function getHotelPrompts()
        if not hotelFound or not hotelHouses then
            return {}
        end

        local partyPrompts = {}
        local normalPrompts = {}

        for _, prompt in ipairs(hotelHouses:GetDescendants()) do
            if prompt:IsA("ProximityPrompt")
                and prompt.Name == "KnockPrompt" then

                local knocked = prompt:GetAttribute("Knocked") == true
                local party = prompt:GetAttribute("Party") == true

                if not hotelSettings.getKnocked or knocked then
                    if hotelSettings.partyRoomPriority and party then
                        table.insert(partyPrompts, prompt)
                    else
                        table.insert(normalPrompts, prompt)
                    end
                end
            end
        end

        local results = {}

        for _, prompt in ipairs(partyPrompts) do
            table.insert(results, prompt)
        end

        for _, prompt in ipairs(normalPrompts) do
            table.insert(results, prompt)
        end

        return results
    end

    -- =====================================================
    -- NEIGHBORHOOD PROMPT FINDER
    -- =====================================================

    local function getNeighborhoodPrompts()
        if not neighborhoodHouses then
            return {}
        end

        local partyPrompts = {}
        local normalPrompts = {}

        for _, prompt in ipairs(neighborhoodHouses:GetDescendants()) do
            if prompt:IsA("ProximityPrompt")
                and prompt.Name == "KnockPrompt" then

                local knocked = prompt:GetAttribute("Knocked") == true
                local party = prompt:GetAttribute("Party") == true

                if not neighborhoodSettings.getKnocked or knocked then
                    if neighborhoodSettings.partyRoomPriority and party then
                        table.insert(partyPrompts, prompt)
                    else
                        table.insert(normalPrompts, prompt)
                    end
                end
            end
        end

        local results = {}

        for _, prompt in ipairs(partyPrompts) do
            table.insert(results, prompt)
        end

        for _, prompt in ipairs(normalPrompts) do
            table.insert(results, prompt)
        end

        return results
    end

    -- =====================================================
    -- CONTINUOUS TRANSPARENCY SYNC
    -- =====================================================

    task.spawn(function()
        while runState.running do
            updateHotelTransparency()
            updateNeighborhoodTransparency()
            task.wait(0.2)
        end
    end)

    -- =====================================================
    -- CLEANUP
    -- =====================================================

    task.spawn(function()
        while runState.running do
            task.wait(1)
        end

        if safeSpotHotel and safeSpotHotel.Parent then
            safeSpotHotel:Destroy()
        end

        if safeSpotNeighborhood and safeSpotNeighborhood.Parent then
            safeSpotNeighborhood:Destroy()
        end
    end)

    -- =====================================================
    -- FINISHED
    -- =====================================================

    print("[Ding Dong Ditch] Loading finished")
    print("[Ding Dong Ditch] Hotel found: " .. tostring(hotelFound))
    print("[Ding Dong Ditch] Neighborhood exit found: " .. tostring(escapeNeighborhood ~= nil))
end


