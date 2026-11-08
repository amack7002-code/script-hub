local Window = getgenv().RayfieldWindow
local Rayfield = getgenv().RayfieldLib

if not Window then
    warn("RayfieldWindow not found! Make sure to run the loader first.")
    return
end

-- lights out
if game.PlaceId == 101421882323748 then
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
    local plr = game.Players.LocalPlayer
    local function detectOffhand(item)
        local offhand = plr:GetAttribute("Offhand")
        return offhand == item
    end

    if not detectOffhand("Totem") then
        return
    end
end
