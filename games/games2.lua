local Window = getgenv().RayfieldWindow
local Rayfield = getgenv().RayfieldLib

if not Window then
    warn("RayfieldWindow not found! Make sure to run the loader first.")
    return
end

-- lights out
if game.PlaceId == 101421882323748 then
    _G.NotGames1 = false
    local mTab = Window:CreateTab("main", "compass")

    local level0 = workspace:WaitForChild("Level0")
    local facelings = level0:WaitForChild("Facelings")

    local espEnabled = false
    local espConnection = nil

    local function clearESP()
        for _, v in pairs(facelings:GetChildren()) do
            if v:IsA("Model") then
                -- Remove Highlight
                local highlight = v:FindFirstChild("esp")
                if highlight then
                    highlight:Destroy()
                end

                -- Remove BillboardGui
                local billboard = v:FindFirstChild("state")
                if billboard then
                    billboard:Destroy()
                end
            end
        end
    end

    local function applyESP(model)
        if not model:IsA("Model") then return end
        if model:FindFirstChild("esp") then return end

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "esp"
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model

        -- Find a good part to attach the billboard to
        local adornee = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head")
            or model.PrimaryPart
            or model:FindFirstChildWhichIsA("BasePart")

        if not adornee then return end

        -- BillboardGui
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "state"
        billboardGui.Adornee = adornee
        billboardGui.Size = UDim2.new(0, 120, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = model

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboardGui

        local function updateText()
            local state = model:GetAttribute("State")
            textLabel.Text = state and tostring(state) or "Unknown"
        end

        updateText()

        -- Live update when State changes
        model:GetAttributeChangedSignal("State"):Connect(updateText)
    end

    local function startESP()
        -- Apply to existing ones
        for _, v in pairs(facelings:GetChildren()) do
            applyESP(v)
        end

        -- Watch for new ones
        if espConnection then
            espConnection:Disconnect()
        end

        espConnection = facelings.ChildAdded:Connect(function(child)
            if espEnabled then
                task.wait(0.1) -- small delay so the model fully loads
                applyESP(child)
            end
        end)
    end

    local function stopESP()
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        clearESP()
    end

    mTab:CreateButton({
        Name = "Monster ESP (Toggle)",
        Callback = function()
            espEnabled = not espEnabled

            if espEnabled then
                startESP()
                print("[ESP] Monster ESP Enabled")
            else
                stopESP()
                print("[ESP] Monster ESP Disabled")
            end
        end
    })
end

--steal or die
if game.PlaceId == 119925538689885 then 
    _G.NotGames1 = false
    local mTab = Window:CreateTab("main", "compass")
    local Players = game:GetService("Players")

    local monsterESPEnabled = false
    local connections = {}

    local function applyMonsterESP(character)
        if not character or not character.Parent then return end
        if character:FindFirstChild("MonsterESP") then return end

        -- Only apply if they have the EntityKind attribute
        if not character:GetAttribute("EntityKind") then return end

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

    local function clearMonsterESP()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local esp = character:FindFirstChild("MonsterESP")
                if esp then
                    esp:Destroy()
                end
            end
        end
    end

    local function onCharacterAdded(character)
        if not monsterESPEnabled then return end

        -- Wait a tiny bit for attributes to load
        task.defer(function()
            applyMonsterESP(character)
        end)

        -- In case EntityKind is added a bit later
        local conn
        conn = character:GetAttributeChangedSignal("EntityKind"):Connect(function()
            if monsterESPEnabled then
                applyMonsterESP(character)
            end
            if conn then
                conn:Disconnect()
            end
        end)
    end

    local function startMonsterESP()
        -- Apply to current players
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                applyMonsterESP(player.Character)
            end

            table.insert(connections, player.CharacterAdded:Connect(onCharacterAdded))
        end

        -- Handle players who join later
        table.insert(connections, Players.PlayerAdded:Connect(function(player)
            table.insert(connections, player.CharacterAdded:Connect(onCharacterAdded))

            if player.Character then
                applyMonsterESP(player.Character)
            end
        end))
    end

    local function stopMonsterESP()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        table.clear(connections)

        clearMonsterESP()
    end
    mTab:CreateToggle({
        Name = "Monster ESP (Toggle)",
        CurrentValue = false, -- optional, starts off
        Callback = function(Value)
            monsterESPEnabled = Value

            if monsterESPEnabled then
                startMonsterESP()
                print("[ESP] Monster ESP Enabled")
            else
                stopMonsterESP()
                print("[ESP] Monster ESP Disabled")
            end
        end
    })

end

--strafex i dont care about ts + vibecoded game
if game.PlaceId == 129861507977954 then
    _G.NotGames1 = false
    local plr = game.Players.LocalPlayer
    local function detectOffhand(item)
        local offhand = plr:GetAttribute("Offhand")
        return offhand == item
    end

    if not detectOffhand("Totem") then
        return
    end
end

--ding dong ditch idk game
if game.PlaceId == 92551591080135 then
    _G.NotGames1 = false
    -- im the best vibe coder trust
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local player = Players.LocalPlayer
    local houses = workspace.Map.Houses
    
    local getknocked = false
    local autoescape = true
    local partyRoomPriority = false
    local autoFarm = false
    
    local partTransparency = 0
    
    local exitopen = ReplicatedStorage.MatchInfo.ExitOpen
    local escape = workspace.Map.Environment.NorthStairs.StreetDoor
    
    local totalPrompts = {}
    
    -- SAFE SPOT
    
    local safeSpot = Instance.new("Part")
    safeSpot.Name = "safe"
    safeSpot.Size = Vector3.new(1000, 1, 1000)
    safeSpot.Anchored = true
    safeSpot.CFrame = CFrame.new(0, 200, 0)
    safeSpot.Transparency = partTransparency
    safeSpot.Parent = workspace
    
    -- RAYFIELD GEN 1
    
    Etab:CreateToggle({
        Name = "Auto Farm",
        CurrentValue = false,
        Flag = "AutoFarm",
        Callback = function(value)
            autoFarm = value
        end
    })
    
    Etab:CreateToggle({
        Name = "Get already Knocked",
        CurrentValue = false,
        Flag = "GetKnocked",
        Callback = function(value)
            getknocked = value
        end
    })
    
    Etab:CreateToggle({
        Name = "Auto Escape",
        CurrentValue = true,
        Flag = "AutoEscape",
        Callback = function(value)
            autoescape = value
        end
    })
    
    Etab:CreateToggle({
        Name = "Party Room Priority",
        CurrentValue = false,
        Flag = "PartyRoomPriority",
        Callback = function(value)
            partyRoomPriority = value
        end
    })
    
    Etab:CreateSlider({
        Name = "Safe Spot Transparency",
        Range = {0, 1},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = 0,
        Flag = "SafeSpotTransparency",
        Callback = function(value)
            partTransparency = value
            safeSpot.Transparency = value
        end
    })
    
    -- PROMPT FINDER
    
    local function getdoorProxPrompt()
        table.clear(totalPrompts)
    
        local partyPrompts = {}
        local normalPrompts = {}
    
        for _, v in pairs(houses:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Name == "KnockPrompt" then
    
                local knocked = v:GetAttribute("Knocked") == true
                local party = v:GetAttribute("Party") == true
    
                if not getknocked or knocked then
                    if partyRoomPriority and party then
                        table.insert(partyPrompts, v)
                    else
                        table.insert(normalPrompts, v)
                    end
                end
            end
        end
    
        -- PARTY ROOMS FIRST
    
        for _, v in ipairs(partyPrompts) do
            table.insert(totalPrompts, v)
        end
    
        -- NORMAL ROOMS AFTERWARD
    
        for _, v in ipairs(normalPrompts) do
            table.insert(totalPrompts, v)
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
        if not part then
            return
        end
    
        if part:IsA("BasePart") then
            getRoot().CFrame = part.CFrame + Vector3.new(0, 1, 0)
    
        elseif part:IsA("Model") then
            getRoot().CFrame = part:GetPivot() + Vector3.new(0, 1, 0)
        end
    end
    
    -- PROMPT ACTIVATION
    
    local function activatePrompt(prompt)
        if prompt and prompt.Parent and prompt.Enabled then
            fireproximityprompt(prompt)
        end
    end
    
    -- AUTO FARM LOOP
    
    task.spawn(function()
        while true do
            if not autoFarm then
                task.wait(0.2)
                continue
            end
    
            -- AUTO ESCAPE
    
            if autoescape and exitopen.Value == true then
                teleportTo(escape)
                task.wait(0.5)
                continue
            end
    
            local prompts = getdoorProxPrompt()
    
            for _, prompt in ipairs(prompts) do
    
                if not autoFarm then
                    break
                end
    
                -- CHECK EXIT
    
                if autoescape and exitopen.Value == true then
                    break
                end
    
                if not prompt.Parent or not prompt.Enabled then
                    continue
                end
    
                local door = prompt.Parent.Parent
    
                if door then
                    -- TELEPORT TO DOOR
    
                    teleportTo(door)
    
                    task.wait(0.2)
    
                    -- ACTIVATE PROMPT
    
                    activatePrompt(prompt)
    
                    task.wait(0.2)
    
                    -- RETURN TO SAFE SPOT
    
                    teleportTo(safeSpot)
    
                    task.wait(5)
                end
            end
    
            task.wait(0.5)
        end
    end)
end
