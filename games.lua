local Window = getgenv().RayfieldWindow
local Rayfield = getgenv().RayfieldLib

if not Window then
    warn("RayfieldWindow not found! Make sure to run the loader first.")
    return
end

-- prison Life
if game.PlaceId == 155615604 then
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- -- Gun mod helper
    -- local function applyGunMod(toolName)
    --     local tool = character:FindFirstChild(toolName) or player.Backpack:FindFirstChild(toolName)
    --     if tool and tool:FindFirstChild("GunStates") then
    --         local ok, gun = pcall(require, tool.GunStates)
    --         if ok and gun then
    --             gun.Damage = math.huge
    --             gun.MaxAmmo = math.huge
    --             gun.CurrentAmmo = math.huge
    --             gun.StoredAmmo = math.huge
    --             gun.FireRate = 0.1
    --             gun.AutoFire = true
    --             gun.Range = 1e13
    --             gun.Spread = 0
    --             gun.ReloadTime = 1e-8
    --             gun.Bullets = 10
    --             print(tool.Name.." mod applied!")
    --         end
    --     end
    -- end

    --========================
    -- LocalPlayer Tab
    --========================
    local PlayerTab = Window:CreateTab("Local Player", "user")
    local customSpeed = 16
    local customJump = 50
    local invisible = false
    local savedCFrame, fakeHRP

    -- -- Invisibility
    -- local function becomeInvisible()
    --     if not character then return end
    --     local hrp = character:FindFirstChild("HumanoidRootPart")
    --     if not hrp or fakeHRP then return end
    --     savedCFrame = hrp.CFrame
    --     fakeHRP = hrp:Clone()
    --     fakeHRP.Name = "FakeHumanoidRootPart"
    --     fakeHRP.Parent = character
    --     hrp.Anchored = true
    --     hrp.CanCollide = false
    --     hrp.Transparency = 1
    --     hrp.CFrame = CFrame.new(0,9999,0)
    --     character.PrimaryPart = fakeHRP
    --     for _, part in ipairs(character:GetChildren()) do
    --         if part:IsA("BasePart") and part ~= hrp then
    --             local weld = Instance.new("WeldConstraint")
    --             weld.Part0 = fakeHRP
    --             weld.Part1 = part
    --             weld.Parent = fakeHRP
    --         end
    --     end
    --     invisible = true
    -- end

    -- local function becomeVisible()
    --     if not character then return end
    --     local hrp = character:FindFirstChild("HumanoidRootPart")
    --     if fakeHRP then
    --         hrp.CFrame = fakeHRP.CFrame or savedCFrame or hrp.CFrame
    --         character.PrimaryPart = hrp
    --         fakeHRP:Destroy()
    --         fakeHRP = nil
    --     elseif savedCFrame then
    --         hrp.CFrame = savedCFrame
    --     end
    --     hrp.Anchored = false
    --     hrp.CanCollide = true
    --     hrp.Transparency = 0
    --     invisible = false
    -- end

    PlayerTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {10, 1000},
        Increment = 1,
        CurrentValue = customSpeed,
        Callback = function(v)
            customSpeed = v
            if humanoid then humanoid.WalkSpeed = v end
        end
    })

    PlayerTab:CreateSlider({
        Name = "JumpPower",
        Range = {10, 1000},
        Increment = 1,
        CurrentValue = customJump,
        Callback = function(v)
            customJump = v
            if humanoid then humanoid.JumpPower = v end
        end
    })

    -- PlayerTab:CreateToggle({
    --     Name = "Invisibility (V to toggle too)",
    --     CurrentValue = false,
    --     Callback = function(v)
    --         if v then becomeInvisible() else becomeVisible() end
    --     end
    -- })

    -- UserInputService.InputBegan:Connect(function(input, gpe)
    --     if gpe then return end
    --     if input.KeyCode == Enum.KeyCode.V then
    --         if invisible then becomeVisible() else becomeInvisible() end
    --     end
    -- end)

    --========================
    -- Combat Tab
    --========================
    local CombatTab = Window:CreateTab("Combat", "sword")
	local GunModMode = 0 -- 0 = Off, 1 = Gun Mod

local OldNamecall

OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	
	if method == "GetAttributes" and GunModMode == 1 then
		local result = OldNamecall(self, ...)

		if typeof(result) == "table" then
			result.AutoFire = true
			result.FireRate = 0
			result.Range = 555
			result.Spread = 555
			
			-- You can uncomment these for more powerful mods later
			-- result.MaxAmmo = 999
			-- result.CurrentAmmo = 999
			
			-- print(self, "modded") -- optional
		end

		return result
	end

	return OldNamecall(self, ...)
end)

	local function findRemington()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v.Name == "Remington 870" then
				return v:FindFirstChildWhichIsA("BasePart")
			end
		end
		return nil
	end

	-- Updated to accept a string (the name of the tool) instead of an instance
	local function waitForTool(toolName)
		local player = game.Players.LocalPlayer
		local character = player.Character
		local backpack = player.Backpack

		repeat
			task.wait()
			-- Check if the tool exists in either the Character or Backpack
			if character and character:FindFirstChild(toolName) then return end
			if backpack and backpack:FindFirstChild(toolName) then return end
		until false
	end

	local function hasRemington()
    local player = game.Players.LocalPlayer

    return player.Backpack:FindFirstChild("Remington 870")
        or (player.Character and player.Character:FindFirstChild("Remington 870"))
end

local function getRem()
    local player = game.Players.LocalPlayer

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    if hasRemington() then
        return
    end

    local save = hrp.CFrame

    local remPart = findRemington()
    if not remPart then return end

    hrp.CFrame = remPart.CFrame

    firetouchinterest(hrp, remPart, 0)
    task.wait()
    firetouchinterest(hrp, remPart, 1)

    repeat
        task.wait()
    until hasRemington() or not player.Character

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = save
    end
end

	local function findMP5()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v.Name == "MP5" then
				return v:FindFirstChildWhichIsA("BasePart")
			end
		end
		return nil
	end

    local function hasMP5()
    local player = game.Players.LocalPlayer

    return player.Backpack:FindFirstChild("MP5")
        or (player.Character and player.Character:FindFirstChild("MP5"))
end

local function getMP5()
    local player = game.Players.LocalPlayer

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    if hasMP5() then
        return
    end

    local save = hrp.CFrame

    local mp5Part = findMP5()
    if not mp5Part then
        return
    end

    hrp.CFrame = mp5Part.CFrame

    firetouchinterest(hrp, mp5Part, 0)
    task.wait()
    firetouchinterest(hrp, mp5Part, 1)

    repeat
        task.wait()
    until hasMP5() or not player.Character

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = save
    end
end

    CombatTab:CreateButton({
        Name = "Gun Mod",
        Callback = function()
            GunModMode = 1
            print("Gun Mod Enabled")
        end
    })

local autoRem = false

CombatTab:CreateToggle({
    Name = "Auto Get Remington",
    CurrentValue = false,
    Flag = "AutoRemington",
    Callback = function(Value)
        autoRem = Value

        if autoRem then
            task.spawn(function()
                while autoRem do
                    pcall(getRem)
                    task.wait(0.5)
                end
            end)
        end
    end
})

    local autoMP5 = false
local autoMP5Thread

CombatTab:CreateToggle({
    Name = "Auto Get MP5",
    CurrentValue = false,
    Flag = "AutoMP5",
    Callback = function(Value)
        autoMP5 = Value

        if autoMP5 and not autoMP5Thread then
            autoMP5Thread = task.spawn(function()
                while autoMP5 do
                    pcall(function()
                        getMP5()
                    end)

                    task.wait(1)
                end

                autoMP5Thread = nil
            end)
        end
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if autoMP5 then
        task.wait(1) -- Wait for the character to fully load
        pcall(function()
            getMP5()
        end)
    end
end)

	-- CombatTab:CreateButton({
	-- 	Name = "OP Gun Mod",
	-- 	Callback = function()
	-- 		GunModMode = 2
	-- 	end
	-- })

    --========================
    -- Teleport Tab
    --========================
    local TeleportTab = Window:CreateTab("Teleport", "compass")
    local function teleportTo(pos)
        if hrp then hrp.CFrame = CFrame.new(pos) end
    end

    TeleportTab:CreateButton({ Name = "Police spawn", Callback = function() teleportTo(Vector3.new(836, 99.985, 2307)) end })
    TeleportTab:CreateButton({ Name = "Prison Cells", Callback = function() teleportTo(Vector3.new(916, 99.98, 2456)) end })
    TeleportTab:CreateButton({ Name = "Prison Roof",  Callback = function() teleportTo(Vector3.new(815, 118, 2365)) end })
end


--// TWISTED
if game.PlaceId == 14170731342 then 

	--// Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")

	local plr = Players.LocalPlayer

	--========================
	-- Local Player Tab (Fly)
	--========================
	local LPTab = Window:CreateTab("Local Player", 4483362458)

	-- Fly state
	local flying = false
	local keyDown = {}
	local hotkey = Enum.KeyCode.G
	local speed = 70

	-- Connections
	local inputBeganConn, inputEndedConn, renderConn
	local originalFOV
	local flyToggle

	-- Character helpers
	local function getChar()
		return plr.Character or plr.CharacterAdded:Wait()
	end

	local function getHumanoid()
		return getChar():WaitForChild("Humanoid")
	end

	local function getHRP()
		return getChar():WaitForChild("HumanoidRootPart")
	end

	--========================
	-- Fly Logic
	--========================
	local function startFlying()
		if renderConn then return end -- prevent stacking

		local char = getChar()
		local hrp = getHRP()
		local hum = getHumanoid()
		local camera = workspace.CurrentCamera
		if not camera then return end

		originalFOV = camera.FieldOfView
		camera.FieldOfView = 100
		keyDown = {}

		inputBeganConn = UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				keyDown[input.KeyCode] = true
			end
		end)

		inputEndedConn = UIS.InputEnded:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				keyDown[input.KeyCode] = false
			end
		end)

		renderConn = RunService.RenderStepped:Connect(function(dt)
			if not flying or not hrp or not hum then return end

			-- keep humanoid stable
			if hum:GetState() ~= Enum.HumanoidStateType.Physics then
				hum:ChangeState(Enum.HumanoidStateType.Physics)
			end

			-- kill physics velocity
			hrp.AssemblyLinearVelocity = Vector3.zero

			local dir = Vector3.zero
			if keyDown[Enum.KeyCode.W] then dir += camera.CFrame.LookVector end
			if keyDown[Enum.KeyCode.S] then dir -= camera.CFrame.LookVector end
			if keyDown[Enum.KeyCode.A] then dir -= camera.CFrame.RightVector end
			if keyDown[Enum.KeyCode.D] then dir += camera.CFrame.RightVector end
			if keyDown[Enum.KeyCode.Space] then dir += Vector3.yAxis end
			if keyDown[Enum.KeyCode.LeftControl] then dir -= Vector3.yAxis end

			if dir.Magnitude > 0 then
				hrp.CFrame += dir.Unit * speed * dt
			end
		end)
	end

	local function stopFlying()
		local camera = workspace.CurrentCamera
		if camera and originalFOV then
			camera.FieldOfView = originalFOV
		end

		if inputBeganConn then inputBeganConn:Disconnect() inputBeganConn = nil end
		if inputEndedConn then inputEndedConn:Disconnect() inputEndedConn = nil end
		if renderConn then renderConn:Disconnect() renderConn = nil end

		keyDown = {}
	end

	--========================
	-- UI Toggle
	--========================
	flyToggle = LPTab:CreateToggle({
		Name = "Fly (Press G)",
		CurrentValue = false,
		Callback = function(val)
			flying = val
			if flying then
				startFlying()
			else
				stopFlying()
			end
		end
	})

	--========================
	-- Hotkey Toggle
	--========================
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == hotkey then
			flying = not flying
			flyToggle:Set(flying)
		end
	end)

	--========================
	-- Fly Speed Slider
	--========================
	LPTab:CreateSlider({
		Name = "Fly Speed",
		Range = {10, 5000},
		Increment = 5,
		Suffix = "Studs/s",
		CurrentValue = speed,
		Callback = function(val)
			speed = val
		end
	})

	--========================
	-- Auto cleanup on respawn
	--========================
	plr.CharacterAdded:Connect(function()
		if flying then
			task.wait(0.2)
			stopFlying()
			startFlying()
		end
	end)

	--========================
	-- Teleport Tab (reserved)
	--========================
	Window:CreateTab("Teleport", 4483362458)
end

--// GRACE
if game.PlaceId == 138837502355157 then 

	--// Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local player = Players.LocalPlayer

	--////////////////////////////////////////////////////////////
	--// HELPERS
	--////////////////////////////////////////////////////////////

	local function getChar()
		return player.Character or player.CharacterAdded:Wait()
	end

	local function getHRP()
		return getChar():WaitForChild("HumanoidRootPart")
	end

	--////////////////////////////////////////////////////////////
	--// GRACE REPRIEVE (PATCHED – SAFE LOOP)
	--////////////////////////////////////////////////////////////

	local function grace()
		-- Remove NOW objects
		for _, obj in ipairs(player:GetDescendants()) do
			if obj.Name == "NOW" then
				obj:Destroy()
			end
		end

		-- Beacon pickup
		local beacons = workspace:FindFirstChild("Beacons")
		if beacons then
			for _, part in ipairs(beacons:GetChildren()) do
				if part.Name == "Part" then
					local beaconRemote = workspace:FindFirstChild("Script")
						and workspace.Script:FindFirstChild("BeaconPickup")
					if beaconRemote then
						beaconRemote:FireServer(part)
					end
				end
			end
		end

		-- Soft remote cleanup (do NOT spam)
		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				local n = obj.Name:sub(1,4)
				if n == "Send" or n == "Kill" then
					obj:Destroy()
				end
			end
		end
	end

	--////////////////////////////////////////////////////////////
	--// GRACE REGULAR / ZEN
	--////////////////////////////////////////////////////////////

	local function grace2()
		local char = getChar()
		local hrp = getHRP()
		local rooms = workspace:FindFirstChild("Rooms")
		if not rooms then return end

		local roomModels = {}

		for _, m in ipairs(rooms:GetChildren()) do
			if m:IsA("Model") and tonumber(m.Name) then
				table.insert(roomModels, {model=m, num=tonumber(m.Name)})
			end
		end

		table.sort(roomModels, function(a,b)
			return a.num < b.num
		end)

		for _, room in ipairs(roomModels) do
			local vault = room.model:FindFirstChild("VaultEntrance")
			if vault then
				local prompt =
					vault:FindFirstChild("Hinged")
					and vault.Hinged:FindFirstChild("Cylinder")
					and vault.Hinged.Cylinder:FindFirstChild("ProximityPrompt")

				if prompt then
					ReplicatedStorage.TriggerPrompt:FireServer(prompt)
					ReplicatedStorage.Events.EnteredSaferoom:FireServer()
				end
			else
				for _, d in ipairs(room.model:GetDescendants()) do
					if d:IsA("BaseScript") then
						d:Destroy()
					end
				end
			end
		end

		-- Move to exit
		local last = roomModels[#roomModels]
		if last then
			local exit = last.model:FindFirstChild("Exit")
			if exit and exit:IsA("BasePart") then
				hrp.CFrame = exit.CFrame * CFrame.Angles(0, math.rad(45), 0)
				workspace.CurrentCamera.CFrame = hrp.CFrame
			end
		end
	end

	--////////////////////////////////////////////////////////////
	--// UI
	--////////////////////////////////////////////////////////////

	local MainTab = Window:CreateTab("Main", "home")

	local hbGrace1, hbGrace2

	MainTab:CreateToggle({
		Name = "❌ Grace Reprieve [PATCHED] ❌",
		CurrentValue = false,
		Callback = function(v)
			if v then
				-- Anti kick (safe)
				if hookfunction then
					pcall(function()
						hookfunction(player.Kick, function() end)
					end)
				end

				hbGrace1 = RunService.Heartbeat:Connect(function()
					grace()
					task.wait(0.5)
				end)
			else
				if hbGrace1 then hbGrace1:Disconnect() hbGrace1 = nil end
			end
		end
	})

	MainTab:CreateToggle({
		Name = "Grace Regular (Normal / Zen)",
		CurrentValue = false,
		Callback = function(v)
			if v then
				hbGrace2 = RunService.Heartbeat:Connect(function()
					grace2()
					task.wait(0.5)
				end)
			else
				if hbGrace2 then hbGrace2:Disconnect() hbGrace2 = nil end
			end
		end
	})

	MainTab:CreateButton({
		Name = "Return to Lobby",
		Callback = function()
			pcall(function()
				ReplicatedStorage:WaitForChild("byebyemyFRIENDbacktothelobby"):FireServer()
			end)
		end
	})

	MainTab:CreateButton({
		Name = "Buy Crown (100 Keys)",
		Callback = function()
			pcall(function()
				ReplicatedStorage:WaitForChild("BuyKCrown"):InvokeServer()
			end)
		end
	})

	MainTab:CreateLabel("⚠ Use badge farming ONLY in reprieve + modifier lobbies")
end



--the final stand 2
if game.PlaceId == 2899434514 then
	local EspTab = Window:CreateTab("ESP", "eye")
	_G.ESPENABLED = true

local folder = workspace:WaitForChild("Zombies")

local function addESP()
	for _, v in pairs(folder:GetChildren()) do
		if not v:FindFirstChild("ESP") then
			local esp = Instance.new("Highlight")
			esp.Name = "ESP"
			esp.FillTransparency = 0.5
			esp.OutlineTransparency = 0
			esp.Parent = v
		end
	end
end

local function removeESP()
	for _, v in pairs(folder:GetChildren()) do
		local esp = v:FindFirstChild("ESP")
		if esp then
			esp:Destroy()
		end
	end
end

while task.wait(0.5) do
	if _G.ESPENABLED then
		addESP()
	else
		removeESP()
	end
end
end

if game.PlaceId == 91095706097751 then
	print("game")
end

--// Survive BRAINROT in Area 51!
if game.PlaceId == 95557151887828 then 

	--// Services
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	--// UI Tabs
	local ATab = Window:CreateTab("Grab", "eye")
	local BTab = Window:CreateTab("Go to", "eye")

	--// Character / HRP handling
	local function getHRP()
		local char = player.Character or player.CharacterAdded:Wait()
		return char:WaitForChild("HumanoidRootPart")
	end

	local hrp = getHRP()

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		hrp = getHRP()
	end)

	--// World references
	local lobby = workspace:WaitForChild("Lobby", 10)
	local map   = workspace:WaitForChild("Map", 10)

	--////////////////////////////////////////////////////////////
	--// TELEPORT BUTTONS
	--////////////////////////////////////////////////////////////

	BTab:CreateButton({
		Name = "Go to Lobby",
		Callback = function()
			if not lobby then return end

			local spawn =
				lobby:FindFirstChild("SpawnLocation")
				or lobby:FindFirstChildWhichIsA("BasePart")

			if spawn then
				hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
			end
		end
	})

	BTab:CreateButton({
		Name = "Go to Map",
		Callback = function()
			if not map or not map:IsA("Model") then return end

			local part =
				map.PrimaryPart
				or map:FindFirstChildWhichIsA("BasePart")

			if part then
				hrp.CFrame = part.CFrame + Vector3.new(0, 10, -14)
			end
		end
	})

	--////////////////////////////////////////////////////////////
	--// GRAB DROPPED ITEMS
	--////////////////////////////////////////////////////////////

	ATab:CreateButton({
		Name = "Grab all dropped items",
		Callback = function()
			local dropStorage = workspace:FindFirstChild("DroppedToolsStorage")
			if not dropStorage then
				warn("DroppedToolsStorage not found")
				return
			end

			local savedCFrame = hrp.CFrame

			for _, part in ipairs(dropStorage:GetDescendants()) do
				if part:IsA("BasePart") then
					hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
					task.wait(0.25)
				end
			end

			hrp.CFrame = savedCFrame
		end
	})
end


--// Zack Service Station (ZSS)
if game.PlaceId == 9359839118 then 

	local FTab = Window:CreateTab("funzy", "eye")

	--// Services
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer

	--////////////////////////////////////////////////////////////
	--// BLOXBULL AUTO BUY
	--////////////////////////////////////////////////////////////

	local function getDrinkPrompt()
		local vendors = workspace:WaitForChild("Vendors", 10)
		if not vendors then return end

		local vendor = vendors:FindFirstChild("Vendor_BloxBull_1")
		if not vendor then return end

		local root = vendor:FindFirstChild("Root")
		if not root then return end

		-- Primary search
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("ProximityPrompt") and obj.Name:lower():find("bloxbull") then
				return obj
			end
		end

		-- Backup path
		if root:FindFirstChild("Button") then
			return root.Button:FindFirstChild("BuyBloxBull")
		end
	end

	local drinkprox = getDrinkPrompt()

	local function tpAndReturnBloxbull()
		if not drinkprox then
			warn("BloxBull ProximityPrompt not found")
			return
		end

		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		local original = hrp.CFrame
		local target = CFrame.new(
			11.7194176, 3.00000072, -39.3352356,
			0.0309463572, 0, -0.999521017,
			0, 1, 0,
			0.999521017, 0, 0.0309463572
		)

		hrp.CFrame = target
		task.wait(0.25)

		drinkprox.HoldDuration = 0
		fireproximityprompt(drinkprox)

		task.wait(5)
		hrp.CFrame = original
	end

	--////////////////////////////////////////////////////////////
	--// UI
	--////////////////////////////////////////////////////////////

	local ATab = Window:CreateTab("Auto", "eye")
	ATab:CreateButton({
		Name = "Get Drink",
		Callback = tpAndReturnBloxbull
	})

	FTab:CreateInput({
		Name = "Set Token (client)",
		CurrentValue = "",
		PlaceholderText = "Input Number",
		RemoveTextAfterFocusLost = false,
		Flag = "Input1",
		Callback = function(Text)
	game:GetService("Players").LocalPlayer:SetAttribute("adTokens", Text)
		end,
	})

	--////////////////////////////////////////////////////////////
	--// LOCAL PLAYER
	--////////////////////////////////////////////////////////////

	-- local LPTab = Window:CreateTab("Local Player", "eye")

	-- local humanoid
	-- local speedEnabled = false
	-- local jumpEnabled = false
	-- local customSpeed = 16
	-- local customJump = 50

	-- local function getHumanoid()
	-- 	local char = player.Character or player.CharacterAdded:Wait()
	-- 	humanoid = char:WaitForChild("Humanoid")

	-- 	humanoid.WalkSpeed = speedEnabled and customSpeed or 16
	-- 	humanoid.JumpPower = jumpEnabled and customJump or 50
	-- end

	-- getHumanoid()
	-- player.CharacterAdded:Connect(function()
	-- 	task.wait(0.2)
	-- 	getHumanoid()
	-- end)

	-- -- WalkSpeed slider
	-- LPTab:CreateSlider({
	-- 	Name = "WalkSpeed",
	-- 	Range = {10, 100},
	-- 	Increment = 1,
	-- 	CurrentValue = 16,
	-- 	Callback = function(v)
	-- 		customSpeed = v
	-- 		if speedEnabled and humanoid then
	-- 			humanoid.WalkSpeed = v
	-- 		end
	-- 	end
	-- })

	-- -- WalkSpeed toggle
	-- LPTab:CreateToggle({
	-- 	Name = "Custom Speed",
	-- 	CurrentValue = false,
	-- 	Callback = function(state)
	-- 		speedEnabled = state
	-- 		if humanoid then
	-- 			humanoid.WalkSpeed = state and customSpeed or 16
	-- 		end
	-- 	end
	-- })

	-- -- JumpPower slider
	-- LPTab:CreateSlider({
	-- 	Name = "Jump Power",
	-- 	Range = {50, 100},
	-- 	Increment = 1,
	-- 	CurrentValue = 50,
	-- 	Callback = function(v)
	-- 		customJump = v
	-- 		if jumpEnabled and humanoid then
	-- 			humanoid.JumpPower = v
	-- 		end
	-- 	end
	-- })

	-- -- Jump toggle
	-- LPTab:CreateToggle({
	-- 	Name = "Custom Jump",
	-- 	CurrentValue = false,
	-- 	Callback = function(state)
	-- 		jumpEnabled = state
	-- 		if humanoid then
	-- 			humanoid.JumpPower = state and customJump or 50
	-- 		end
	-- 	end
	-- })
end


--// 3008
if game.PlaceId == 2768379856 then 
	IsLoaded = true

	--// Services
	local Players = game:GetService("Players")
	local Lighting = game:GetService("Lighting")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local player = Players.LocalPlayer

	--////////////////////////////////////////////////////////////
	--// LIGHTING FIX (NO FOG / BLOOD NIGHT)
	--////////////////////////////////////////////////////////////

	local function removeFog()
		local fog = Lighting:FindFirstChild("FogDay_Blur")
		if fog then fog.Density = 0 end

		local blood = Lighting:FindFirstChild("BloodNight_Atmosphere")
		if blood then blood.Density = 0 end
	end

	removeFog()
	Lighting.ChildAdded:Connect(removeFog)

	--////////////////////////////////////////////////////////////
	--// ESP TAB
	--////////////////////////////////////////////////////////////

	local EspTab = Window:CreateTab("ESP", "eye")
	EspTab:CreateLabel(
		"If ESP appears without enabling it, toggle Player ESP off/on once.",
		4483362458,
		Color3.fromRGB(0,0,0),
		false
	)

	local espEnabled = false
	local highlights = {}
	local charConns = {}

	local function addESP(p)
		if p == player or not p.Character or highlights[p] then return end

		local hl = Instance.new("Highlight")
		hl.Adornee = p.Character
		hl.FillColor = Color3.fromRGB(255, 0, 0)
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.5
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = workspace

		highlights[p] = hl
	end

	local function removeESP(p)
		if highlights[p] then
			highlights[p]:Destroy()
			highlights[p] = nil
		end
	end

	local function hookPlayer(p)
		if charConns[p] then charConns[p]:Disconnect() end
		charConns[p] = p.CharacterAdded:Connect(function()
			if espEnabled then
				task.wait(0.2)
				addESP(p)
			end
		end)
	end

	EspTab:CreateToggle({
		Name = "Enable Player ESP",
		CurrentValue = false,
		Callback = function(state)
			espEnabled = state

			if state then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= player then
						addESP(p)
						hookPlayer(p)
					end
				end

				Players.PlayerAdded:Connect(function(p)
					if espEnabled then
						hookPlayer(p)
					end
				end)

				Players.PlayerRemoving:Connect(function(p)
					removeESP(p)
					if charConns[p] then
						charConns[p]:Disconnect()
						charConns[p] = nil
					end
				end)
			else
				for _, p in ipairs(Players:GetPlayers()) do
					removeESP(p)
				end
				for _, c in pairs(charConns) do c:Disconnect() end
				charConns = {}
			end
		end
	})

	--////////////////////////////////////////////////////////////
	--// LOCAL PLAYER TAB
	--////////////////////////////////////////////////////////////

	local LPTab = Window:CreateTab("Local Player", 4483362458)

	local customSpeed = 16
	local speedEnabled = false

	local function applySpeed()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = speedEnabled and customSpeed or 16
		end
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		applySpeed()
	end)

	LPTab:CreateSlider({
		Name = "WalkSpeed",
		Range = {10, 100},
		Increment = 1,
		CurrentValue = 16,
		Callback = function(v)
			customSpeed = v
			if speedEnabled then applySpeed() end
		end
	})

	LPTab:CreateToggle({
		Name = "Custom Speed",
		CurrentValue = false,
		Callback = function(v)
			speedEnabled = v
			applySpeed()
		end
	})

	--////////////////////////////////////////////////////////////
	--// FULLBRIGHT
	--////////////////////////////////////////////////////////////

	local originalLighting = {
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		Brightness = Lighting.Brightness
	}

	LPTab:CreateToggle({
		Name = "FullBright",
		CurrentValue = false,
		Callback = function(v)
			if v then
				Lighting.FogEnd = 1e9
				Lighting.FogStart = 0
				Lighting.Brightness = 5
			else
				Lighting.FogEnd = originalLighting.FogEnd
				Lighting.FogStart = originalLighting.FogStart
				Lighting.Brightness = originalLighting.Brightness
			end
		end
	})

	--////////////////////////////////////////////////////////////
	--// ENABLE TIMER / CLOCK
	--////////////////////////////////////////////////////////////

	LPTab:CreateButton({
		Name = "Enable Timer / Clock",
		Callback = function()
			local gui = player.PlayerGui:WaitForChild("MainGui", 5)
			if not gui then return end

			local topBar = gui:FindFirstChild("TopBar")
			if not topBar then return end

			local calendar = topBar:FindFirstChild("Calendar")
			if not calendar then return end

			local clock = calendar:FindFirstChild("Gamepass_Clock")
			if not clock then return end

			clock.Visible = true

			local label = clock:FindFirstChildWhichIsA("TextLabel")
			if not label then return end

			local timeLeft = ReplicatedStorage
				:WaitForChild("ServerSettings")
				:WaitForChild("TimeSettings")
				:WaitForChild("TimeLeft")

			local function fmt(t)
				t = math.max(0, t)
				return string.format("%02d:%02d", math.floor(t / 60), t % 60)
			end

			label.Text = fmt(timeLeft.Value)
			timeLeft:GetPropertyChangedSignal("Value"):Connect(function()
				label.Text = fmt(timeLeft.Value)
			end)
		end
	})
end

--brick battles
if game.PlaceId == 85556817125839 then
	LPTab:CreateToggle({
		Name = "Auto Tix and Blocks",
		CurrentValue = false,
		Callback = function(v)
			local drops = workspace.Live.Drops
			local p = game.Players.LocalPlayer
			local c = p.Character
			local hrp = c.HumanoidRootPart

			while Wait() do
				for i,v in ipairs(drops:GetChildren()) do
					v.CFrame = hrp.CFrame
					v.CanCollide = false
					v.Transparency = 1
				end
			end
		end
	})
end




-- Transfur Outbreak
if game.PlaceId == 5987922834 then 

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local player = Players.LocalPlayer

	--// UI
	local ESPTab = Window:CreateTab("ESP", 4483362458)
	local PTab = Window:CreateTab("Player", 4483362458)

	--// Multiplier (SAFE)
	local multiplier = player:WaitForChild("Multiplier")
	local multi = multiplier:WaitForChild("Amount")
	local time = multiplier:WaitForChild("Expiration")

	PTab:CreateButton({
		Name = "Inf Multiplier (Cosmetic)",
		Callback = function()
			multi.Value = math.huge
			time.Value = 9e9
		end
	})

	PTab:CreateButton({
		Name = "Max Normal Multiplier",
		Callback = function()
			multi.Value = 25
			time.Value = 9e9
		end
	})

	ESPTab:CreateParagraph({
		Title = "ESP Colors",
		Content = "Red = Humans | Green = Infecteds"
	})

	--// Utilities
	local function getHRP(model)
		if not model then return nil end
		return model:FindFirstChild("HumanoidRootPart")
			or model.PrimaryPart
			or model:FindFirstChildWhichIsA("BasePart")
	end

	--////////////////////////////////////////////////////////////
	--// GENERIC ESP SYSTEM
	--////////////////////////////////////////////////////////////

	local function createESP(folder, color)
		local enabled = false
		local highlights = {}
		local connection

		local function add(model)
			if model == player.Character then return end
			if highlights[model] then return end

			local highlight = Instance.new("Highlight")
			highlight.Adornee = model
			highlight.FillColor = color
			highlight.FillTransparency = 0.8
			highlight.OutlineColor = color
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = workspace

			local primary = getHRP(model)
			local billboard

			if primary then
				billboard = Instance.new("BillboardGui")
				billboard.Adornee = primary
				billboard.Size = UDim2.new(0, 120, 0, 45)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = workspace

				local name = Instance.new("TextLabel")
				name.Size = UDim2.new(1, 0, 0.5, 0)
				name.BackgroundTransparency = 1
				name.Text = model.Name
				name.TextColor3 = Color3.new(1, 1, 1)
				name.TextStrokeTransparency = 0
				name.Font = Enum.Font.GothamBold
				name.TextScaled = true
				name.Parent = billboard

				local dist = Instance.new("TextLabel")
				dist.Size = UDim2.new(1, 0, 0.5, 0)
				dist.Position = UDim2.new(0, 0, 0.5, 0)
				dist.BackgroundTransparency = 1
				dist.Text = "0m"
				dist.TextColor3 = Color3.fromRGB(0, 255, 0)
				dist.TextStrokeTransparency = 0
				dist.Font = Enum.Font.Gotham
				dist.TextScaled = true
				dist.Parent = billboard

				highlights[model] = {highlight = highlight, billboard = billboard, dist = dist}
			else
				highlights[model] = {highlight = highlight}
			end
		end

		local function remove(model)
			local data = highlights[model]
			if not data then return end
			if data.highlight then data.highlight:Destroy() end
			if data.billboard then data.billboard:Destroy() end
			highlights[model] = nil
		end

		return {
			Toggle = function(v)
				enabled = v
				if not v then
					if connection then connection:Disconnect() end
					for m in pairs(highlights) do remove(m) end
					highlights = {}
					return
				end

				for _, model in pairs(folder:GetChildren()) do
					if model:IsA("Model") then add(model) end
				end

				folder.ChildAdded:Connect(function(m)
					if enabled and m:IsA("Model") then add(m) end
				end)

				folder.ChildRemoved:Connect(remove)

				connection = RunService.Heartbeat:Connect(function()
					local myHRP = getHRP(player.Character)
					if not myHRP then return end

					for model, data in pairs(highlights) do
						if not model.Parent then
							remove(model)
						elseif data.dist then
							local hrp = getHRP(model)
							if hrp then
								local d = (hrp.Position - myHRP.Position).Magnitude
								data.dist.Text = math.floor(d) .. "m"
								data.dist.TextColor3 = d < 50 and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
							end
						end
					end
				end)
			end
		}
	end

	--// Humans ESP
	local humansESP = createESP(
		workspace:WaitForChild("PlayerCharacters"):WaitForChild("Humans"),
		Color3.fromRGB(255, 0, 0)
	)

	ESPTab:CreateToggle({
		Name = "Player ESP (Humans)",
		Callback = humansESP.Toggle
	})

	--// Infecteds ESP
	local infectedsESP = createESP(
		workspace:WaitForChild("PlayerCharacters"):WaitForChild("Infecteds"),
		Color3.fromRGB(0, 255, 0)
	)

	ESPTab:CreateToggle({
		Name = "Infecteds ESP",
		Callback = infectedsESP.Toggle
	})

	--////////////////////////////////////////////////////////////
	--// BLOOD BOX ESP
	--////////////////////////////////////////////////////////////

	local BloodBoxESP = false
	local BloodBoxes = {}
	local BloodConn

	ESPTab:CreateToggle({
		Name = "Blood Box ESP",
		Callback = function(v)
			BloodBoxESP = v
			if not v then
				if BloodConn then BloodConn:Disconnect() end
				for _, h in pairs(BloodBoxes) do h:Destroy() end
				BloodBoxes = {}
				return
			end

			local folder = workspace:WaitForChild("Collectibles")

			local function add(obj)
				if BloodBoxes[obj] then return end
				local adornee = obj:IsA("Model")
					and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
					or obj
				if not adornee then return end

				local h = Instance.new("Highlight")
				h.Adornee = adornee
				h.FillColor = Color3.fromRGB(200, 0, 0)
				h.OutlineColor = Color3.fromRGB(255, 50, 50)
				h.FillTransparency = 0.4
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = workspace
				BloodBoxes[obj] = h
			end

			for _, obj in pairs(folder:GetChildren()) do
				if string.find(string.lower(obj.Name), "blood box") then
					add(obj)
				end
			end

			BloodConn = RunService.Heartbeat:Connect(function()
				for obj, h in pairs(BloodBoxes) do
					if not obj.Parent then
						h:Destroy()
						BloodBoxes[obj] = nil
					end
				end
			end)
		end
	})

	--////////////////////////////////////////////////////////////
	--// TWEEN TO NEAREST BLOOD BANK
	--////////////////////////////////////////////////////////////

	ESPTab:CreateButton({
		Name = "Tween to Nearest Blood Bank",
		Callback = function()
			local char = player.Character
			local hrp = getHRP(char)
			if not hrp then return end

			local folder = workspace:WaitForChild("Collectibles")
			local closest, dist = nil, math.huge

			for _, obj in pairs(folder:GetChildren()) do
				if string.find(string.lower(obj.Name), "blood bank") then
					local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
					if part then
						local d = (part.Position - hrp.Position).Magnitude
						if d < dist then
							dist = d
							closest = part
						end
					end
				end
			end

			if not closest then return end

			local t = TweenService:Create(
				hrp,
				TweenInfo.new(math.clamp(dist / 200, 0.5, 2), Enum.EasingStyle.Quart),
				{CFrame = CFrame.new(closest.Position + Vector3.new(0,5,0))}
			)

			local hum = char:FindFirstChild("Humanoid")
			if hum then hum.PlatformStand = true end
			t:Play()
			t.Completed:Connect(function()
				if hum then hum.PlatformStand = false end
			end)
		end
	})
end




-- Build a Bunker 
if game.PlaceId == 129125743283781 then
    print("🏠 Build a Bunker LOADED! Infinite stats + base TP active!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer  -- Fixed: defined plr

    local PlrTab = Window:CreateTab("Player", "gamepad-2")
    local TPTab = Window:CreateTab("Teleport", "gamepad-2")

    -- Safe spawn part finder
    local function findSpawnPart()
        local success, part = pcall(function()
            return workspace:WaitForChild("Bunker", 5):WaitForChild("StartingRoom", 5):WaitForChild("Model", 5):WaitForChild("Part", 5)
        end)
        return success and part or nil
    end

    local partspawn = findSpawnPart()
    if not partspawn then
        warn("⚠️ Spawn Part not found! Retrying on TP...")
    end

    -- Smooth TP to base
    local function tpToBase()
        if not partspawn then
            partspawn = findSpawnPart()
            if not partspawn then warn("❌ Base not found!") return end
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local targetCF = partspawn.CFrame + Vector3.new(0, 5, 0)
            local tween = TweenService:Create(hrp, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {CFrame = targetCF})
            tween:Play()
            print("🏠 Teleported to base!")
        else
            warn("❌ No character!")
        end
    end

    TPTab:CreateButton({
        Name = "Go to Base",
        Callback = tpToBase
    })

    -- Infinite Stamina (deep search player)
    local staminaEnabled = false
    local staminaConn
    local function toggleStamina()
        staminaEnabled = not staminaEnabled
        if staminaConn then staminaConn:Disconnect() staminaConn = nil end

        if staminaEnabled then
            staminaConn = RunService.Heartbeat:Connect(function()
                for _, obj in ipairs(player:GetDescendants()) do
                    if obj.Name == "Stamina" and (obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("IntConstrainedValue")) then
                        obj.Value = 100
                    end
                end
            end)
            print("✅ Infinite Stamina ON!")
        else
            print("❌ Infinite Stamina OFF!")
        end
    end

    -- Infinite Hunger (deep search player)
    local hungerEnabled = false
    local hungerConn
    local function toggleHunger()
        hungerEnabled = not hungerEnabled
        if hungerConn then hungerConn:Disconnect() hungerConn = nil end

        if hungerEnabled then
            hungerConn = RunService.Heartbeat:Connect(function()
                for _, obj in ipairs(player:GetDescendants()) do
                    if obj.Name == "Hunger" and (obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("IntConstrainedValue")) then
                        obj.Value = 100
                    end
                end
            end)
            print("✅ Infinite Hunger ON!")
        else
            print("❌ Infinite Hunger OFF!")
        end
    end

    -- UI Toggles (CurrentValue for Rayfield)
    PlrTab:CreateToggle({
        Name = "Infinite Hunger (client-synced)",
        CurrentValue = false,
        Callback = toggleHunger
    })

    PlrTab:CreateToggle({
        Name = "Infinite Stamina",
        CurrentValue = false,
        Callback = toggleStamina
    })

    PlrTab:CreateLabel("Loops search player deeply - works on respawn!")

    -- Respawn safety (re-toggle if needed, but loops persist)
    player.CharacterAdded:Connect(function()
        task.wait(1)  -- Values reload
    end)

    print("Build a Bunker features ready! Build without limits 🏠🔨")
end



-- FNAF Eternal Nights 
if game.PlaceId == 76758897829889 then
    print("🌙 FNAF Eternal Nights LOADED! ESP + safe zone ready - survive forever!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer

    local ESPTab = Window:CreateTab("ESP", "eye")
    local MTab = Window:CreateTab("Misc", "zap")
    local TPTab = Window:CreateTab("Teleport", "gamepad-2")

    local ESPData = {}
    local animFolder = workspace:WaitForChild("Game"):WaitForChild("Animatronics"):WaitForChild("Animatronics")

    -- Custom colors
    local animColors = {
        ["Freddy"] = Color3.fromRGB(139, 69, 19),
        ["Bonnie"] = Color3.fromRGB(75, 0, 130),
        ["Chica"] = Color3.fromRGB(255, 215, 0),
        ["Foxy"] = Color3.fromRGB(255, 0, 0),
        ["Golden Freddy"] = Color3.fromRGB(255, 223, 0),
    }

    local function createESP(model)
        if ESPData[model] then return end

        local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
        if not primary then return end

        local color = animColors[model.Name] or Color3.fromRGB(255, 50, 50)

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Adornee = model
        highlight.FillColor = color
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model

        -- Billboard
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = primary
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Parent = primary

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1.5, 0, 0.55, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = model.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.Parent = billboard

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1.5, 0, 0.55, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextScaled = true
        distLabel.TextXAlignment = Enum.TextXAlignment.Center
        distLabel.Parent = billboard

        -- Distance update
        local conn = RunService.Heartbeat:Connect(function()
            if not model.Parent or not _G.AnimESP_Enabled then
                highlight.Enabled = false
                billboard.Enabled = false
                return
            end

            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local dist = (primary.Position - hrp.Position).Magnitude
            distLabel.Text = math.floor(dist) .. "m"
            distLabel.TextColor3 = dist < 50 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

            local tooFar = dist > 1000
            highlight.Enabled = not tooFar
            billboard.Enabled = not tooFar
        end)

        ESPData[model] = {highlight = highlight, billboard = billboard, connection = conn}
    end

    local function destroyESP(model)
        local data = ESPData[model]
        if not data then return end
        if data.connection then data.connection:Disconnect() end
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        ESPData[model] = nil
    end

    ESPTab:CreateToggle({
        Name = "Animatronics ESP (Custom Colors)",
        CurrentValue = false,
        Callback = function(v)
            _G.AnimESP_Enabled = v

            if v then
                -- Initial scan
                for _, model in ipairs(animFolder:GetChildren()) do
                    if model:IsA("Model") then task.spawn(createESP, model) end
                end

                -- New animatronics
                animFolder.ChildAdded:Connect(function(child)
                    if child:IsA("Model") then task.spawn(createESP, child) end
                end)

                animFolder.ChildRemoved:Connect(destroyESP)
            else
                -- Disable all
                for model, data in pairs(ESPData) do
                    if data.highlight then data.highlight.Enabled = false end
                    if data.billboard then data.billboard.Enabled = false end
                end
            end
        end
    })

    -- Safe Platform
    MTab:CreateButton({
        Name = "Spawn Safe Platform",
        Callback = function()
            local platform = Instance.new("Part")
            platform.Name = "SafePlatform_EternalNights"
            platform.Size = Vector3.new(10000, 1, 10000)  -- Huge but not infinite to avoid lag
            platform.Position = Vector3.new(-105, 115, 113)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Material = Enum.Material.Neon
            platform.Color = Color3.fromRGB(0, 255, 255)
            platform.Transparency = 0.7
            platform.Parent = workspace

            print("🛡️ Safe platform spawned!")
        end
    })

    -- Safe Zone TP (smooth)
    local function getHRP()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 5)
    end

    TPTab:CreateButton({
        Name = "Safe Zone",
        Callback = function()
            local hrp = getHRP()
            if not hrp then return end

            local target = CFrame.new(
                -103.130112, 115.818985, 113.644478,
                0.998549104, 6.11236004e-08, -0.0538492166,
                -5.70468082e-08, 1, 7.72446569e-08,
                0.0538492166, -7.40606581e-08, 0.998549104
            )

            local tween = TweenService:Create(hrp, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {CFrame = target})
            tween:Play()

            print("🌙 Teleported to safe zone!")
        end
    })

    print("FNAF Eternal Nights features ready! ESP + safe zone = eternal survival 🐻")
end



-- FNAF Coop 
if game.PlaceId == 42034090823 then
    print("🐻 FNAF Coop LOADED! Animatronics ESP active - see them coming!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local ESPTab = Window:CreateTab("ESP", "eye")

    local espEnabled = false
    local highlights = {}
    local billboards = {}
    local connections = {}

    local function getHRP()
        local char = player.Character
        if char then return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart end
        return nil
    end

    local function createESP(model)
        if not model or not model:IsA("Model") then return end
        if highlights[model] then return end  -- Already has ESP

        -- Set PrimaryPart if missing
        if not model.PrimaryPart then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    model.PrimaryPart = part
                    break
                end
            end
        end
        if not model.PrimaryPart then return end

        -- Highlight
        local highlight = Instance.new("Highlight")
        highlight.Adornee = model
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.3
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
        highlights[model] = highlight

        -- Billboard (name + distance)
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = model.PrimaryPart
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Parent = model.PrimaryPart

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = model.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextScaled = true
        distLabel.Parent = billboard

        billboards[model] = {billboard = billboard, nameLabel = nameLabel, distLabel = distLabel}
    end

    local function removeESP(model)
        if highlights[model] then
            highlights[model]:Destroy()
            highlights[model] = nil
        end
        if billboards[model] then
            billboards[model].billboard:Destroy()
            billboards[model] = nil
        end
    end

    local function scanAnimatronics()
        local animFolder = workspace:FindFirstChild("Animatronics")
        if not animFolder then return end

        for _, folder in ipairs(animFolder:GetChildren()) do
            if folder:IsA("Folder") or folder:IsA("Model") then
                for _, anim in ipairs(folder:GetChildren()) do
                    if anim:IsA("Model") then
                        createESP(anim)
                    end
                end
            end
        end
    end

    ESPTab:CreateToggle({
        Name = "Animatronics ESP",
        CurrentValue = false,
        Callback = function(v)
            espEnabled = v
            if v then
                scanAnimatronics()

                -- ChildAdded for new animatronics
                local animFolder = workspace:FindFirstChild("Animatronics")
                if animFolder then
                    connections.added = animFolder.DescendantAdded:Connect(function(desc)
                        if desc.Parent and desc.Parent:IsA("Model") then
                            task.wait(0.1)  -- Wait for model to load
                            createESP(desc.Parent)
                        end
                    end)
                end

                -- Distance update loop
                connections.dist = RunService.Heartbeat:Connect(function()
                    local myHRP = getHRP()
                    if not myHRP then return end

                    for model, data in pairs(billboards) do
                        if model.Parent and model.PrimaryPart then
                            local dist = (model.PrimaryPart.Position - myHRP.Position).Magnitude
                            data.distLabel.Text = math.floor(dist) .. "m"
                            data.distLabel.TextColor3 = dist < 50 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                        else
                            removeESP(model)
                        end
                    end
                end)
            else
                -- Cleanup
                for model in pairs(highlights) do
                    removeESP(model)
                end
                for _, conn in pairs(connections) do
                    conn:Disconnect()
                end
                connections = {}
            end
        end
    })

    ESPTab:CreateLabel("Red = close, Green = far | Works on all animatronics!")

    print("FNAF Coop ESP ready! Toggle on and survive the night 🐻🌙")
end



-- Baldi Frenzy 
if game.PlaceId == 14792165933 then
    print("📚 Baldi Frenzy LOADED! Infinite speed/boost/stamina active - never get caught!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local LPTab = Window:CreateTab("Local Player", "gamepad-2")

    local SETTINGS = {
        Speed = 500,
        Boost = 100,
        Stamina = false
    }

    local speedConn, boostConn, staminaConn, humanoidConn = nil, nil, nil, nil

    local function getValues()
        return workspace:FindFirstChild("Game")
            and workspace.Game:FindFirstChild("Players")
            and workspace.Game.Players:FindFirstChild(player.Name)
            and workspace.Game.Players[player.Name]:FindFirstChild("Values")
    end

    local function getPlayerFolder()
        return workspace:FindFirstChild("Game")
            and workspace.Game:FindFirstChild("Players")
            and workspace.Game.Players:FindFirstChild(player.Name)
    end

    -- SPEED LOOP
    local function updateSpeed()
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.RenderStepped:Connect(function()
            local values = getValues()
            if values and values:FindFirstChild("Speed") then
                values.Speed.Value = SETTINGS.Speed
            end
        end)
    end

    -- BOOST LOOP
    local function updateBoost()
        if boostConn then boostConn:Disconnect() end
        boostConn = RunService.RenderStepped:Connect(function()
            local values = getValues()
            if values and values:FindFirstChild("Boostometer") then
                values.Boostometer.Value = SETTINGS.Boost
            end
        end)
    end

    -- INFINITE STAMINA (deep search everywhere)
    local function updateStamina()
        if staminaConn then staminaConn:Disconnect() end
        if not SETTINGS.Stamina then return end

        staminaConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                -- Search Values folder recursively
                local values = getValues()
                if values then
                    for _, obj in ipairs(values:GetDescendants()) do
                        if obj.Name == "Stamina" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            obj.Value = math.huge
                        end
                    end
                end

                -- Search entire player folder
                local playerFolder = getPlayerFolder()
                if playerFolder then
                    for _, obj in ipairs(playerFolder:GetDescendants()) do
                        if obj.Name == "Stamina" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            obj.Value = math.huge
                        end
                    end
                end

                -- Search character
                if player.Character then
                    for _, obj in ipairs(player.Character:GetDescendants()) do
                        if obj.Name == "Stamina" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            obj.Value = math.huge
                        end
                    end
                end
            end)
        end)
    end

    -- HUMANOID BACKUP SPEED (anti-reset)
    local function updateHumanoidSpeed()
        if humanoidConn then humanoidConn:Disconnect() end
        humanoidConn = RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character.Humanoid.WalkSpeed = SETTINGS.Speed
            end
        end)
    end

    local function startAll()
        updateSpeed()
        updateBoost()
        updateStamina()
        updateHumanoidSpeed()
    end

    -- UI
    LPTab:CreateToggle({
        Name = "Infinite Stamina",
        CurrentValue = false,
        Callback = function(v)
            SETTINGS.Stamina = v
            updateStamina()
        end
    })

    LPTab:CreateSlider({
        Name = "Speed",
        Range = {16, 2000},
        Increment = 10,
        CurrentValue = 500,
        Callback = function(v)
            SETTINGS.Speed = v
            updateSpeed()
            updateHumanoidSpeed()
        end
    })

    LPTab:CreateSlider({
        Name = "Boostometer",
        Range = {0, 200},
        Increment = 1,
        CurrentValue = 100,
        Callback = function(v)
            SETTINGS.Boost = v
            updateBoost()
        end
    })

    -- Auto-restart on respawn
    startAll()
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        startAll()
    end)

    print("Baldi Frenzy hacks fully loaded! Run forever 📚💨")
end


-- Break In 2 
if game.PlaceId == 13864667823 then
    IsLoaded = true
    print("🏠 Break In 2 LOADED! Speed, TPs & items ready - survive the chaos!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer

    local LPTab = Window:CreateTab("Local Player", "gamepad-2")
    local TPTab = Window:CreateTab("Teleport", "gamepad-2")
    local ItemsTab = Window:CreateTab("Items", "gamepad-2")

    -- Respawn-safe HRP
    local function getHRP()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 5)
    end

    -- Smooth TP
    local function smoothTP(targetCF)
        local hrp = getHRP()
        if not hrp then return end
        local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
        tween:Play()
    end

    --============ LOCAL PLAYER (Speed + Jump) ============
    local speedEnabled = false
    local customSpeed = 16
    local jumpEnabled = false
    local customJump = 50

    local function applyMods()
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if speedEnabled then hum.WalkSpeed = customSpeed end
        if jumpEnabled then hum.JumpPower = customJump end
    end

    RunService.Heartbeat:Connect(applyMods)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        applyMods()
    end)

    LPTab:CreateSlider({Name = "WalkSpeed", Range = {16, 1000}, Increment = 10, CurrentValue = 16,
        Callback = function(v) customSpeed = v end})
    LPTab:CreateToggle({Name = "Enable Speed", CurrentValue = false,
        Callback = function(v) speedEnabled = v end})

    LPTab:CreateSlider({Name = "Jump Power", Range = {50, 1000}, Increment = 10, CurrentValue = 50,
        Callback = function(v) customJump = v end})
    LPTab:CreateToggle({Name = "Enable Jump", CurrentValue = false,
        Callback = function(v) jumpEnabled = v end})

    --============ TELEPORTS ============
    TPTab:CreateButton({Name = "Home", Callback = function() smoothTP(CFrame.new(-214.5, 33, -789.7)) end})
    TPTab:CreateButton({Name = "Kitchen", Callback = function() smoothTP(CFrame.new(-244, 29, -738)) end})
    TPTab:CreateButton({Name = "Shop", Callback = function() smoothTP(CFrame.new(-250, 29, -838)) end})
    TPTab:CreateButton({Name = "Gym", Callback = function() smoothTP(CFrame.new(-256, 62, -843)) end})
    TPTab:CreateButton({Name = "Secret Room", Callback = function() smoothTP(CFrame.new(-282, 29, -853)) end})
    TPTab:CreateButton({Name = "Fight Arena", Callback = function() smoothTP(CFrame.new(-259.25, 59.6, -724.55)) end})
    TPTab:CreateButton({Name = "Boss Arena", Callback = function()
        smoothTP(CFrame.new(-1562.28857, -369.261871, -989.433105, -1.1920929e-07, 0, -1.00000012, 0, 1, 0, 1.00000012, 0, -1.1920929e-07))
    end})

    --============ ITEMS ============
    local RemoteEvents = ReplicatedStorage:WaitForChild("Events")
    local GiveTool = RemoteEvents:WaitForChild("GiveTool")

    ItemsTab:CreateSection("Rainbow Pizza")
    ItemsTab:CreateButton({Name = "Get Rainbow Pizza", Callback = function() GiveTool:FireServer("RainbowPizza") end})
    ItemsTab:CreateButton({Name = "Get 10 Rainbow Pizza", Callback = function()
        for i = 1, 10 do GiveTool:FireServer("RainbowPizza") task.wait(0.1) end
    end})

    ItemsTab:CreateSection("Golden Apple")
    ItemsTab:CreateButton({Name = "Get Golden Apple", Callback = function() GiveTool:FireServer("GoldenApple") end})
    ItemsTab:CreateButton({Name = "Get 5 Golden Apples", Callback = function()
        for i = 1, 5 do GiveTool:FireServer("GoldenApple") task.wait(0.1) end
    end})
    ItemsTab:CreateButton({Name = "Get 10 Golden Apples", Callback = function()
        for i = 1, 10 do GiveTool:FireServer("GoldenApple") task.wait(0.1) end
    end})

    ItemsTab:CreateSection("Rainbow Pizza Box")
    ItemsTab:CreateButton({Name = "Get Rainbow Pizza Box (client-sided?)", Callback = function() GiveTool:FireServer("RainbowPizzaBox") end})

    ItemsTab:CreateSection("Cookies")
    ItemsTab:CreateButton({Name = "Get Cookie", Callback = function() GiveTool:FireServer("Cookie") end})
    ItemsTab:CreateButton({Name = "Get 10 Cookies", Callback = function()
        for i = 1, 10 do GiveTool:FireServer("Cookie") task.wait(0.1) end
    end})
    ItemsTab:CreateButton({Name = "Get 100 Cookies", Callback = function()
        for i = 1, 100 do GiveTool:FireServer("Cookie") task.wait(0.05) end
    end})
    ItemsTab:CreateButton({Name = "Get 1000 Cookies (LAG WARNING)", Callback = function()
        for i = 1, 1000 do GiveTool:FireServer("Cookie") task.wait(0.05) end
    end})

    ItemsTab:CreateSection("Apples")
    ItemsTab:CreateButton({Name = "Get Apple", Callback = function() GiveTool:FireServer("Apple") end})
    ItemsTab:CreateButton({Name = "Get 10 Apples", Callback = function()
        for i = 1, 10 do GiveTool:FireServer("Apple") task.wait(0.1) end
    end})
    ItemsTab:CreateButton({Name = "Get 100 Apples", Callback = function()
        for i = 1, 100 do GiveTool:FireServer("Apple") task.wait(0.05) end
    end})
    ItemsTab:CreateButton({Name = "Get 1000 Apples (LAG WARNING)", Callback = function()
        for i = 1, 1000 do GiveTool:FireServer("Apple") task.wait(0.05) end
    end})

    ItemsTab:CreateSection("Misc")
    ItemsTab:CreateButton({Name = "Get OP Armor", Callback = function() GiveTool:FireServer("GiveArmor") end})
    ItemsTab:CreateButton({Name = "Get Gold Key", Callback = function() GiveTool:FireServer("KeyGold") end})

    ItemsTab:CreateSection("Weapons")
    ItemsTab:CreateButton({Name = "Get Best Weapons", Callback = function()
        local tools = {"Broom", "Bat", "PitchFork", "Hammer", "Wrench"}
        for _, tool in ipairs(tools) do
            GiveTool:FireServer(tool)
            task.wait(0.2)
        end
    end})

    print("Break In 2 features fully loaded! Speed up, TP around & spam items 🍕⚔️")
end


-- Evade 
if game.PlaceId == 9872472334 then
    print("🏃 Evade LOADED! God speed & jump active - outrun Nextbot!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local LPTab = Window:CreateTab("Character", "user")

    local genv = (getgenv and getgenv()) or _G
    local GLOBAL_KEY = "__EVADE_MOVEMENT_MANAGER_v1"

    -- Unload old version
    if genv[GLOBAL_KEY] and type(genv[GLOBAL_KEY].Unload) == "function" then
        genv[GLOBAL_KEY].Unload()
    end

    local Manager = {}
    genv[GLOBAL_KEY] = Manager

    -- State
    Manager.humanoid = nil
    Manager.hrp = nil
    Manager.humPropConn = nil
    Manager.charConn = nil
    Manager.speedEnabled = false
    Manager.customSpeed = 32
    Manager.defaultSpeed = 16
    Manager.speedConn = nil
    Manager.jumpEnabled = false
    Manager.customJump = 120
    Manager.defaultJump = 50
    Manager.jumpConn = nil
    Manager.fallbackEnabled = true
    Manager.fallbackConn = nil
    Manager.fallbackActive = false

    -- Helper
    local function almostEqual(a, b, eps) eps = eps or 1e-3 return math.abs((a or 0) - (b or 0)) <= eps end

    -- Attach humanoid
    local function attachHumanoid(character)
        local ok, hum = pcall(function() return character:WaitForChild("Humanoid", 5) end)
        if not ok or not hum then return end

        -- Cleanup old
        if Manager.humPropConn then pcall(Manager.humPropConn.Disconnect, Manager.humPropConn) Manager.humPropConn = nil end
        if Manager.fallbackConn then pcall(Manager.fallbackConn.Disconnect, Manager.fallbackConn) Manager.fallbackConn = nil Manager.fallbackActive = false end

        Manager.humanoid = hum
        Manager.hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")

        -- Defaults
        Manager.defaultSpeed = hum.WalkSpeed or 16
        Manager.defaultJump = hum.UseJumpPower and (hum.JumpPower or 50) or ((hum.JumpHeight or 7.2) * 7)

        -- Watch UseJumpPower changes
        Manager.humPropConn = hum:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
            if Manager.jumpEnabled and Manager.humanoid then
                if hum.UseJumpPower then
                    pcall(function() hum.JumpPower = Manager.customJump end)
                else
                    pcall(function() hum.JumpHeight = Manager.customJump / 7 end)
                end
            end
            -- Re-enable fallback if needed
            if Manager.fallbackActive and Manager.fallbackEnabled then
                Manager.EnableFallback()
            end
        end)

        -- Apply current overrides
        if Manager.speedEnabled then pcall(function() hum.WalkSpeed = Manager.customSpeed end) end
        if Manager.jumpEnabled then
            if hum.UseJumpPower then pcall(function() hum.JumpPower = Manager.customJump end)
            else pcall(function() hum.JumpHeight = Manager.customJump / 7 end) end
        end
    end

    -- Character handler
    Manager.charConn = player.CharacterAdded:Connect(attachHumanoid)
    if player.Character then attachHumanoid(player.Character) end

    -- Speed loop
    local function createSpeedConn()
        if Manager.speedConn then return end
        Manager.speedConn = RunService.RenderStepped:Connect(function()
            if Manager.humanoid and Manager.speedEnabled and Manager.humanoid.WalkSpeed ~= Manager.customSpeed then
                pcall(function() Manager.humanoid.WalkSpeed = Manager.customSpeed end)
            end
        end)
    end

    local function destroySpeedConn()
        if Manager.speedConn then pcall(Manager.speedConn.Disconnect, Manager.speedConn) Manager.speedConn = nil end
    end

    -- Jump loop
    local function createJumpConn()
        if Manager.jumpConn then return end
        Manager.jumpConn = RunService.RenderStepped:Connect(function()
            if not Manager.humanoid or not Manager.jumpEnabled then return end
            if Manager.humanoid.UseJumpPower then
                if Manager.humanoid.JumpPower ~= Manager.customJump then
                    pcall(function() Manager.humanoid.JumpPower = Manager.customJump end)
                end
            else
                local target = Manager.customJump / 7
                if not almostEqual(Manager.humanoid.JumpHeight, target) then
                    pcall(function() Manager.humanoid.JumpHeight = target end)
                end
            end
        end)
    end

    local function destroyJumpConn()
        if Manager.jumpConn then pcall(Manager.jumpConn.Disconnect, Manager.jumpConn) Manager.jumpConn = nil end
    end

    -- Fallback jump (velocity boost if property blocked)
    function Manager.EnableFallback()
        if Manager.fallbackConn or not Manager.humanoid or not Manager.hrp then return end
        Manager.fallbackActive = true
        Manager.fallbackConn = Manager.humanoid.Jumping:Connect(function(active)
            if active and Manager.fallbackActive then
                local g = workspace.Gravity or 196.2
                local vel = math.sqrt(2 * g * (Manager.customJump / 7))
                pcall(function()
                    local cur = Manager.hrp.AssemblyLinearVelocity
                    Manager.hrp.AssemblyLinearVelocity = Vector3.new(cur.X, vel, cur.Z)
                end)
            end
        end)
    end

    function Manager.DisableFallback()
        if Manager.fallbackConn then pcall(Manager.fallbackConn.Disconnect, Manager.fallbackConn) Manager.fallbackConn = nil end
        Manager.fallbackActive = false
    end

    -- API
    function Manager.EnableSpeed()
        if Manager.speedEnabled then return end
        Manager.speedEnabled = true
        if Manager.humanoid then pcall(function() Manager.humanoid.WalkSpeed = Manager.customSpeed end) end
        createSpeedConn()
    end

    function Manager.DisableSpeed()
        if not Manager.speedEnabled then return end
        Manager.speedEnabled = false
        if Manager.humanoid then pcall(function() Manager.humanoid.WalkSpeed = Manager.defaultSpeed end) end
        destroySpeedConn()
    end

    function Manager.SetSpeed(v)
        Manager.customSpeed = v
        if Manager.speedEnabled and Manager.humanoid then pcall(function() Manager.humanoid.WalkSpeed = v end) end
    end

    function Manager.EnableJump()
        if Manager.jumpEnabled then return end
        Manager.jumpEnabled = true
        if Manager.humanoid then
            if Manager.humanoid.UseJumpPower then pcall(function() Manager.humanoid.JumpPower = Manager.customJump end)
            else pcall(function() Manager.humanoid.JumpHeight = Manager.customJump / 7 end) end
        end
        createJumpConn()
        if Manager.fallbackEnabled then
            task.delay(0.08, function()
                if Manager.humanoid and Manager.jumpEnabled and Manager.fallbackEnabled then
                    local applied = Manager.humanoid.UseJumpPower and (Manager.humanoid.JumpPower == Manager.customJump) or almostEqual(Manager.humanoid.JumpHeight, Manager.customJump/7)
                    if not applied then Manager.EnableFallback() end
                end
            end)
        end
    end

    function Manager.DisableJump()
        if not Manager.jumpEnabled then return end
        Manager.jumpEnabled = false
        if Manager.humanoid then
            if Manager.humanoid.UseJumpPower and Manager.humanoid.JumpPower == Manager.customJump then
                pcall(function() Manager.humanoid.JumpPower = Manager.defaultJump end)
            elseif not Manager.humanoid.UseJumpPower then
                local tgt = Manager.customJump / 7
                if almostEqual(Manager.humanoid.JumpHeight, tgt) then
                    pcall(function() Manager.humanoid.JumpHeight = Manager.defaultJump / 7 end)
                end
            end
        end
        destroyJumpConn()
        Manager.DisableFallback()
    end

    function Manager.SetJump(v)
        Manager.customJump = v
        if Manager.jumpEnabled and Manager.humanoid then
            if Manager.humanoid.UseJumpPower then pcall(function() Manager.humanoid.JumpPower = v end)
            else pcall(function() Manager.humanoid.JumpHeight = v / 7 end) end
        end
    end

    function Manager.Unload()
        if Manager.charConn then pcall(Manager.charConn.Disconnect, Manager.charConn) end
        if Manager.humPropConn then pcall(Manager.humPropConn.Disconnect, Manager.humPropConn) end
        destroySpeedConn()
        destroyJumpConn()
        Manager.DisableFallback()
        if Manager.humanoid then
            pcall(function()
                Manager.humanoid.WalkSpeed = Manager.defaultSpeed
                if Manager.humanoid.UseJumpPower then Manager.humanoid.JumpPower = Manager.defaultJump
                else Manager.humanoid.JumpHeight = Manager.defaultJump / 7 end
            end)
        end
        Manager.humanoid = nil
        Manager.hrp = nil
        genv[GLOBAL_KEY] = nil
        print("[Evade Manager] Unloaded.")
    end

    -- UI
    LPTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {10, 1000},
        Increment = 10,
        CurrentValue = 32,
        Callback = function(v) Manager.SetSpeed(v) end
    })

    LPTab:CreateToggle({
        Name = "Enable Speed",
        CurrentValue = false,
        Callback = function(s) if s then Manager.EnableSpeed() else Manager.DisableSpeed() end end
    })

    LPTab:CreateSlider({
        Name = "Jump Power",
        Range = {50, 1000},
        Increment = 10,
        CurrentValue = 120,
        Callback = function(v) Manager.SetJump(v) end
    })

    LPTab:CreateToggle({
        Name = "Enable Jump",
        CurrentValue = false,
        Callback = function(s) if s then Manager.EnableJump() else Manager.DisableJump() end end
    })

    LPTab:CreateToggle({
        Name = "Fallback Jump (if blocked)",
        CurrentValue = true,
        Callback = function(s) Manager.fallbackEnabled = s end
    })

    LPTab:CreateButton({
        Name = "Reset Movement",
        Callback = function()
            Manager.DisableSpeed()
            Manager.DisableJump()
        end
    })

    print("Evade movement manager ready! Outrun everything 🏃💨")
end


-- Bordr Gam 
if game.PlaceId == 3411100258 then
    print("🏰 Bordr Gam LOADED! Teleports active - rule the borders!")

    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local plr = Players.LocalPlayer

    local TPTab = Window:CreateTab("Teleport", "user")

    -- Respawn-safe HRP getter
    local function getHRP()
        local char = plr.Character or plr.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 5)
    end

    -- Smooth teleport
    local function smoothTP(targetCFrame)
        local hrp = getHRP()
        if not hrp then warn("No HRP!") return end

        local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end

    TPTab:CreateButton({
        Name = "Castle Outside",
        Callback = function()
            smoothTP(CFrame.new(0.471342564, 11.0001364, 524.591309, -0.999975741, -3.45285791e-08, -0.0069689774, -3.47548479e-08, 1, 3.23468292e-08, 0.0069689774, 3.25882468e-08, -0.999975741))
        end
    })

    TPTab:CreateLabel("Respawn-safe TPs! Works after death.")

    print("Bordr Gam teleports ready! Conquer the castle! 🏰")
end



-- Bridge Duels 
if game.PlaceId == 139566161526375 then
   
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

 	local MTab = Window:CreateTab("Main", "crosshair")
    local CTab = Window:CreateTab("Combat", "crosshair")
	local VTab = Window:CreateTab("Visual", "crosshair")

    -- Get BridgeDuel env (critical for advanced features)
    -- local BridgeDuel = getrenv()._G.BridgeDuel
    -- if not BridgeDuel then warn("BridgeDuel env not found - some features disabled!") end

    -- local Library = getrenv()._G.Library or { DeviceType = "PC" }

	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")

	local p = Players.LocalPlayer

	local bhopConnection
	local bridgeConnection

	_G.SakinSettings = _G.SakinSettings or {}
	_G.SakinSettings.PushPower = 2

	-- === 🏃 BHOP TOGGLE ===
	MTab:CreateToggle({
		Name = "Bhop (can get anti cheated back)",
		CurrentValue = false,
		Callback = function(state)
			if state then
				bhopConnection = RunService.Heartbeat:Connect(function()
					local char = p.Character
					if not char then return end

					local hum = char:FindFirstChildOfClass("Humanoid")
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if not hum or not hrp then return end

					if UIS:IsKeyDown(Enum.KeyCode.Space) then
						if hum.FloorMaterial ~= Enum.Material.Air then 
							hum.Jump = true 
						end

						if hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial == Enum.Material.Air then
							hrp.CFrame = hrp.CFrame:Lerp(
								hrp.CFrame + (hum.MoveDirection * _G.SakinSettings.PushPower),
								0.5
							)
						end
					end
				end)
			else
				if bhopConnection then
					bhopConnection:Disconnect()
					bhopConnection = nil
				end
			end
		end
	})

	-- === 🧱 BRIDGE TOGGLE ===
	MTab:CreateToggle({
		Name = "Fast Bridge",
		CurrentValue = false,
		Callback = function(state)
			if state then
				local cooldown = 0

				bridgeConnection = RunService.Heartbeat:Connect(function(dt)
					local char = p.Character
					if not char then return end

					cooldown += dt
					if cooldown < 0.1 then return end
					cooldown = 0

					local tool = char:FindFirstChildOfClass("Tool")
					if tool then
						local name = tool.Name:lower()
						if name:find("block") or name:find("wool") or name:find("clay") then
							tool:Activate()
						end
					end
				end)
			else
				if bridgeConnection then
					bridgeConnection:Disconnect()
					bridgeConnection = nil
				end
			end
		end
	})

	_G.SakinSettings = _G.SakinSettings or {}
	_G.SakinSettings.AutoEat = false

	local autoEatLoop

	MTab:CreateToggle({
		Name = "Auto Gap / Auto Heal",
		CurrentValue = false,
		Callback = function(state)
			_G.SakinSettings.AutoEat = state

			if state then
				autoEatLoop = task.spawn(function()
					while _G.SakinSettings.AutoEat do
						task.wait(0.4)

						if plr.Character then
							local hum = p.Character:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health < hum.MaxHealth then
								
								local apple =
									plr.Backpack:FindFirstChild("Apple") or
									plr.Character:FindFirstChild("Apple") or
									plr.Backpack:FindFirstChild("Golden Apple") or
									plr.Backpack:FindFirstChild("Gapple")

								if apple then
									apple.Parent = plr.Character
									apple:Activate()
									task.wait(0.1)
									apple:Deactivate()
								end
							end
						end
					end
				end)
			else
				_G.SakinSettings.AutoEat = false
			end
		end
	})
	

	CTab:CreateToggle({
		Name = "Blatant killaura",
		CurrentValue = false,
		Callback = function(v)
			if v then
				-- === TURN ON ===
				local radius = 15
				local weaponName = "WoodenSword"   -- you can change this if you want
				local RunService = game:GetService("RunService")
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local localPlayer = Players.LocalPlayer

				local toolService = ReplicatedStorage:WaitForChild("Modules", 9e9)
					:WaitForChild("Knit", 9e9)
					:WaitForChild("Services", 9e9)
					:WaitForChild("ToolService", 9e9)

				local attackFunction = toolService:WaitForChild("RF", 9e9):WaitForChild("AttackPlayerWithSword", 9e9)

				-- Store the connection so we can stop it later
				getgenv().KillauraConnection = RunService.RenderStepped:Connect(function()
					local character = localPlayer.Character
					if not character then return end
					local myHRP = character:FindFirstChild("HumanoidRootPart")
					if not myHRP then return end

					for _, player in pairs(Players:GetPlayers()) do
						if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local targetChar = player.Character
							local targetHRP = targetChar.HumanoidRootPart
							if (myHRP.Position - targetHRP.Position).Magnitude <= radius then
								local args = {
									[1] = workspace:FindFirstChild(targetChar.Name),
									[2] = false,
									[3] = weaponName,
									[4] = "â€‹"
								}
								attackFunction:InvokeServer(unpack(args))
							end
						end
					end
				end)

			else
				-- === TURN OFF ===
				if getgenv().KillauraConnection then
					getgenv().KillauraConnection:Disconnect()
					getgenv().KillauraConnection = nil
				end
			end
		end
	})

	CTab:CreateToggle({
		Name = "Auto Block",
		CurrentValue = false,
		Callback = function(v)
			if v then
				-- === TURN ON ===
				local radius = 20  -- Change this if you want a different range
				local RunService = game:GetService("RunService")
				local Players = game:GetService("Players")
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local localPlayer = Players.LocalPlayer

				local toolService = ReplicatedStorage:WaitForChild("Modules", 9e9)
					:WaitForChild("Knit", 9e9)
					:WaitForChild("Services", 9e9)
					:WaitForChild("ToolService", 9e9)

				local blockRemote = toolService:WaitForChild("RF", 9e9):WaitForChild("ToggleBlockSword", 9e9)

				getgenv().AutoBlockConnection = RunService.RenderStepped:Connect(function()
					local character = localPlayer.Character
					if not character then return end
					local myHRP = character:FindFirstChild("HumanoidRootPart")
					if not myHRP then return end

					-- Optional: Only block if holding a sword
					local sword = character:FindFirstChildOfClass("Tool")
					if not sword or not sword.Name:find("Sword") then return end

					for _, player in pairs(Players:GetPlayers()) do
						if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local targetChar = player.Character
							local targetHRP = targetChar.HumanoidRootPart
							local targetHum = targetChar:FindFirstChild("Humanoid")

							if targetHum and targetHum.Health > 0 then
								if (myHRP.Position - targetHRP.Position).Magnitude <= radius then
									local args = {
										[1] = true,           -- Block ON
										[2] = sword.Name      -- Use actual sword name
									}
									pcall(function()
										blockRemote:InvokeServer(unpack(args))
									end)
								end
							end
						end
					end
				end)

			else
				-- === TURN OFF ===
				if getgenv().AutoBlockConnection then
					getgenv().AutoBlockConnection:Disconnect()
					getgenv().AutoBlockConnection = nil
				end
			end
		end
	})

	local closetkill = false
	local closetkillsettings = {
		AuraRange = 18,
	}

    CTab:CreateToggle({
        Name = "Closet killaura",
        CurrentValue = false,
        Callback = function(v)
			closetkill = v
            if v then
				task.spawn(function()
					while task.wait(0.1) do
						if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
						
						local myTool = plr.Character:FindFirstChildOfClass("Tool")
						
						for _, enemy in pairs(Players:GetPlayers()) do
							if enemy ~= plr and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
								local eHrp = enemy.Character.HumanoidRootPart
								local dist = (eHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
								
								if dist <= closetkillsettings.AuraRange then
									-- Hit
									
									-- if _G.SakinSettings.Hitboxes then
									-- 	eHrp.Size = Vector3.new(_G.SakinSettings.HitboxSize, _G.SakinSettings.HitboxSize, _G.SakinSettings.HitboxSize)
									-- 	eHrp.Transparency = 0.8
									-- 	eHrp.CanCollide = false
									-- end
									-- Aura
									if closetkill and myTool and (myTool.Name:lower():find("sword") or myTool.Name:lower():find("blade")) then
										myTool:Activate()
									end
								else
									-- Сброс хитбокса
									if eHrp.Size.X > 2 then
										eHrp.Size = Vector3.new(2, 2, 1)
										eHrp.Transparency = 1
									end
								end
							end
						end
					end
				end)
			end
        end
    })


	local shooting = false
local mode = "Off"

-- 🔍 Wall check
local function isVisible(targetHRP)
    local char = plr.Character
    if not char then return false end
    local origin = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not origin then return false end

    local direction = (targetHRP.Position - origin.Position)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local result = workspace:Raycast(origin.Position, direction, rayParams)
    if result and not result.Instance:IsDescendantOf(targetHRP.Parent) then
        return false
    end

    return true
end

-- 🎯 Prediction
local function getPredictedPosition(targetHRP)
    local char = plr.Character
    if not char then return targetHRP.Position end
    local origin = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not origin then return targetHRP.Position end

    local distance = (targetHRP.Position - origin.Position).Magnitude
    local projectileSpeed = 120 -- tweak this
    local travelTime = distance / projectileSpeed
    return targetHRP.Position + (targetHRP.Velocity * travelTime)
end

-- 🔄 Single Loop
task.spawn(function()
    while true do
        if shooting and mode ~= "Off" then
            local char = plr.Character
            if char then
                local bow = char:FindFirstChild("DefaultBow")
                if bow then
                    local targetHRP = getClosestPlayer()
                    if targetHRP and isVisible(targetHRP) then
                        local targetPos
                        if mode == "Prediction" then
                            targetPos = getPredictedPosition(targetHRP)
                        else
                            targetPos = targetHRP.Position
                        end

                        local args = { targetPos, 0.6116725271567702 }
                        bow:WaitForChild("__comm__")
                           :WaitForChild("RF")
                           :WaitForChild("Fire")
                           :InvokeServer(unpack(args))
                    end
                end
            end
        end
        task.wait(0.5) -- fire rate
    end
end)

-- 🎛 Dropdown
CTab:CreateDropdown({
    Name = "Auto Bow Mode",
    Options = { "Off", "Normal", "Prediction" },
    CurrentOption = "Off",
    Callback = function(option)
        mode = option
        shooting = (option ~= "Off")
    end
})

	
	
	local Players = game:GetService("Players")

	local espObjects = {}
	local espLoopRunning = false

	VTab:CreateToggle({
		Name = "Player Esp",
		CurrentValue = false,
		Callback = function(state)

			espLoopRunning = state

			-- Clear existing ESP when toggled off
			if not state then
				for _, esp in pairs(espObjects) do
					if esp then
						esp:Destroy()
					end
				end
				espObjects = {}
				return
			end

			-- Loop updates every second
			task.spawn(function()
				while espLoopRunning do

					-- Clear old ESP
					for _, esp in pairs(espObjects) do
						if esp then
							esp:Destroy()
						end
					end
					espObjects = {}

					-- Re-add ESP
					for _, player in pairs(Players:GetPlayers()) do
						if player ~= Players.LocalPlayer then
							local char = player.Character
							if char and not char:FindFirstChild("esp") then
								local highlight = Instance.new("Highlight")
								highlight.Name = "esp"
								highlight.Parent = char
								highlight.FillColor = Color3.fromRGB(255, 0, 0)
								highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
								highlight.OutlineTransparency = 0.8

								table.insert(espObjects, highlight)
							end
						end
					end

					task.wait(.5) -- update every second
				end
			end)
		end
	})


end



-- Lifting Simulator 
if game.PlaceId == 3652625463 then
    print("🏋️ Lifting Simulator LOADED! Speed hacks active.")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local LPTab = Window:CreateTab("Local Player", "user")

    -- Speed variables (respawn-safe)
    local customSpeed = 16
    local speedEnabled = false
    local humanoid = nil
    local speedConn = nil

    -- Get humanoid safely
    local function getHumanoid()
        local char = player.Character
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
        end
    end

    -- Apply speed
    local function applySpeed()
        if humanoid and speedEnabled then
            humanoid.WalkSpeed = customSpeed
        elseif humanoid then
            humanoid.WalkSpeed = 16  -- Reset default
        end
    end

    -- Speed loop
    local function startSpeedLoop()
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(applySpeed)
    end

    -- Handle respawn
    player.CharacterAdded:Connect(function()
        task.wait(0.5)  -- Wait for humanoid
        getHumanoid()
        applySpeed()
        if speedEnabled then startSpeedLoop() end
    end)

    -- Initial setup
    getHumanoid()
    startSpeedLoop()

    -- UI Slider
    LPTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 1000},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(v)
            customSpeed = v
            applySpeed()
        end
    })

    -- UI Toggle
    LPTab:CreateToggle({
        Name = "Custom Speed",
        CurrentValue = false,
        Callback = function(state)
            speedEnabled = state
            if state then
                startSpeedLoop()
            else
                if speedConn then
                    speedConn:Disconnect()
                    speedConn = nil
                end
                applySpeed()  -- Reset
            end
        end
    })

    LPTab:CreateLabel("Speed works on respawn! Lift faster 🚀")

    print("Lifting Simulator speed fully loaded!")
end


--Bedwars
if game.PlaceId == 6872274481 then
    local STab = Window:CreateTab("Scripts", 4483362458)
	STab:CreateButton({Name = "VoidWare Rewrite", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))() end})
	STab:CreateButton({Name = "VoidWare Old", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/NewMainScript.lua", true))() end})
	STab:CreateButton({Name = "VoidWare Packet", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWPacket/main/NewMainScript.lua", true))() end})
	
end



-- Infamy 
if game.PlaceId == 6182305461 then
    print("🕵️ Infamy LOADED! Chaos mode activated. Cause havoc!")

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local player = Players.LocalPlayer

    local TpTab = Window:CreateTab("TP", "gamepad-2")
    local CTab = Window:CreateTab("Combat", "gamepad-2")

    -- Respawn-safe HRP getter
    local function getHRP()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 5)
    end

    -- Smooth Teleport function
    local function smoothTP(targetCF)
        local hrp = getHRP()
        if not hrp then warn("No HRP found!") return end

        local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
        tween:Play()
    end

    -- TP Buttons
    TpTab:CreateButton({Name = "Starter Area", Callback = function()
        smoothTP(CFrame.new(-1070.89209, 208.956314, 207.611008, 0.999327183, 3.50095219e-09, 0.0366769396, -3.3585672e-09, 1, -3.94375288e-09, -0.0366769396, 3.81791754e-09, 0.999327183))
    end})

    TpTab:CreateButton({Name = "Criminal AI Store", Callback = function()
        smoothTP(CFrame.new(189.297363, 6.25, 173.019821, 0.101432741, 3.83402359e-08, 0.99484241, 2.30658959e-09, 1, -3.87741821e-08, -0.99484241, 6.22766461e-09, 0.101432741))
    end})

    TpTab:CreateButton({Name = "Melee Weapon Store", Callback = function()
        smoothTP(CFrame.new(-39.3742294, 3.25000072, -92.277092, 0.99938947, -8.86175826e-08, -0.0349383503, 8.9264951e-08, 1, 1.69690342e-08, 0.0349383503, -2.00774455e-08, 0.99938947))
    end})

    -- Gun Mods (Inf Ammo + Attempt God Stats)
    local GunModConnection = nil
    CTab:CreateToggle({
        Name = "Mod Guns (Inf Ammo + God Stats)",
        CurrentValue = false,
        Callback = function(v)
            if v then
                print("🔫 Gun Mods ON - Infinite ammo & max stats!")
                if GunModConnection then GunModConnection:Disconnect() end
                GunModConnection = RunService.Heartbeat:Connect(function()
                    local character = player.Character
                    local backpack = player:FindFirstChild("Backpack")
                    if not backpack then return end

                    local containers = {backpack}
                    if character then table.insert(containers, character) end

                    for _, container in pairs(containers) do
                        for _, tool in pairs(container:GetDescendants()) do
                            if tool:IsA("Tool") then
                                -- Infinite Ammo (search deeper if needed)
                                for _, obj in pairs(tool:GetDescendants()) do
                                    if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("DoubleConstrainedValue") then
                                        if string.find(string.lower(obj.Name), "ammo") or string.find(string.lower(obj.Name), "magazine") or string.find(string.lower(obj.Name), "clip") then
                                            obj.Value = 99999
                                        end
                                    end
                                end

                                -- God Stats (damage, fire rate, etc. - broad search)
                                for _, obj in pairs(tool:GetDescendants()) do
                                    if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                                        local nameLower = string.lower(obj.Name)
                                        if string.find(nameLower, "damage") or string.find(nameLower, "firerate") or string.find(nameLower, "speed") or string.find(nameLower, "range") or string.find(nameLower, "bullet") then
                                            obj.Value = obj.Value * 10 or 99999  -- Boost massively
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                print("🔫 Gun Mods OFF")
                if GunModConnection then
                    GunModConnection:Disconnect()
                    GunModConnection = nil
                end
            end
        end
    })

    CTab:CreateLabel("Works on most guns - inf ammo reliable, god stats may vary by update.")

    print("Infamy features ready! Go raise that wanted level! 🕵️🔥")
end

--shoot the boss
if game.PlaceId == 115196082055466 then


    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer

    -- Wait for leaderstats safely
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = player:WaitForChild("leaderstats", 10)
    end
    if not leaderstats then warn("No leaderstats found!") return end

    local Money = leaderstats:FindFirstChild("Money")
    local Strength = leaderstats:FindFirstChild("Strength")

    -- Remote (with safe wait)
    local WinGain = ReplicatedStorage:FindFirstChild("Event") and ReplicatedStorage.Event:FindFirstChild("WinGain")
    if not WinGain then
        WinGain = ReplicatedStorage:WaitForChild("Event", 10):WaitForChild("WinGain", 10)
    end
    if not WinGain then warn("WinGain remote not found!") return end

    -- Tabs (empty for now - add more if you expand)
    local MoneyTab = Window:CreateTab("Money", "dollar-sign")
    local StrengthTab = Window:CreateTab("Strength", "zap")
    local UpgradeTab = Window:CreateTab("Upgrade", "arrow-up")
    local GunTab = Window:CreateTab("Buy Gun", "crosshair")
    local EggTab = Window:CreateTab("Egg", "egg")

    -- Amount selector
    local selectedAmount = 1000
    local amountMap = {
        ["1"] = 1, ["10"] = 10, ["100"] = 100,
        ["1k"] = 1e3, ["10k"] = 1e4, ["100k"] = 1e5,
        ["1m"] = 1e6, ["10m"] = 1e7, ["100m"] = 1e8,
        ["1b"] = 1e9, ["10b"] = 1e10, ["100b"] = 1e11,
        ["1t"] = 1e12, ["10t"] = 1e13, ["100t"] = 1e14,
        ["1Qa"] = 1e15, ["10Qa"] = 1e16, ["100Qa"] = 1e17,
        ["1Qi"] = 1e18, ["10Qi"] = 1e19, ["100Qi"] = 1e20,
        ["1Sx"] = 1e21, ["10Sx"] = 1e22, ["100Sx"] = 1e23,
        ["1Sp"] = 1e24, ["10Sp"] = 1e25, ["100Sp"] = 1e26,
        ["1Oc"] = 1e27, ["10Oc"] = 1e28, ["100Oc"] = 1e29,
        ["1Nm"] = 1e30, ["10Nm"] = 1e31, ["100Nm"] = 1e32,
        ["1Dc"] = 1e33, ["10Dc"] = 1e34, ["100Dc"] = 1e35
    }

    local options = {}
    for k in pairs(amountMap) do table.insert(options, k) end
    table.sort(options, function(a,b) return amountMap[a] < amountMap[b] end)

    MoneyTab:CreateDropdown({
        Name = "Select Amount",
        Options = options,
        CurrentOption = {"1k"},
        Callback = function(option)
            selectedAmount = amountMap[option] or 1000
            print("Selected amount: " .. option .. " (" .. selectedAmount .. ")")
        end
    })

    MoneyTab:CreateButton({
        Name = "Farm Money (Fire WinGain)",
        Callback = function()
            WinGain:FireServer(selectedAmount)
            print("Farmed: " .. selectedAmount .. " money!")
        end
    })

    MoneyTab:CreateLabel("Spam the button for infinite money! 💸")

    print("Shoot The Boss money farmer ready! Use the Money tab.")
end



-- Jailbreak
if game.PlaceId == 606849621 then
    local RunService = game:GetService("RunService")
    local plr = Players.LocalPlayer

    -- create tabs
    local LPTab = Window:CreateTab("Local Player", "user")
    local TPTab = Window:CreateTab("Teleport", "user")

    -- moves the player to the target like walking
    local function walkToPosition(targetPos, speed)
        speed = speed or 50 -- studs per second
        local char = plr.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return end

        local dir = (targetPos - hrp.Position).Unit
        local distance = (targetPos - hrp.Position).Magnitude

        while distance > 2 and char.Parent do
            local dt = RunService.Heartbeat:Wait()
            local move = dir * speed * dt
            -- ensure we don't overshoot
            if move.Magnitude > distance then
                move = dir * distance
            end
            hrp.CFrame = CFrame.new(hrp.Position + move)
            distance = (targetPos - hrp.Position).Magnitude
        end
    end

    -- teleport buttons
    TPTab:CreateButton({
        Name = "Go to City Crim Base",
        Callback = function()
            walkToPosition(Vector3.new(-270, 18, 1607), 100)
        end
    })

    TPTab:CreateButton({
        Name = "Go to Cargo Drop Off",
        Callback = function()
            walkToPosition(Vector3.new(-341, 21, 2056), 100)
        end
    })

    TPTab:CreateButton({
        Name = "Go to City Garage",
        Callback = function()
            walkToPosition(Vector3.new(-391, 18, 1202), 100)
        end
    })
end


-- break in 1 Lobby 
if game.PlaceId == 1318971886 then
    IsLoaded = true
    print("Break In 1 Lobby Detected! Waiting for game start...")
    
    local BI1Tab = Window:CreateTab("Break In 1", "alert-triangle")
    BI1Tab:CreateLabel("You're in the Break In 1 Lobby", 4483362458, Color3.fromRGB(0,0,0), false)
    BI1Tab:CreateLabel("Features will activate once you join a game.", "moon", Color3.fromRGB(255, 200, 0), false)
end

--break in 1
if game.PlaceId == 4620170611 then
    IsLoaded = true
    print("Break In 1 Main Game LOADED! Items & TP features active.")

    local player = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Items Tab
    local ItemsTab = Window:CreateTab("Items", "shopping-bag")
    local FoodSection = ItemsTab:CreateSection("Food")
    
    local remotePath = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("GiveTool")
    
    ItemsTab:CreateButton({Name = "Get Pizza", Callback = function()
        remotePath:FireServer("Pizza2")
    end})
    
    ItemsTab:CreateButton({Name = "Get Cookie", Callback = function()
        remotePath:FireServer("Cookie")
    end})
    
    ItemsTab:CreateButton({Name = "Get Apple", Callback = function()
        remotePath:FireServer("Apple")
    end})

    local WeaponSection = ItemsTab:CreateSection("Weapons")
    ItemsTab:CreateButton({Name = "Get Pitchfork", Callback = function()
        remotePath:FireServer("Pitchfork")
    end})

    -- TP Tab
    local TpTab = Window:CreateTab("TP", "map-pin")
    
    TpTab:CreateSection("Safe Areas (Before Bad Guys Appear)")
    TpTab:CreateButton({Name = "Basement", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(69.7992401, -17.4561653, -151.839005) end
    end})
    
    TpTab:CreateButton({Name = "Attic", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-19.8243885, 35.3421631, -209.463837) end
    end})

    TpTab:CreateDivider()

    TpTab:CreateSection("After Sewer (Safe Rooms)")
    TpTab:CreateButton({Name = "House", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-15.4009457, -0.010137558, -207.683945) end
    end})
    
    TpTab:CreateButton({Name = "Blue Room", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-48, 17, -208) end
    end})
    
    TpTab:CreateButton({Name = "Pink Room", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(3, 18, -226) end
    end})
    
    TpTab:CreateButton({Name = "Green Room", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(5, 19, -197) end
    end})

    TpTab:CreateDivider()

    TpTab:CreateSection("Stores & Arenas")
    TpTab:CreateButton({Name = "Cookie Store", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-448.749725, 2.6038785, -115.249283) end
    end})
    
    TpTab:CreateButton({Name = "Chips Store", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-448.868439, 9.67501163, -115.257103) end
    end})
    
    TpTab:CreateButton({Name = "Bloxy Cola Store", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-448.499725, 2.80001426, -103.299995) end
    end})
    
    TpTab:CreateButton({Name = "Medkit Store", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-448.759674, 2.73754048, -126.800011) end
    end})
    
    TpTab:CreateButton({Name = "Deviled Egg Arena", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(2917, 4333, -2293) end
    end})
    
    TpTab:CreateButton({Name = "Sewer Arena", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(-53, -286, -1486) end
    end})
    
    TpTab:CreateButton({Name = "Cure Store", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(
                -448.627899, 9.42856598, -126.901138,
                0.0263155699, 0, -0.999653697,
                0, 1, 0,
                0.999653697, 0, 0.0263155699
            )
        end
    end})

    print("Break In 1 features fully loaded! Use Items & TP tabs.")
end


-- Survive and Kill the Killers in Area 51 
if game.PlaceId == 155382109 then
    print("🔫 Survive and Kill the Killers in Area 51 LOADED! Features active.")

    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local PTab = Window:CreateTab("Player", "moon")
    local GunsTab = Window:CreateTab("Guns", "moon")

    -- Safe HRP getter (respawn-safe)
    local function getHRP()
        local char = player.Character or player.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart", 5)
    end

    -- Become Zombie (with CanCollide loop)
    PTab:CreateButton({
        Name = "Become Zombie",
        Callback = function()
            local hrp = getHRP()
            if not hrp then warn("No HRP found!") return end

            local button = workspace:FindFirstChild("AREA51") 
                and workspace.AREA51:FindFirstChild("Outside")
                and workspace.AREA51.Outside:FindFirstChild("Hangar")
                and workspace.AREA51.Outside.Hangar:FindFirstChild("Right")
                and workspace.AREA51.Outside.Hangar.Right:FindFirstChild("Zombie Morph")
                and workspace.AREA51.Outside.Hangar.Right["Zombie Morph"]:FindFirstChild("TheButton")

            if not button then warn("Zombie button not found!") return end

            firetouchinterest(hrp, button, 0)
            task.wait(0.03)
            firetouchinterest(hrp, button, 1)

            -- Permanent no-collide loop
            spawn(function()
                while task.wait() do
                    pcall(function() button.CanCollide = false end)
                end
            end)

            print("🧟 Became Zombie!")
        end
    })

    -- Wear Armor (with CanCollide loop)
    PTab:CreateButton({
        Name = "Wear Armor",
        Callback = function()
            local hrp = getHRP()
            if not hrp then warn("No HRP found!") return end

            local giver = workspace:FindFirstChild("AREA51")
                and workspace.AREA51:FindFirstChild("Amory2Room")
                and workspace.AREA51.Amory2Room:FindFirstChild("Armory")
                and workspace.AREA51.Amory2Room.Armory:FindFirstChild("Giver")

            if not giver then warn("Armor giver not found!") return end

            firetouchinterest(hrp, giver, 0)
            task.wait(0.03)
            firetouchinterest(hrp, giver, 1)

            -- Permanent no-collide loop
            spawn(function()
                while task.wait() do
                    pcall(function() giver.CanCollide = false end)
                end
            end)

            print("🛡️ Armor equipped!")
        end
    })

    --============ GUNS GRABBER (UNCOMMENT TO ENABLE) ============
    -- Helper: find a usable BasePart in the model
    local function findAnyPart(model)
        if not model then return nil end
        if model.PrimaryPart then return model.PrimaryPart end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
        return nil
    end

    -- Grab all weapons
    local function grabAllWeapons()
        local weaponsFolder = workspace:FindFirstChild("Weapons")
        if not weaponsFolder then warn("❌ workspace.Weapons not found") return end

        local hrp = getHRP()
        if not hrp then return end

        local savedCFrame = hrp.CFrame

        for _, weapon in ipairs(weaponsFolder:GetChildren()) do
            if weapon:IsA("Model") then
                local part = findAnyPart(weapon)
                if part then
                    hrp.CFrame = part.CFrame
                    task.wait(0.5)  -- time to pick up
                end
            end
        end

        hrp.CFrame = savedCFrame
        print("🔫 Grabbed all weapons & returned!")
    end

    -- TP to specific weapon & return
    local function tpToWeapon(name)
        local weaponsFolder = workspace:FindFirstChild("Weapons")
        if not weaponsFolder then warn("❌ workspace.Weapons not found") return end

        local hrp = getHRP()
        if not hrp then return end

        local savedCFrame = hrp.CFrame
        local found = false

        for _, obj in ipairs(weaponsFolder:GetChildren()) do
            if obj:IsA("Model") and string.lower(obj.Name) == string.lower(name) then
                local part = findAnyPart(obj)
                if part then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)
                    found = true
                end
            end
        end

        hrp.CFrame = savedCFrame
        if found then print("🔫 Grabbed " .. name) else warn("Weapon not found: " .. name) end
    end

    GunsTab:CreateButton({
        Name = "Grab All Weapons",
        Callback = grabAllWeapons
    })

    GunsTab:CreateSection("Individual Weapons (may vary by mode)")

    local weaponList = {"AN-94", "AWP", "Colt Anaconda", "DB Shotgun", "Desert Eagle", "Flamethrower", "G36C", "M1014", "M14", "M16A2/M203", "M4A1", "MP5K", "P90", "R870", "RayGun", "SVD", "AK-47"}

    for _, w in ipairs(weaponList) do
        GunsTab:CreateButton({
            Name = w,
            Callback = function() tpToWeapon(w) end
        })
    end

    print("Area 51 features fully loaded!")
end




--deadly deliverly
if game.PlaceId == 93044798454681 then
	print("deadly deliverly")
end


--============ 99 NIGHTS IN THE FOREST (Lobby Detection) ============
if game.PlaceId == 79546208627805 then
    print("🌲 99 Nights in the Forest lobby detected! Waiting for game start...")
    local N99Tab = Window:CreateTab("99 Nights", "moon")
    N99Tab:CreateLabel("In lobby - Features will activate when game starts!", "gamepad-2")
end

--============ 99 NIGHTS IN THE FOREST ============
if game.PlaceId == 126509999114328 then  
	local RunService = game:GetService("RunService")
    -- Tabs
	local MTab = Window:CreateTab("Main", "gamepad-2")
    local LPTab = Window:CreateTab("Local Player", "gamepad-2")
    local TpTab = Window:CreateTab("Teleport", "gamepad-2")
    local BSTab = Window:CreateTab("Bring Stuff", "gamepad-2")
    local ATab = Window:CreateTab("Auto", "gamepad-2")
	local ETab = Window:CreateTab("ESP", "gamepad-2")

    --============ LOCAL PLAYER ============
    LPTab:CreateSection("Character Mods")

	local safezoneBaseplates = {}
	local baseplateSize = Vector3.new(2048, 1, 2048)
	local baseY = 100
	local centerPos = Vector3.new(0, baseY, 0) -- original center

	for dx = -1, 1 do
		for dz = -1, 1 do
			local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
			local baseplate = Instance.new("Part")
			baseplate.Name = "SafeZoneBaseplate"
			baseplate.Size = baseplateSize
			baseplate.Position = pos
			baseplate.Anchored = true
			baseplate.CanCollide = true
			baseplate.Transparency = 1
			baseplate.Color = Color3.fromRGB(255, 255, 255)
			baseplate.Parent = workspace
			table.insert(safezoneBaseplates, baseplate)
		end
	end
	
	--toggle visibility/collision for all baseplates

	MTab:CreateToggle({
		Name = "Safe Zone",
		CurrentValue = false,
		Callback = function(v)
			for _, baseplate in ipairs(safezoneBaseplates) do
				baseplate.Transparency = enabled and 0.8 or 1
				baseplate.CanCollide = enabled
			end
		end
	})

	local killAuraToggle = false
	local radius = 200

	local toolsDamageIDs = {
		["Old Axe"] = "1_8982038982",
		["Good Axe"] = "112_8982038982",
		["Strong Axe"] = "116_8982038982",
		["Chainsaw"] = "647_8992824875",
		["Spear"] = "196_8999010016"
	}

	local function getAnyToolWithDamageID()
		for toolName, damageID in pairs(toolsDamageIDs) do
			local tool = player.Inventory:FindFirstChild(toolName)
			if tool then
				return tool, damageID
			end
		end
		return nil, nil
	end

	local function equipTool(tool)
		if tool then
			RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
		end
	end

	local function unequipTool(tool)
		if tool then
			RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
		end
	end

	local function killAuraLoop()
		while killAuraToggle do
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:FindFirstChild("HumanoidRootPart")

			if hrp then
				local tool, damageID = getAnyToolWithDamageID()

				if tool and damageID then
					equipTool(tool)

					for _, mob in ipairs(Workspace.Characters:GetChildren()) do
						if mob:IsA("Model") then
							local part = mob:FindFirstChildWhichIsA("BasePart")

							if part and (part.Position - hrp.Position).Magnitude <= radius then
								pcall(function()
									RemoteEvents.ToolDamageObject:InvokeServer(
										mob,
										tool,
										damageID,
										CFrame.new(part.Position)
									)
								end)
							end
						end
					end
				else
					warn("No supported tool found in inventory")
				end
			end

			task.wait(0.1)
		end

		local tool = getAnyToolWithDamageID()
		unequipTool(tool)
	end

	MTab:CreateToggle({
		Name = "Kill Aura",
		CurrentValue = false,
		Callback = function(Value)
			killAuraToggle = Value

			if Value then
				task.spawn(killAuraLoop)
			else
				local tool = getAnyToolWithDamageID()
				unequipTool(tool)
			end
		end,
	})

	MTab:CreateSlider({
		Name = "Kill Aura Radius",
		Range = {20, 500},
		Increment = 1,
		Suffix = "Studs",
		CurrentValue = radius,
		Callback = function(Value)
			radius = Value
		end,
	})

    local Players = game:GetService("Players")
local player = Players.LocalPlayer

local speedEnabled = true
local jumpEnabled = true

local customSpeed = 50
local customJump = 100

local function applyMovement()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.WalkSpeed = speedEnabled and customSpeed or 16

    if hum.UseJumpPower then
        hum.JumpPower = jumpEnabled and customJump or 50
    else
        hum.JumpHeight = jumpEnabled and (customJump / 7) or 7.2
    end
end



    -- RunService.Heartbeat:Connect(applyMovement)
    -- player.CharacterAdded:Connect(function()
    --     task.wait(0.5)
    --     applyMovement()
    -- end)

	LPTab:CreateButton({Name = "Inf Health", Callback = function()
		local function vu3(pu1)
			pu1.Humanoid.Changed:Connect(function(p2)
				if p2 == "Health" and pu1.Humanoid.Health < 100 then
					game:GetService("ReplicatedStorage").RemoteEvents.DamagePlayer:FireServer(math.huge * - 1)
				end
			end)
		end
		game.Players.LocalPlayer.CharacterAdded:Connect(function(p4)
			vu3(p4)
		end)
		vu3(game.Players.LocalPlayer.Character)

    end})

    LPTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Callback = function(v)
        speedEnabled = v
        applyMovement()
    end
})

LPTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        customSpeed = v
        applyMovement()
    end
})

    LPTab:CreateSlider({Name = "Jump Power", Range = {50, 1000}, Increment = 10, CurrentValue = 150,
        Callback = function(v) customJump = v end})
    LPTab:CreateToggle({Name = "Enable Jump", CurrentValue = false,
        Callback = function(v) jumpEnabled = v end})

    -- Noclip
    local noclipEnabled = false
    local noclipConn
    LPTab:CreateToggle({Name = "Noclip", CurrentValue = false,
        Callback = function(v)
            noclipEnabled = v
            if v then
                if noclipConn then noclipConn:Disconnect() end
                noclipConn = RunService.Stepped:Connect(function()
                    if player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end)
            else
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            end
        end})

    -- Hip Height
    local hipEnabled = false
    local customHip = 25
    LPTab:CreateSlider({Name = "Hip Height", Range = {0, 100}, Increment = 1, CurrentValue = 25,
        Callback = function(v) customHip = v end})
    LPTab:CreateToggle({Name = "Enable Hip Height", CurrentValue = false,
        Callback = function(v)
            hipEnabled = v
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.HipHeight = v and customHip or 2 end
        end})

    LPTab:CreateLabel("Recommended: Hip Height > 25 for no fall damage")

    --============ TELEPORT ============
    TpTab:CreateButton({Name = "Campfire", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(0.79, 50.88, 0.49) end
    end})

    local childNames = {"Lost Child", "Lost Child2", "Lost Child3", "Lost Child4"}
    for i, name in ipairs(childNames) do
        TpTab:CreateButton({Name = "Child " .. i, Callback = function()
            local model
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == name then
                    model = obj
                    break
                end
            end
            if model then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if part then
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local offset = part.CFrame.LookVector * -6
                        hrp.CFrame = CFrame.new(part.Position + offset + Vector3.new(0, 5, 0), part.Position)
                    end
                end
            end
        end})
    end

    --============ BRING STUFF ============
    local selectedMode = "Normal"
    local selectedTarget = "Player"
    local modes = {Normal = {Duration = 0.05, Delay = 0.05}, Fast = {Duration = 0.005, Delay = 0.003}, ["Ultra Fast"] = {Duration = 0.0001, Delay = 0.0001}}
    local targets = {Player = nil, Fire = CFrame.new(0.79, 50.88, 0.49), Workbench = CFrame.new(-50, 8, 300)}

    local function getTargetCF()
        if selectedTarget == "Player" then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            return hrp and hrp.CFrame or CFrame.new()
        end
        return targets[selectedTarget] or CFrame.new()
    end

    local function bringItems(name)
        local items = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == name then table.insert(items, obj) end
        end
        if #items == 0 then warn("No " .. name .. " found") return end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local saved = hrp.CFrame
        local lift = 0

        for _, item in ipairs(items) do
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                for _, p in ipairs(item:GetDescendants()) do
                    if p:IsA("BasePart") then p.Anchored = false end
                end
                part.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
                local goal = part.CFrame + Vector3.new(0, lift + 3, 0)
                TweenService:Create(part, TweenInfo.new(modes[selectedMode].Duration), {CFrame = goal}):Play()
                lift = lift + 0.5
            end
        end
        task.wait(0.2)
        hrp.CFrame = saved
    end

    BSTab:CreateDropdown({Name = "Bring Mode", Options = {"Normal", "Fast", "Ultra Fast"}, CurrentOption = "Normal",
        Callback = function(v) selectedMode = v end})
    BSTab:CreateDropdown({Name = "Bring To", Options = {"Player", "Fire", "Workbench"}, CurrentOption = "Player",
        Callback = function(v) selectedTarget = v end})

    local categories = {
        Food = {"Carrot", "Berry", "Cake", "Morsel", "Apple", "Steak", "Stew", "Corn", "Chili"},
        Healing = {"Bandage", "MedKit"},
        Scrap = {"Sheet Metal", "Old Radio", "Broken Microwave", "Broken Fan", "Bolt", "Tyre", "Old Car Engine", "Metal Chair", "Washing Machine"},
        Fuel = {"Log", "Fuel Canister", "Coal", "Chair", "Oil Barrel"},
        Weapons = {"Good Axe", "Rifle", "Revolver", "Tactical Shotgun", "Spear", "Infernal Sword", "Ice Sword", "Strong Axe", "Crossbow"},
        Armor = {"Iron Body", "Leather Body", "Thorn Body"},
        Misc = {"Giant Sack", "Good Sack", "Infernal Sack", "Coin Stack", "Riot Shield", "Sacrifice Totem", "Defence Blueprint", "Lava Mine Blueprint", "Metor Shard", "Strong Flashlight", "Seed Box", "Bunny Foot", "Alpha Wolf Pelt", "Wolf Pelt", "Bear Pelt", "Rifle Ammo", "Revolver Ammo", "Sapling", "Cultist Gem"}
    }

    for cat, list in pairs(categories) do
        BSTab:CreateSection(cat)
        for _, item in ipairs(list) do
            BSTab:CreateButton({Name = "Bring All " .. item, Callback = function() bringItems(item) end})
        end
    end

    --============ AUTO ============
    ATab:CreateButton({Name = "Open All Chests", Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local saved = hrp.CFrame
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == "Main" then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    prompt.HoldDuration = 0
                    fireproximityprompt(prompt)
                    task.wait(0.1)
                end
            end
        end
        hrp.CFrame = saved
    end})

	local itemESPConnection

ItemTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Callback = function(state)
        local itemFolder = workspace:FindFirstChild("Items")
        if not itemFolder then
            warn("workspace.Items folder not found")
            return
        end

        local itemNames = {
            ["Revolver"] = true,
            ["Oil Barrel"] = true,
            ["Chainsaw"] = true,
            ["Giant Sack"] = true,
            ["Bunny Foot"] = true,
            ["MedKit"] = true,
            ["Alien Chest"] = true,
            ["Berry"] = true,
            ["Bolt"] = true,
            ["Broken Fan"] = true,
            ["Carrot"] = true,
            ["Coal"] = true,
            ["Coin Stack"] = true,
            ["Hologram Emitter"] = true,
            ["Item Chest"] = true,
            ["Laser Fence Blueprint"] = true,
            ["Log"] = true,
            ["Old Flashlight"] = true,
            ["Old Radio"] = true,
            ["Sheet Metal"] = true,
            ["Bandage"] = true,
            ["Rifle"] = true
        }

        local function createESP(model)
            if not model:IsA("Model") or not itemNames[model.Name] then
                return
            end

            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if not part or model:FindFirstChild("ESP") then
                return
            end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESP"
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.AlwaysOnTop = true
            billboard.Adornee = part
            billboard.StudsOffset = Vector3.new(0, 3, 0)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.Text = model.Name
            label.TextSize = 17
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextStrokeTransparency = 0.5
            label.FontFace = Font.new(
                "rbxassetid://16658246179",
                Enum.FontWeight.Regular,
                Enum.FontStyle.Normal
            )

            label.Parent = billboard
            billboard.Parent = model
        end

        local function removeESP()
            for _, model in ipairs(itemFolder:GetChildren()) do
                local esp = model:FindFirstChild("ESP")
                if esp then
                    esp:Destroy()
                end
            end
        end

        -- Disconnect previous connection
        if itemESPConnection then
            itemESPConnection:Disconnect()
            itemESPConnection = nil
        end

        if state then
            for _, model in ipairs(itemFolder:GetChildren()) do
                createESP(model)
            end

            itemESPConnection = itemFolder.ChildAdded:Connect(function(model)
                if model:IsA("Model") and itemNames[model.Name] then
                    task.wait()
                    createESP(model)
                end
            end)
        else
            removeESP()
        end
    end,
})
end



--color or die
if game.PlaceId == 12931609417 then
	print("color or die")
end


--Legend of the bone sword (LOTBS)
if game.PlaceId == 428375933 then
	local TeleportList = {
		CFrame.new(-569.802856, 33.4269905, -419.924835, 0.00419165334, -4.57811353e-08, -0.999991238, 4.82047255e-08, 1, -4.55794797e-08, 0.999991238, -4.80132485e-08, 0.00419165334),
		CFrame.new(-621.229675, 33.363369, -421.17984, 0.967559278, -4.96804553e-08, -0.252644062, 5.86709774e-08, 1, 2.80520904e-08, 0.252644062, -4.19649346e-08, 0.967559278),
		CFrame.new(-623.189697, 33.3970871, -545.201294, 0.640820622, 4.00801881e-08, 0.767690659, -8.94207446e-08, 1, 2.24341274e-08, -0.767690659, -8.30237212e-08, 0.640820622),
		CFrame.new(-474.420502, 33.3633881, -549.294617, 0.335187227, -4.90318319e-09, -0.942151546, 1.08463226e-07, 1, 3.33834898e-08, 0.942151546, -1.13378519e-07, 0.335187227),
		CFrame.new(-605.293884, 20.9410324, -473.158936, -0.0158276837, -2.256348e-08, 0.999874711, 9.65521796e-09, 1, 2.27191457e-08, -0.999874711, 1.00135997e-08, -0.0158276837),
		CFrame.new(-690.220642, 20.9410725, -494.52774, 0.985517263, -5.9089782e-08, -0.169575185, 6.16167384e-08, 1, 9.63923874e-09, 0.169575185, -1.99483061e-08, 0.985517263),
		CFrame.new(-608.201721, 58.374012, -543.024231, -0.978619814, -1.51923238e-08, 0.205677509, -2.56760249e-08, 1, -4.83025318e-08, -0.205677509, -5.25507957e-08, -0.978619814),
		CFrame.new(-405.234619, 63.7604675, -543.684998, -0.0116383517, -9.20926695e-08, -0.999932289, 1.74616821e-09, 1, -9.21192296e-08, 0.999932289, -2.81816592e-09, -0.0116383517)
	}
		local ATab = Window:CreateTab("Auto", "eye")
		local BTTab = Window:CreateTab("Badge Teleports", "eye")
		-- Player BoolValue ESP toggle
		ATab:CreateButton({
			Name = "Complete obby",
			CurrentValue = false,
			Flag = "Auto_Obby",
			Callback = function(value)
				spawn(function()
					for i, cf in ipairs(TeleportList) do
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							LocalPlayer.Character.HumanoidRootPart.CFrame = cf
							--print("Teleported to #" .. i .. " - Waiting 3 seconds...")
							task.wait(.00000000000001)  -- Change this number if you want faster/slower
						end
					end
					print("ALL TELEPORTS FINISHED!")
				end)
			end
		})

	ATab:CreateToggle({
		Name = "Auto Money",
		CurrentValue = false,
		Flag = "AutoMoneyToggle",
		Callback = function(value)
			getgenv().AutoMoneyEnabled = value  -- This is your master ON/OFF switch

			if value then
				-- START ONLY WHEN TOGGLED ON
				spawn(function()
					while getgenv().AutoMoneyEnabled do  -- This loop stops the SECOND it's off
						local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
						local root = character:WaitForChild("HumanoidRootPart")

						local TeleportList = {
							CFrame.new(-408.933411, 55.7566528, -543.338379, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						}

						-- TELEPORT LOOP (checks every frame)
						for _, cf in ipairs(TeleportList) do
							if not getgenv().AutoMoneyEnabled then break end  -- Instant stop if toggled off
							if root and root.Parent then
								root.CFrame = cf
							end
							task.wait(.5)  -- Super fast but safe
						end

						-- ONLY FIRE IF STILL ENABLED
						if getgenv().AutoMoneyEnabled then
							pcall(function()
								game:GetService("ReplicatedStorage").Remotes.Sell:FireServer("Diaboli", 5555555)
							end)
						end

						task.wait(0.05)  -- Tiny delay between cycles
					end
				end)
			end
			-- WHEN TOGGLED OFF → getgenv().AutoMoneyEnabled = false → loop breaks instantly
			-- NO extra code needed. The while condition stops EVERYTHING including FireServer
		end
	})


	-- RAYFIELD / KAVO / ANY UI LIB BUTTON - ONE-CLICK TELEPORT

	BTTab:CreateButton({
		Name = "TP to Secret obby",
		Callback = function()
			local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = CFrame.new(1218.11963, 172.230835, 2482.26831, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				print("Teleported to secret spot!")
			else
				warn("Character not loaded yet!")
			end
		end,
	})


	BTTab:CreateButton({
		Name = "TP to Fluffy the creeper",
		Callback = function()
			local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = CFrame.new(-1572.6554, 7.89999866, 37.1199913, 1, 0, 0, 0, 1, 0, 0, 0, 1)
				print("Teleported to secret spot!")
			else
				warn("Character not loaded yet!")
			end
		end,
	})
end

--piggy
if game.GameId == 1516533665 then
	local ITab = Window:CreateTab("items", "eye")
	local LPTab = Window:CreateTab("character", "eye")
	local EspTab = Window:CreateTab("ESP", "eye")
	
	--// Services
	local Workspace = game:GetService("Workspace")

	--// ---------------- PIGGYNPC ESP ----------------
	local espHighlights = {}
	local espEnabled = false
	local piggyConnections = {}

	local PiggyFile = Workspace:FindFirstChild("PiggyNPC") -- change if your bot folder name is different

	local function createHighlight(object)
		if not object:IsA("Model") then return end
		local primaryPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
		if not primaryPart then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = object.Name .. "_ESP"
		highlight.Adornee = object
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 0
		highlight.Parent = object

		espHighlights[object] = highlight
	end

	local function enableESP()
		if espEnabled then return end
		espEnabled = true

		if PiggyFile then
			for _, obj in ipairs(PiggyFile:GetChildren()) do
				createHighlight(obj)
			end

			-- Auto-add ESP for new PiggyNPCs
			local conn = PiggyFile.ChildAdded:Connect(function(obj)
				if espEnabled then
					task.wait(0.1)
					createHighlight(obj)
				end
			end)
			table.insert(piggyConnections, conn)
		end
	end

	local function disableESP()
		if not espEnabled then return end
		espEnabled = false

		for object, highlight in pairs(espHighlights) do
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end
		table.clear(espHighlights)

		for _, conn in ipairs(piggyConnections) do
			conn:Disconnect()
		end
		table.clear(piggyConnections)
	end

	--// ---------------- PLAYER ESP (SPECIFIC BOOLVALUE) ----------------
	local TARGET_BOOL_NAME = "IsStunned" -- change this to your BoolValue name
	local playerHighlights = {}
	local playerESPEnabled = false
	local playerConnections = {}

	local function createPlayerHighlight(boolObject)
		if not boolObject or not boolObject.Parent then return end
		local parent = boolObject.Parent
		if not parent:IsA("Model") and not parent:IsA("BasePart") then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = boolObject.Name .. "_BoolESP"
		highlight.Adornee = parent
		highlight.FillColor = Color3.fromRGB(0, 255, 0) -- green
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 0
		highlight.Parent = parent

		playerHighlights[boolObject] = highlight
	end

	local function enablePlayerESP()
		if playerESPEnabled then return end
		playerESPEnabled = true

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local boolValue = player.Character:FindFirstChild(TARGET_BOOL_NAME, true)
				if boolValue and boolValue:IsA("BoolValue") then
					createPlayerHighlight(boolValue)
				end
			end

			-- Track new characters for each player
			local charConn = player.CharacterAdded:Connect(function(character)
				task.wait(1)
				if playerESPEnabled then
					local boolValue = character:FindFirstChild(TARGET_BOOL_NAME, true)
					if boolValue and boolValue:IsA("BoolValue") then
						createPlayerHighlight(boolValue)
					end
				end
			end)
			table.insert(playerConnections, charConn)
		end

		-- Handle new players joining
		local playerConn = Players.PlayerAdded:Connect(function(player)
			local charConn = player.CharacterAdded:Connect(function(character)
				task.wait(1)
				if playerESPEnabled then
					local boolValue = character:FindFirstChild(TARGET_BOOL_NAME, true)
					if boolValue and boolValue:IsA("BoolValue") then
						createPlayerHighlight(boolValue)
					end
				end
			end)
			table.insert(playerConnections, charConn)
		end)
		table.insert(playerConnections, playerConn)
	end

	local function disablePlayerESP()
		if not playerESPEnabled then return end
		playerESPEnabled = false

		for boolObj, highlight in pairs(playerHighlights) do
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end
		table.clear(playerHighlights)

		for _, conn in ipairs(playerConnections) do
			conn:Disconnect()
		end
		table.clear(playerConnections)
	end

	-- PiggyNPC ESP toggle
	EspTab:CreateToggle({
		Name = "Enable ESP for PiggyNPC",
		CurrentValue = false,
		Flag = "PiggyNPC_ESP_Toggle",
		Callback = function(value)
			if value then
				enableESP()
			else
				disableESP()
			end
		end
	})

	-- Player BoolValue ESP toggle
	EspTab:CreateToggle({
		Name = "Enable ESP for Player piggy",
		CurrentValue = false,
		Flag = "PlayerBoolESP_Toggle",
		Callback = function(value)
			if value then
				enablePlayerESP()
			else
				disablePlayerESP()
			end
		end
	})

	--normal PLAYER NOT CURRENTLY PIGGY
	local TARGET_BOOL_NAME = "IsStunned" -- change this to your BoolValue name
	local playerHighlights = {}
	local normalPlayEnabled = false
	local normalPlayConnections = {}

	local function createNormalHighlight(character)
		if not character or not character:IsA("Model") then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = character.Name .. "_NormalPlayerESP"
		highlight.Adornee = character
		highlight.FillColor = Color3.fromRGB(255, 255, 255) -- white
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 0
		highlight.Parent = character

		playerHighlights[character] = highlight
	end

	local function enableNormalPlay()
		if normalPlayEnabled then return end
		normalPlayEnabled = true

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				-- Only highlight if they DON'T have the BoolValue
				local boolValue = player.Character:FindFirstChild(TARGET_BOOL_NAME, true)
				if not boolValue then
					createNormalHighlight(player.Character)
				end
			end

			-- Track respawns
			local charConn = player.CharacterAdded:Connect(function(character)
				task.wait(1)
				if normalPlayEnabled then
					local boolValue = character:FindFirstChild(TARGET_BOOL_NAME, true)
					if not boolValue then
						createNormalHighlight(character)
					end
				end
			end)
			table.insert(normalPlayConnections, charConn)
		end

		-- Handle new players joining
		local playerConn = Players.PlayerAdded:Connect(function(player)
			local charConn = player.CharacterAdded:Connect(function(character)
				task.wait(1)
				if normalPlayEnabled then
					local boolValue = character:FindFirstChild(TARGET_BOOL_NAME, true)
					if not boolValue then
						createNormalHighlight(character)
					end
				end
			end)
			table.insert(normalPlayConnections, charConn)
		end)
		table.insert(normalPlayConnections, playerConn)
	end

	local function disableNormalPlay()
		if not normalPlayEnabled then return end
		normalPlayEnabled = false

		for _, highlight in pairs(playerHighlights) do
			if highlight and highlight.Parent then
				highlight:Destroy()
			end
		end
		table.clear(playerHighlights)

		for _, conn in ipairs(normalPlayConnections) do
			conn:Disconnect()
		end
		table.clear(normalPlayConnections)
	end


	EspTab:CreateToggle({
		Name = "Enable ESP for Players",
		CurrentValue = false,
		Flag = "NormalPlay_ESP_Toggle",
		Callback = function(value)
			if value then
				enableNormalPlay()
			else
				disableNormalPlay()
			end
		end
	})

		local RunService = game:GetService("RunService")
		local LocalPlayer = Players.LocalPlayer

		local humanoid
		local customSpeed = 16
		local speedEnabled = false

		-- Function to safely grab humanoid
		local function getHumanoid()
			local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			return character:WaitForChild("Humanoid")
		end

		humanoid = getHumanoid()

		LocalPlayer.CharacterAdded:Connect(function(char)
			humanoid = char:WaitForChild("Humanoid")
			task.wait(0.5)
			if speedEnabled then
				humanoid.WalkSpeed = customSpeed
			end
		end)

		-- === Rayfield Controls ===
		LPTab:CreateSlider({
			Name = "WalkSpeed",
			Range = {10, 100},
			Increment = 1,
			CurrentValue = customSpeed,
			Callback = function(v)
				customSpeed = v
			end
		})

		LPTab:CreateToggle({
			Name = "Custom Speed",
			CurrentValue = false,
			Callback = function(state)
				speedEnabled = state
			end
		})

		-- === Hard enforcement ===
		task.spawn(function()
			while task.wait(0.0005) do -- every 0.05s (20 times/sec)
				if humanoid then
					if speedEnabled then
						if humanoid.WalkSpeed ~= customSpeed then
							humanoid.WalkSpeed = customSpeed
						end
					else
						if humanoid.WalkSpeed ~= 16 then
							humanoid.WalkSpeed = 16
						end
					end
				else
					humanoid = getHumanoid()
				end
			end
		end)


	ITab:CreateButton({
		Name = "Grab ALL Green Keys in Piggy (PIGGY FIXED)",
		Callback = function()
			local player = game:GetService("Players").LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if not hrp or not humanoid then
				Rayfield:Notify({
					Title = "Error",
					Content = "Character not ready!",
					Duration = 3,
				})
				return
			end
			
			local savePos = hrp.CFrame
			local saveHealth = humanoid.Health
			local greenKeysFound = 0
			local promptsFired = 0
			
			-- **PIGGY KEYS: WALK INTO THEM (Touch pickup)**
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and (
					string.lower(obj.Name):find("green") and 
					string.lower(obj.Name):find("key")
				) then
					greenKeysFound = greenKeysFound + 1
					
					-- **METHOD 1: Teleport ONTO key (forces touch pickup)**
					hrp.CFrame = obj.CFrame * CFrame.new(0, 0, 0)  -- Directly on top
					task.wait(0.3)  -- Let touch register
					
					-- **METHOD 2: Fire ProximityPrompt if exists**
					for _, prompt in ipairs(obj:GetDescendants()) do
						if prompt:IsA("ProximityPrompt") then
							fireproximityprompt(prompt)
							promptsFired = promptsFired + 1
							task.wait(0.2)
						elseif prompt:IsA("ClickDetector") then
							fireclickdetector(prompt)
							promptsFired = promptsFired + 1
							task.wait(0.2)
						end
					end
					
					-- **METHOD 3: Force equip (Piggy exploit bypass)**
					humanoid:EquipTool(obj)
					task.wait(0.1)
				end
			end
			
			-- Return + restore
			hrp.CFrame = savePos
			humanoid.Health = saveHealth
			
			Rayfield:Notify({
				Title = "Piggy Green Key Grabber",
				Content = string.format("Found %d keys | Fired %d prompts!", greenKeysFound, promptsFired),
				Duration = 4,
			})
		end
	})	
end

-- The Prison Thing
if game.PlaceId == 73510530738011 then
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local plr = Players.LocalPlayer

    local TTab = Window:CreateTab("Tools", 4483362458)

    local spoonEnabled = false
    local spoonConnection

    local function toggleSpoon()
        spoonEnabled = not spoonEnabled

        if spoonEnabled then
            -- 🔥 RenderStepped Spoon Loop
            spoonConnection = RunService.RenderStepped:Connect(function()
                local Spoon = plr.Backpack:FindFirstChild("Spoon")
                if Spoon then
                    Spoon:SetAttribute("Debounce", 0.01)
                    Spoon:SetAttribute("DigRadius", 100)
                    Spoon:SetAttribute("EnergyPerDig", 0)
                end
            end)
            print("⚡ **RENDERSTEP SUPER SPOON ON** – MAX SPEED DIG HACK! ⛏️💨")
        else
            -- Disconnect
            if spoonConnection then
                spoonConnection:Disconnect()
                spoonConnection = nil
            end
            print("❌ Spoon Mod **OFF**")
        end
    end

    TTab:CreateToggle({
        Name = "Infinite Spoon Mod",
        CurrentValue = false,
        Callback = toggleSpoon
    })

    --[[ 
    -- Button version if you prefer
    TTab:CreateButton({
        Name = "Toggle Infinite Spoon Mod",
        Callback = toggleSpoon
    })
	--]]
    
end



--survive 15 minutes
if game.PlaceId == 135529168948713 then
	local ETab = Window:CreateTab("Enemies", 4483362458)

	ETab:CreateButton({
		Name = "Grab All Enemies",
		Callback = function()
			local lp = game.Players.LocalPlayer
			local enemiesFolder = workspace.Gameplay.WaitForChild("Enemies")
			if not enemiesFolder then return end
			

			local distance = 10
			
			while wait() do
				local playerHRP = lp.Character:FindFirstChild("HumanoidRootPart")
				for _, npc in ipairs(enemiesFolder:GetChildren()) do
					local npcHRP = npc:FindFirstChild("HumanoidRootPart")
					local npcHumanoid = npc:FindFirstChild("Humanoid")
					if npcHRP and npcHumanoid and npcHumanoid.Health > 0 then
						npcHRP.CFrame = playerHRP.CFrame + playerHRP.CFrame.LookVector * distance
					end
				end
				task.wait(0.1)
			end
		end
	})
end

--combat initiation (CI)
if game.PlaceId == 14582748896 then
	local TPTab = Window:CreateTab("Teleport", 4483362458)
	local EnemiesTab = Window:CreateTab("Enemies", 4483362458)


    
	TPTab:CreateButton({
        Name = "Go to Safe area",
        Callback = function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(472.963257, 2025.79968, -191.102081, 0.591504276, -3.70859468e-08, -0.806301832, 2.76708256e-09, 1, -4.39651764e-08, 0.806301832, 2.37744882e-08, 0.591504276)
            end
        end
    })

	TPTab:CreateButton({
		Name = "Spawn Safe Platform",
		Callback = function()
			local platform = Instance.new("Part")
			platform.Size = Vector3.new(9e9, 1, 9e9)
			platform.Position = Vector3.new(-105, 115, 113)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Material = Enum.Material.Neon
			platform.Color = Color3.fromRGB(0, 255, 255)
			platform.Transparency = 1
			platform.Parent = workspace
		end
	})
	
	local freezeEnabled = false
    local espEnabled = false

    local EnemiesSection = EnemiesTab:CreateSection("Enemies")

    EnemiesTab:CreateButton({
    Name = "Toggle Freeze Enemies",
    Callback = function()
        freezeEnabled = not freezeEnabled
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://7038734120"
        sound.Volume = 2.75
        sound.Parent = game.Workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)

        for _, enemy in ipairs(enemiesFolder:GetChildren()) do
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = freezeEnabled end
        end
    end
    })

    EnemiesTab:CreateButton({
    Name = "Grab All Enemies",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end
        
        getgenv().Farm = true
        local distance = 10
        
        while getgenv().Farm do
            local playerHRP = lp.Character:FindFirstChild("HumanoidRootPart")
            for _, npc in ipairs(enemiesFolder:GetChildren()) do
                local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                local npcHumanoid = npc:FindFirstChild("Humanoid")
                if npcHRP and npcHumanoid and npcHumanoid.Health > 0 then
                    npcHRP.CFrame = playerHRP.CFrame + playerHRP.CFrame.LookVector * distance
                end
            end
            task.wait(0.1)
        end
    end
    })

    EnemiesTab:CreateButton({
    Name = "Toggle Enemy ESP",
    Callback = function()
        espEnabled = not espEnabled
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        if not enemiesFolder then return end

        local function updateESP()
            while espEnabled do
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:IsA("Model") then
                        local highlight = enemy:FindFirstChild("EspHighlight")
                        
                        if espEnabled then
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = "EspHighlight"
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.FillTransparency = 0.5
                                highlight.Parent = enemy
                            end
                        else
                            if highlight then highlight:Destroy() end
                        end
                    end
                end
                task.wait(0.2)
            end

            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                local highlight = enemy:FindFirstChild("EspHighlight")
                if highlight then highlight:Destroy() end
            end
        end

        if espEnabled then
            task.spawn(updateESP)
        end
    end
    })

    local BossesSection = EnemiesTab:CreateSection("Bosses")

    EnemiesTab:CreateButton({
    Name = "Kill Jason Instantly",
    Callback = function()
        local Jason = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Jason")
        if not Jason then return end
        
        local humanoid = Jason:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
    })

    local UltrakillSection = EnemiesTab:CreateSection("ULTRAKILL")

    EnemiesTab:CreateButton({
    Name = "DESTROY THE MAP",
    Callback = function()
        local enemiesFolder = workspace:FindFirstChild("Enemies")
        local mapsFolder = workspace:FindFirstChild("Maps")
        
        if enemiesFolder then enemiesFolder:Destroy() end
        if mapsFolder then mapsFolder:Destroy() end
        
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(100, 4, 100)
        platform.Position = Vector3.new(0, 0, 0)
        platform.Anchored = true
        platform.Parent = workspace
        
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end
    })

    local PlayerTab = Window:CreateTab("Player", 4483362458)

    PlayerTab:CreateButton({
    Name = "Infinite Dashes",
    Callback = function()
        game.Players.LocalPlayer.Character:SetAttribute("DashRegenTime", 0.01)
    end
    })

    PlayerTab:CreateButton({
    Name = "No Aggro (Teammate Mode)",
    Callback = function()
        game.Players.LocalPlayer.Character:SetAttribute("AggroMultiplier", 0)
    end
    })

    PlayerTab:CreateButton({
    Name = "Godly Aggro (Tank Mode)",
    Callback = function()
        game.Players.LocalPlayer.Character:SetAttribute("AggroMultiplier", math.huge)
    end
    })

	local WeaponsTab = Window:CreateTab("Weapons", 4483362458)

    WeaponsTab:CreateButton({
    Name = "Slingshot Spam",
    Callback = function()
        local slingshot = game.Players.LocalPlayer.Backpack:FindFirstChild("Slingshot")
        if not slingshot then return end
        
        slingshot:SetAttribute("Firerate", 0.01)
        slingshot:SetAttribute("Capacity", math.huge)
        slingshot:SetAttribute("ChargeRate", 0)
        slingshot:SetAttribute("Spread", 1.35)
    end
    })

    WeaponsTab:CreateButton({
    Name = "Swords No Cooldown",
    Callback = function()
        local backpack = game.Players.LocalPlayer.Backpack
        if not backpack then return end

        local swordAttributes = { Swingrate = 0.01, LungeRate = 0.01 }
        local function updateWeapon(weaponName)
            local weapon = backpack:FindFirstChild(weaponName)
            if weapon then for attr, value in pairs(swordAttributes) do weapon:SetAttribute(attr, value) end end
        end

        updateWeapon("Sword")
        updateWeapon("Katana")
        updateWeapon("Firebrand")
    end
    })

    WeaponsTab:CreateButton({
    Name = "Paintball Gun No Cooldown",
    Callback = function()
        local backpack = game.Players.LocalPlayer.Backpack
        if not backpack then return end

        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("paintball") then
                item:SetAttribute("Firerate", 0.01)
                item:SetAttribute("Capacity", math.huge)
                item:SetAttribute("ReloadTime", 0)
            end
        end
    end
    })

    local FlowTab = Window:CreateTab("flow", 4483362458)

    FlowTab:CreateButton({
    Name = "flow.",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.WalkSpeed = 30

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://85299714943811"
        sound.Volume = 8.5
        sound.Parent = character
        sound:Play()

        local aura = Instance.new("ParticleEmitter")
        aura.Parent = character.HumanoidRootPart
        aura.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(147, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
        })
        aura.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 3)
        })
        aura.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        aura.Lifetime = NumberRange.new(0.5, 1)
        aura.Rate = 50
        aura.Speed = NumberRange.new(3, 5)
        aura.SpreadAngle = Vector2.new(0, 180)
        aura.Enabled = true
        aura.CanCollide = false

        local function updateWalkSpeed()
            if humanoid then
                humanoid.WalkSpeed = 100
            end
        end

        local noclip = false
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.P then
                noclip = true
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.P then
                noclip = false
            end
        end)

        game:GetService("RunService").Stepped:Connect(function()
            if noclip then
                for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
                end
            else
                for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
                end
            end
        end)

        game:GetService("RunService").Heartbeat:Connect(updateWalkSpeed)
    end
    })

    FlowTab:CreateButton({
    Name = "Remove Flow",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId:match("15961487228") then
                track:Stop()
                end
            end
        end
        
        for _, sound in pairs(character:GetChildren()) do
            if sound:IsA("Sound") and sound.SoundId:match("85299714943811") then
                sound:Stop()
                sound:Destroy()
            end
        end
        
        if character:FindFirstChild("HumanoidRootPart") then
            for _, effect in pairs(character.HumanoidRootPart:GetChildren()) do
                if effect:IsA("ParticleEmitter") then
                effect:Destroy()
                end
            end
        end
        
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name == "HumanoidRootPart" then
                part.CanCollide = false
                else
                part.CanCollide = true
                end
            end
        end
    end
    })

	-- Function to modify tool attributes safely (check both Backpack and equipped tools)
	local function modifyToolAttributes(toolName, attributes)
		local player = game.Players.LocalPlayer
		local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)

		if tool then
			for attribute, value in pairs(attributes) do
				tool:SetAttribute(attribute, value)
			end
			print(toolName .. " attributes have been set.")
		else
			print(toolName .. " not found in the Backpack or equipped.")
		end
	end

	local Tab = Window:CreateTab("Fun Stuffz", 0)

	local Section1 = Tab:CreateSection("Sword")
	Tab:CreateParagraph({Title = "Sword", Content = "Parry go BRRR"})

	-- Button for Modded Sword
	Tab:CreateButton({
		Name = "Modded Sword",
		Callback = function(Value)
			modifyToolAttributes("Sword", {
				LungeRate = 0,
				Swingrate = 0,
				OffhandSwingRate = 0
			})
		end
	})

	-- Button for Modded Firebrand
	Tab:CreateButton({
		Name = "Modded Firebrand",
		Callback = function()
			modifyToolAttributes("Firebrand", {
				LungeRate = 0,
				Swingrate = 0,
				OffhandSwingRate = 0,
				Windup = 0
			})
		end
	})

	-- Button for Modded Katana
	Tab:CreateButton({
		Name = "Modded Katana",
		Callback = function()
			modifyToolAttributes("Katana", {
				LungeRate = 0,
				Swingrate = 0,
				OffhandSwingRate = 0
			})
		end
	})

	local Section2 = Tab:CreateSection("Slingshot")
	Tab:CreateParagraph({Title = "Slingshot", Content = "Spammy!"})

	-- Button for Modded Slingshot
	Tab:CreateButton({
		Name = "Modded Slingshot",
		Callback = function()
			modifyToolAttributes("Slingshot", {
				Capacity = math.huge,
				ChargeRate = 0,
				Firerate = 0,
				Spread = 0,
				ProjectileSpeed = 10000
			})
		end
	})

	-- Button for Modded Flamethrower
	Tab:CreateButton({
		Name = "Modded Flamethrower",
		Callback = function()
			modifyToolAttributes("Flamethrower", {
				Cooldown = 0
			})
		end
	})

	local Section3 = Tab:CreateSection("Paintball Gun")
	Tab:CreateParagraph({Title = "Paintball Gun", Content = "Ah, yes! The good ol' ranged guns!"})

	-- Button for Modded Paintball Gun
	Tab:CreateButton({
		Name = "Modded Paintball Gun",
		Callback = function()
			modifyToolAttributes("Paintball Gun", {
				Firerate = 0,
				ProjectileSpeed = 10000
						})
		end
	})

	-- Button for Modded BB Gun
	Tab:CreateButton({
		Name = "Modded BB Gun",
		Callback = function()
			modifyToolAttributes("BB Gun", {
				Firerate = 0,
				MinShots = 2,
				MaxShots = math.huge -- Use `math.huge` for infinite value
			})
		end
	})

	-- Button for Modded Freeze Ray
	Tab:CreateButton({
		Name = "Modded Freeze Ray (Always Charged)",
		Callback = function()
			modifyToolAttributes("Freeze Ray", {
				Firerate = 0,
				ProjectileSpeed = 10000,
				ChargeTime = 0
			})
		end
	})
	Tab:CreateButton({
		Name = "Modded Freeze Ray (Hold to Charge)",
		Callback = function()
			modifyToolAttributes("Freeze Ray", {
				Firerate = 0,
				ProjectileSpeed = 10000,
			})
		end
	})

	local Section4 = Tab:CreateSection("Superball")
	Tab:CreateParagraph({Title = "Superball", Content = "Bounce."})

	-- Button for Modded super Ball
	Tab:CreateButton({
		Name = "Modded Super Ball (buggy)",
		Callback = function(Value)
			modifyToolAttributes("Superball", {
				ThrowRate = 0,
				Damage = 9e9
			})
		end
	})

	-- Button for Modded rocket launcher
	Tab:CreateButton({
		Name = "Modded Rocket Launcher (buggy)",
		Callback = function(Value)
			modifyToolAttributes("Rocket Launcher", {
				Cooldown = 0.0001,
				DirectDamage = 9e9,
				Range = 9e9,
				ProjectileSpeed = 400,
				Damage = 9e9
			})
		end
	})

	-- Button for Modded Ninja Stars
	Tab:CreateButton({
		Name = "Modded Ninja Stars",
		Callback = function(Value)
			modifyToolAttributes("Ninja Stars", {
				ThrowRate = 0,
				Capacity = math.huge,
				ChargeRate = 0
			})
		end
	})

	-- Button for Modded Bazooka
	Tab:CreateButton({
		Name = "Modded Bazooka",
		Default = false,
		Flag = "Bazooka",
		Callback = function()
			modifyToolAttributes("Bazooka", {
				ReloadTick = 0,
				Capacity = math.huge,
				PassiveReloadTick = 0
			})
		end
	})

	local Section5 = Tab:CreateSection("Timebomb")
	Tab:CreateParagraph({Title = "Timebomb", Content = "Chat is this real?"})

	-- Button for Modded Subspace Tripmine
	Tab:CreateButton({
		Name = "Modded Subspace Tripmine",
		Default = false,
		Flag = "Subspace_Tripmine",
		Callback = function()
			modifyToolAttributes("Subspace Tripmine", {
				Cooldown = 0
			})
		end
	})

	-- Button for Modded Explosive Pinata
	Tab:CreateButton({
		Name = "Modded Explosive Pinata",
		Callback = function(Value)
				modifyToolAttributes("Explosive Pinata", {
					Cooldown = 0
				})
		end
	})

	local Section6 = Tab:CreateSection("Trowel")
	Tab:CreateParagraph({Title = "Trowel", Content = "Hey look guys! I'm a Builder Man!"})

	-- Toggle for Frozen Wrench
	Tab:CreateToggle({
		Name = "Frozen Wrench",
		Flag = "Wrench",
		Callback = function(Value)
			local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("Wrench") or game.Players.LocalPlayer.Character:FindFirstChild("Wrench")
			if tool then
				tool:SetAttribute("TimeScale", Value and 0 or 1)
			else
				print("Wrench not found in the Backpack or equipped.")
			end
		end
	})

	-- Hats Tab
	local Tab2 = Window:CreateTab("Hats", 0)

	-- Button for Electric Punk
	Tab2:CreateButton({
		Name = "Electric Punk (Lighting Chance)",
		Callback = function()
			local accessoryEffects = game.Players.LocalPlayer.Backpack.Parent:FindFirstChild("AccessoryEffects")
			if accessoryEffects then
				accessoryEffects:SetAttribute("Lightning_Chance", 100)
			else
				print("AccessoryEffects not found.")
			end
		end
	})

	Tab2:CreateInput({
		Name = "Melee Range (5 = +500%)",
		CurrentValue = "5",
		RemoveTextAfterFocusLost = false,
		PlaceholderText = "",
		Flag = "meleerangevalue",
		Callback = function(Value)
			Rayfield.Flags["meleerangevalue"] = { Value = Value }
		end	  
	})

	Tab2:CreateInput({
		Name = "Pogo Range (5 = +500%)",
		Default = "5",
		RemoveTextAfterFocusLost = false,
		PlaceholderText = "",
		Flag = "pogorangevalue",
		Callback = function(Value)
			Rayfield.Flags["pogorangevalue"] = { Value = Value }
		end	  
	})

	Tab2:CreateButton({
		Name = "Bandit/Stage Prop (Melee Range & Pogo Range)",
		Callback = function()
			local accessoryEffects = game.Players.LocalPlayer.Backpack.Parent:FindFirstChild("AccessoryEffects")
			if accessoryEffects then
				accessoryEffects:SetAttribute("Melee_Range", Rayfield.Flags["meleerangevalue"].Value)
				accessoryEffects:SetAttribute("Pogo_Range", Rayfield.Flags["pogorangevalue"].Value)
			else
				print("AccessoryEffects not found.")
			end
		end
	})

	-- Character Tab
	local Tab3 = Window:CreateTab("Character")

	-- Button for Infinite Dashes
	Tab3:CreateButton({
		Name = "Infinite Dashes",
		Callback = function()
			local character = game.Players.LocalPlayer.Character
			if character then
				character:SetAttribute("DashRegenTime", 0.05)
				character:SetAttribute("DashRegenFury", 0.05)
			else
				print("Character not found.")
			end
		end
	})

	-- Utility Boost Textbox and Button
	Tab3:CreateInput({
		Name = "Utility Boost Value",
		CurrentValue = "2",
		RemoveTextAfterFocusLost = false,
		PlaceholderText = "",
		Flag = "utilityboostvalue",
		Callback = function(Value)
			Rayfield.Flags["utilityboostvalue"] = { Value = Value }
		end
	})

	Tab3:CreateButton({
		Name = "Utility Boost",
		Callback = function()
			local character = game.Players.LocalPlayer.Character
			if character then
				character:SetAttribute("UtilityBoost", Rayfield.Flags["utilityboostvalue"].Value)
			else
				print("Character not found.")
			end
		end
	})
	--survive in area 51
end





--my noob army
if game.PlaceId == 111769828221159 then 
    local CoinsTab = Window:CreateTab("Coins")
    local ATab = Window:CreateTab("Auto", 4483362458)

    -- Collect Coins
    CoinsTab:CreateButton({
        Name = "Collect Coins",
        Callback = function()
            local plr = game.Players.LocalPlayer
            local char = plr.Character or plr.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            
            local CoinFolder = workspace:FindFirstChild("Coins")
            if not CoinFolder then return end
            
            for _, coin in pairs(CoinFolder:GetDescendants()) do
                if coin:IsA("BasePart") or coin:IsA("MeshPart") then
                    -- Teleport + touch for reliability
                    hrp.CFrame = coin.CFrame + Vector3.new(0, 5, 0)  -- Slight offset to ensure touch
                    firetouchinterest(hrp, coin, 0)
                    task.wait()  -- Small yield
                    firetouchinterest(hrp, coin, 1)
                end
            end
        end
    })

    -- Auto Buy Noobs
    local selectedNoobs = {"Bacon"}  -- Default

    ATab:CreateDropdown({
        Name = "Select Noobs",
        Options = {
            "Bacon","Bacon Girl","FBI Noob","Frost Knight","Frozen Zombie","Mafia",
            "Marine Noob","Noob","Novice Soldier Noob","Police Noob","President Noob",
            "Prisoner","Risking Queen","SWAT Noob","Sniper Noob","Soldier",
            "Soldier Noob","Special Forces Noob","Strong Man","Thug","Veteran Noob"
        },
        CurrentOption = {"Bacon"},
        MultipleOptions = true,
        Callback = function(options)
            selectedNoobs = options
        end
    })

    local autoBuyConnection

    ATab:CreateToggle({
        Name = "Auto Buy Noobs",
        CurrentValue = false,
        Callback = function(enabled)
            if autoBuyConnection then
                autoBuyConnection:Disconnect()
                autoBuyConnection = nil
            end

            if not enabled then return end

            autoBuyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local conveyor = workspace:FindFirstChild("ConveyorCharacters")
                local buyRemote = game.ReplicatedStorage:FindFirstChild("Remotes")
                    and game.ReplicatedStorage.Remotes:FindFirstChild("BuyCharacter")

                if not conveyor or not buyRemote then return end

                for _, model in pairs(conveyor:GetChildren()) do
                    if model:IsA("Model") and table.find(selectedNoobs, model.Name) then
                        buyRemote:FireServer(model.Name)
                        -- Small delay only after buying to avoid spamming too hard
                        task.wait(0.05)
                    end
                end
            end)
        end
    })
end

--infamy
if game.PlaceId == 3104101863 then
	local PTab = Window:CreateTab("Player", "sprout")

	-- LocalScript → Put in StarterPlayer > StarterPlayerScripts
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	local function forceMaxStorage()
		local character = player.Character or player.CharacterAdded:Wait()
		if not character then return end
		
		local storage = character
			:WaitForChild("CharStats", 10)
			:WaitForChild("GunInventory", 10)
			:WaitForChild("Gun1", 10)
			:WaitForChild("Storage", 10)
		
		-- Infinite loop that keeps slamming the value to max
		task.spawn(function()
			while task.wait(0.0001) do  -- checks 10 times per second (super fast)
				if not storage or not storage.Parent then break end
				
				-- If Storage is a NumberValue / IntValue (most common for ammo, kills, etc.)
				if storage:IsA("NumberValue") or storage:IsA("IntValue") then
					if storage.Value < 999999999 then
						storage.Value = 999999999
						print("Forced Storage → 999999999")
					end
				end
			end
		end)
	end

	PTab:CreateButton({
		Name = "Inf Ammo",
		Callback = function()
			forceMaxStorage()
			player.CharacterAdded:Connect(forceMaxStorage)
		end,
	})
end


--forsaken
if game.GameId == 6331902150 then
	local PTab = Window:CreateTab("player", "sprout")
	local ESPTab = Window:CreateTab("ESP", "sprout")
	local CTab = Window:CreateTab("Combat", "sprout")
	local FTab = Window:CreateTab("Farm", "sprout")

	while not game:IsLoaded() do wait() end

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local LocalPlayer = Players.LocalPlayer
	local KillersFolder = workspace.Players:WaitForChild("Killers")
	local SurvivorsFolder = workspace.Players:WaitForChild("Survivors")
	local MapFolder = workspace.Map.Ingame:WaitForChild("Map")


	-- ESP toggle state
	local ESPState = {
		Killer = false,
		Survivor = false,
		Generator = false
	}

	-- Highlight helpers
	local function applyHighlight(model, name, color)
		if not model:FindFirstChild(name) then
			local h = Instance.new("Highlight")
			h.Name = name
			h.Adornee = model
			h.FillTransparency = 1
			h.OutlineColor = color
			h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = model
		end
	end

	local function removeHighlight(model, name)
		local h = model:FindFirstChild(name)
		if h then h:Destroy() end
	end

	-- RunService loop
	RunService.RenderStepped:Connect(function()
		local localChar = LocalPlayer.Character
		if not localChar then return end

		-- 🔴 Killer ESP
		for _, killer in ipairs(KillersFolder:GetChildren()) do
			if killer:IsA("Model") and killer:FindFirstChild("HumanoidRootPart") then
				if ESPState.Killer then
					applyHighlight(killer, "KillerHighlight", Color3.fromRGB(255, 0, 0))
				else
					removeHighlight(killer, "KillerHighlight")
				end
			end
		end

		-- 🟢 Survivor ESP (ignore yourself)
		for _, survivor in ipairs(SurvivorsFolder:GetChildren()) do
			if survivor:IsA("Model") and survivor ~= localChar then
				if ESPState.Survivor then
					applyHighlight(survivor, "SurvivorHighlight", Color3.fromRGB(0, 255, 0))
				else
					removeHighlight(survivor, "SurvivorHighlight")
				end
			end
		end

		-- ⚙️ Generator ESP (unfinished only)
		for _, obj in ipairs(MapFolder:GetChildren()) do
			if obj:IsA("Model") and obj.Name == "Generator" then
				if ESPState.Generator then
					local progress = obj:FindFirstChild("Progress", true)
					if progress and progress:IsA("ValueBase") and progress.Value < 100 then
						applyHighlight(obj, "GeneratorHighlight", Color3.fromRGB(255, 255, 255))
					else
						removeHighlight(obj, "GeneratorHighlight")
					end
				else
					removeHighlight(obj, "GeneratorHighlight")
				end
			end
		end
	end)

	-- Wait for the game to fully load
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local Players = game:GetService("Players")

	-- Settings
	local TARGET_GROUP_ID = 33548380          -- Group to kick
	local TARGET_GROUP_NAME = "Forsaken Dev Team"     -- Optional name for notification

	-- Possible tags to monitor
	local ALL_TAGS = {"Member", "Forsaken Tester", "Forsaken Community Contributor", "Forasken Contributor", "Forasken Moderator",
	"Forasken Head Moderator", "Forasken PR", "Analytics", "Forasken Developer", "Forasken Programmer", "Owners", "Holder"}

	-- Table to track selected tags
	local SelectedTags = {}

	-- Track already checked players
	local checkedPlayers = {}

	-- Function to kick player
	local function kickPlayer(plr, reason)
		if plr and plr:IsDescendantOf(Players) then
			plr:Kick("Unwanted player detected! Reason: " .. reason)
		end
	end

	-- Check a single player
	local function checkPlayer(plr)
		-- Check group
		local rank = plr:GetRankInGroup(TARGET_GROUP_ID)
		if rank > 0 then
			kickPlayer(plr, "Member of group: " .. TARGET_GROUP_NAME)
			return
		end

		-- Check tags (StringValue, ObjectValue, or Attribute "GameTag")
		local tag = plr:GetAttribute("GameTag")
		if tag and table.find(SelectedTags, tag) then
			kickPlayer(plr, "Tag: " .. tag)
			return
		end
	end

	-- Activate kicker
	local function activateKicker()
		-- Existing players
		for _, plr in ipairs(Players:GetPlayers()) do
			if not table.find(checkedPlayers, plr) then
				table.insert(checkedPlayers, plr)
				checkPlayer(plr)
			end
		end

		-- Listen for new players
		Players.PlayerAdded:Connect(function(plr)
			table.insert(checkedPlayers, plr)
			checkPlayer(plr)
		end)
	end


	-- Dropdown for selecting tags
	PTab:CreateDropdown({
		Name = "Select Tags to Auto leave",
		Options = ALL_TAGS,
		MultiSelect = true,
		CurrentOption = {},
		Flag = "TagDropdown",
		Callback = function(selected)
			SelectedTags = selected
		end
	})

	-- Button to activate kicker
	PTab:CreateButton({
		Name = "Activate Kicker (Might not work)",
		Callback = function()
			if #SelectedTags == 0 then
				Rayfield:Notify({
					Title = "Error",
					Content = "Please select at least one tag!",
					Duration = 4
				})
				return
			end
			activateKicker()
			Rayfield:Notify({
				Title = "Kicker Activated",
				Content = "Monitoring group: " .. TARGET_GROUP_NAME .. " and selected tags",
				Duration = 4
			})
		end
	})

	-- Returns true if any killer HRP is nearby
	local function isKillerNearby()
		for _, killerModel in ipairs(KILLER_FOLDER:GetChildren()) do
			if killerModel:IsA("Model") then
				local hrp = killerModel:FindFirstChild("HumanoidRootPart")
				if hrp then
					local distance =
						(humanoidRootPart.Position - hrp.Position).Magnitude

					if distance <= DETECTION_RANGE then
						return true
					end
				end
			end
		end
		return false
	end


	CTab:CreateToggle({
		Name = "Auto Block",
		CurrentValue = false,
		Callback = function(v)
			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local VIM = game:GetService("VirtualInputManager")

			local localPlayer = Players.LocalPlayer
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

			local blockUI = localPlayer.PlayerGui:WaitForChild("MainUI")
				.AbilityContainer.Block

			-- Killer container
			local KILLER_FOLDER = workspace.Players:WaitForChild("Killers")
			local DETECTION_RANGE = 25

			-- debounce
			local lastBlock = 0
			local BLOCK_COOLDOWN = 0.4 -- seconds
			local ToBlock 



			local LocalPlayer = Players.LocalPlayer
			local playerName = LocalPlayer.Name
			local targetModelName = "Guest1337"  -- Change if needed

			if SurvivorsFolder then
				local survivorModel = SurvivorsFolder:FindFirstChild(targetModelName) 
				or SurvivorsFolder:FindFirstChildWhichIsA("Model", true)  -- Fallback search

				-- Optional extra check with attribute if it exists
				-- if survivorModel and survivorModel:GetAttribute("Username") ~= playerName then survivorModel = nil end

				if survivorModel then
					print("Found target model:", survivorModel.Name)

					-- Single connection that runs every frame
					RunService.RenderStepped:Connect(function()
						if isKillerNearby() then
							if tick() - lastBlock >= BLOCK_COOLDOWN then
								lastBlock = tick()

								-- Press Q
								VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
								task.wait(0.05)  -- Short hold time
								-- Release Q
								VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
							end
						end
					end)
				else
					warn("Could not find the target survivor model (Guest1337)")
				end
			else
				warn("SurvivorsFolder not found!")
			end

			-- Handle respawn
			localPlayer.CharacterAdded:Connect(function(newChar)
				character = newChar
				humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
			end)

		end,
	})

		CTab:CreateSlider({
		Name = "Auto Block Delay",
		Range = {0.25, 4},
		Increment = .01,
		Suffix = "seconds",
		CurrentValue = 1,
		Callback = function(BlockValue)
			ToBlock = BlockValue
		end,
	})



	--// UI Toggles
	ESPTab:CreateToggle({
		Name = "Killer ESP",
		CurrentValue = false,
		Callback = function(v)
			ESPState.Killer = v
		end,
	})

	ESPTab:CreateToggle({
		Name = "Survivor ESP",
		CurrentValue = false,
		Callback = function(v)
			ESPState.Survivor = v
		end,
	})

	ESPTab:CreateToggle({
		Name = "Generator ESP",
		CurrentValue = false,
		Callback = function(v)
			ESPState.Generator = v
		end,
	})




	-- Toggle in Farm tab
	FTab:CreateSection("Bot Control")
	FTab:CreateToggle({
		Name = "Use Walking mode (safer)",
		CurrentValue = false,
		Callback = function(v)
			_G.WalkingBot_Enabled = v

			if v then
				Rayfield:Notify({Title = "Walking Bot", Content = "ON - Walking to gens!", Duration = 4})

				if _G.WalkingBot_Loaded then return end
				_G.WalkingBot_Loaded = true

				local PFS = game:GetService("PathfindingService")
				local VIM = game:GetService("VirtualInputManager")
				local Players = game:GetService("Players")
				local player = Players.LocalPlayer

				local testPath = PFS:CreatePath({
					AgentRadius = 2,
					AgentHeight = 5,
					AgentCanJump = false,
					AgentJumpHeight = 10,
					AgentCanClimb = true,
					AgentMaxSlope = 45
				})

				local isInGame = false
				local currentCharacter = nil
				local humanoid = nil
				local stamina = 0
				local busy = false
				local Spectators = {}

				-- Spectator / in-game check
				task.spawn(function()
					while _G.WalkingBot_Loaded do
						Spectators = {}
						for _, child in game.Workspace.Players.Spectating:GetChildren() do
							table.insert(Spectators, child.Name)
						end
						isInGame = not table.find(Spectators, player.Name)
						task.wait(1)
					end
				end)

				-- Sprint helper
				task.spawn(function()
					while _G.WalkingBot_Loaded do
						if isInGame and currentCharacter then
							pcall(function()
								currentCharacter.Humanoid:SetAttribute("BaseSpeed", 14)
								local barText = player.PlayerGui.TemporaryUI.PlayerInfo.Bars.Stamina.Amount.Text
								stamina = tonumber(string.split(barText, "/")[1]) or 0
								local isSprintingFOV = currentCharacter.FOVMultipliers.Sprinting.Value == 1.125
								if not isSprintingFOV and stamina >= 70 and not busy then
									VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
								else
									VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
								end
							end)
						end
						task.wait(0.5)
					end
				end)

				-- Auto rejoin after 20 mins
				task.spawn(function()
					task.wait(20 * 60)
					if _G.WalkingBot_Enabled then
						game:GetService("TeleportService"):Teleport(game.PlaceId)
					end
				end)

				-- Main repeating bot loop
				task.spawn(function()
					while _G.WalkingBot_Loaded do
						if _G.WalkingBot_Enabled and isInGame then
							-- RE-DETECT character every loop (fixes new round/death)
							currentCharacter = nil
							for _, surv in ipairs(game.Workspace.Players.Survivors:GetChildren()) do
								if surv:GetAttribute("Username") == player.Name then
									currentCharacter = surv
									humanoid = currentCharacter:FindFirstChild("Humanoid")
									break
								end
							end

							if not currentCharacter or not humanoid or humanoid.Health <= 0 then
								task.wait(1)
							else
								-- Check if all gens done
								local allGensComplete = true
								for _, genData in ipairs(game.ReplicatedStorage.ObjectiveStorage:GetChildren()) do
									if genData.Value ~= genData:GetAttribute("RequiredProgress") then
										allGensComplete = false
										break
									end
								end

								if allGensComplete then
									print("✅ All gens complete — Evading killers!")
									repeat
										if not _G.WalkingBot_Enabled then break end
										for _, killer in ipairs(game.Workspace.Players.Killers:GetChildren()) do
											if killer:FindFirstChild("HumanoidRootPart") and currentCharacter:FindFirstChild("HumanoidRootPart") then
												local dist = (killer.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
												if dist <= 100 then
													local evadePos = currentCharacter.HumanoidRootPart.Position + (-killer.HumanoidRootPart.CFrame.LookVector).Unit * 50
													testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, evadePos)
													if testPath.Status == Enum.PathStatus.Success then
														for _, wp in ipairs(testPath:GetWaypoints()) do
															if not _G.WalkingBot_Enabled then break end
															humanoid:MoveTo(wp.Position)
															humanoid.MoveToFinished:Wait()
														end
													end
												end
											end
										end
										task.wait(0.2)
									until #game.Workspace.Players.Killers:GetChildren() == 0 or not _G.WalkingBot_Enabled
								else
									-- REPEATING generator repair (loops forever)
									repeat
										if not _G.WalkingBot_Enabled then break end
										local foundGen = false
										for _, gen in ipairs(game.Workspace.Map.Ingame.Map:GetChildren()) do
											if gen.Name == "Generator" and gen.Progress.Value ~= 100 then
												foundGen = true
												print("🔧 Heading to generator:", gen.Name)
												local goalPos = gen.Positions.Right.Position
												testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, goalPos)
												if testPath.Status == Enum.PathStatus.Success then
													for _, wp in ipairs(testPath:GetWaypoints()) do
														if not _G.WalkingBot_Enabled then break end
														humanoid:MoveTo(wp.Position)
														humanoid.MoveToFinished:Wait()
													end

													local prompt = gen.Main.Prompt
													if prompt and (currentCharacter.HumanoidRootPart.Position - goalPos).Magnitude < 15 then
														prompt.HoldDuration = 0
														prompt.RequiresLineOfSight = false
														prompt.MaxActivationDistance = 99999
														Workspace.Camera.CFrame = CFrame.new(201.610779, 64.460968, 1307.98096, 0.99840349, -0.0556023642, 0.00994364079, -1.31681965e-09, 0.176041901, 0.984382629, -0.0564845055, -0.982811034, 0.17576085)
														task.wait(0.1)
														busy = true
														repeat
															if not _G.WalkingBot_Enabled then break end
															prompt:InputHoldBegin()
															prompt:InputHoldEnd()
															task.wait(genTime or 0.1)
															gen.Remotes.RE:FireServer()
															task.wait(2.5)
														until gen.Progress.Value == 100
														busy = false
														print("✅ Generator completed!")
													end
												end
												break  -- Go to next gen after trying one
											end
										end
										if not foundGen then task.wait(2) end
									until allGensComplete or not _G.WalkingBot_Enabled
								end
							end
						end
						task.wait(0.5)
					end
				end)
			else
				Rayfield:Notify({Title = "Walking Bot", Content = "OFF", Duration = 4})
			end
		end,
	})

	FTab:CreateToggle({
		Name = "Enable Tween Mode (works better)",
		CurrentValue = false,
		Callback = function(Value)
			while not game:IsLoaded() do wait() end

			local Players = game:GetService("Players")
			local PathfindingService = game:GetService("PathfindingService")
			local TweenService = game:GetService("TweenService")
			local VirtualInputManager = game:GetService("VirtualInputManager")
			local RunService = game:GetService("RunService")
			local Workspace = game:GetService("Workspace")
			local LocalPlayer = Players.LocalPlayer

			local testPath = PathfindingService:CreatePath({
				AgentRadius = 2, AgentHeight = 5, AgentCanJump = false,
				AgentJumpHeight = 10, AgentCanClimb = true, AgentMaxSlope = 45
			})

			-- Variables
			local isInGame, currentCharacter, humanoid = false, nil, nil
			local isSprinting, stamina, busy = false, 0, false
			local Spectators = {}
			local fail_attempt = 0

			-- Bot control
			local BotEnabled = false

			-- Tween settings
			local TWEEN_TIME = 1.2  -- Adjust speed here (lower = faster)

			local CurrentTween = nil
			local NoClipConnection = nil

			-- NoClip during tween (always enabled when tween runs - no toggle)
			local function EnableNoClip(state)
				if state then
					NoClipConnection = RunService.Stepped:Connect(function()
						if currentCharacter then
							for _, part in pairs(currentCharacter:GetDescendants()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
								end
							end
						end
					end)
				elseif NoClipConnection then
					NoClipConnection:Disconnect()
					NoClipConnection = nil
					if currentCharacter then
						for _, part in pairs(currentCharacter:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = true
							end
						end
					end
				end
			end

			-- Direct tween to target
			local function TweenStraightTo(targetPos)
				if not currentCharacter or not currentCharacter:FindFirstChild("HumanoidRootPart") then return false end
				local hrp = currentCharacter.HumanoidRootPart
				if CurrentTween then CurrentTween:Cancel() end

				local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear)
				CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})

				EnableNoClip(true)
				CurrentTween:Play()

				local completed = false
				CurrentTween.Completed:Connect(function()
					completed = true
					EnableNoClip(false)
				end)

				task.delay(TWEEN_TIME + 3, function()
					if not completed then EnableNoClip(false) end
				end)

				return true
			end

			-- In-game check
			task.spawn(function()
				while true do
					Spectators = {}
					for _, child in Workspace.Players.Spectating:GetChildren() do
						table.insert(Spectators, child.Name)
					end
					isInGame = not table.find(Spectators, LocalPlayer.Name)
					wait(1)
				end
			end)

			-- Sprint helper
			task.spawn(function()
				while true do
					if isInGame and currentCharacter then
						pcall(function()
							currentCharacter.Humanoid:SetAttribute("BaseSpeed", 14)
							local barText = LocalPlayer.PlayerGui.TemporaryUI.PlayerInfo.Bars.Stamina.Amount.Text
							stamina = tonumber(string.split(barText, "/")[1])
							local isSprintingFOV = currentCharacter.FOVMultipliers.Sprinting.Value == 1.125
							if not isSprintingFOV and stamina >= 70 and not busy then
								VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
							end
						end)
					end
					wait(1)
				end
			end)

			-- Auto-hop
			task.spawn(function()
				wait(20 * 60)
				game:GetService("TeleportService"):Teleport(game.PlaceId)
			end)

			-- Main bot loop
			task.spawn(function()
				while true do
					if BotEnabled and isInGame then
						-- Find character
						for _, surv in ipairs(Workspace.Players.Survivors:GetChildren()) do
							if surv:GetAttribute("Username") == LocalPlayer.Name then
								currentCharacter = surv
								humanoid = currentCharacter:WaitForChild("Humanoid")
								break
							end
						end

						if not currentCharacter then wait(0.1) continue end

						-- Death check
						if currentCharacter.Humanoid.Health <= 0 then
							print("💀 You died.")
							isInGame = false
							busy = false
							wait(0.1)
							continue
						end

						-- All gens check
						local allGensComplete = true
						for _, gen in ipairs(game.ReplicatedStorage.ObjectiveStorage:GetChildren()) do
							if gen.Value ~= gen:GetAttribute("RequiredProgress") then
								allGensComplete = false
								break
							end
						end

						if allGensComplete then
							print("✅ All gens done — EVADING!")
							while #Workspace.Players.Killers:GetChildren() >= 1 do
								if not BotEnabled or not isInGame then break end
								for _, killer in ipairs(Workspace.Players.Killers:GetChildren()) do
									local dist = (killer.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
									if dist <= 100 then
										local evadeDir = (currentCharacter.HumanoidRootPart.Position - killer.HumanoidRootPart.Position).Unit * 100
										local goalPos = currentCharacter.HumanoidRootPart.Position + evadeDir
										TweenStraightTo(goalPos)
										wait(TWEEN_TIME + 0.2)
									end
								end
								wait(0.1)
							end
						else
							-- Repair generators
							for _, gen in ipairs(Workspace.Map.Ingame.Map:GetChildren()) do
								if not BotEnabled or not isInGame then break end
								if gen.Name == "Generator" and gen.Progress.Value ~= 100 then
									print("🔧 Flying straight to generator!")
									local goalPos = gen.Positions.Right.Position
									TweenStraightTo(goalPos)
									wait(TWEEN_TIME + 0.5)

									local prompt = gen.Main.Prompt
									if prompt then
										prompt.HoldDuration = 0
										prompt.RequiresLineOfSight = false
										prompt.MaxActivationDistance = 99999
										Workspace.Camera.CFrame = CFrame.new(201.610779, 64.460968, 1307.98096, 0.99840349, -0.0556023642, 0.00994364079, -1.31681965e-09, 0.176041901, 0.984382629, -0.0564845055, -0.982811034, 0.17576085)
										wait(0.1)
										busy = true
										while gen.Progress.Value ~= 100 and BotEnabled and isInGame do
											prompt:InputHoldBegin()
											prompt:InputHoldEnd()
											gen.Remotes.RE:FireServer()
											wait(2.5)
										end
										busy = false
										print("✅ Generator complete!")
									end
								end
							end
						end
					end
					wait(0.1)
				end
			end)
			BotEnabled = Value
			Rayfield:Notify({
				Title = "Tween Bot",
				Content = Value and "🔴 ACTIVE - Flying & repairing!" or "⚪ Disabled",
				Duration = 4
			})
		end,
	})

	FTab:CreateSlider({
		Name = "Tween Speed (lower = faster)",
		Range = {0.3, 3},
		Increment = 0.1,
		Suffix = "seconds",
		CurrentValue = 1.2,
		Callback = function(Value)
			TWEEN_TIME = Value
		end,
	})

	FTab:CreateSlider({
		Name = "Fix Gen Time",
		Range = {1, 10},
		Increment = 1,
		Suffix = "seconds",
		CurrentValue = 1,
		Callback = function(Value)
			genTime = Value
		end,
	})
end

--furry infection
if game.PlaceId == 15491631439 then
	local CTab = Window:CreateTab("Combat", "sprout")


	function isSpawned(player)
		if workspace:FindFirstChild(player.Name) and player.Character:FindFirstChild("HumanoidRootPart") then
			return true
		else
			return false
		end
	end

	CTab:CreateToggle({
		Name = "Punch Aura",
		CurrentValue = false,
		Callback = function(v)
			local Player = game.Players.LocalPlayer.Character
			local enabled = v -- Track toggle state
			task.spawn(function() -- Use task.spawn for cleaner loop
				while enabled do
					for _, v in pairs(game:GetService("Players"):GetPlayers()) do
						if v.Name ~= game:GetService("Players").LocalPlayer.Name and isSpawned(v) then
							if v.Character and v.Character.HumanoidRootPart and Player and Player.HumanoidRootPart then
								if (v.Character.HumanoidRootPart.Position - Player.HumanoidRootPart.Position).Magnitude <= 45 then
									local args = {
										[1] = v.Character.HumanoidRootPart,
										[2] = v.Character.Humanoid,
										[3] = v.Character.HumanoidRootPart.Position
									}
									game:GetService("Players").LocalPlayer.Character.Punch.Remote.Hit:FireServer(unpack(args))
								end
							end
						end
					end
					task.wait(0.05) -- task.wait is cleaner than wait()
				end
			end)
		end,
	})


end

--========================
-- Grow a Garden
--========================
if game.PlaceId == 126884695634066 then
    IsLoaded = true
    local GrowAGardenTab = Window:CreateTab("Grow A Garden", "sprout")
    local Label = GrowAGardenTab:CreateLabel("The scripts for GAG are still in progress so don't expect them to be good", 4483362458, Color3.fromRGB(0, 0, 0), false)
    local FarmTab = Window:CreateTab("GAG Auto Farm", "leaf")
    local TpTab = Window:CreateTab("GAG Teleport", "map-pin")
    local ScriptsTab = Window:CreateTab("GAG Scripts", "scroll")
    local QoLTab = Window:CreateTab("GAG QoL", "settings-2")

    -- ---------- shared utils ----------
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local function dist(a, b) return (a - b).Magnitude end

    local nameHints = {"Plant","Seed","Fruit","Coin","Gem","Harvest"}
    local function looksLikeTarget(inst)
        local n = inst.Name:lower()
        for _, hint in ipairs(nameHints) do
            if n:find(hint:lower()) then return true end
        end
        return false
    end

    local function getTargets()
        local found = {}
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("Model") then
                local hasPrompt = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                local hasClick = d:FindFirstChildWhichIsA("ClickDetector", true)
                if (hasPrompt or hasClick) and looksLikeTarget(d) then
                    local root
                    if d:IsA("BasePart") then
                        root = d
                    elseif d:IsA("Model") then
                        root = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                    end
                    if root then
                        table.insert(found, {root = root, prompt = hasPrompt, click = hasClick, inst = d})
                    end
                end
            end
        end
        return found
    end

    -- ---------- Auto Farm ----------
    local autoPrompt = false
    local autoClick = false
    local hopDelay = 0.2

    local function firePrompt(prompt)
        if not prompt or not prompt.Parent then return end
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, 3)
            else
                local old = prompt.HoldDuration
                prompt.HoldDuration = 0
                prompt:InputHoldBegin()
                task.wait()
                prompt:InputHoldEnd()
                prompt.HoldDuration = old
            end
        end)
    end

    local function fireClick(cd)
        if not cd or not cd.Parent then return end
        pcall(function()
            if fireclickdetector then
                fireclickdetector(cd)
            else
                local p = cd.Parent
                if p and p:IsA("BasePart") then
                    p:Activate()
                end
            end
        end)
    end

    local function tpTo(part)
        if character and character:FindFirstChild("HumanoidRootPart") and part then
            character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
        end
    end

    FarmTab:CreateToggle({
        Name = "Auto ProximityPrompt",
        CurrentValue = false,
        Callback = function(v)
            autoPrompt = v
            if not v then return end
            task.spawn(function()
                while autoPrompt do
                    local targets = getTargets()
                    table.sort(targets, function(a, b)
                        return dist(humanoidRootPart.Position, a.root.Position) < dist(humanoidRootPart.Position, b.root.Position)
                    end)
                    for _, t in ipairs(targets) do
                        if not autoPrompt then break end
                        if t.prompt then
                            if dist(humanoidRootPart.Position, t.root.Position) > 12 then
                                tpTo(t.root)
                            end
                            firePrompt(t.prompt)
                            task.wait(hopDelay)
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    })

    FarmTab:CreateToggle({
        Name = "Auto ClickDetector",
        CurrentValue = false,
        Callback = function(v)
            autoClick = v
            if not v then return end
            task.spawn(function()
                while autoClick do
                    local targets = getTargets()
                    table.sort(targets, function(a, b)
                        return dist(humanoidRootPart.Position, a.root.Position) < dist(humanoidRootPart.Position, b.root.Position)
                    end)
                    for _, t in ipairs(targets) do
                        if not autoClick then break end
                        if t.click then
                            if dist(humanoidRootPart.Position, t.root.Position) > 12 then
                                tpTo(t.root)
                            end
                            fireClick(t.click)
                            task.wait(hopDelay)
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    })

    FarmTab:CreateSlider({
        Name = "Hop Delay (s)",
        Range = {0, 2},
        Increment = 0.05,
        CurrentValue = hopDelay,
        Callback = function(v) hopDelay = v end
    })

    FarmTab:CreateButton({
        Name = "Collect Nearest Once",
        Callback = function()
            local targets = getTargets()
            if #targets == 0 then return end
            table.sort(targets, function(a, b)
                return dist(humanoidRootPart.Position, a.root.Position) < dist(humanoidRootPart.Position, b.root.Position)
            end)
            local t = targets[1]
            tpTo(t.root)
            if t.prompt then firePrompt(t.prompt) end
            if t.click then fireClick(t.click) end
        end
    })

    -- ---------- Teleport ----------
    local savedCFrame
    TpTab:CreateButton({ Name = "Save Current Spot", Callback = function() if humanoidRootPart then savedCFrame = humanoidRootPart.CFrame end end })
    TpTab:CreateButton({ Name = "Return to Saved Spot", Callback = function() if humanoidRootPart and savedCFrame then humanoidRootPart.CFrame = savedCFrame end end })
    TpTab:CreateButton({
        Name = "TP to Nearest Target",
        Callback = function()
            local targets = getTargets()
            if #targets == 0 then return end
            table.sort(targets, function(a, b)
                return dist(humanoidRootPart.Position, a.root.Position) < dist(humanoidRootPart.Position, b.root.Position)
            end)
            tpTo(targets[1].root)
        end
    })

    -- ---------- Extra Scripts ----------
    ScriptsTab:CreateButton({ Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
    ScriptsTab:CreateButton({ Name = "Dark Dex",       Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))() end })
    ScriptsTab:CreateButton({ Name = "Turtle Spy",     Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua"))() end })

    -- ---------- QoL ----------
    local player = game.Players.LocalPlayer
    local antiAfkConn
    QoLTab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Callback = function(v)
            if v then
                if antiAfkConn then antiAfkConn:Disconnect() end
                local vu = game:GetService("VirtualUser")
                antiAfkConn = player.Idled:Connect(function()
                    vu:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
                end)
                print("✅ Anti-AFK Enabled")
            else
                if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
                print("❌ Anti-AFK Disabled")
            end
        end
    })
end


--aniPhobia
if game.PlaceId == 6788434697 then
	local ITab = Window:CreateTab("Items", 4483362458)
	local GTab = Window:CreateTab("Guns", 4483362458)
	local TTab = Window:CreateTab("Teleports", 4483362458)

	TTab:CreateButton({
		Name = "Go to Town",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(2378, 245.499985, -2276, 1, 6.34618544e-08, 2.43703424e-14, -6.34618544e-08, 1, 7.39426582e-08, -1.96778036e-14, -7.39426582e-08, 1)
		end
	})

	TTab:CreateButton({
		Name = "Go to Church",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(2802, 115.682602, -3470, 1, 3.40310891e-08, 2.76172653e-14, -3.40310891e-08, 1, 1.21097045e-07, -2.3496201e-14, -1.21097045e-07, 1)
		end
	})

	TTab:CreateButton({
		Name = "Go to Garage",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(4710, 214.540283, -3484, 1, 2.03217994e-08, 3.6021638e-14, -2.03217994e-08, 1, 1.24064972e-08, -3.5769517e-14, -1.24064972e-08, 1)
		end
	})

	TTab:CreateButton({
		Name = "Go to Farm",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(-2834, 212.142242, -4971, 1, -5.18712291e-08, 3.32067713e-14, 5.18712291e-08, 1, -3.16683213e-08, -3.15640966e-14, 3.16683213e-08, 1)
		end
	})

	TTab:CreateButton({
		Name = "Go to Campgrounds",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(-3800.34106, 426.265503, 4505.33691, -0.871125758, 4.58007285e-08, -0.491059989, 3.73616054e-08, 1, 2.69907368e-08, 0.491059989, 5.16553555e-09, -0.871125758)
		end
	})

		TTab:CreateButton({
		Name = "Go to Spawn",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(5989.8623, 16.5, 1131.91492, -0.999985456, -7.90075561e-10, 0.00539668836, -9.20014509e-10, 1, -2.40750548e-08, -0.00539668836, -2.40796698e-08, -0.999985456)
		end
	})


		TTab:CreateButton({
		Name = "Go to Millitary base armory",
		Callback = function()
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(-6912.02783, 213.20488, -4375.43945, -0.187105536, -0.00651038671, -0.982318223, 0.000559974695, 0.999977171, -0.00673408248, 0.98233968, -0.00181005755, -0.187097624)
		end
	})

end






--========================
--MM2
--========================
if game.PlaceId == 142823291 then

    IsLoaded = true
    local AimbotTab = Window:CreateTab("MM2 Aimbot", 4483362458)

    local aimToggleKey   = Enum.KeyCode.E
    local forceFPKey     = Enum.KeyCode.F
    local togglePartKey  = Enum.KeyCode.Q
    local ignoreTeamKey  = Enum.KeyCode.T

    local circleFOV
    pcall(function()
        circleFOV = Drawing.new("Circle")
        circleFOV.Visible = true
        circleFOV.Color = Color3.fromRGB(255, 255, 255)
        circleFOV.Thickness = 2
        circleFOV.NumSides = 100
        circleFOV.Radius = circleRadius
    end)

    local aimbotToggle = AimbotTab:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = true,
        Flag = "AimbotEnabled",
        Callback = function(val) aimbotEnabled = val end,
    })

    local ForceFPSToggle = AimbotTab:CreateToggle({
        Name = "Force First Person (F)",
        CurrentValue = forceFirstPerson,
        Callback = function(v)
            forceFirstPerson = v
            LocalPlayer.CameraMode = v and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
        end,
    })

    local aimPartDropdown = AimbotTab:CreateDropdown({
        Name = "Aim Part",
        Options = {"Head", "HumanoidRootPart"},
        CurrentOption = "Head",
        Flag = "AimPart",
        Callback = function(opt) aimAtHead = (opt == "Head") end,
    })

    local smoothSlider = AimbotTab:CreateSlider({
        Name = "Smoothness",
        Range = {0, 1},
        Increment = 0.05,
        CurrentValue = 0.2,
        Flag = "Smoothness",
        Callback = function(val) smoothness = val end,
    })

    local switchKeybind = AimbotTab:CreateKeybind({
        Name = "Switch Aim Part",
        CurrentKeybind = "F",
        HoldToInteract = false,
        Flag = "SwitchKey",
        Callback = function()
            aimAtHead = not aimAtHead
            aimPartDropdown:Set(aimAtHead and "Head" or "HumanoidRootPart")
        end,
    })

    local toggleKeybind = AimbotTab:CreateKeybind({
        Name = "Toggle Aimbot",
        CurrentKeybind = "E",
        HoldToInteract = false,
        Flag = "ToggleKey",
        Callback = function()
            aimbotEnabled = not aimbotEnabled
            aimbotToggle:Set(aimbotEnabled)
        end,
    })

    -- Single aimbot loop w/ simple wall check
    local function IsVisible(part)
        if ignoreWalls then return true end
        local origin = Camera.CFrame.Position
        local direction = (part.Position - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        local result = workspace:Raycast(origin, direction, params)
        return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
    end

	RunService.RenderStepped:Connect(function()
		if circleFOV then circleFOV.Position = UserInputService:GetMouseLocation() end
		if not aimbotEnabled then return end

		local closest, closestDist = nil, circleRadius
		local mousePos = UserInputService:GetMouseLocation()

		for _, plr in ipairs(Players:GetPlayers()) do
			if IsValidTarget(plr) then
				local char = plr.Character
				local part = aimAtHead and char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
				if part then
					local vector, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
						if dist < closestDist and IsVisible(part) then
							closest = part
							closestDist = dist
						end
					end
				end
			end
		end

		if closest then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
		end
	end)
end


--idk prob (hell's garden)
if game.PlaceId == 138150927368356 then
    local TTab = Window:CreateTab("tp", "home")

    local function FindPart(modelName)
        local foundModel = nil
        for _, obj in pairs(game.Workspace.TreeFolder:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == modelName then
                print("Found:", obj:GetFullName())
                foundModel = obj
                break  -- Stop after first match
            end
        end

        if foundModel then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            local targetPart = foundModel.PrimaryPart or foundModel:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)  -- Slightly above to avoid getting stuck
                Rayfield:Notify({Title = "TP", Content = "Teleported to " .. modelName .. "!", Duration = 4})
            else
                Rayfield:Notify({Title = "TP", Content = "No valid part found in " .. modelName, Duration = 4})
            end
        else
            Rayfield:Notify({Title = "TP", Content = modelName .. " not found in TreeFolder!", Duration = 4})
        end
    end

    TTab:CreateButton({
        Name = "Armor chest",
        Callback = function()
            FindPart("Armor chest")
        end
    })

	    -- Add more buttons if you want
    -- Example:
    -- TTab:CreateButton({
    --     Name = "Another Item",
    --     Callback = function()
    --         FindPart("Another Item Name")
    --     end
    -- })
end


--beat gubby in his own home
if game.PlaceId == 111452220770252 then
	    TTab:CreateButton({
        Name = "op thing",
        Callback = function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")

			local NetworkingFolder = ReplicatedStorage:WaitForChild("Networking", 3)
			local ServerFolder = NetworkingFolder and NetworkingFolder:FindFirstChild("Server")
			local RemoteEventsFolder = ServerFolder and ServerFolder:FindFirstChild("RemoteEvents")
			local DamageFolder = RemoteEventsFolder and RemoteEventsFolder:FindFirstChild("DamageEvents")
			if not (NetworkingFolder and ServerFolder and RemoteEventsFolder and DamageFolder) then return end

			local TARGET_POS = Vector3.new(
				-0.8127598762512207,
				3.0275533199310303,
				0.008699118159711361
			)

			local remoteTemplates = {
				{name="PhysicsDamage", args={233.33, TARGET_POS}},
				{name="SlapDamage", args={TARGET_POS}},
				{name="FistDamage", args={TARGET_POS, 1955}},
				{name="PhysicsDamage", args={134.89, TARGET_POS}},
				{name="TaserDamage", args={TARGET_POS}},
				{name="JackhammerDamage", args={TARGET_POS}},
				{name="AirstrikeDamage", args={TARGET_POS, 3.6}},
				{name="FlamethrowerDamage", args={TARGET_POS}},
				{name="GrenadeDamage", args={TARGET_POS, 3.98}},
				{name="BaseballDamage", args={TARGET_POS, 40}},
				{name="BowlingBallDamage", args={TARGET_POS, 40}},
				{name="LandmineDamage", args={TARGET_POS, 1.54}},
				{name="EnvironmentFireDamage", args={TARGET_POS}},
				{name="JobApplicationDamage", args={TARGET_POS}},
				{name="BowlingBallDamage", args={TARGET_POS, 2.13}},
				{name="TimeBombDamage", args={TARGET_POS}},
				{name="MinigunDamage", args={TARGET_POS}},
				{name="RocketLauncherDamage", args={TARGET_POS}},
				{name="BurnDamage", args={TARGET_POS}},
				{name="SmiteDamage", args={TARGET_POS}},
				{name="EarthquakeDamage", args={TARGET_POS}},
				{name="VoidDamage", args={TARGET_POS}},
			}

			local remotes = {}
			for _, t in ipairs(remoteTemplates) do
				local r = DamageFolder:FindFirstChild(t.name)
				if r then
					table.insert(remotes, {inst = r, args = t.args})
				end
			end
			if #remotes == 0 then return end

			local NEVERLOSE = loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NEVERLOSE-UI-Nightly/main/source.lua"
			))()
			NEVERLOSE:Theme("dark")

			local Window = NEVERLOSE:AddWindow("Unknown", "Unknown")
			local Notification = NEVERLOSE:Notification()
			Notification.MaxNotifications = 6

			Window:AddTabLabel("Home")
			local MainTab = Window:AddTab("Main", "ads")

			local Section = MainTab:AddSection("Cash", "left")
			local SectionRight = MainTab:AddSection("AutoBuy", "right")

			local RATE = 50
			local running = false

			local runningBuy = false
			local buyDelay = 0.1

			local runningClaim = false
			local CLAIM_RATE = 100

			local OpenPresent = RemoteEventsFolder:WaitForChild("OpenPresent")
			local CLAIM_POS = vector.create(
				-2.083083391189575,
				3.327760934829712,
				-3.3822533396232757e-07
			)

			Section:AddToggle("Instant Cash", false, function(v)
				running = v
			end)

			Section:AddSlider("Cash spam/s", 1, 50, 50, function(v)
				RATE = math.clamp(math.floor(v), 1, 50)
			end)

			Section:AddToggle("Auto Claim Gift", false, function(v)
				runningClaim = v
				if v then
					Notification:Notify(
						"info",
						"Auto Claim Gift",
						"You will still receive gifts even without gift boxes on the map"
					)
				end
			end)

			SectionRight:AddToggle("Auto buy all tools", false, function(v)
				runningBuy = v
				if v then
					Notification:Notify(
						"info",
						"Notification",
						"Enable the auto buy all tools feature\nso it can make much more money\nfrom those tools"
					)
				end
			end)

			local PurchaseAction = RemoteEventsFolder:FindFirstChild("PurchaseAction")
			local toolNames = {
				"SlapHand","FistHand","BuzzSawTool","TaserTool","JackhammerTool",
				"AirstrikeTool","FlamethrowerTool","GrenadeWeapon","BaseballWeapon",
				"LandmineWeapon","MolotovWeapon","PaintballGunWeapon","JobApplicationWeapon",
				"BowlingBallWeapon","TimeBombWeapon","MinigunWeapon","RocketLauncherWeapon",
				"FireballMagic","SmiteMagic","EarthquakeMagic","GravityWellMagic",
			}

			task.spawn(function()
				while true do
					if running then
						local start = tick()
						for _, r in ipairs(remotes) do
							task.spawn(function()
								pcall(function()
									r.inst:FireServer(unpack(r.args))
								end)
							end)
						end
						local dt = tick() - start
						local waitTime = (1 / RATE) - dt
						task.wait(waitTime > 0 and waitTime or 0)
					else
						task.wait(0.12)
					end
				end
			end)

			task.spawn(function()
				while true do
					if runningBuy and PurchaseAction then
						for _, tool in ipairs(toolNames) do
							if not runningBuy then break end
							pcall(function()
								PurchaseAction:FireServer(tool)
							end)
							task.wait(buyDelay)
						end
					else
						task.wait(0.12)
					end
				end
			end)

			task.spawn(function()
				while true do
					if runningClaim then
						local start = tick()
						pcall(function()
							OpenPresent:FireServer(CLAIM_POS)
						end)
						local dt = tick() - start
						local waitTime = (1 / CLAIM_RATE) - dt
						task.wait(waitTime > 0 and waitTime or 0)
					else
						task.wait(0.12)
					end
				end
			end)

			NEVERLOSE:Init()

        end
    })
end

--kick the door
if game.PlaceId == 91095706097751 then
	TTab:CreateButton({
        Name = "op thing",
        Callback = function()
			local windUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

			local player = game:GetService("Players").LocalPlayer
			local rs = game:GetService("ReplicatedStorage")
			local pg = player:WaitForChild("PlayerGui")

			local stuff = {
				remotes = {
					["Escape"] = rs.Packages._Index["sleitnick_knit@1.5.1"].knit.Services.EscapeService.RF:FindFirstChild("Escape"),
					["KickDoor"] = {},
					["SkipIntro"] = rs:FindFirstChild("Remotes"):FindFirstChild("SkipIntro")
				},
				map = {
					["ExitHighlight"] = workspace:FindFirstChild("Exit"):FindFirstChild("Highlight"),
					["EscapeDoor"] = workspace:FindFirstChild("MainDoor"):FindFirstChild("Main"),
					["HideSpots"] = workspace:FindFirstChild("Hide"),
				},
				gui = {
					["KickText"] = pg:FindFirstChild("Main"):FindFirstChild("Kick"),
					["SkipIntroBtn"] = pg:FindFirstChild("Main"):FindFirstChild("SkipIntro")
				},
				cfg = {
					autoEscape = false,
					autoSkip = false,
					autoKick = false
				}
			}

			local window = windUI:CreateWindow({
				Title = "🚪KICK THE DOOR [⚡] script (totally not skid)",
				Icon = "cat",
				Author = "by k1llm3sixy",
				Folder = "tli",
			})

			window:OnDestroy(function()
				stuff.cfg.autoEscape = false
				stuff.cfg.autoSkip = false
				stuff.cfg.autoKick = false
			end)

			window:EditOpenButton({
				Title = "Open",
				Icon = "chevrons-left-right-ellipsis",
				CornerRadius = UDim.new(0,16),
				StrokeThickness = 2,
				Color = ColorSequence.new(
					Color3.fromHex("FF0F7B"),
					Color3.fromHex("F89B29")
				),
				OnlyMobile = false,
				Enabled = true,
				Draggable = true,
			})

			function addToggle(tab, title, desc, def, cb)
				tab:Toggle({
					Title = title,
					Desc = desc,
					Icon = "check",
					Default = def,
					Callback = cb
				})
			end

			local mainTab = window:Tab({ Title = "Main" })

			addToggle(mainTab, "Auto kick door", nil, false, function(state)
				stuff.cfg.autoKick = state
				kickDoor()
			end)
			addToggle(mainTab, "Auto skip intro", nil, false, function(state)
				stuff.cfg.autoSkip = state
				skipIntro()
			end)
			addToggle(mainTab, "Auto escape", nil, false, function(state)
				stuff.cfg.autoEscape = state
				escape()
			end)

			function kickDoor()
				local tool = player.Backpack:FindFirstChild("Kick") or player.Character:FindFirstChild("Kick")
				stuff.remotes.KickDoor = tool and tool:FindFirstChild("Hitbox")

				if stuff.gui.KickText.Text ~= "KICKS: 40/40" and stuff.cfg.autoKick then
					task.wait(2.1)
					stuff.remotes.KickDoor:FireServer(stuff.map.EscapeDoor)
				end
			end

			function escape()
				if stuff.map.ExitHighlight.Enabled and stuff.cfg.autoEscape then
					stuff.remotes.Escape:InvokeServer("Exit")
				end
			end

			function skipIntro()
				if stuff.gui.SkipIntroBtn.Visible and stuff.cfg.autoSkip then
					stuff.remotes.SkipIntro:FireServer()
				end
			end

			function fastHide()
				for _, spot in pairs(stuff.map.HideSpots:GetChildren()) do
					local prompt = spot:FindFirstChild("Prompt")
					if prompt then
						prompt.HoldDuration = 0
						prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
							prompt.HoldDuration = 0
						end)
					end
				end
			end

			task.spawn(fastHide)

			stuff.map.ExitHighlight:GetPropertyChangedSignal("Enabled"):Connect(escape)
			stuff.gui.KickText:GetPropertyChangedSignal("Text"):Connect(kickDoor)
			stuff.gui.SkipIntroBtn:GetPropertyChangedSignal("Visible"):Connect(skipIntro)
        end
    })
end


--zombie ressistance
if game.PlaceId == 12500497961 then
	local CTab = Window:CreateTab("Codes", "home")
	local BTab = Window:CreateTab("Base", "home")
	CTab:CreateButton({
	Name = "Redem Current Codes",
	Callback = function()
		game:GetService("ReplicatedStorage").Remotes.Codes.RedeemCode:InvokeServer("Prestige4")
		game:GetService("ReplicatedStorage").Remotes.Codes.RedeemCode:InvokeServer("150k")
		game:GetService("ReplicatedStorage").Remotes.Codes.RedeemCode:InvokeServer("zombie")
	end,
	})

	BTab:CreateButton({
		Name = "Go Back to Base",
		Callback = function()
			game:GetService("ReplicatedStorage").Remotes.Misc.TeleportToBase:FireServer()
		end,
	})

	BTab:CreateButton({
		Name = "Get Survivors",
		Callback = function()
			local sur = workspace.Survivors
			local plr = game.Players.LocalPlayer
			local char = plr.Character or plr.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")

			-- Save original position
			local saved = hrp.CFrame

			for _, model in pairs(sur:GetChildren()) do
				if model:IsA("Model") then
					local root = model:FindFirstChild("HumanoidRootPart")
					if root then
						hrp.CFrame = root.CFrame
						task.wait(0.2)
					end
				end
			end

			-- Teleport back to where you started
			hrp.CFrame = saved

		end,
	})	
end

--ban or get banned
if game.PlaceId == 96017656548489 then
	local MTab = Window:CreateTab("Money", "home")
	MTab:CreateButton({
		Name = "Inf money(you get tp back to spawn after it collects)",
		Callback = function()
			local Players = game:GetService("Players")
			local player = Players.LocalPlayer

			local function getHRP()
				local char = player.Character or player.CharacterAdded:Wait()
				return char:WaitForChild("HumanoidRootPart")
			end

			local hrp = getHRP()
			local buttonFolder = workspace.ButtonsMoney
			local buttonParts = {}

			-- Collect all button parts
			for _, model in pairs(buttonFolder:GetDescendants()) do
				if model:IsA("Model") then
					local mainPart = model:FindFirstChild("Main")
					if mainPart and mainPart:IsA("BasePart") then
						table.insert(buttonParts, mainPart)
						mainPart.Transparency = 1 -- Make invisible once
					end
				end
			end

			-- Main loop: touch all buttons repeatedly
			while task.wait(0.1) do
				-- Refresh HRP if character respawned
				if not hrp or not hrp.Parent then
					hrp = getHRP()
				end

				for _, buttonPart in ipairs(buttonParts) do
					firetouchinterest(hrp, buttonPart, 0) -- touch begin
					firetouchinterest(hrp, buttonPart, 1) -- touch end
				end
			end

		end,
	})
end

if game.PlaceId == 74407860720916 then
	local ATab = Window:CreateTab("Auto", "home")

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")

	local player = Players.LocalPlayer
	local tapCubeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("TapCube")

	local tappingEnabled = false
	local connection

	-- Function to start the loop
	local function startTapping()
		if connection then return end
		connection = RunService.RenderStepped:Connect(function()
			if tapCubeEvent and tappingEnabled then
				tapCubeEvent:FireServer()
			end
		end)
	end

	-- Function to stop the loop
	local function stopTapping()
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end

	ATab:CreateToggle({
	Name = "Auto Tap Cube",
	CurrentValue = false,
	Callback = function(val)
		tappingEnabled = val
		if tappingEnabled then
			startTapping()
		else
			stopTapping()
		end
	end
	})

end

--tds lobby
if game.PlaceId == 3260590327 then
	local TTab = Window:CreateTab("troll", "home")

	-- FIXED Party Invite Spammer (Fully Working - No Freezes!)
	local InviteTypes = {"Annoying troll", "normal inv everyone", "slow but annoying", "slow but normal"}

	TTab:CreateDropdown({
		Name = "Invite Type",
		Options = InviteTypes,  -- Fixed: populate options
		CurrentOption = {"Annoying troll"},
		MultipleOption = false,  -- Fixed: correct param name
		Flag = "InviteType",
		Callback = function(selected)
			inviteType = selected[1]  -- Store current type
			print("Invite type set to: " .. inviteType)
		end
	})

	local inviteType = "Annoying troll"  -- Default
	local invitingEnabled = false
	local inviteConn = nil

	-- Invite functions (spawned coroutines)
	local function inviteAnnoying()
		local plrs = game:GetService("Players")
		local rfunc = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
		while invitingEnabled do
			rfunc:InvokeServer("Party", "CreateParty")
			for _, plr in ipairs(plrs:GetPlayers()) do
				if plr ~= plrs.LocalPlayer then
					rfunc:InvokeServer("Party", "InvitePlayer", plr)
				end
			end
			rfunc:InvokeServer("Party", "LeaveParty")
			task.wait()  -- Fixed: task.wait (fast spam)
		end
	end

	local function inviteNormal()
		local plrs = game:GetService("Players")
		local rfunc = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
		while invitingEnabled do
			for _, plr in ipairs(plrs:GetPlayers()) do
				if plr ~= plrs.LocalPlayer then
					rfunc:InvokeServer("Party", "InvitePlayer", plr)
				end
			end
			task.wait()
		end
	end

	local function inviteSlowAnnoy()
		local plrs = game:GetService("Players")
		local rfunc = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
		while invitingEnabled do
			rfunc:InvokeServer("Party", "CreateParty")
			for _, plr in ipairs(plrs:GetPlayers()) do
				if plr ~= plrs.LocalPlayer then
					rfunc:InvokeServer("Party", "InvitePlayer", plr)
				end
			end
			rfunc:InvokeServer("Party", "LeaveParty")
			task.wait(3)
		end
	end

	local function inviteSlowNorm()
		local plrs = game:GetService("Players")
		local rfunc = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
		while invitingEnabled do
			for _, plr in ipairs(plrs:GetPlayers()) do
				if plr ~= plrs.LocalPlayer then
					rfunc:InvokeServer("Party", "InvitePlayer", plr)
				end
			end
			task.wait(3)
		end
	end

	-- Start/Stop logic
	local function startInviting()
		if inviteConn then return end  -- Already running
		invitingEnabled = true

		task.spawn(function()
			if inviteType == "Annoying troll" then
				inviteAnnoying()
			elseif inviteType == "normal inv everyone" then
				inviteNormal()
			elseif inviteType == "slow but annoying" then
				inviteSlowAnnoy()
			elseif inviteType == "slow but normal" then
				inviteSlowNorm()
			end
		end)

		print("✅ Invite spam STARTED (" .. inviteType .. ")")
	end

	local function stopInviting()
		invitingEnabled = false
		if inviteConn then
			inviteConn:Disconnect()
			inviteConn = nil
		end
		print("⏹️ Invite spam STOPPED")
	end

	-- Toggle (fixed logic)
	TTab:CreateToggle({  -- Assuming TTab is your tab
		Name = "Invite Spam",
		CurrentValue = false,
		Flag = "InviteToggle",
		Callback = function(enabled)
			if enabled then
				startInviting()
			else
				stopInviting()
			end
		end
	})

	else if game.PlaceId == 5591597781 then
		local AHTab = Window:CreateTab("Auto - Hardcore", "home")
		local APTab = Window:CreateTab("Auto - PVP", "home")
		local ASTab = Window:CreateTab("Auto - Survival", "home")
		local ASPECIALTab = Window:CreateTab("Auto - Special Modes", "home")

		function load(link)
			local success, err = pcall(function()
				loadstring(game:HttpGet(link))()
			end)
			if not success then
				warn("Failed to load script: " .. err)
			end
		end

		ASTab:CreateSection("Easy Farm")

		ASTab:CreateButton({
			Name = "Simplicity farm",
			Callback = function()
				load("https://pastefy.app/gUZwXGQQ/raw")
			end,
		})

		ASTab:CreateSection("Casual Farm")

	end
end

--Knock knock
if game.PlaceId == 94177325451296 then
	local ATab = Window:CreateTab("ESP", "eye")

	local killers = {
		"Bear",
		"Cartoon Cat",
		"Clown",
		"Crawler",
		"Crying Guy",
		"Elf",
		"Happy Boy",
		"Jeff The Killer",
		"Mimic",
		"Old Guy",
		"Rake",
		"Rat",
		"Stalker",
		"Tall",
		"Angel",
		"Bunny",
		"Ghostface",
		"Guest 666",
		"Intruder",
		"Little Boy",
		"Nun",
		"Gilbert",
		"Happy Boy",
		"Mannequin",
		"Maternal Wraith",
		"Pigskin",
		"Sirenhead",
		"Slenderman",
		"Soup",
		"Spider"
	}

	local function isKiller(name)
		for i = 1, #killers do
			if string:GetFullName(name, killers[i]) then
				return true
			end
		end
	end

	local function addESP(v)
		if not v:FindFirstChild("esp") then
			local esp = Instance.new("Highlight")
			esp.Name = "esp"
			esp.Parent = v
		end
	end

	-- 🔹 Run ONCE
	for _, v in ipairs(workspace:GetDescendants()) do
		if isKiller(v.Name) then
			addESP(v)
		end
	end

	-- 🔹 Only run when new things appear
	workspace.DescendantAdded:Connect(function(v)
		if isKiller(v.Name) then
			addESP(v)
		end
	end)
end

--you vs david
if game.PlaceId == 104744437428142 then
	local ATab = Window:CreateTab("Useful stuff", "eye")
	ATab:CreateToggle({
		Name = "Esp",
		CurrentValue = fovLocked,
		Callback = function()
			local gameEnv = getfenv()
			local getService = gameEnv.game.getService
			local Workspace = getService(gameEnv.game, "Workspace")

			local PlayersInGame = Workspace:WaitForChild("PlayersInGame")

			local function updateModel(target)
				if not target:IsA("Model") then 
					return 
				end

				local highlight = target:FindFirstChild("StatusHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "StatusHighlight"
					highlight.Parent = target
				end

				local david = target:FindFirstChild("David")

				if david and david:IsA("BoolValue") then
					highlight.FillColor = Color3.fromRGB(255, 0, 0)
					highlight.OutlineColor = Color3.new(0, 0, 0)
				else
					highlight.FillColor = Color3.fromRGB(0, 255, 0)
					highlight.OutlineColor = Color3.new(1, 1, 1)
				end
			end

			local function setupModel(object)
				if not object:IsA("Model") then 
					return 
				end

				updateModel(object)

				object.ChildAdded:Connect(function()
					updateModel(object)
				end)

				object.ChildRemoved:Connect(function()
					updateModel(object)
				end)
			end

			PlayersInGame.ChildAdded:Connect(setupModel)

			for _, child in pairs(PlayersInGame:GetChildren()) do
				task.spawn(setupModel, child)
			end
		end
	})
end


-- dive for brainrots
if game.PlaceId == 113303333910928 then
	local TTab = Window:CreateTab("TP", 4483362458) -- Title, Image
	TTab:CreateButton({
	Name = "Go to OG Spot",
	Callback = function()
			local player = game.Players.LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")

			hrp.CFrame = CFrame.new(
				4.14027882, 6747.87939, 3369.63135
			)
	end,
	})

	TTab:CreateButton({
	Name = "Go to Spawn",
	Callback = function()
			local player = game.Players.LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")

			hrp.CFrame = CFrame.new(
				7.04930353, 7616.51953, -14.4627686
			)
	end,
	})
end

--escaoe rising lava for brainrots
if game.PlaceId == 137723497878181 then 
	local GTab = Window:CreateTab("Get Brainrots", 4483362458) -- Title, Image
	GTab:CreateButton({
	Name = "Get zone 9 brainrot(if doesnt do anything then there isnt any)",
	Callback = function()
		local player = game.Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local save = hrp.CFrame  -- save current position

		local z9 = workspace:WaitForChild("Brainrots"):WaitForChild("Zone9")

		for _, model in ipairs(z9:GetChildren()) do
			if model:IsA("Model") then
				
				-- Teleport to model
				hrp.CFrame = model:GetPivot()
				task.wait(0.3)

				for _, obj in ipairs(model:GetDescendants()) do
					if obj:IsA("ProximityPrompt") then
						obj.HoldDuration = 0
						obj.MaxActivationDistance = math.huge
						
						pcall(function()
							fireproximityprompt(obj)
						end)
						
						-- Return to original position
						hrp.CFrame = save  -- just use the saved CFrame directly

						task.wait(0.2)

						
					end
				end
			end
		end
	end,
	})
end


--Escape Tsunami for Stranger Things
if game.PlaceId == 88003968263990 then 
	local GTab = Window:CreateTab("Get thing", 4483362458) -- Title, Image
	GTab:CreateButton({
	Name = "tp to last zone",
	Callback = function()
		local plr = game.Players.LocalPlayer
		local char = plr.Character or plr:WaitForChild("Character")
		local hrp = char:WaitForChild("HumanoidRootPart")

		hrp.CFrame = CFrame.new(-3896.41675, 53.998024, -2864.86841, -0.851649463, -2.79699055e-08, -0.524111807, 1.61913292e-08, 1, -7.96762123e-08, 0.524111807, -7.63422676e-08, -0.851649463)
	end,
	})
end

--fight your zombie
if game.PlaceId == 92683694220101 then
	local ATab = Window:CreateTab("Auto", 4483362458) -- Title, Image

	local AutoCollect = false

	ATab:CreateToggle({
		Name = "Auto Collect Orbs",
		CurrentValue = false,
		Callback = function(Value)
			AutoCollect = Value
			
			if AutoCollect then
				local coinFolder = workspace:WaitForChild("Orbs")
				local player = game.Players.LocalPlayer
				task.spawn(function()
					while AutoCollect do
						local char = player.Character or player.CharacterAdded:Wait()
						local hrp = char:WaitForChild("HumanoidRootPart")
						
						for _, v in ipairs(coinFolder:GetChildren()) do
							if v:IsA("BasePart") then
								v.CFrame = hrp.CFrame
							end
						end
						
						task.wait()
					end
				end)
			end
		end,
	})

	local AutoFight = false

	ATab:CreateToggle({
		Name = "Auto Fight",
		CurrentValue = false,
		Callback = function(Value)
			AutoFight = Value
			
			if AutoFight then
				task.spawn(function()
					local attack = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AxeSwing")
					
					while AutoFight do
						attack:FireServer()
						task.wait(0.1) -- small delay to avoid spam detection
					end
				end)
			end
		end,
	})

	local AutoLuckyBlock = false

	ATab:CreateToggle({
		Name = "Auto Collect Lucky Block",
		CurrentValue = false,
		Callback = function(Value)
			AutoLuckyBlock = Value

			local folder = workspace:WaitForChild("Debris")
			local player = game.Players.LocalPlayer
			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			
			if AutoLuckyBlock then
				task.spawn(function()
					for _, model in ipairs(folder:GetChildren()) do
						if model:IsA("Model") then
							
							-- teleport to model
							hrp.CFrame = model:GetPivot()
							task.wait(0.3)

							-- search inside model
							for _, obj in ipairs(model:GetDescendants()) do
								if obj:IsA("ProximityPrompt") then
									pcall(function()
									wait(2)
										obj.HoldDuration = 0
										fireproximityprompt(obj)
									end)
									task.wait(0.2)
								end
							end
						end
					end
					task.wait()
				end)
			end
		end,
	})
end

--escape disasters for brainrots
if game.PlaceId == 83903557857049 then
	local ATab = Window:CreateTab("Get Brainrots", 4483362458)

	ATab:CreateButton({
		Name = "Delete Disaster",
		Callback = function()
			local disaster = workspace.ActiveDisaster

			for i, v in ipairs(disaster:GetChildren()) do
				v:Destroy()	
			end
		end,
	})

	ATab:CreateButton({
		Name = "Get All Brainrots",
		Callback = function()
			local active = workspace:WaitForChild("ActiveBrainrots")

			local plr = game.Players.LocalPlayer
			local char = plr.Character or plr.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")

			local save = hrp.CFrame

			for _, v in ipairs(active:GetChildren()) do
				if v:IsA("Model") then
					
					-- Go to brainrot
					hrp.CFrame = v:GetPivot()
					task.wait(0.3)

					-- Find proximity prompts inside the model
					for _, k in ipairs(v:GetDescendants()) do
						if k:IsA("ProximityPrompt") then
							k.HoldDuration = 0
							fireproximityprompt(k)
							task.wait(0.2)
						end
					end
					
					task.wait(.5)

					-- Return to saved position
					hrp.CFrame = save
					task.wait(0.3)
				end
			end
		end,
	})
end

--Dandy's World Lobby
if game.PlaceId == 16116270224 then
	local MTab = Window:CreateTab("Main", 4483362458)

	MTab:CreateButton({
	Name = "Redeem All Codes",
	Callback = function()
			local Code = game:GetService("ReplicatedStorage").Events.CodeEvent

			local args = {
				"ICHOR",
				"ONETHOUSAND",
				"TENMILLION",
				"FIFTYMILLION",
				"HUNDREDMILLION",
				"2HUNDREDMILLION",
				"SKINTICKET",
				"300K",
				"EASTER2025",
				"1BILLION",
				"FESTIVEGIFT",
				"HAPPYHALLOWEEN",
				"SPOOKYSEASON",
				"APRIL1",

			}

			if Code then
				Code:FireServer(unpack(args))
			end
	end,
	})

end


--dandy's world
if game.PlaceId ==  16552821455 then
	local ETab = Window:CreateTab("Visual", 4483362458)
	local MTab = Window:CreateTab("Main", 4483362458)
	local currentroomFolder = workspace.CurrentRoom
	local currentRoom = currentroomFolder:GetChildren() 


	-- ====================
	-- Player ESP (dynamic for new players joining mid-game)
	-- ====================
	local PESP_ENABLED = false
	local playerESPConnection

	ETab:CreateToggle({
		Name = "Player ESP",
		CurrentValue = false,
		Flag = "ToggleESP",
		Callback = function(Value)
			PESP_ENABLED = Value
			
			-- Disconnect old connection if exists
			if playerESPConnection then
				playerESPConnection:Disconnect()
				playerESPConnection = nil
			end
			
			if Value then
				-- Initial apply to current players
				for _, playerModel in ipairs(workspace.InGamePlayers:GetChildren()) do
					if not playerModel:FindFirstChild("esp") then
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = playerModel
						hl.FillColor       = Color3.fromRGB(0, 100, 255)
						hl.OutlineColor    = Color3.fromRGB(180, 180, 255)
						hl.FillTransparency   = 0.4
						hl.OutlineTransparency = 0.15
						hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end
				
				-- Dynamic: new players/models added
				playerESPConnection = workspace.InGamePlayers.ChildAdded:Connect(function(newPlayerModel)
					if PESP_ENABLED and not newPlayerModel:FindFirstChild("esp") then
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = newPlayerModel
						hl.FillColor       = Color3.fromRGB(0, 100, 255)
						hl.OutlineColor    = Color3.fromRGB(180, 180, 255)
						hl.FillTransparency   = 0.4
						hl.OutlineTransparency = 0.15
						hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end)
			else
				-- OFF: clean up all existing
				for _, playerModel in ipairs(workspace.InGamePlayers:GetChildren()) do
					local existing = playerModel:FindFirstChild("esp")
					if existing then
						existing:Destroy()
					end
				end
			end
		end
	})

	-- ====================
	-- Monster/Twisted ESP (dynamic for new spawns)
	-- ====================
	local MESP_ENABLED = false
	local monsterESPConnection

	ETab:CreateToggle({
		Name = "Monster ESP",
		CurrentValue = false,
		Flag = "ToggleMESP",
		Callback = function(Value)
			MESP_ENABLED = Value
			
			if monsterESPConnection then
				monsterESPConnection:Disconnect()
				monsterESPConnection = nil
			end
			
			local function applyESPToMonsters()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") 
						and (obj.Name:find("Twisted") or obj.Name:find("Monster") or obj.Name:find("Entity"))
						and not obj:FindFirstChild("esp") then
						
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = obj
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineColor = Color3.fromRGB(255, 80, 80)
						hl.FillTransparency = 0.35
						hl.OutlineTransparency = 0.1
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end
			end
			
			if Value then
				applyESPToMonsters()
				
				-- Dynamic: new monsters added anywhere in workspace
				monsterESPConnection = workspace.DescendantAdded:Connect(function(newObj)
					if MESP_ENABLED and newObj:IsA("Model") 
						and (newObj.Name:find("Twisted") or newObj.Name:find("Monster") or newObj.Name:find("Entity"))
						and not newObj:FindFirstChild("esp") then
						
						task.wait(0.1)  -- small delay for model to load fully
						
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = newObj
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineColor = Color3.fromRGB(255, 80, 80)
						hl.FillTransparency = 0.35
						hl.OutlineTransparency = 0.1
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end)
			else
				-- OFF: remove all
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") 
						and (obj.Name:find("Twisted") or obj.Name:find("Monster") or obj.Name:find("Entity")) then
						
						local existing = obj:FindFirstChild("esp")
						if existing then
							existing:Destroy()
						end
					end
				end
			end
		end
	})

	-- ====================
	-- Item ESP (dynamic for new items)
	-- ====================
	local IESP_ENABLED = false
	local itemESPConnection

	ETab:CreateToggle({
		Name = "Item ESP",
		CurrentValue = false,
		Flag = "ToggleIESP",
		Callback = function(Value)

			IESP_ENABLED = Value

			if itemESPConnection then
				itemESPConnection:Disconnect()
				itemESPConnection = nil
			end

			local function createESP(v)
				if not v:IsA("Model") or v:FindFirstChild("esp") then return end
				
				local hl = Instance.new("Highlight")
				hl.Name = "esp"
				hl.Parent = v
				hl.FillColor = Color3.fromRGB(0,255,0)
				hl.OutlineColor = Color3.fromRGB(100,255,100)
				hl.FillTransparency = 0.4
				hl.OutlineTransparency = 0.2
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				
				local part = v:FindFirstChildWhichIsA("BasePart")
				if part then
					local billboard = Instance.new("BillboardGui")
					billboard.Name = "espLabel"
					billboard.Parent = v
					billboard.Adornee = part
					billboard.Size = UDim2.new(0,200,0,50)
					billboard.StudsOffset = Vector3.new(0,1.5,0)
					billboard.AlwaysOnTop = true
					
					local text = Instance.new("TextLabel")
					text.Size = UDim2.new(1,0,1,0)
					text.BackgroundTransparency = 1
					text.Text = v.Name
					text.TextScaled = false
					text.TextSize = 32
					text.TextColor3 = Color3.fromRGB(0,255,0)
					text.Font = Enum.Font.SourceSansBold
					text.Parent = billboard
					
					local textOutline = Instance.new("UIStroke")
					textOutline.Parent = text
					textOutline.Color = Color3.fromRGB(0,0,0)
					textOutline.Thickness = 2
				end
			end

			local function applyItemESP()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Folder") and obj.Name:find("Items") then
						for _, v in ipairs(obj:GetChildren()) do
							createESP(v)
						end
					end
				end
			end

			local function removeItemESP()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Folder") and obj.Name:find("Items") then
						for _, v in ipairs(obj:GetChildren()) do
							
							local esp = v:FindFirstChild("esp")
							if esp then esp:Destroy() end
							
							local label = v:FindFirstChild("espLabel")
							if label then label:Destroy() end
							
						end
					end
				end
			end

			if Value then
				applyItemESP()

				itemESPConnection = workspace.DescendantAdded:Connect(function(newObj)
					if IESP_ENABLED then
						task.wait(0.1)
						
						local folder = newObj:FindFirstAncestorWhichIsA("Folder")
						if folder and folder.Name:find("Items") then
							createESP(newObj)
						end
					end
				end)
			else
				removeItemESP()
			end

		end
	})


	-- ====================
	-- Generator ESP (for the Ichor extraction machines)
	-- ====================
	local GESP_ENABLED = false
	local generatorESPConnection

	ETab:CreateToggle({
		Name = "Generator ESP",
		CurrentValue = false,
		Flag = "ToggleGESP",  -- unique flag
		Callback = function(Value)
			GESP_ENABLED = Value
			
			-- Disconnect old connection if exists
			if generatorESPConnection then
				generatorESPConnection:Disconnect()
				generatorESPConnection = nil
			end
			
			local function applyGeneratorESP()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") 
						and obj.Name:find("Generator") or obj.Name:find("Extractor")  -- common names; adjust if needed 
						and not obj:FindFirstChild("esp") then
						
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = obj
						hl.FillColor = Color3.fromRGB(0, 200, 255)          -- cyan/teal for objectives/machines
						hl.OutlineColor = Color3.fromRGB(100, 255, 255)     -- brighter cyan outline
						hl.FillTransparency = 0.4
						hl.OutlineTransparency = 0.15
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end
			end
			
			local function removeGeneratorESP()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("Model") 
						and obj.Name:find("Generator") or obj.Name:find("Extractor") then
						
						local existing = obj:FindFirstChild("esp")
						if existing then
							existing:Destroy()
						end
					end
				end
			end
			
			if Value then
				-- ON: Apply to all current generators/machines
				applyGeneratorESP()
				
				-- Dynamic: Highlight new machines as they appear (rare but possible in updates/events)
				generatorESPConnection = workspace.DescendantAdded:Connect(function(newObj)
					if GESP_ENABLED and newObj:IsA("Model") 
						and (newObj.Name:find("Machine") or newObj.Name:find("Generator") or newObj.Name:find("Extractor"))
						and not newObj:FindFirstChild("esp") then
						
						task.wait(0.1)  -- small delay for model to load
						
						local hl = Instance.new("Highlight")
						hl.Name = "esp"
						hl.Parent = newObj
						hl.FillColor = Color3.fromRGB(0, 200, 255)
						hl.OutlineColor = Color3.fromRGB(100, 255, 255)
						hl.FillTransparency = 0.4
						hl.OutlineTransparency = 0.15
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					end
				end)
			else
				-- OFF: Clean up all generator ESP
				removeGeneratorESP()
			end
		end
	})

	local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local menu = playerGui.ScreenGui.Menu

ETab:CreateButton({
    Name = "Delete Skill Check",
    Callback = function()

        local skillcheck = {
            SkillFrame = menu.SkillCheckFrame,
            SkillMessage = menu.SkillCheckMessage,
            Calibration = menu.Calibrate
        }

        for _, object in pairs(skillcheck) do
            if object then
                object:Destroy()
            end
        end

    end,
})

	MTab:CreateButton({
	Name = "Delete Anti Cheat (most of it)",
	Callback = function()
			local AC = game:GetService("ReplicatedStorage").Events.AntiCheatTrigger

			if AC then
				AC:Destroy()
			end
	end,
	})
end

-- if game.PlaceId == 114640202062357 then


-- 	local GTab = Window:CreateTab("Get thing", 4483362458) -- Title, Image
-- 	GTab:CreateButton({
-- 		Name = "tp to last zone",
-- 		Callback = function()
-- 			local plr = game.Players.LocalPlayer
-- 			local char = plr.Character or plr:WaitForChild("Character")
-- 			local hrp = char:WaitForChild("HumanoidRootPart")
-- 			hrp.CFrame = CFrame.new(
-- 			26.8123493, -9.81965446, -15706.9209,
-- 			0.389285624, 6.44679901e-08, 0.921117127,
-- 			5.79820565e-08, 1, -9.44934939e-08,
-- 			-0.921117127, 9.01932253e-08, 0.389285624
-- 		)
-- 		end,
-- 	})
-- end

--1 kill = 1 armor
if game.PlaceId == 132547252102193 then
	local CTab = Window:CreateTab("Combat", 4483362458)
	local Players = game:GetService("Players")
	local rs = game:GetService("ReplicatedStorage")

	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local event = rs:WaitForChild("Packages"):WaitForChild("Knit")
		:WaitForChild("Services"):WaitForChild("CombatService")
		:WaitForChild("RE"):WaitForChild("OnDamageDealt")

	local plrs = workspace.GameObjects.Players
	local bots = workspace.GameObjects.Bots

	local AURA = false

	-- Get closest enemy
	local function getEnemy()
		local closest = nil
		local shortestDist = math.huge

		for _, v in pairs(plrs:GetChildren()) do
			if v ~= char and v:FindFirstChild("HumanoidRootPart") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closest = v
				end
			end
		end

		for _, v in pairs(bots:GetChildren()) do
			if v:FindFirstChild("HumanoidRootPart") then
				local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closest = v
				end
			end
		end

		return closest, shortestDist
	end

	-- Loop
	task.spawn(function()
		while task.wait(0.2) do
			if AURA then
				local enemy, dist = getEnemy()

				if enemy and dist <= 200 then
					local args = {
						[1] = enemy,
						[2] = 10 -- damage (you can change this)
					}

					event:FireServer(unpack(args))
				end
			end
		end
	end)

	-- Rayfield Toggle
	CTab:CreateToggle({
		Name = "Damage Aura",
		CurrentValue = false,
		Flag = "DamageAura",
		Callback = function(Value)
			AURA = Value
		end,
	})

	local rs = game:GetService("ReplicatedStorage")
	local acFolder = rs:WaitForChild("AntiCheatExploit")
	local knit = rs:WaitForChild("Packages")
	if acFolder then
		acFolder:Destroy()
	end
	if knit and knit:WaitForChild("Knit") then
		local services = knit.Knit:WaitForChild("Services")
		if services then
			local acService = services:WaitForChild("AntiCheatService")
			if acService then
				acService:Destroy()
			end
		end
	end
end

--scary sushi
if game.PlaceId == 16454414227 then
	local TTab = Window:CreateTab("Teleports", 4483362458)

	local Players = game:GetService("Players")
	local plr = Players.LocalPlayer

	local spawns = game.Workspace:WaitForChild("Kitchen"):WaitForChild("WorkstationSpawns")

	local targetSpawn = nil
	local connections = {}

	local function getCharacter()
		return plr.Character or plr.CharacterAdded:Wait()
	end

	-- 🔄 Toggle: allow reselection or not
	local allowReselect = false

	

	TTab:CreateButton({
		Name = "Teleport to Workstation (touch workstation)",
		Callback = function()
			-- 🧹 Cleanup old connections (prevents duplicates if script re-runs)
			for _, conn in pairs(connections) do
				conn:Disconnect()
			end
			table.clear(connections)

			-- 👆 Detect touch
			for i = 1, 8 do
				local spawnPart = spawns:FindFirstChild("Workstation" .. i)
				if spawnPart then
					local conn = spawnPart.Touched:Connect(function(hit)
						local character = getCharacter()
						if hit.Parent ~= character then return end

						if targetSpawn and not allowReselect then return end

						targetSpawn = spawnPart
						print("Selected Spawn:", spawnPart.Name)
					end)

					table.insert(connections, conn)
				end
			end


			local character = getCharacter()
			local hrp = character:FindFirstChild("HumanoidRootPart")

			if not targetSpawn then
				warn("No spawn selected!")
				return
			end

			if not hrp then
				warn("No HumanoidRootPart!")
				return
			end

			-- 📍 Teleport slightly above to avoid getting stuck
			hrp.CFrame = targetSpawn.CFrame + Vector3.new(0, 3, 0)
		end,
	})
end


--seeker vs hider
if game.PlaceId == 18336470541 then

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera

	-- SETTINGS
	local espEnabled = false
	local tracersEnabled = false
	local boxesEnabled = false
	local espMode = "ESP"

	-- SAFE WEAPONS
	local SAFE_WEAPONS = {
		"usp","glock","p2000","p250","five","tec","cz","deagle",
		"revolver","dual","p350","knife","blade","dagger","luger",
		"silencer","suppressed","pistol","handgun",
		"p320","makarov","pm","tokarev","tt33","tt-33"
	}

	-- TAB
	local VTab = Window:CreateTab("Visual", 4483362458)

	-- TOGGLES
	VTab:CreateToggle({
		Name = "ESP Master",
		CurrentValue = false,
		Callback = function(v)
			espEnabled = v
		end
	})

	VTab:CreateToggle({
		Name = "Boxes",
		CurrentValue = false,
		Callback = function(v)
			boxesEnabled = v
		end
	})

	VTab:CreateToggle({
		Name = "Tracers",
		CurrentValue = false,
		Callback = function(v)
			tracersEnabled = v
		end
	})

	-- DROPDOWN
	VTab:CreateDropdown({
		Name = "ESP Mode",
		Options = {"ESP", "Chams"},
		CurrentOption = {"ESP"},
		Callback = function(opt)
			espMode = opt[1]
		end
	})

	-- CLEAR
	local function clearESP()
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				for _, v in ipairs(p.Character:GetChildren()) do
					if v.Name:find("ESP_") then
						v:Destroy()
					end
				end
			end
		end
	end

	-- LOOP
	RunService.RenderStepped:Connect(function()
		if not espEnabled then
			clearESP()
			return
		end

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
				
				local char = p.Character
				local hum = char.Humanoid
				local hrp = char.HumanoidRootPart
				
				-- TOOL DETECTION
				local tool = char:FindFirstChildOfClass("Tool") or (p.Backpack and p.Backpack:FindFirstChildOfClass("Tool"))
				local tn = tool and tool.Name:lower() or ""

				local isGlass = tn:find("glass") and tn:find("breaker")
				local isGun = false

				if tool and not isGlass then
					local safe = false
					for _, name in ipairs(SAFE_WEAPONS) do
						if tn:find(name) then
							safe = true
							break
						end
					end
					if not safe then isGun = true end
				end

				-- COLORS
				local outlineCol = isGun and Color3.fromRGB(255,0,0)
					or (isGlass and Color3.fromRGB(0,180,255) or Color3.fromRGB(0,255,0))

				local nickCol = not isGun and "rgb(255,255,0)" or "rgb(255,0,0)"
				local hpCol = hum.Health < 30 and "rgb(255,0,0)"
					or (hum.Health < 80 and "rgb(255,255,0)" or "rgb(0,255,0)")

				local weaponCol = isGun and "rgb(255,0,0)"
					or (isGlass and "rgb(0,180,255)" or "rgb(200,200,200)")

				-- HIGHLIGHT
				local h = char:FindFirstChild("ESP_Highlight") or Instance.new("Highlight", char)
				h.Name = "ESP_Highlight"
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

				if espMode == "Chams" then
					h.FillTransparency = 0.5
					h.FillColor = outlineCol
					h.OutlineTransparency = 1

					if char:FindFirstChild("ESP_Info") then
						char.ESP_Info:Destroy()
					end
				else
					h.FillTransparency = 1
					h.OutlineTransparency = 0
					h.OutlineColor = outlineCol

					-- INFO GUI
					local info = char:FindFirstChild("ESP_Info") or Instance.new("BillboardGui", char)
					if info.Name ~= "ESP_Info" then
						info.Name = "ESP_Info"
						info.Size = UDim2.new(0,200,0,100)
						info.AlwaysOnTop = true
						info.StudsOffset = Vector3.new(0,4,0)

						local label = Instance.new("TextLabel", info)
						label.Size = UDim2.new(1,0,1,0)
						label.BackgroundTransparency = 1
						label.Font = Enum.Font.GothamBold
						label.TextSize = 13
						label.RichText = true
					end

					local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)

					info.TextLabel.Text = string.format(
						'<font color="%s">%s</font>\n<font color="%s">HP: %d</font>\n<font color="%s">%s</font>\n<font color="rgb(170,85,255)">[%dm]</font>',
						nickCol,
						p.Name:upper(),
						hpCol,
						math.floor(hum.Health),
						weaponCol,
						(tool and tool.Name:upper() or "SAFE"),
						dist
					)
				end

				-- BOX
				if boxesEnabled then
					local box = char:FindFirstChild("ESP_Box") or Instance.new("BoxHandleAdornment", char)
					box.Name = "ESP_Box"
					box.Adornee = hrp
					box.Size = Vector3.new(4,6,2)
					box.Color3 = outlineCol
					box.AlwaysOnTop = true
				else
					if char:FindFirstChild("ESP_Box") then
						char.ESP_Box:Destroy()
					end
				end

				-- TRACERS (OPTIMIZED)
				if tracersEnabled then
					local tracer = char:FindFirstChild("ESP_Tracer")
					local att0 = Camera:FindFirstChild("ESP_Att0_" .. p.Name)
					local att1 = hrp:FindFirstChild("ESP_Att1")

					if not tracer then
						tracer = Instance.new("Beam")
						tracer.Name = "ESP_Tracer"
						tracer.Parent = char

						att0 = Instance.new("Attachment")
						att0.Name = "ESP_Att0_" .. p.Name
						att0.Parent = Camera

						att1 = Instance.new("Attachment")
						att1.Name = "ESP_Att1"
						att1.Parent = hrp

						tracer.Attachment0 = att0
						tracer.Attachment1 = att1
						tracer.Width0 = 0.1
						tracer.Width1 = 0.1
						tracer.Color = ColorSequence.new(outlineCol)
					end
				else
					if char:FindFirstChild("ESP_Tracer") then
						char.ESP_Tracer:Destroy()
					end
					if Camera:FindFirstChild("ESP_Att0_" .. p.Name) then
						Camera["ESP_Att0_" .. p.Name]:Destroy()
					end
					if hrp:FindFirstChild("ESP_Att1") then
						hrp.ESP_Att1:Destroy()
					end
				end
			end
		end
	end)
end

--RNG Fighting
if game.PlaceId == 100490989733123 then
	local MTab = Window:CreateTab("Main", 4483362458)

	local rolling = false

	MTab:CreateToggle({
		Name = "Auto Roll",
		CurrentValue = false,
		Callback = function(state)
			rolling = state

			if rolling then
				task.spawn(function()
					while rolling do
						game:GetService("ReplicatedStorage")
							:WaitForChild("RemoteEvents")
							:WaitForChild("Roll")
							:FireServer("Roll", "Weapons")

						task.wait(1)
					end
				end)
			end
		end
	})
end

--Bite By Night
if game.PlaceId == 70845479499574 then
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local plr = Players.LocalPlayer

    local MTab = Window:CreateTab("Main", 4483362458)
	local STab = Window:CreateTab("Survivor", 4483362458)
	local VTab = Window:CreateTab("Visual", 4483362458)

	local function notify2(title, text)
		Rayfield:Notify({
			Title = title,
			Content = text,
			Duration = 3
		})
	end

	    --// JUMP
    local jumpBoost = false
    local jpLoop = nil
    local jpCA = nil

    MTab:CreateToggle({
        Name = "Allow Jumping",
        CurrentValue = false,
        Callback = function(state)
            jumpBoost = state

            local function applyJump(hum)
                if not hum then return end

                if hum.UseJumpPower then
                    hum.JumpPower = jumpBoost and 50 or 0
                else
                    hum.JumpHeight = jumpBoost and 7 or 0
                end
            end

            if jumpBoost then
                Rayfield:Notify({
					Title = "Jump Enabled",
					Content = "Enabled.",
					Duration = 3
				})

                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                applyJump(hum)

                -- cleanup old connections
                if jpLoop then jpLoop:Disconnect() end
                if jpCA then jpCA:Disconnect() end

                -- detect BOTH properties
                if hum then
                    jpLoop = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                        applyJump(hum)
                    end)

                    hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                        applyJump(hum)
                    end)
                end

                -- respawn handling
                jpCA = plr.CharacterAdded:Connect(function(char)
                    local hum = char:WaitForChild("Humanoid")
                    applyJump(hum)

                    if jpLoop then jpLoop:Disconnect() end

                    jpLoop = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                        applyJump(hum)
                    end)

                    hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                        applyJump(hum)
                    end)
                end)

            else
                Rayfield:Notify({
					Title = "Jump Enabled",
					Content = "Disabled.",
					Duration = 3
				})

                if jpLoop then
                    jpLoop:Disconnect()
                    jpLoop = nil
                end

                if jpCA then
                    jpCA:Disconnect()
                    jpCA = nil
                end

                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hum then
                    if hum.UseJumpPower then
                        hum.JumpPower = 0
                    else
                        hum.JumpHeight = 0
                    end
                end
            end
        end
    })



	local viewKiller = false
	local killerAddedConn
	local killerRemovedConn

	MTab:CreateToggle({
		Name = "View Killer",
		CurrentValue = false,
		Callback = function(state)
			viewKiller = state

			local Players = game:GetService("Players")
			local player = Players.LocalPlayer
			local camera = workspace.CurrentCamera

			local function setKillerCamera(killerChar)
				local hum = killerChar:FindFirstChildOfClass("Humanoid")
				if hum then
					camera.CameraSubject = hum
				end
			end

			local playersFolder = workspace:FindFirstChild("PLAYERS")
			local killerFolder = playersFolder and playersFolder:FindFirstChild("KILLER")

			if state then
				if killerFolder then
					local currentKiller = killerFolder:GetChildren()[1]
					if currentKiller then
						setKillerCamera(currentKiller)
					end

					killerAddedConn = killerFolder.ChildAdded:Connect(setKillerCamera)

					killerRemovedConn = killerFolder.ChildRemoved:Connect(function()
						if viewKiller then
							local char = player.Character
							local hum = char and char:FindFirstChildOfClass("Humanoid")
							if hum then
								camera.CameraSubject = hum
							end
						end
					end)
				end

				Rayfield:Notify({
					Title = "View Killer",
					Content = "Enabled.",
					Duration = 3
				})

			else
				if killerAddedConn then
					killerAddedConn:Disconnect()
					killerAddedConn = nil
				end

				if killerRemovedConn then
					killerRemovedConn:Disconnect()
					killerRemovedConn = nil
				end

				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if hum then
					camera.CameraSubject = hum
				end

				Rayfield:Notify({
					Title = "View Killer",
					Content = "Disabled.",
					Duration = 3
				})
			end
		end,
	})


    --// AUTO GENERATOR
	local GenSpeed = 0.4
	local AutoGen = false
	local genLoop

	STab:CreateToggle({
		Name = "Auto Generator",
		CurrentValue = false,
		Callback = function(v)
			AutoGen = v

			local plr = game:GetService("Players").LocalPlayer

			if AutoGen then
				Rayfield:Notify({
					Title = "Auto Generator",
					Content = "Enabled.",
					Duration = 3
				})

				genLoop = task.spawn(function()
					while AutoGen do
						local success = false

						-- 🔹 METHOD 1: GUI
						local gui = plr:FindFirstChild("PlayerGui")
						if gui and gui:FindFirstChild("Gen") then
							pcall(function()
								gui.Gen.GeneratorMain.Event:FireServer(true)
								success = true
							end)
						end

						-- 🔹 METHOD 2: Workspace Generator (fallback)
						if not success then
							local maps = workspace:FindFirstChild("MAPS")
							local gameMap = maps and maps:FindFirstChild("GAME MAP")
							local gens = gameMap and gameMap:FindFirstChild("Generators")

							if gens then
								for _, v in ipairs(gens:GetChildren()) do
									if v:IsA("Model") and v.Name:lower():find("generator") then
										-- example fallback action (adjust if needed)
										pcall(function()
											if v:FindFirstChild("Event") then
												v.Event:FireServer(true)
												success = true
											end
										end)

										if success then break end
									end
								end
							end
						end

						task.wait(GenSpeed)
					end
				end)

			else
				AutoGen = false

				Rayfield:Notify({
					Title = "Auto Generator",
					Content = "Disabled.",
					Duration = 3
				})
			end
		end
	})

	STab:CreateSlider({
		Name = "Auto Gen Speed",
		Range = {0, 1},
		Increment = 0.1,
		Suffix = "seconds",
		CurrentValue = 0.4,
		Flag = "AutoSpeedGen", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
		Callback = function(Value)
			GenSpeed = Value
		end,
	})

	local genLoop = nil

	STab:CreateToggle({
		Name = "Auto Generator (Proximity)",
		CurrentValue = false,
		Callback = function(v)
			AutoGen = v

			local plr = game.Players.LocalPlayer
			local character = plr.Character or plr.CharacterAdded:Wait()
			local root = character:WaitForChild("HumanoidRootPart")

			local genFolder = workspace.MAPS["GAME MAP"].Generators

			if v then
				Rayfield:Notify({
					Title = "Auto Generator",
					Content = "Enabled - Finding nearest prompt",
					Duration = 3
				})

				genLoop = task.spawn(function()
					while AutoGen do
						-- Find the closest ProximityPrompt
						local closestPrompt = nil
						local shortestDistance = math.huge

						for _, prompt in ipairs(genFolder:GetDescendants()) do
							if prompt:IsA("ProximityPrompt") then
								local part = prompt.Parent
								if part and part:IsA("BasePart") then
									local distance = (root.Position - part.Position).Magnitude
									if distance < shortestDistance then
										shortestDistance = distance
										closestPrompt = prompt
									end
								end
							end
						end

						-- Fire the closest prompt if found and in reasonable range
						if closestPrompt then
							pcall(function()
								fireproximityprompt(closestPrompt)
							end)
						end

						task.wait(GenSpeed or 0.15)  -- Adjust this value (lower = faster, but don't go too low)
					end
				end)

			else
				AutoGen = false

				Rayfield:Notify({
					Title = "Auto Generator",
					Content = "Disabled.",
					Duration = 3
				})

				if genLoop then
					task.cancel(genLoop)
					genLoop = nil
				end
			end
		end
	})

	
	local infStam = false
	local stamConn
	local stamValue

	STab:CreateToggle({
		Name = "Infinite Stamina",
		CurrentValue = false,
		Callback = function(state)
			infStam = state

			if state then
				Rayfield:Notify({
					Title = "Infinite Stamina",
					Content = "Enabled.",
					Duration = 3
				})

				-- cleanup old
				if stamConn then
					stamConn:Disconnect()
					stamConn = nil
				end

				stamConn = RunService.Heartbeat:Connect(function()
					if not infStam then return end

					local playersFolder = workspace:FindFirstChild("PLAYERS")
					if not playersFolder then return end

					local aliveFolder = playersFolder:FindFirstChild("ALIVE")
					local model = aliveFolder and aliveFolder:FindFirstChild(player.Name)

					if not model then return end

					-- 🔍 find stamina value once
					if not stamValue then
						for _, v in ipairs(model:GetDescendants()) do
							if v:IsA("NumberValue") and v.Name:lower():find("stam") then
								stamValue = v
								break
							end
						end
					end

					if model then
						model:SetAttribute("Stamina", 100)
					end 
					

					-- ✅ Method 1: NumberValue (main)
					if stamValue then
						if stamValue.Value < 100 then
							stamValue.Value = 100
						end
					end

					-- ✅ Method 2: Attribute (fallback)
					local attr = model:GetAttribute("Stamina")
					if attr ~= nil and attr < 100 then
						model:SetAttribute("Stamina", 100)
					end
				end)

			else
				infStam = false

				Rayfield:Notify({
					Title = "Infinite Stamina",
					Content = "Disabled.",
					Duration = 3
				})

				if stamConn then
					stamConn:Disconnect()
					stamConn = nil
				end

				stamValue = nil
			end
		end
	})


	local AntiStun = false
	local NoStunConn

	STab:CreateToggle({
		Name = "Anti Stun",
		CurrentValue = false,
		Callback = function(state)
			AntiStun = state

			local Players = game:GetService("Players")
			local RunService = game:GetService("RunService")
			local player = Players.LocalPlayer

			if state then
				Rayfield:Notify({
					Title = "Anti Stun",
					Content = "Enabled.",
					Duration = 3
				})

				-- disconnect old connection
				if NoStunConn then
					NoStunConn:Disconnect()
					NoStunConn = nil
				end

				-- 🟢 RunService loop (every frame)
				NoStunConn = RunService.RenderStepped:Connect(function()
					if not AntiStun then return end

					local playersFolder = workspace:FindFirstChild("PLAYERS")
					if not playersFolder then return end

					local aliveFolder = playersFolder:FindFirstChild("ALIVE")
					

					local myAliveModel = aliveFolder and aliveFolder:FindFirstChild(player.Name)
					

					-- stun
					if myAliveModel then
						myAliveModel:SetAttribute("Stun", false)
					end

				end)

			else
				AntiStun = false

				Rayfield:Notify({
					Title = "Anti Stun",
					Content = "Disabled.",
					Duration = 3
				})

				if NoStunConn then
					NoStunConn:Disconnect()
					NoStunConn = nil
				end
			end
		end
	})

	STab:CreateToggle({
		Name = "Auto Block (predict)",
		CurrentValue = false,
		Callback = function(state)
			if not state then return end

			local playersFolder = workspace:FindFirstChild("PLAYERS")
			local killersFolder = playersFolder and playersFolder:FindFirstChild("KILLER")

			if not killersFolder then
				warn("[Auto Block] KILLER folder not found!")
				return
			end

			local VIM = game:GetService("VirtualInputManager")
			local LocalPlayer = game.Players.LocalPlayer

			-- Find the ability holder (cleaned up)
			local function findAbilityHolder()
				local abilitiesList = LocalPlayer.PlayerGui:FindFirstChild("UI")
					and LocalPlayer.PlayerGui.UI:FindFirstChild("UI")
					and LocalPlayer.PlayerGui.UI.UI:FindFirstChild("GameUIContainer")
					and LocalPlayer.PlayerGui.UI.UI.GameUIContainer:FindFirstChild("Abilities")
					and LocalPlayer.PlayerGui.UI.UI.GameUIContainer.Abilities:FindFirstChild("List")

				if not abilitiesList then return nil end

				for _, slot in pairs(abilitiesList:GetChildren()) do
					if slot.Name:find("1") or slot.Name:find("2") then
						for _, child in pairs(slot:GetChildren()) do
							if child.Name:find("Holder") then
								return child
							end
						end
					end
				end
				return nil
			end

			local abilityHolder = findAbilityHolder()

			task.spawn(function()
				while state do
					-- Update my position safely
					local myChar = LocalPlayer.Character
					if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
						task.wait(0.1)
						continue
					end

					local myPos = myChar.HumanoidRootPart.Position

					-- Find killer
					local killer = nil
					for _, v in pairs(killersFolder:GetChildren()) do
						if v:FindFirstChild("HumanoidRootPart") then
							killer = v
							break
						end
					end

					if killer and killer:FindFirstChild("HumanoidRootPart") then
						local killerPos = killer.HumanoidRootPart.Position
						local distance = (killerPos - myPos).Magnitude

						-- Predict & Auto Block (tweak the number if needed)
						if distance <= 7 then   -- Increased slightly for better prediction
							-- Simulate pressing LeftShift (Block)
							VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
							task.wait(0.07)  -- Short hold time
							VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)

							print("Auto Blocked! Distance:", math.round(distance * 10) / 10, "studs")
						end
					end

					task.wait(0.025)  -- Fast loop for prediction
				end
			end)
		end
	})

	local dotLoop = nil   -- This must stay outside the callback so it doesn't get reset

	STab:CreateToggle({
		Name = "Auto Barricade",
		CurrentValue = false,
		Callback = function(state)
			AntiStun = state

			if state then
				Rayfield:Notify({
					Title = "Auto Barricade",
					Content = "Enabled.",
					Duration = 3
				})

				local function centerDot(frame)
					if frame then
						frame.AnchorPoint = Vector2.new(0.5, 0.5)
						frame.Position = UDim2.new(0.5, 0, 0.5, 0)
					end
				end

				-- Only create the loop if it doesn't already exist
				if not dotLoop then
					dotLoop = RunService.RenderStepped:Connect(function()
						local dot = player.PlayerGui:FindFirstChild("Dot")
						if dot then
							local container = dot:FindFirstChild("Container")
							if container then
								local frame = container:FindFirstChild("Frame")
								if frame then
									centerDot(frame)
								end
							end
						end
					end)
				end

			else
				AntiStun = false

				Rayfield:Notify({
					Title = "Auto Barricade",
					Content = "Disabled.",
					Duration = 3
				})

				-- Properly disconnect and clean up
				if dotLoop then
					dotLoop:Disconnect()
					dotLoop = nil
				end
			end
		end
	})

	local esp = {
    survivors = {},
    killers = {},
    generators = {}
	}

	-- Helper functions
	local function add(tbl, obj, color)
		if not obj or tbl[obj] then return end
		local h = Instance.new("Highlight")
		h.FillColor = color
		h.FillTransparency = 0.5
		h.OutlineColor = color
		h.Adornee = obj
		h.Parent = obj          -- Parent after setting Adornee (helps with some Highlight bugs)
		tbl[obj] = h
	end

	local function remove(tbl, obj)
		if tbl[obj] then
			tbl[obj]:Destroy()
			tbl[obj] = nil
		end
	end

	local function clear(tbl)
		for obj, h in pairs(tbl) do
			if h then h:Destroy() end
			tbl[obj] = nil
		end
	end

	-- ====================== SURVIVOR ESP ======================
	local survivorEnabled = false
	local survivorLoop

	VTab:CreateToggle({
		Name = "Survivor ESP",
		CurrentValue = false,
		Callback = function(state)
			survivorEnabled = state

			local playersFolder = workspace:FindFirstChild("PLAYERS")
			local alive = playersFolder and playersFolder:FindFirstChild("ALIVE")

			if not alive then
				Rayfield:Notify({ Title = "Error", Content = "Wait for match to start.", Duration = 3 })
				return
			end

			if state then
				Rayfield:Notify({ Title = "Survivor ESP", Content = "Enabled.", Duration = 3 })

				-- clean old
				if esp.survivorAdd then esp.survivorAdd:Disconnect() end
				if esp.survivorRemove then esp.survivorRemove:Disconnect() end

				-- listeners (ONLY ONCE)
				esp.survivorAdd = alive.ChildAdded:Connect(function(v)
					if v:IsA("Model") then
						add(esp.survivors, v, Color3.fromRGB(80, 180, 255))
					end
				end)

				esp.survivorRemove = alive.ChildRemoved:Connect(function(v)
					remove(esp.survivors, v)
				end)

				-- 🔁 LOOP
				survivorLoop = task.spawn(function()
					while survivorEnabled do
						for _, v in ipairs(alive:GetChildren()) do
							if v:IsA("Model") and not esp.survivors[v] then
								add(esp.survivors, v, Color3.fromRGB(80, 180, 255))
							end
						end
						task.wait(.5)
					end
				end)

			else
				survivorEnabled = false

				Rayfield:Notify({ Title = "Survivor ESP", Content = "Disabled.", Duration = 3 })

				if esp.survivorAdd then
					esp.survivorAdd:Disconnect()
					esp.survivorAdd = nil
				end

				if esp.survivorRemove then
					esp.survivorRemove:Disconnect()
					esp.survivorRemove = nil
				end

				clear(esp.survivors)
			end
		end
	})

	-- ====================== KILLER ESP ======================
	local killerEnabled = false
	local killerLoop

	VTab:CreateToggle({
		Name = "Killer ESP",
		CurrentValue = false,
		Callback = function(state)
			killerEnabled = state

			local playersFolder = workspace:FindFirstChild("PLAYERS")
			local killers = playersFolder and playersFolder:FindFirstChild("KILLER")

			if not killers then
				Rayfield:Notify({ Title = "Error", Content = "Wait for match to start.", Duration = 3 })
				return
			end

			if state then
				Rayfield:Notify({ Title = "Killer ESP", Content = "Enabled.", Duration = 3 })

				-- clean old
				if esp.killerAdd then esp.killerAdd:Disconnect() end
				if esp.killerRemove then esp.killerRemove:Disconnect() end

				-- listeners (ONLY ONCE)
				esp.killerAdd = killers.ChildAdded:Connect(function(v)
					if v:IsA("Model") then
						add(esp.killers, v, Color3.fromRGB(255, 80, 80))
					end
				end)

				esp.killerRemove = killers.ChildRemoved:Connect(function(v)
					remove(esp.killers, v)
				end)

				-- 🔁 LOOP
				killerLoop = task.spawn(function()
					while killerEnabled do
						for _, v in ipairs(killers:GetChildren()) do
							if v:IsA("Model") and not esp.killers[v] then
								add(esp.killers, v, Color3.fromRGB(255, 80, 80))
							end
						end
						task.wait(.5)
					end
				end)

			else
				killerEnabled = false

				Rayfield:Notify({ Title = "Killer ESP", Content = "Disabled.", Duration = 3 })

				if esp.killerAdd then
					esp.killerAdd:Disconnect()
					esp.killerAdd = nil
				end

				if esp.killerRemove then
					esp.killerRemove:Disconnect()
					esp.killerRemove = nil
				end

				clear(esp.killers)
			end
		end
	})

	-- ====================== GENERATOR ESP ======================
	local genEnabled = false
	local genLoop

	VTab:CreateToggle({
		Name = "Generator ESP",
		CurrentValue = false,
		Callback = function(state)
			genEnabled = state

			if state then
				Rayfield:Notify({
					Title = "Generator ESP",
					Content = "Enabled.",
					Duration = 3
				})

				-- disconnect old connections just in case
				if esp.genAdd then esp.genAdd:Disconnect() end
				if esp.genRemove then esp.genRemove:Disconnect() end

				-- listeners (only once)
				esp.genAdd = workspace.DescendantAdded:Connect(function(v)
					if v:IsA("Model") and v.Name == "Generator" then
						add(esp.generators, v, Color3.fromRGB(0, 255, 100))
					end
				end)

				esp.genRemove = workspace.DescendantRemoving:Connect(function(v)
					if esp.generators[v] then
						remove(esp.generators, v)
					end
				end)

				-- 🔁 LOOP (safe)
				genLoop = task.spawn(function()
					while genEnabled do
						for _, v in ipairs(workspace:GetDescendants()) do
							if v:IsA("Model") and v.Name == "Generator" then
								if not esp.generators[v] then
									add(esp.generators, v, Color3.fromRGB(0, 255, 100))
								end
							end
						end
						task.wait(.5) -- adjust speed here
					end
				end)

			else
				genEnabled = false

				Rayfield:Notify({
					Title = "Generator ESP",
					Content = "Disabled.",
					Duration = 3
				})

				if esp.genAdd then
					esp.genAdd:Disconnect()
					esp.genAdd = nil
				end

				if esp.genRemove then
					esp.genRemove:Disconnect()
					esp.genRemove = nil
				end

				clear(esp.generators)
			end
		end
	})

	-- ====================== BATTERY ESP ======================
	local batteryEnabled = false
	local batteryLoop

	VTab:CreateToggle({
		Name = "Battery ESP",
		CurrentValue = false,
		Callback = function(state)
			batteryEnabled = state

			if state then
				Rayfield:Notify({ Title = "Battery ESP", Content = "Enabled.", Duration = 3 })

				-- listener (optional but good)
				if batteryConn then batteryConn:Disconnect() end
				batteryConn = workspace.DescendantAdded:Connect(function(v)
					if v:IsA("MeshPart") and v.Name == "Battery" then
						createBatteryHighlight(v)
					end
				end)

				-- 🔁 LOOP
				batteryLoop = task.spawn(function()
					while batteryEnabled do
						local ignore = workspace:FindFirstChild("IGNORE")
						if ignore then
							for _, v in ipairs(ignore:GetDescendants()) do
								if v:IsA("MeshPart") and v.Name == "Battery" then
									if not batteryHighlights[v] then
										createBatteryHighlight(v)
									end
								end
							end
						end
						task.wait(3)
					end
				end)

			else
				batteryEnabled = false

				Rayfield:Notify({ Title = "Battery ESP", Content = "Disabled.", Duration = 3 })

				if batteryConn then
					batteryConn:Disconnect()
					batteryConn = nil
				end

				clear(batteryHighlights)
			end
		end
	})

	-- ====================== FUSE BOX ESP ======================
	local fuseEnabled = false
	local fuseLoop

	VTab:CreateToggle({
		Name = "Fuse Box ESP",
		CurrentValue = false,
		Callback = function(state)
			fuseEnabled = state

			if state then
				Rayfield:Notify({ Title = "Fuse Box ESP", Content = "Enabled.", Duration = 3 })

				fuseLoop = task.spawn(function()
					while fuseEnabled do
						local maps = workspace:FindFirstChild("MAPS")
						local gameMap = maps and maps:FindFirstChild("GAME MAP")
						local fuseBoxes = gameMap and gameMap:FindFirstChild("FuseBoxes")

						if fuseBoxes then
							for _, box in ipairs(fuseBoxes:GetChildren()) do
								local battery = box:FindFirstChild("Battery")
								if battery and not fuseHighlights[battery] then
									createFuseHighlight(battery)
								end
							end
						end

						task.wait(.3)
					end
				end)

			else
				fuseEnabled = false

				Rayfield:Notify({ Title = "Fuse Box ESP", Content = "Disabled.", Duration = 3 })
				clear(fuseHighlights)
			end
		end
	})

	-- ====================== BEAR TRAP ESP ======================
	local trapEnabled = false
	local trapLoop

	VTab:CreateToggle({
		Name = "Bear Trap ESP",
		CurrentValue = false,
		Callback = function(state)
			trapEnabled = state

			if state then
				Rayfield:Notify({ Title = "Bear Trap ESP", Content = "Enabled.", Duration = 3 })

				trapLoop = task.spawn(function()
					while trapEnabled do
						local ignore = workspace:FindFirstChild("IGNORE")
						if ignore then
							for _, obj in ipairs(ignore:GetChildren()) do
								if obj:IsA("Model") and obj.Name == "Trap" then
									if not trapHighlights[obj] then
										createTrapHighlight(obj)
									end

									for _, part in ipairs(obj:GetDescendants()) do
										if part:IsA("BasePart") and not trapHighlights[part] then
											createTrapHighlight(part)
										end
									end
								end
							end
						end
						task.wait(.3)
					end
				end)

			else
				trapEnabled = false

				Rayfield:Notify({ Title = "Bear Trap ESP", Content = "Disabled.", Duration = 3 })
				clear(trapHighlights)
			end
		end
	})
end


local allowed = {
	[79943475071382] = true,
	[92671411590360] = true

}

--Amber Alert
if allowed[game.PlaceId] then
	local m = workspace:WaitForChild("Monsters")
	local flora = workspace.Map.Exterior:WaitForChild("Flora")

	local VTab = Window:CreateTab("Visual", 4483362458)

	local espEnabled = false

	-- LOOP
	task.spawn(function()
		while true do
			task.wait(.5) -- update delay (lower = faster, more lag)

			if espEnabled then
				for _, v in pairs(m:GetChildren()) do
					if not v:FindFirstChild("esp") then
						local esp = Instance.new("Highlight")
						esp.Name = "esp"
						esp.FillColor = Color3.fromRGB(255, 0, 0)
						esp.OutlineColor = Color3.fromRGB(255, 255, 255)
						esp.Parent = v
					end
				end
			else
				for _, v in pairs(m:GetChildren()) do
					local esp = v:FindFirstChild("esp")
					if esp then
						esp:Destroy()
					end
				end
			end
		end
	end)


	VTab:CreateToggle({
		Name = "Monster ESP",
		CurrentValue = false,
		Callback = function(state)
			espEnabled = state
			
			Rayfield:Notify({
				Title = "Monster ESP",
				Content = state and "Enabled" or "Disabled",
				Duration = 3
			})
		end
	})

	local function removeTree()
		if not flora then
			Rayfield:Notify({
				Title = "Remove Trees",
				Content = "Flora not found on this map.",
				Duration = 3
			})
			return
		end

		for _, v in pairs(flora:GetChildren()) do
			if v.Name:find("Tree") or v.Name:find("Sapling") then
				v:Destroy()
			end
		end
	end

	if flora then
		VTab:CreateButton({
			Name = "Remove Trees",
			Callback = removeTree
		})
	else
		VTab:CreateButton({
			Name = "Remove Trees (Not Available)",
			Callback = function()
				Rayfield:Notify({
					Title = "Unavailable",
					Content = "No flora found on this map.",
					Duration = 3
				})
			end
		})
	end
end

--phenomenon
if game.PlaceId == 115816909322231 then
	local BF = workspace:WaitForChild("BoiledOne")

	local espEnabled = false

	-- APPLY ESP
	local function applyBoiledESP()
		for _, v in pairs(BF:GetChildren()) do
			if not v:FindFirstChild("esp") then
				-- Highlight
				local esp = Instance.new("Highlight")
				esp.Name = "esp"
				esp.FillColor = Color3.fromRGB(255, 170, 0)
				esp.OutlineColor = Color3.fromRGB(255, 255, 255)
				esp.Parent = v

				-- Billboard GUI (name)
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "esp_gui"
				billboard.Size = UDim2.new(0, 200, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = v

				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.TextScaled = true
				text.Text = v.Name
				text.TextColor3 = Color3.fromRGB(255, 255, 255)
				text.Parent = billboard
			end
		end
	end

	-- REMOVE ESP
	local function removeBoiledESP()
		for _, v in pairs(BF:GetChildren()) do
			local esp = v:FindFirstChild("esp")
			if esp then esp:Destroy() end

			local gui = v:FindFirstChild("esp_gui")
			if gui then gui:Destroy() end
		end
	end

	-- LOOP
	task.spawn(function()
		while true do
			if espEnabled then
				applyBoiledESP()
			end
			task.wait(0.5)
		end
	end)

	-- RAYFIELD TOGGLE
	VTab:CreateToggle({
		Name = "Boiled ESP",
		CurrentValue = false,
		Callback = function(state)
			espEnabled = state

			if not state then
				removeBoiledESP()
			end

			Rayfield:Notify({
				Title = "Boiled ESP",
				Content = state and "Enabled" or "Disabled",
				Duration = 3
			})
		end
	})
end

--home Alone [HORROR]
if game.PlaceId == 15988754129 then
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local PlayerGui = player:WaitForChild("PlayerGui")

	local Tracker = PlayerGui:WaitForChild("Main"):WaitForChild("MonsterTracker")
	local C = game:GetService("ReplicatedStorage").Chores

	local MTab = Window:CreateTab("Main", 4483362458)

	plr.CameraMode = Enum.CameraMode.Classic
	local char = plr.Character
	plr:GetPropertyChangedSignal("CameraMode"):Connect(function()
		if plr.CameraMode ~= Enum.CameraMode.Classic then
			plr.CameraMode = Enum.CameraMode.Classic
			plr.CameraMaxZoomDistance = 0.5
		end	
	end)

	MTab:CreateButton({
		Name = "Enable Tracker",
		Callback = function()
			Tracker.Visible = true
		end,
	})

	MTab:CreateButton({
		Name = "do chores",
		Callback = function()
			for i, v in pairs(C:GetChildren()) do
				if v:IsA("BoolValue") then
					v.Value = true
				end
			end
		end,
	})
end


local BLgames = {
	[17122385635] = true,
	[71832465156084] = true
}

--basketball legends
if BLgames[game.PlaceId] then
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- Update character on respawn
	player.CharacterAdded:Connect(function(newChar)
		char = newChar
		hrp = newChar:WaitForChild("HumanoidRootPart")
	end)

	local MainTab = Window:CreateTab("Main", 4483362458)

	------------------------------------------------
	-- AUTO GREEN (Improved Reliability)
	------------------------------------------------
	local autoGreen = false
	local shootPower = 0.95
	local shootConnection

	local function getShootRemote()
		local pkgs = ReplicatedStorage:FindFirstChild("Packages")
		return pkgs and pkgs:FindFirstChild("Knit") and pkgs.Knit.Services.ControlService.RE.Shoot
	end

	local function setupAutoGreen()
		if shootConnection then
			shootConnection:Disconnect()
			shootConnection = nil
		end

		-- Wait for the Visual GUI (it can recreate)
		local visualGui = player:WaitForChild("PlayerGui"):WaitForChild("Visual", 5)
		local shootingElement = visualGui and visualGui:FindFirstChild("Shooting")

		if not shootingElement then
			return
		end

		shootConnection = shootingElement:GetPropertyChangedSignal("Visible"):Connect(function()
			if not (shootingElement.Visible and autoGreen) then return end
			
			task.wait(0.23) -- You can tweak this value (0.20 - 0.28 range is common)
			local Shoot = getShootRemote()
			if Shoot then
				Shoot:FireServer(shootPower)
			end
		end)
	end

	MainTab:CreateToggle({
		Name = "Auto Green",
		CurrentValue = false,
		Callback = function(Value)
			autoGreen = Value
			if autoGreen then
				setupAutoGreen()
			elseif shootConnection then
				shootConnection:Disconnect()
				shootConnection = nil
			end
		end,
	})

	MainTab:CreateSlider({
		Name = "Green Timing",
		Range = {80, 100},
		Increment = 1,
		CurrentValue = 95,
		Callback = function(Value)
			shootPower = Value / 100
		end,
	})

	------------------------------------------------
	-- BALL MAGNET (Optimized + Smoother)
	------------------------------------------------
	local magnet = false
	local magnetDistance = 30

	RunService.Heartbeat:Connect(function()
		if not magnet or not hrp then return end

		for _, v in ipairs(workspace:GetChildren()) do
			if v.Name == "Basketball" and v:IsA("BasePart") then
				local dist = (hrp.Position - v.Position).Magnitude
				if dist <= magnetDistance and dist > 4 then  -- avoid pulling ball you're already holding
					firetouchinterest(hrp, v, 0)
					firetouchinterest(hrp, v, 1)
				end
			end
		end
	end)

	MainTab:CreateToggle({
		Name = "Ball Magnet",
		CurrentValue = false,
		Callback = function(Value)
			magnet = Value
		end,
	})

	MainTab:CreateSlider({
		Name = "Magnet Distance",
		Range = {10, 80},
		Increment = 1,
		CurrentValue = 30,
		Callback = function(Value)
			magnetDistance = Value
		end,
	})

	------------------------------------------------
	-- AUTO REBOUND (Less Blatant + Smoother)
	------------------------------------------------
	local autoRebound = false
	local reboundDistance = 12  -- Only activate when ball is somewhat far

	RunService.RenderStepped:Connect(function()
		if not autoRebound or not hrp then return end

		for _, v in ipairs(workspace:GetChildren()) do
			if v.Name == "Basketball" and v:IsA("BasePart") then
				local dist = (hrp.Position - v.Position).Magnitude
				if dist > reboundDistance then
					-- Smooth lerp instead of instant teleport (much less detectable)
					hrp.CFrame = hrp.CFrame:Lerp(
						CFrame.new(v.Position + Vector3.new(0, 3, 0)), 
						0.45  -- Adjust 0.3-0.6 for speed (higher = faster snap)
					)
				end
				break  -- Only track the first (usually the main) basketball
			end
		end
	end)

	MainTab:CreateToggle({
		Name = "Auto Rebound(fast kinda bad)",
		CurrentValue = false,
		Callback = function(Value)
			autoRebound = Value
		end,
	})

	local autoRebound = false

	RunService.RenderStepped:Connect(function()
	if not autoRebound or not char:FindFirstChild("HumanoidRootPart") then return end

	for _,v in pairs(workspace:GetChildren()) do
		if v.Name == "Basketball" and v:IsA("BasePart") then
			char.HumanoidRootPart.CFrame = CFrame.new(v.Position + Vector3.new(0,2,0))
		end
	end
	end)

	MainTab:CreateToggle({
	Name = "Auto Rebound",
	CurrentValue = false,
	Callback = function(Value)
		autoRebound = Value
	end,
	})

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")

	local player = Players.LocalPlayer
	local event = ReplicatedStorage.Packages.Knit.Services.ControlService.RE.Guard

	local guardDistance    = 8
	local debounceTime     = 0.35
	local lastGuard        = 0
	local lastBallSearch   = 0
	local BALL_SEARCH_RATE = 1

	local ball           = nil
	local autoGuard      = false
	local guardConnection = nil

	------------------------------------------------
	-- HELPERS
	------------------------------------------------

	local function findBall()
		for _, obj in workspace:GetDescendants() do
			if not obj:IsA("BasePart") and not obj:IsA("MeshPart") then continue end
			local n = obj.Name:lower()
			if n:find("basketball") or n:find("bball") or n == "ball" or n:find("hoopball") then
				return obj
			end
		end
		return nil
	end

	local function getBallPosition()
		if not ball or not ball.Parent then return nil end
		local ok, pos = pcall(function() return ball.Position end)
		return ok and pos or nil
	end

	local function getBallHolder()
		if not ball or not ball.Parent then return nil end
		local parent = ball.Parent
		if parent:FindFirstChildOfClass("Humanoid") then
			return Players:GetPlayerFromCharacter(parent)
		end
		local grandparent = parent.Parent
		if grandparent and grandparent:FindFirstChildOfClass("Humanoid") then
			return Players:GetPlayerFromCharacter(grandparent)
		end
		return nil
	end

	local function isOppositeTeam(holder)
		if not holder or not holder:IsA("Player") then return false end
		if not player.Team or not holder.Team then return true end
		return player.Team ~= holder.Team
	end

	------------------------------------------------
	-- MAIN LOOP
	------------------------------------------------

	local function startGuard(char)
		local hrp = char:WaitForChild("HumanoidRootPart")

		if guardConnection then
			guardConnection:Disconnect()
			guardConnection = nil
		end

		guardConnection = RunService.Heartbeat:Connect(function()
			if not autoGuard then return end

			if not ball or not ball.Parent then
				local now = tick()
				if now - lastBallSearch >= BALL_SEARCH_RATE then
					lastBallSearch = now
					ball = findBall()
				end
				return
			end

			local ballPos = getBallPosition()
			if not ballPos then return end

			if (hrp.Position - ballPos).Magnitude > guardDistance then return end

			local holder = getBallHolder()
			if holder and isOppositeTeam(holder) then
				local now = tick()
				if now - lastGuard >= debounceTime then
					lastGuard = now
					event:FireServer(true)
				end
			end
		end)
	end

	------------------------------------------------
	-- TOGGLE
	------------------------------------------------

	MainTab:CreateToggle({
		Name         = "Auto Guard",
		CurrentValue = false,
		Callback     = function(Value)
			autoGuard = Value
			if autoGuard and player.Character then
				startGuard(player.Character)
			elseif not autoGuard and guardConnection then
				guardConnection:Disconnect()
				guardConnection = nil
			end
		end,
	})

	------------------------------------------------
	-- SETUP
	------------------------------------------------

	ball = findBall()

	player.CharacterAdded:Connect(function(char)
		if autoGuard then
			startGuard(char)
		end
	end)

	player.CharacterRemoving:Connect(function()
		if guardConnection then
			guardConnection:Disconnect()
			guardConnection = nil
		end
	end)

end

--lumber tycoon 2
if game.PlaceId == 13822889 then
	local MTab = Window:CreateTab("Main", 4483362458)
	local water = workspace.Water

	local function getWater()
		for i, v in pairs(water:GetChildren()) do
			if v.Name:find("Water") and v:IsA("Part") then
				v.CanCollide = true
			end
		end
	end

	local function stopWater()
		for i, v in pairs(water:GetChildren()) do
			if v.Name:find("Water") and v:IsA("Part") then
				v.CanCollide = false
			end
		end
	end

	MTab:CreateToggle({
		Name = "Walk on Water",
		CurrentValue = false,
		Callback = function(Value)
			if Value then
				getWater()
			else
				stopWater()
			end
		end,
	})
end

--mini empire lobby
if game.PlaceId == 11755449133 then
	local QTab = Window:CreateTab("Queue", 4483362458)

	local selectedQueue = "None"

	-- Dropdown
	QTab:CreateDropdown({
		Name = "Choose Queue",
		Options = {"None", "Casual", "Blitz", "Ambush", "Duel", "Ranked"},
		CurrentOption = "None",
		MultipleOptions = false,
		Flag = "Dropdown1",
		Callback = function(option)
			-- Ensure we get a string even if the UI library passes a table
			if type(option) == "table" then
				selectedQueue = option[1]
			else
				selectedQueue = option
			end
			print("✅ Queue selected:", selectedQueue)
		end,
	})

	-- Helper function to get queue ID
	local function findGame()
		local queueMap = {
			["None"]   = nil,
			["Casual"] = 1,
			["Ambush"] = 2,
			["Blitz"]  = 3,
			["Ranked"] = 4,
			["Duel"]   = 5,
		}
		return queueMap[selectedQueue]
	end

	-- ==================== BUTTON: Auto Queue ====================
	QTab:CreateButton({
		Name = "Queue",
		Callback = function()
			local queueId = findGame()
			
			if queueId == nil then
				warn(" No valid queue selected! Current selection:", selectedQueue)
				return
			end

			local success, result = pcall(function()
				-- Sending the boolean and the specific ID to the server
				return game:GetService("ReplicatedStorage").Remotes.Queue:InvokeServer(true, queueId)
			end)

			if success then
				print(" Successfully ")
			else
				warn("Failed")
			end
		end,
	})
end

--mini empire
if game.PlaceId == 13272778002 then
    --// TAB INITIALIZATION
    local MTab = Window:CreateTab("Main", 4483362458)
    local BTab = Window:CreateTab("Build", 4483362458)
    local ATab = Window:CreateTab("Army", 4483362458)
    local VTab = Window:CreateTab("Visual", 4483362458)
    local FTab = Window:CreateTab("Funnys", 4483362458)

    --// VARIABLES
    local SelectedColor = "None"
    local SelectedUnit, SelectedVehicle, SelectedBoat = "None", "None", "None"
    local SpawnMode = "Single"
    local LocalPlayer = game:GetService("Players").LocalPlayer

    --// AUTO FLAGS
    local autoFarm, autoUnit, autoVehicle, autoBoat = false, false, false, false
    local autoFarmId, autoUnitId, autoVehicleId, autoBoatId = 0, 0, 0, 0

    --// HELPERS
    local function getMap()
        local mapFolder = workspace:FindFirstChild("Map")
        if not mapFolder then return nil end
        for _, v in ipairs(mapFolder:GetChildren()) do
            if v:IsA("Folder") then return v end
        end
        return nil
    end


    local function findStructures(searchName)
        if not SelectedColor or SelectedColor == "None" then return {} end
        local results = {}
        local highlights = workspace:FindFirstChild("Highlights")
        if not highlights then return {} end

        for _, v in pairs(highlights:GetDescendants()) do
            -- FIX: IsA("Instance") is always true; check for meaningful types only
            if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:find(searchName) and v:GetAttribute("Id") ~= nil then
                if SelectedColor == "White" then
                    if v.Parent and v.Parent.Name:find("White") then table.insert(results, v) end
                elseif v.Name:find(SelectedColor) then
                    table.insert(results, v)
                end
            end
        end
        return results
    end

    local function getId(instance)
        local id = instance:GetAttribute("Id")
        if not id then
            for _, child in ipairs(instance:GetDescendants()) do
                id = child:GetAttribute("Id")
                if id then break end
            end
        end
        return id
    end

    -- Resolves targets based on SpawnMode; returns nil if nothing found
    local function getTargets(list)
        if #list == 0 then return nil end
        return SpawnMode == "Multi" and list or { list[1] }
    end

    --// REMOTES
    local function fireQueue(id, selection)
        return pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UnitQueue"):FireServer(id, selection, true)
        end)
    end

	--// UPDATED HELPERS
	local function getFertile()
		local map = workspace:FindFirstChild("Map")
		-- Specifically looking for Map -> Shroud -> Terrain -> Fertile
		local shroud = map and map:FindFirstChild("Shroud")
		local terrain = shroud and shroud:FindFirstChild("Terrain")
		local fertile = terrain and terrain:FindFirstChild("Fertile")
		
		if not fertile then return {} end

		local list = {}
		for _, v in ipairs(fertile:GetChildren()) do
			-- Matches 'FertileA', 'FertileB', etc.
			if v.Name:find("Fertile") then 
				table.insert(list, v) 
			end
		end
		return list
	end

	--// UPDATED REMOTES
	local function placeFarm()
		local fertiles = getFertile()
		if #fertiles == 0 then return end
		
		-- Iterate through fertile spots to attempt placement
		for _, tile in ipairs(fertiles) do
			pcall(function()
				-- logic matches your example: "Farm", Instance, 0
				game:GetService("ReplicatedStorage")
					:WaitForChild("Remotes")
					:WaitForChild("PlaceBuilding")
					:InvokeServer("Farm", tile, 0)
			end)
		end
	end

	--// OIL PUMP HELPERS
	local function getOilSpots()
		local map = workspace:FindFirstChild("Map")
		local shroud = map and map:FindFirstChild("Shroud")
		local terrain = shroud and shroud:FindFirstChild("Terrain")
		local fertile = terrain and terrain:FindFirstChild("Fertile")
		
		if not fertile then return {} end

		local list = {}
		for _, v in ipairs(fertile:GetChildren()) do
			-- Filtering for Fertile tiles (like FertileA, FertileB)
			if v.Name:find("Fertile") then 
				table.insert(list, v) 
			end
		end
		return list
	end

	local function placeOilPump()
		local spots = getOilSpots()
		if #spots == 0 then return end
		
		-- logic matches your example: "Oil Pump", Instance, 0
		for _, tile in ipairs(spots) do
			pcall(function()
				game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlaceBuilding"):InvokeServer("Oil Pump", tile, 0)
			end)
		end
	end

	--// GOLD MINE HELPERS
	local function getOreSpots()
		local map = workspace:FindFirstChild("Map")
		local shroud = map and map:FindFirstChild("Shroud")
		local terrain = shroud and shroud:FindFirstChild("Terrain")
		local ore = terrain and terrain:FindFirstChild("Ore")
		
		if not ore then return {} end

		local list = {}
		for _, v in ipairs(ore:GetChildren()) do
			-- Specifically looking for OreA, OreB, etc.
			if v.Name:find("Ore") then 
				table.insert(list, v) 
			end
		end
		return list
	end

	local function placeGoldMine()
		local spots = getOreSpots()
		if #spots == 0 then return end
		
		for _, tile in ipairs(spots) do
			pcall(function()
				-- Matches your args: "Gold Mine", Instance, 0
				game:GetService("ReplicatedStorage")
					:WaitForChild("Remotes")
					:WaitForChild("PlaceBuilding")
					:InvokeServer("Gold Mine", tile, 0)
			end)
		end
	end

	--// OIL RIG HELPERS
	local function getOilRigSpots()
		local map = workspace:FindFirstChild("Map")
		local shroud = map and map:FindFirstChild("Shroud")
		local terrain = shroud and shroud:FindFirstChild("Terrain")
		local oilFolder = terrain and terrain:FindFirstChild("Oil")
		
		if not oilFolder then return {} end

		local list = {}
		for _, v in ipairs(oilFolder:GetChildren()) do
			-- Matches 'OilSpot' or variations like 'OilSpotA'
			if v.Name:find("OilSpot") then 
				table.insert(list, v) 
			end
		end
		return list
	end

	local function placeOilRig()
		local spots = getOilRigSpots()
		if #spots == 0 then return end
		
		for _, tile in ipairs(spots) do
			pcall(function()
				-- Matches your args: "Oil Rig", Instance, 0
				game:GetService("ReplicatedStorage")
					:WaitForChild("Remotes")
					:WaitForChild("PlaceBuilding")
					:InvokeServer("Oil Rig", tile, 0)
			end)
		end
	end

    --// MAIN TAB
    MTab:CreateDropdown({
        Name = "Choose Color",
        Options = {"None", "Blue", "Green", "Orange", "Purple", "Red", "Yellow", "White"},
        CurrentOption = {"None"},
        MultipleOptions = false,
        Callback = function(Options) SelectedColor = Options[1] end,
    })

    --// BUILD TAB
    BTab:CreateButton({
        Name = "Manual Place Farm",
        Callback = function() placeFarm() end,
    })

    BTab:CreateToggle({
        Name = "Auto Place Farm",
        CurrentValue = false,
        Callback = function(v)
            autoFarm = v
            if not v then return end
            -- FIX: increment ID so any previous loop sees a stale ID and exits
            autoFarmId += 1
            local myId = autoFarmId
            task.spawn(function()
                while autoFarm and autoFarmId == myId do
                    placeFarm()
                    task.wait()
                end
            end)
        end,
    })

	--// OIL PUMP UI
	BTab:CreateSection("Oil")

	BTab:CreateButton({
		Name = "Manual Place Oil Pump",
		Callback = function() 
			placeOilPump() 
		end,
	})

	local autoOil = false
	local autoOilId = 0

	BTab:CreateToggle({
		Name = "Auto Place Oil Pump",
		CurrentValue = false,
		Callback = function(v)
			autoOil = v
			if not v then return end
			
			autoOilId += 1
			local myId = autoOilId
			task.spawn(function()
				while autoOil and autoOilId == myId do
					placeOilPump()
					task.wait(1) -- Set to 1 second to prevent server lag, adjust if needed
				end
			end)
		end,
	})

	--// GOLD MINE UI
	BTab:CreateSection("Gold")

	BTab:CreateButton({
		Name = "Manual Place Gold Mine",
		Callback = function() 
			placeGoldMine() 
		end,
	})

	local autoGold = false
	local autoGoldId = 0

	BTab:CreateToggle({
		Name = "Auto Place Gold Mine",
		CurrentValue = false,
		Callback = function(v)
			autoGold = v
			if not v then return end
			
			autoGoldId += 1
			local myId = autoGoldId
			task.spawn(function()
				while autoGold and autoGoldId == myId do
					placeGoldMine()
					-- Gold mines are usually limited by the number of nodes, 
					-- so a 1s wait is safe and efficient.
					task.wait(1) 
				end
			end)
		end,
	})

	--// OIL RIG UI
	BTab:CreateSection("Oil")

	BTab:CreateButton({
		Name = "Manual Place Oil Rig",
		Callback = function() 
			placeOilRig() 
		end,
	})

	local autoRig = false
	local autoRigId = 0

	BTab:CreateToggle({
		Name = "Auto Place Oil Rig",
		CurrentValue = false,
		Callback = function(v)
			autoRig = v
			if not v then return end
			
			autoRigId += 1
			local myId = autoRigId
			task.spawn(function()
				while autoRig and autoRigId == myId do
					placeOilRig()
					task.wait(1) 
				end
			end)
		end,
	})

    --// ARMY TAB
    ATab:CreateDropdown({
        Name = "Spawn Mode",
        Options = {"Single", "Multi"},
        CurrentOption = {"Single"},
        MultipleOptions = false,
        Callback = function(Options) SpawnMode = Options[1] or "Single" end,
    })

    -- Units
    ATab:CreateSection("Units")
    ATab:CreateDropdown({
        Name = "Choose Unit",
        Options = {"None", "Builder", "Scout", "Gunner", "Shotgunner", "Sniper", "Rocketeer"},
        CurrentOption = {"None"},
        MultipleOptions = false,
        Callback = function(Options) SelectedUnit = Options[1] or "None" end,
    })

    ATab:CreateButton({
        Name = "Manual Train Unit",
        Callback = function()
            if SelectedUnit == "None" then return end
            local targets = getTargets(findStructures("Training Camp"))
            if not targets then return end
            for _, c in ipairs(targets) do
                local id = getId(c)
                if id then fireQueue(id, SelectedUnit) end
            end
        end,
    })

    ATab:CreateToggle({
        Name = "Auto Train Units",
        CurrentValue = false,
        Callback = function(v)
            autoUnit = v
            if not v then return end
            autoUnitId += 1
            local myId = autoUnitId
            task.spawn(function()
                while autoUnit and autoUnitId == myId do
                    if SelectedUnit ~= "None" then
                        local targets = getTargets(findStructures("Training Camp"))
                        if targets then
                            for _, c in ipairs(targets) do
                                if not autoUnit or autoUnitId ~= myId then break end
                                local id = getId(c)
                                if id then fireQueue(id, SelectedUnit) end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end,
    })

    -- Vehicles
    ATab:CreateSection("Vehicles")
    ATab:CreateDropdown({
        Name = "Choose Vehicle",
        Options = {"None", "Humvee", "Light Tank", "Heavy Tank", "Missile Truck"},
        CurrentOption = {"None"},
        MultipleOptions = false,
        Callback = function(Options) SelectedVehicle = Options[1] or "None" end,
    })

    ATab:CreateButton({
        Name = "Manual Train Vehicle",
        Callback = function()
            if SelectedVehicle == "None" then return end
            local targets = getTargets(findStructures("Vehicle Factory"))
            if not targets then return end
            for _, f in ipairs(targets) do
                local id = getId(f)
                if id then fireQueue(id, SelectedVehicle) end
            end
        end,
    })

    ATab:CreateToggle({
        Name = "Auto Vehicle",
        CurrentValue = false,
        Callback = function(v)
            autoVehicle = v
            if not v then return end
            autoVehicleId += 1
            local myId = autoVehicleId
            task.spawn(function()
                while autoVehicle and autoVehicleId == myId do
                    if SelectedVehicle ~= "None" then
                        local targets = getTargets(findStructures("Vehicle Factory"))
                        if targets then
                            for _, f in ipairs(targets) do
                                if not autoVehicle or autoVehicleId ~= myId then break end
                                local id = getId(f)
                                if id then fireQueue(id, SelectedVehicle) end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end,
    })

    -- Boats
    ATab:CreateSection("Boats")
    ATab:CreateDropdown({
        Name = "Choose Boat",
        Options = {"None", "Speed Boat", "Builder Boat", "Barge", "Destroyer", "Submarine"},
        CurrentOption = {"None"},
        MultipleOptions = false,
        Callback = function(Options) SelectedBoat = Options[1] or "None" end,
    })

    ATab:CreateButton({
        Name = "Manual Train Boat",
        Callback = function()
            if SelectedBoat == "None" then return end
            local targets = getTargets(findStructures("Harbor"))
            if not targets then return end
            for _, h in ipairs(targets) do
                local id = getId(h)
                if id then fireQueue(id, SelectedBoat) end
            end
        end,
    })

    ATab:CreateToggle({
        Name = "Auto Boat",
        CurrentValue = false,
        Callback = function(v)
            autoBoat = v
            if not v then return end
            autoBoatId += 1
            local myId = autoBoatId
            task.spawn(function()
                while autoBoat and autoBoatId == myId do
                    if SelectedBoat ~= "None" then
                        local targets = getTargets(findStructures("Harbor"))
                        if targets then
                            for _, h in ipairs(targets) do
                                if not autoBoat or autoBoatId ~= myId then break end
                                local id = getId(h)
                                if id then fireQueue(id, SelectedBoat) end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end,
    })

    --// VISUALS
    -- FIX: "Show Map" was incorrectly placed on MTab; moved to VTab where it belongs
    VTab:CreateButton({
        Name = "Show Map",
        Callback = function()
            local map = getMap()
            if not map then return end
            for _, v in ipairs(map:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    local col = v:GetAttribute("FogOfWarColor")
                    if col then v.Color = col end
                elseif v:IsA("Model") then
                    v:SetAttribute("FogOfWarHidden", false)
                end
            end
        end,
    })

    --// FUNNYS TAB
    FTab:CreateToggle({
        Name = "Show Tester",
        CurrentValue = false,
        Callback = function(v) LocalPlayer:SetAttribute("IsTester", v) end,
    })
end

--zoo or oof
if game.PlaceId == 139233844569220 then
	local VTab = Window:CreateTab("Visual", 4483362458)

	local espList = {}

	VTab:CreateToggle({
		Name = "Animal ESP",
		CurrentValue = false,
		Callback = function(Value)
			if Value then
				for _, v in pairs(workspace.Gameplay.Dynamic.Animals:GetChildren()) do
					local esp = Instance.new("Highlight")
					esp.Parent = v
					espList[v] = esp
				end
			else
				for _, esp in pairs(espList) do
					if esp then
						esp:Destroy()
					end
				end
				espList = {}
			end
		end,
	})
end

--dig or die
if game.PlaceId == 87341346192053 then

	--[[
		local function MTA(toolName, attributes)
			local player = game.Players.LocalPlayer
			local tool = player.Backpack:FindFirstChild(toolName) or player.Character:FindFirstChild(toolName)

			if tool then
				for attribute, value in pairs(attributes) do
					tool:SetAttribute(attribute, value)
				end
				print("found")
			else
				print("not found or is equiped")
			end
		end
		]]
	

	local MTab = Window:CreateTab("Mod Stuff", 4483362458) -- Title, Image

	MTab:CreateButton({
		Name = "Mod Shovel",
		Callback = function()
			for _, v in pairs(player.Backpack:GetChildren()) do
				if v:IsA("Tool") and v.Name:find("Shovel") then
					v:SetAttribute("BlockBreakCooldown", 0)
					v:SetAttribute("BlockBreakCooldownBase", 0)
					v:SetAttribute("BlockBreakDamage", 999)
				end
			end
		end,
	})

		local b = game:GetService("Players").LocalPlayer.Backpack.Name:find("Block")
	local s = game:GetService("Players").LocalPlayer.Backpack.Name:find("Shovel")


	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	MTab:CreateButton({
		Name = "Mod Blocks",
		Callback = function()
			for _, v in pairs(player.Backpack:GetChildren()) do
				if v:IsA("Tool") and v.Name:find("Block") then
					v:SetAttribute("Cooldown", 0)
				end
			end
		end,
	})
end

--volleyBall Legends
if game.PlaceId == 73956553001240 then
	local Services = {
		Players = game:GetService("Players"),
		RunService = game:GetService("RunService"),
		Workspace = game:GetService("Workspace"),
		CoreGui = game:GetService("CoreGui"),
		TeleportService = game:GetService("TeleportService"),
		UserInputService = game:GetService("UserInputService")
	}

	local Hitbox = {
		Enabled = false,
		Interval = 5,
		Size = 1.0,
		CurrentSize = 1.0,
		Color = Color3.fromRGB(0, 255, 100),
	}

	function Hitbox:ApplyToBall(model)
		if not model:IsA("Model") then return end
		if not model.Name:match("^CLIENT_BALL_%d+$") then return end

		local basePart
		for _, child in ipairs(model:GetDescendants()) do
			if child:IsA("BasePart") then
				basePart = child
				break
			end
		end

		if not basePart then return end

		local hitbox = model:FindFirstChild("HB")

		if not hitbox then
			hitbox = Instance.new("Part")
			hitbox.Name = "HB"
			hitbox.Shape = Enum.PartType.Ball
			hitbox.Size = Vector3.new(2, 2, 2) * self.CurrentSize
			hitbox.CFrame = basePart.CFrame
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.Material = Enum.Material.ForceField
			hitbox.Color = self.Color
			hitbox.Parent = model
		else
			hitbox.Size = Vector3.new(2, 2, 2) * self.CurrentSize
			hitbox.CFrame = basePart.CFrame
			hitbox.Color = self.Color
		end
	end

	function Hitbox:UpdateAll()
		if not self.Enabled then return end

		self.CurrentSize = self.Size -- driven by slider

		for _, model in ipairs(Services.Workspace:GetDescendants()) do
			if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
				self:ApplyToBall(model)
			end
		end
	end

	function Hitbox:StartAutoUpdate()
		if self.UpdateThread then
			self.UpdateThread:Disconnect()
		end

		self.UpdateThread = Services.RunService.Heartbeat:Connect(function()
			if tick() - (self.LastUpdate or 0) >= self.Interval then
				self:UpdateAll()
				self.LastUpdate = tick()
			end
		end)
	end

	function Hitbox:Cleanup()
		if self.UpdateThread then
			self.UpdateThread:Disconnect()
			self.UpdateThread = nil
		end

		for _, model in ipairs(Services.Workspace:GetDescendants()) do
			if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
				local hitbox = model:FindFirstChild("HB")
				if hitbox then 
					hitbox:Destroy() 
				end
			end
		end
	end

	function Hitbox:Unload()
		self.Enabled = false
		self:Cleanup()
	end

	Services.Workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
			task.wait(0.1)
			if Hitbox.Enabled then
				Hitbox:ApplyToBall(child)
			end
		end
	end)

	-- ============================
	-- 🎯 UI CONTROLS
	-- ============================
	local MainTab = Window:CreateTab("Hitboxes", "target")

	MainTab:CreateToggle({
		Name = "Enable Hitboxes V1",
		CurrentValue = Hitbox.Enabled,
		Callback = function(state)
			Hitbox.Enabled = state
			
			if state then
				Hitbox:StartAutoUpdate()
				Hitbox:UpdateAll()
			else
				Hitbox:Cleanup()
			end
		end
	})

	MainTab:CreateSlider({
		Name = "Hitbox Size",
		Range = {0.5, 20},
		Increment = 0.1,
		Suffix = "x",
		CurrentValue = Hitbox.Size,
		Callback = function(value)
			Hitbox.Size = value
			if Hitbox.Enabled then
				Hitbox:UpdateAll()
			end
		end
	})

	MainTab:CreateColorPicker({
		Name = "Color",
		Color = Hitbox.Color,
		Callback = function(color)
			Hitbox.Color = color
			if Hitbox.Enabled then
				Hitbox:UpdateAll()
			end
		end
	})

	local hitboxScale = 5.0

	-- Find the first BasePart in a model
	local function findFirstPart(model)
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				return descendant
			end
		end
	end

	-- Update hitboxes for client balls
	local function updateHitboxes(scale)
		for _, model in ipairs(Workspace:GetChildren()) do
			if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
				local ball = model:FindFirstChild("Ball.001")
				if not ball then
					local basePart = findFirstPart(model)
					if basePart then
						ball = Instance.new("Part")
						ball.Name = "Ball.001"
						ball.Shape = Enum.PartType.Ball
						ball.Size = Vector3.new(2, 2, 2) * scale
						ball.CFrame = basePart.CFrame
						ball.Anchored = true
						ball.CanCollide = false
						ball.Transparency = 0.7
						ball.Material = Enum.Material.ForceField
						ball.Color = Color3.fromRGB(0, 255, 0)
						ball.Parent = model
					end
				else
					ball.Size = Vector3.new(2, 2, 2) * scale
				end
			end
		end
	end

	-- Remove all hitboxes
	local function removeHitboxes()
		for _, model in ipairs(Workspace:GetChildren()) do
			if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
				local ball = model:FindFirstChild("Ball.001")
				if ball then
					ball:Destroy()
				end
			end
		end
	end

	-- Monitor for new client balls
	Workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
			task.wait(0.1)
			updateHitboxes(hitboxScale)
		end
	end)

	MainTab:CreateToggle({
		Name = "Hitbox V2",
		CurrentValue = false,
		Callback = function(state)
			if state then
				updateHitboxes(hitboxScale)
			else
				updateHitboxes(0)
			end
		end
	})

	MainTab:CreateSlider({
		Name = "Hitbox V2 Size",
		Range = {0, 20},
		Increment = 0.1,
		Suffix = "x",
		CurrentValue = hitboxScale,
		Callback = function(value)
			hitboxScale = value
			updateHitboxes(value)
		end
	})

	-- Remove hitboxes button
	MainTab:CreateButton({
		Name = "Remove Hitboxes V2",
		Callback = function()
			removeHitboxes()
			-- Rayfield:Notify({
			-- 	Title = "Hitboxes Removed",
			-- 	Content = "All hitboxes cleared",
			-- 	Duration = 2,
			-- 	Image = "power-off"
			-- })
		end
	})

	local LinesTab = Window:CreateTab("Lines", "eye")
	local lineDistance = 50
	local lines = {}
	local linesEnabled = true
	local lineColors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(255, 165, 0),
		Color3.fromRGB(128, 0, 128),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(139, 0, 0),
		Color3.fromRGB(0, 100, 0)
	}

	-- Remove line for a player
	local function removeLine(player)
		local data = lines[player]
		if data then
			if data.beam then data.beam:Destroy() end
			if data.target and data.target.Parent then data.target:Destroy() end
			if data.attachment and data.attachment.Parent then data.attachment:Destroy() end
			lines[player] = nil
		end
	end

	-- Update line for a player
	local function updateLine(player, index)
		if not linesEnabled then
			removeLine(player)
			return
		end

		local character = player.Character
		if not character or not character:FindFirstChild("Head") or not character:FindFirstChild("HumanoidRootPart") then
			removeLine(player)
			return
		end

		local head = character.Head
		local rootPart = character.HumanoidRootPart

		if not lines[player] then
			local attachment = Instance.new("Attachment", head)
			local target = Instance.new("Part")
			target.Anchored = true
			target.CanCollide = false
			target.Transparency = 1
			target.Size = Vector3.new(0.1, 0.1, 0.1)
			target.Parent = Workspace

			local targetAttachment = Instance.new("Attachment", target)
			local beam = Instance.new("Beam")
			beam.Attachment0 = attachment
			beam.Attachment1 = targetAttachment
			beam.Width0 = 0.25
			beam.Width1 = 0.25
			beam.FaceCamera = true
			beam.LightEmission = 1
			beam.Transparency = NumberSequence.new(0.3)
			beam.Color = ColorSequence.new(lineColors[(index - 1) % #lineColors + 1])
			beam.Parent = head

			lines[player] = { beam = beam, target = target, attachment = attachment }
		end

		local data = lines[player]
		data.target.Position = head.Position + rootPart.CFrame.LookVector * lineDistance
	end

	-- Update lines for all players
	RunService.RenderStepped:Connect(function()
		if linesEnabled then
			for index, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
					updateLine(player, index)
				else
					removeLine(player)
				end
			end
		else
			for player in pairs(lines) do
				removeLine(player)
			end
		end
	end)

	-- Handle player leaving
	Players.PlayerRemoving:Connect(removeLine)

	-- Enable lines toggle
	LinesTab:CreateToggle({
		Name = "Enable Lines",
		CurrentValue = true,
		Callback = function(value)
			linesEnabled = value
			if not value then
				for player in pairs(lines) do
					removeLine(player)
				end
			end
		end
	})

	-- Line distance slider
	LinesTab:CreateSlider({
		Name = "Line Distance",
		Range = {0, 100},
		Increment = 10,
		CurrentValue = lineDistance,
		Suffix = " studs",
		Callback = function(value)
			lineDistance = value
		end
	})

	-- Note about lines
	LinesTab:CreateParagraph({
		Title = "Note",
		Content = "If the lines do not appear, just turn the toggle off and on."
	})


	-- Character Tab
	local CharacterTab = Window:CreateTab("Character", "user-round")
	local autoShiftLock = true
	local airMovement = false
	local airMovementSpeed = 16
	local bodyVelocity = nil

	-- Get current walk speed
	local function getWalkSpeed()
		local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
		return humanoid and humanoid.WalkSpeed or 16
	end

	-- Apply air control velocity
	local function applyAirControl(rootPart)
		if bodyVelocity then return end
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.P = 2500
		bodyVelocity.Name = "AirControlVelocity"
		bodyVelocity.Parent = rootPart
	end

	-- Remove air control velocity
	local function removeAirControl()
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
	end

	-- Character setup
	local function setupCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		airMovementSpeed = getWalkSpeed()

		-- Handle jumping and shift lock
		humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			if humanoid.Jump then
				if autoShiftLock then
					task.defer(function()
						task.wait(0.03)
						local lookVector = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
						if lookVector.Magnitude > 0 then
							rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookVector.Unit)
							humanoid.AutoRotate = false
						end
					end)
				else
					humanoid.AutoRotate = true
				end
			end
		end)

		-- Handle air movement
		humanoid.StateChanged:Connect(function(oldState, newState)
			if newState == Enum.HumanoidStateType.Freefall then
				if airMovement then
					applyAirControl(rootPart)
				end
			elseif newState == Enum.HumanoidStateType.Landed then
				removeAirControl()
				humanoid.AutoRotate = true
			end
		end)
	end

	-- Initialize character
	if LocalPlayer.Character then
		setupCharacter(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(setupCharacter)



	-- Air movement toggle
	CharacterTab:CreateToggle({
		Name = "Air Movement (Freeflight)",
		CurrentValue = false,
		Callback = function(value)
			airMovement = value
			if not value then
				removeAirControl()
			end
		end
	})

	-- Air movement speed slider
	CharacterTab:CreateSlider({
		Name = "Air Movement Speed",
		Range = {0, 100},
		Increment = 1,
		CurrentValue = getWalkSpeed(),
		Suffix = " studs/s",
		Callback = function(value)
			airMovementSpeed = value
		end
	})


	-- Update air movement velocity
	RunService.RenderStepped:Connect(function()
		if airMovement and bodyVelocity and LocalPlayer.Character then
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if humanoid then
				bodyVelocity.Velocity = humanoid.MoveDirection * airMovementSpeed
			end
		end
	end)

end 


-- spider mines
if game.PlaceId == 136303206020127 then

	local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image

	local pickaxe = "Rusted Pickaxe" -- default

	local Dropdown = Tab:CreateDropdown({
		Name = "Choose Pickaxe",
		Options = {"Rusted Pickaxe", "Pickaxe", "Heavy Pickaxe", "Drill"},
		CurrentOption = {"Rusted Pickaxe"},
		MultipleOptions = false,
		Flag = "Dropdown1",
		Callback = function(Options)
			pickaxe = Options[1] -- store selected pickaxe
		end,
	})

	local mining = false

	local Toggle = Tab:CreateToggle({
		Name = "Auto Mine(laggy when spiders spawn)",
		CurrentValue = false,
		Callback = function(Value)
			mining = Value

			if mining then
				task.spawn(function()
					while mining do
						local remote = game:GetService("Players")
							.LocalPlayer
							:WaitForChild("Backpack")
							:WaitForChild(pickaxe)
							:WaitForChild("RemoteEvent")

						local hitMap = {
							["Rusted Pickaxe"] = 5,
							["Pickaxe"] = 5,
							["Heavy Pickaxe"] = 5,
							["Drill"] = 4
						}

						local hitsPerDirt = hitMap[pickaxe] or 5
						

						for _, v in ipairs(workspace.Generation:GetDescendants()) do
							if not mining then break end

							if v.Name == "Dirt" then
								for i = 1, hitsPerDirt do
									if not mining then break end
									if not v or not v.Parent then break end

									remote:FireServer(v)
									task.wait(0.1)
								end
							end
						end

						task.wait(1)
					end
				end)
			end
		end,
	})


	Tab:CreateButton({
		Name = "Remove Spiders (Client)",
		Callback = function()
			for i, v in ipairs(workspace:GetChildren()) do
				if v.Name:find("Lurker") or v.Name:find("Jumper") or v.Name:find("Arachnid") or v.Name:find("Bomber") then
					v:Destroy()
				end
			end
		end,
	})
end

if game.PlaceId == 115235776084989 then
	local MTab = Window:CreateTab("Monies", 4483362458) -- Title, Image

	local function getHRP()
		local char = player.Character or player.CharacterAdded:Wait()
		return char:WaitForChild("HumanoidRootPart")
	end

	local hrp = getHRP()
	local folder = workspace:WaitForChild("Map")

	local startCFrame = hrp.CFrame
	local running = false

	local function getPartFromPrompt(prompt)
		local parent = prompt.Parent

		if parent:IsA("BasePart") then
			return parent
		elseif parent:IsA("Attachment") and parent.Parent:IsA("BasePart") then
			return parent.Parent
		end
	end

	local function triggerPrompt(prompt)
		if not prompt or not prompt.Parent then return end

		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false

		local part = getPartFromPrompt(prompt)
		if not part then return end

		hrp.CFrame = part.CFrame
		task.wait(0)

		for i = 1, 3 do
			if not running then return end

			fireproximityprompt(prompt, 1)
			task.wait(0)

			if not prompt.Parent then
				break
			end
		end
	end

	MTab:CreateToggle({
		Name = "Auto Collect",
		CurrentValue = false,
		Callback = function(Value)
			running = Value

			if running then
				task.spawn(function()
					while running do
						for _, v in ipairs(folder:GetDescendants()) do
							if not running then break end

							if v:IsA("ProximityPrompt") and v.ActionText == "Collect" then
								triggerPrompt(v)
								task.wait(0)
							end
						end
						task.wait(0)
					end
				end)
			else
				-- return to start position when turned off
				if hrp then
					hrp.CFrame = startCFrame
				end
			end
		end,
	})
end


--# clicks for owner
if game.PlaceId == 124768944923060 then
    local Tab = Window:CreateTab("Auto", 4483362458)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")

    -- FIX: hoist shared services to the top so both callbacks can access them

    local clickConnection = nil
    Tab:CreateButton({
        Name = "Auto Click",
        Callback = function()
            if clickConnection then return end -- FIX: prevent stacking connections
            local ClickRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Click")
            clickConnection = RunService.Heartbeat:Connect(function()
                pcall(function() ClickRemote:FireServer() end)
            end)
        end,
    })

    local upgradeConnection = nil
    Tab:CreateButton({
        Name = "Auto Buy Upgrade", -- FIX: was duplicate "Auto Click"
        Callback = function()
            if upgradeConnection then return end -- FIX: prevent stacking connections
            local event = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("BuyUpgrade")
            upgradeConnection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    event:FireServer(table.unpack({ "ClickMultiplier" })) -- FIX: table.unpack
                end)
            end)
        end,
    })
end

--survive in area 51
if game.PlaceId == 2214661900 then
	local MTab = Window:CreateTab("Main", "sprout")
	local TTab = Window:CreateTab("Grab Guns", "sprout")
	local GTab = Window:CreateTab("Gun Mods", "sprout")

	-- GTab:CreateParagraph({
	-- 	Title = "NEED EXECUTOR SUPPORT",
	-- 	Content = "Your executor needs hookfunction + getsenv support for the dash mod to work."
	-- })

	local function gettime()
    local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("EventGUI") then
        local timeValue = gui.EventGUI:FindFirstChild("Time")
        return timeValue and timeValue.Value or 0
    end
    return 0
end

-- ==================== INSTANT REGENERATION BUTTON ====================
MTab:CreateButton({
    Name = "Instant regeneration (One Time)",
    Callback = function()
        pcall(function()
            local head = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Head")
            if not head then return end

            local armor = Workspace.Misc and Workspace.Misc:FindFirstChild("Blizzard Armor")
            if armor and armor:FindFirstChild("Head") then
                firetouchinterest(head, armor.Head, 1)
                firetouchinterest(head, armor.Head, 0)
            end
        end)
    end
})

-- ==================== INSTANT REGENERATION TOGGLE ====================
local loip = false

local armorByTime = {
    { min = 0,  max = 15, name = "Blizzard Armor" },
    { min = 15, max = 30, name = "Silver Armor - 15 min Playtime" },
    { min = 30, max = 60, name = "Golden Armor - 30 min Playtime" },
    { min = 60, max = math.huge, name = "Diamond Armor - 60 min Playtime" },
}

MTab:CreateToggle({
    Name = "Instant regeneration (Toggle)",
    Default = false,
    Callback = function(Value)
        loip = Value

        if not Value then return end

        task.spawn(function()
            while loip do
                pcall(function()
                    local character = game.Players.LocalPlayer.Character
                    if not character then return end

                    local head = character:FindFirstChild("Head")
                    if not head then return end

                    local time = gettime()
                    local misc = Workspace:FindFirstChild("Misc")
                    if not misc then return end

                    for _, entry in ipairs(armorByTime) do
                        if time >= entry.min and time < entry.max then
                            local armor = misc:FindFirstChild(entry.name)
                            if armor and armor:FindFirstChild("Head") then
                                firetouchinterest(head, armor.Head, 1)
                                firetouchinterest(head, armor.Head, 0)
                            end
                            break
                        end
                    end
                end)

                task.wait(0.3)
            end
        end)
    end
})

	MTab:CreateButton({
    Name = "Unpack all supply items",
    Callback = function()
        task.spawn(function()
            local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
            local saved = hrp.CFrame

            for _, promp in ipairs(workspace:GetChildren()) do
                if promp:IsA("BasePart") 
                    and (promp.Name == "SupplyBox" or promp.Name == "SupplyBall")
                    and promp:FindFirstChildOfClass("Highlight") then -- ✅ fixed

                    local prompt = promp:FindFirstChild("ProximityPrompt")
                    if not prompt then continue end

                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = math.huge
                    prompt.Enabled = true
                    prompt.ClickablePrompt = true

                    repeat
                        task.wait(0.1)
                        hrp.CFrame = promp.CFrame
                        pcall(function() fireproximityprompt(prompt, 0) end)
                    until not promp.Parent or not promp:FindFirstChild("ProximityPrompt")
                end
            end

            task.wait(0.1)
            hrp.CFrame = saved
        end)
    end
})

	local togl = false
local auraRange = 50
local auraConnection = nil

-- Range Slider
MTab:CreateSlider({
	Name = "Hit Aura Range",
	Range = {10, 200},
	CurrentValue = 50,
	Increment = 5,
	Callback = function(Value)
		auraRange = Value
	end
})

-- Hit Aura Toggle (Multi-Target)
MTab:CreateToggle({
	Name = "Hit aura",
	Default = false,
	Callback = function(Value)
		togl = Value
		
		if Value then
			if auraConnection then
				auraConnection:Disconnect()
			end
			
			auraConnection = task.spawn(function()
				while togl do
					pcall(function()
						local player = game.Players.LocalPlayer
						local character = player.Character
						if not character then return end
						
						local root = character:FindFirstChild("HumanoidRootPart")
						local tool = character:FindFirstChildOfClass("Tool")
						if not root or not tool then return end
						
						local gunScript = tool:FindFirstChild("GunScript_Server")
						if not gunScript then return end
						
						local remote = gunScript:FindFirstChild("InflictTarget")
						if not remote then return end
						
						-- Get all parts in range
						local parts = workspace:GetPartBoundsInRadius(root.Position, auraRange)
						
						for _, part in ipairs(parts) do
							if not part then continue end
							
							local model = part.Parent
							if not model or not model:IsA("Model") or model == character then
								continue
							end
							
							local humanoid = model:FindFirstChildOfClass("Humanoid")
							local head = model:FindFirstChild("Head")
							
							-- Hit every valid target
							if humanoid and head then
								pcall(function()
									remote:FireServer(
										"Head",
										humanoid,
										head,
										tool,
										Vector3.new(0.937201201915741, -0.3045220375061035, -0.17005980014801025)
									)
								end)
							end
						end
					end)
					
					task.wait(0.07) -- Faster loop = hits more targets per second
				end
			end)
			
		else
			togl = false
			if auraConnection then
				auraConnection:Disconnect()
				auraConnection = nil
			end
		end
	end
})

 --[[MTab:CreateToggle({
	Name = "Powerful hit aura",
	Default = false,
	Callback = function(Value)
		togl = Value
		while togl and task.wait(0.1) do
			pcall(function()
		local parts = workspace:GetPartBoundsInRadius(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, 40)
		for _, part in ipairs(parts) do
			if part.Parent:IsA("Model") and part.Parent:FindFirstChildOfClass("Humanoid") and part.Parent ~= game.Players.LocalPlayer.Character and part.Parent.Name ~= "FakeFriend" then
		local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid.Health > 0 and not game.Players:GetPlayerFromCharacter(humanoid.Parent) and not humanoid:IsDescendantOf(Workspace.Ground) and not humanoid:IsDescendantOf(Workspace.Mineshaft) then
		for _, tool in next, table.merger(game.Players.LocalPlayer.Character:GetChildren(), game.Players.LocalPlayer.Backpack:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("GunScript_Server") then
		local args = {
			[1] = "Head",
			[2] = humanoid,
			[3] = humanoid.Parent.Head,
			[4] = tool,
			[5] = Vector3.new(0.937201201915741, -0.3045220375061035, -0.17005980014801025)
		}

		tool.GunScript_Server.InflictTarget:FireServer(unpack(args))
				end
				end
			end
			end
			end
			end)
			end
		end    
	})


	-- GTab:CreateButton({
	-- 	Name = "No Burn Sword Dash Cooldown",
	-- 	Callback = function()
	-- 		local player = game.Players.LocalPlayer
	-- 		local sword = player.Backpack:FindFirstChild("Burning Sword") or player.Character and player.Character:FindFirstChild("Burning Sword")
			
	-- 		if not sword then
	-- 			Rayfield:Notify({
	-- 				Title = "Burning Sword Not Found",
	-- 				Content = "Equip the Burning Sword first!",
	-- 				Duration = 5,
	-- 				Image = 4483362458,
	-- 			})
	-- 			return
	-- 		end

	-- 		local localScript = sword:FindFirstChild("LocalScript") or sword:FindFirstChildWhichIsA("LocalScript")
	-- 		if not localScript then
	-- 			Rayfield:Notify({
	-- 				Title = "Error",
	-- 				Content = "Could not find Burning Sword LocalScript",
	-- 				Duration = 5,
	-- 			})
	-- 			return
	-- 		end

	-- 		local senv = getsenv(localScript)
	-- 		local dashFunc = senv.Dash or senv.dash -- try both common namings

	-- 		if not dashFunc then
	-- 			Rayfield:Notify({
	-- 				Title = "Hook Failed",
	-- 				Content = "Dash function not found in script environment",
	-- 				Duration = 6,
	-- 			})
	-- 			return
	-- 		end

	-- 		-- Hook the dash function
	-- 		hookfunction(dashFunc, function(...)
	-- 			-- Force CanDash to true
	-- 			local char = player.Character
	-- 			if char and char:FindFirstChild("CanDash") then
	-- 				char.CanDash.Value = true
    --                 char:setattribute("Ready", true)
	-- 			end

				
	-- 			-- Call original with original args
	-- 			return dashFunc(...) 
	-- 		end)

	-- 		Rayfield:Notify({
	-- 			Title = "Success",
	-- 			Content = "Burning Sword dash cooldown removed!",
	-- 			Duration = 5,
	-- 		})
	-- 	end
	-- })
	
]]

	local Players = game:GetService("Players")
local Workspace = workspace
local player = Players.LocalPlayer

-- ==================== HELPER ====================
local function getPart(model)
	if not model then return nil end
	if model:IsA("BasePart") then return model end
	return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

-- ==================== FIRE SWORD FUNCTION ====================
local function getFireSword()
	print("🔥 Starting Fire Sword procedure...")
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local savedCFrame = hrp.CFrame

	local incinerator = Workspace:FindFirstChild("Incinerator", true)
	if incinerator then
		-- print every child and their children
		for _, child in ipairs(incinerator:GetDescendants()) do
			if child:IsA("ProximityPrompt") then
				print("PROMPT:", child:GetFullName())
			end
			if child.Name:lower():find("button") or child.Name:lower():find("challenge") then
				print("BUTTON:", child:GetFullName(), child.ClassName)
			end
		end
	else
		warn("Incinerator not found")
	end

	local function firePrompt(prompt)
		if fireproximityprompt then
			fireproximityprompt(prompt, 0) -- ✅ pass 0 duration directly
		else
			prompt:InputBegan()
			task.wait()
			prompt:InputEnded()
		end
	end

	local function activateButton(buttonName)
		local cb = incinerator:FindFirstChild(buttonName, true)
		if not cb then print("⚠️ Button not found: " .. buttonName) return end

		local prompt = cb:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not prompt then warn("⚠️ No ProximityPrompt found for " .. buttonName) return end

		local part = getPart(cb)

		for i = 1, 50 do
			if part then hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) end
			fireproximityprompt(prompt)
			task.wait(0.25)
			if not prompt.Enabled then
				print("✅ " .. buttonName .. " done")
				break
			end
		end
	end

	for i = 1, 7 do
		activateButton("ChallengeButton" .. i)
	end

	local swordPart = incinerator:FindFirstChild("GetBurningSword", true)
	if swordPart then
		local part = getPart(swordPart)
		hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
		task.wait(0.4)
		for i = 1, 6 do
			firetouchinterest(hrp, part, 0)
			task.wait(0.1)
			firetouchinterest(hrp, part, 1)
			task.wait(0.1)
		end
		print("✅ Fire sword collected!")
	else
		warn("⚠️ GetBurningSword not found")
	end

	task.wait(1.5)
	hrp.CFrame = savedCFrame
	print("🔥 Fire Sword done!")
end

-- ==================== WATER GUN FUNCTION ====================
local function getWaterGun()
	print("💧 Starting Water Gun procedure...")
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local sewer = Workspace:FindFirstChild("Sewer", true)
	if not sewer then warn("❌ Sewer not found") return end

	local function doValve(valve)
		local prompt = valve and valve:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not prompt then warn("❌ Prompt not found for " .. tostring(valve)) return end
		for i = 1, 25 do
			local part = getPart(valve)
			if part then hrp.CFrame = CFrame.new(part.Position) end
			fireproximityprompt(prompt)
			task.wait(0.25)
			if not prompt.Enabled then print("✅ " .. valve.Name .. " done") break end
		end
	end

	doValve(sewer:FindFirstChild("Valve1", true))
	doValve(sewer:FindFirstChild("Valve2", true))

	hrp.CFrame = CFrame.new(-362, 960, -54)
end

-- ==================== WEAPONS TABLE ====================
local weapons = {
	["Ice crossbow"] = function(hrp)
		local zone = Workspace:FindFirstChild("IceZone", true)
		local part = zone and getPart(zone:FindFirstChild("GetIceCrossbow", true))
		if part then
			hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			task.wait(0.2)
			firetouchinterest(hrp, part, 0) task.wait(0.1) firetouchinterest(hrp, part, 1)
		else warn("❌ Ice Crossbow not found") end
	end,

	["Volcano"] = function(hrp)
		local zone = Workspace:FindFirstChild("LavaZone", true)
		local part = zone and getPart(zone:FindFirstChild("Escape", true))
		if part then
			hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			task.wait(0.2)
			firetouchinterest(hrp, part, 0) task.wait(0.1) firetouchinterest(hrp, part, 1)
		else warn("❌ Volcano not found") end
	end,

	["Rocket Launcher"] = function(hrp)
		hrp.CFrame = CFrame.new(-354, 1073, 411)
	end,

	["LXW"] = function(hrp)
		local exit = Workspace:FindFirstChild("Exit", true)
		local part = getPart(exit)
		if part then
			hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			task.wait(0.2)
			firetouchinterest(hrp, part, 0) task.wait(0.1) firetouchinterest(hrp, part, 1)
		else warn("❌ Exit not found") end
	end,

	["Hex gun"] = function(hrp)
		local floor2 = Workspace:FindFirstChild("Floor 2", true)
		local part = floor2 and getPart(floor2:FindFirstChild("GetHEXGun", true))
		if part then
			hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			task.wait(0.2)
			firetouchinterest(hrp, part, 0) task.wait(0.1) firetouchinterest(hrp, part, 1)
		else warn("❌ Hex Gun not found") end
	end,

	["Corrupted rifle (Only event)"] = function(hrp)
		local nightcity = Workspace:FindFirstChild("NightCity")
		local part = nightcity and getPart(nightcity:FindFirstChild("Exit", true))
		if part then hrp.CFrame = part.CFrame
		else warn("❌ NightCity event not active") end
	end,

	["Scarecrow skull (Only event)"] = function(hrp)
		local skull = Workspace:FindFirstChild("GetScarecrowSkull", true)
		local part = getPart(skull)
		if part then hrp.CFrame = part.CFrame
		else warn("❌ Scarecrow Skull not found") end
	end,

	["Dual LX3 (Only event)"] = function(hrp)
		local exit = Workspace.MazeWorld:FindFirstChild("ESCAPE FROM THIS HELL", true)
		
		local part = getPart(exit)
		if part then
		hrp.CFrame = part.CFrame
		firetouchinterest(hrp, part, 0) task.wait(0.1) firetouchinterest(hrp, part, 1)
		else warn("❌ exit not found") end
	end,

	["RGB (Only event)"] = function(hrp)
		local exit = Workspace.CorruptedZone:FindFirstChild("RGB - 9999 Cell", true)
		
		local part = getPart(exit)
		if part then hrp.CFrame = part.CFrame
		else warn("❌ exit not found") end
	end,

	["Corrupted Rifle (Only event)"] = function(hrp)
		local exit = Workspace.NightCity:FindFirstChild("Exit", true)
		
		local part = getPart(exit)
		if part then hrp.CFrame = part.CFrame
		else warn("❌ exit not found") end
	end,

	["LXD (Only event)"] = function(hrp)
			local exit = Workspace.DeadGround:FindFirstChild("LXD - 9999 Cell", true)
			
			

			local part = getPart(exit)
			if part then hrp.CFrame = part.CFrame
			else warn("❌ exit not found") end
		end,

	-- in weapons table
	["Mech gun (only event)"] = function(hrp)
		local cyberland = Workspace:FindFirstChild("CyberLand")
		local part = cyberland and getPart(cyberland:FindFirstChild("GetMechGun", true))
		if part then
			hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
			task.wait(0.2)
			firetouchinterest(hrp, part, 0)
			task.wait(0.1)
			firetouchinterest(hrp, part, 1)
		else
			warn("❌ Mech Gun not found / CyberLand not active")
		end
	end,

	["Fire sword"] = function(hrp)
		getFireSword()
	end,

	["Water gun"] = function(hrp)
		getWaterGun()
	end,
}

-- ==================== MAIN DROPDOWN ====================
local weaponDropdown = TTab:CreateDropdown({
    Name = "Get weapon",
    CurrentOption = {"None"}, -- Rayfield uses CurrentOption not Default
    Options = {
        "None",
        "Ice crossbow",
        "Volcano",
        "Rocket Launcher",
        "LXW",
        "Hex gun",
        "Fire sword",
        "Water gun",
        "Corrupted rifle (Only event)",
        "Scarecrow skull (Only event)",
		"Dual LX3 (Only event you have to go in first)",
		"RGB (Only event)",
		"Corrupted Rifle (Only event)",
		"Mech gun (Only event)",
		"LXD (Only event)"
    },
    MultipleOptions = false,
    Callback = function(Value)
        task.spawn(function()
            if type(Value) == "table" then Value = Value[1] end
            if Value == "None" then return end

            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart", 3)
            if not hrp then warn("❌ HumanoidRootPart not found") return end

            task.wait(0.2)

            local action = weapons[Value]
            if action then
                action(hrp)
            else
                warn("❌ Unknown weapon: " .. tostring(Value))
            end

            -- reset back to None when done
            weaponDropdown:Set("None")
        end)
    end
})

	-- if workspace:FindFirstChild("GetScarecrowSkull") then
	-- 	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace["GetScarecrowSkull"].CFrame
	-- end
end


--you vs homelander
if game.PlaceId == 74660999483512 then
    local Tab = Window:CreateTab("ESP", 4483362458) 
    

	local Players = game:GetService("Players")
	local running = false

	Tab:CreateToggle({
		Name = "Player ESP",
		CurrentValue = false,
		Callback = function(Value)
			running = Value
			
			if running then
				task.spawn(function()
					while running do
						for _, player in ipairs(Players:GetPlayers()) do
							if player ~= Players.LocalPlayer and player.Character then
								local role = player:GetAttribute("RoundRole")
								
								if role == "Survivor" then
									local character = player.Character
									
									-- Remove old highlight if exists
									local existing = character:FindFirstChild("ESP_Highlight")
									if existing then 
										existing:Destroy() 
									end
									
									-- Create new highlight
									local esp = Instance.new("Highlight")
									esp.Name = "ESP_Highlight"
									esp.FillColor = Color3.fromRGB(0, 255, 100)     -- Green
									esp.OutlineColor = Color3.fromRGB(255, 255, 255)
									esp.FillTransparency = 0.5
									esp.OutlineTransparency = 0
									esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
									esp.Parent = character
								end
							end
						end
						
						task.wait(0.25)
					end
				end)
			else
				-- Cleanup when turned OFF
				for _, player in ipairs(Players:GetPlayers()) do
					if player.Character then
						local highlight = player.Character:FindFirstChild("ESP_Highlight")
						if highlight then
							highlight:Destroy()
						end
					end
				end
			end
		end,
	})
end

--sell lemons
if game.PlaceId == 79268393072444 then
	local MTab = Window:CreateTab("Main", "sprout")

	local plr = game.Players.LocalPlayer
	local TycoonOwner = nil

	while TycoonOwner == nil do
		task.wait(0.5)
		for i, v in pairs(game.Workspace:GetChildren()) do
			if v.Name:match("Tycoon") then
				local Owner = v:FindFirstChild("Owner")
				if Owner and Owner.Value == plr then
					TycoonOwner = v
					break
				end
			end
		end
	end

	local PurchasesFold = TycoonOwner:FindFirstChild("Purchases")

	local function getPurchaseButtons()
		local buttons = {}
		if TycoonOwner and TycoonOwner:FindFirstChild("Purchases") then
			for _, v in ipairs(TycoonOwner.Purchases:GetDescendants()) do
				if v.Name == "Purchase" then
					table.insert(buttons, v)
				end
			end
		end
		return buttons
	end

	local suffixes = {
		K   = 1e3,
		M   = 1e6,
		B   = 1e9,
		T   = 1e12,
		Qd  = 1e15,
		Qn  = 1e18,
		Sx  = 1e21,
		Sxd = 1e21,
		Sp  = 1e24,
		Oc  = 1e27,
		No  = 1e30,
		Dc  = 1e33,
	}

	local function decodeValue(str)
		local clean = str:gsub("[\226\128\128-\226\128\143]", "")

		local numStr, suffix = clean:match("%$([%d%,%.]+)(%a*)")
		if not numStr then
			return nil
		end

		local num = tonumber((numStr:gsub(",", "")))
		if not num then
			return nil
		end

		if suffix == "" then
			return num
		end

		local multiplier = suffixes[suffix]

		if not multiplier then
			suffix = suffix:sub(1,1):upper() .. suffix:sub(2):lower()
			multiplier = suffixes[suffix]
		end

		if multiplier then
			return num * multiplier
		end

		return num
	end

	local running = false
	local loopActive = false

	MTab:CreateToggle({
		Name = "Auto Buy",
		CurrentValue = false,
		Callback = function(Value)
			running = Value

			if running and not loopActive then
				loopActive = true
				task.spawn(function()
					while running do
						pcall(function()
							for _, fold in pairs(PurchasesFold:GetChildren()) do
								if fold:FindFirstChild("Buttons") then
									for i, nFold in pairs(fold.Buttons:GetChildren()) do
										if nFold:IsA("Folder") then
											for _, btn in pairs(nFold:GetChildren()) do
												if btn:GetAttribute("Shown") and btn:GetAttribute("Enabled") and not btn:GetAttribute("Purchased") then
													local price = decodeValue(btn.Button.Gui.Price.Text)
													local curbalance = decodeValue(plr.leaderstats.Cash.Value)
													if price <= curbalance then
														firetouchinterest(plr.Character.Head, btn.Button, true)
														task.wait()
														firetouchinterest(plr.Character.Head, btn.Button, false)
													end
												end
											end
										elseif nFold:IsA("Model") then
											if nFold:GetAttribute("Shown") and nFold:GetAttribute("Enabled") and not nFold:GetAttribute("Purchased") then
												local price = decodeValue(nFold.Button.Gui.Price.Text)
												local curbalance = decodeValue(plr.leaderstats.Cash.Value)
												if price <= curbalance then
													firetouchinterest(plr.Character.Head, nFold.Button, true)
													task.wait()
													firetouchinterest(plr.Character.Head, nFold.Button, false)
												end
											end
										end
									end
								end
							end
						end)

						task.wait(0.04)
					end
					loopActive = false
				end)
			end
		end,
	})

	local runningUPG = false
	local loopActiveUPG = false

	MTab:CreateToggle({
		Name = "Auto Upgrade",
		CurrentValue = false,
		Callback = function(Value)
			runningUPG = Value

			if runningUPG and not loopActiveUPG then
				loopActiveUPG = true
				task.spawn(function()
					while runningUPG do
						pcall(function()
							for _, fold in pairs(PurchasesFold:GetChildren()) do
								local sub = fold:FindFirstChild(fold.Name)
								if sub then
									if sub:GetAttribute("Enabled") then
										local upgrade = sub:FindFirstChild(fold.Name)
										if upgrade then
											upgrade.Upgrade:InvokeServer(1)
										end
									end
								end
							end
						end)

						task.wait(1)
					end
					loopActiveUPG = false
				end)
			end
		end,
	})

end

if game.PlaceId == 136431686349723 then
	local Players = game:GetService("Players")

	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")

	local enemyFolder = workspace:FindFirstChild("Terrain") and workspace.Terrain:FindFirstChild("Enemies")
	local npcFolder = workspace:FindFirstChild("NPCs")
	local shardFolder = workspace:FindFirstChild("Shards")

	local dangerRadius = 20

	local ESPEnabled = {
		NPC = false,
		Enemy = false
	}

	local function addESP(model, color)
		if not model or not model:IsA("Model") then return end
		if model:FindFirstChild("ESPHighlight") then return end

		local h = Instance.new("Highlight")
		h.Name = "ESPHighlight"
		h.FillColor = color
		h.OutlineColor = Color3.new(1, 1, 1)
		h.FillTransparency = 0.5
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = model
	end

	local function clearESP(folder)
		if not folder then return end
		for _, obj in ipairs(folder:GetChildren()) do
			local h = obj:FindFirstChild("ESPHighlight")
			if h then h:Destroy() end
		end
	end

	------------------------------------------------
	-- TABS
	------------------------------------------------
	local MainTab = Window:CreateTab("Main", 4483362458)

	------------------------------------------------
	-- NPC ESP TOGGLE
	------------------------------------------------
	MainTab:CreateToggle({
		Name = "NPC ESP",
		CurrentValue = false,
		Callback = function(value)
			ESPEnabled.NPC = value

			if npcFolder then
				if value then
					for _, npc in ipairs(npcFolder:GetChildren()) do
						addESP(npc, Color3.fromRGB(0, 255, 0))
					end
				else
					clearESP(npcFolder)
				end
			end
		end
	})

	------------------------------------------------
	-- ENEMY ESP TOGGLE
	------------------------------------------------
	MainTab:CreateToggle({
		Name = "Enemy ESP",
		CurrentValue = false,
		Callback = function(value)
			ESPEnabled.Enemy = value

			if enemyFolder then
				if value then
					for _, enemy in ipairs(enemyFolder:GetChildren()) do
						addESP(enemy, Color3.fromRGB(255, 0, 0))
					end
				else
					clearESP(enemyFolder)
				end
			end
		end
	})

	------------------------------------------------
	-- DANGER CHECK
	------------------------------------------------
	local function checkFolder(folder, position)
		if not folder then return false end

		for _, model in ipairs(folder:GetChildren()) do
			if model:IsA("Model") then
				local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				if root and (root.Position - position).Magnitude <= dangerRadius then
					return true
				end
			end
		end

		return false
	end

	local function dangerNearby(position)
		if npcFolder and #npcFolder:GetChildren() > 0 then
			return checkFolder(npcFolder, position)
		elseif enemyFolder then
			return checkFolder(enemyFolder, position)
		end
		return false
	end

	------------------------------------------------
	-- SHARD FARM BUTTON
	------------------------------------------------
	MainTab:CreateButton({
		Name = "Run Shard Farm (Once)",
		Callback = function()
			if not shardFolder then return end

			local originalCFrame = hrp.CFrame

			for _, shard in ipairs(shardFolder:GetChildren()) do
				local pos

				if shard:IsA("BasePart") then
					pos = shard.Position
				elseif shard:IsA("Model") and shard.PrimaryPart then
					pos = shard.PrimaryPart.Position
				end

				if pos and not dangerNearby(pos) then
					hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
					task.wait(0.02)
				end
			end

			hrp.CFrame = originalCFrame
		end
	})
end

local games = {
    ["game1"] = 83569851223739,
    ["game2"] = 107654875426558
}

if game.PlaceId == games["game1"] or game.PlaceId == games["game2"] then

    local MTab = Window:CreateTab("Main", "sprout")

    local Event = game:GetService("ReplicatedStorage")
        .Modules.Shared.RemoteEventService.AddSpeedRemoteEvent

    local SpeedAuto = false

    MTab:CreateToggle({
        Name = "Auto Speed",
        CurrentValue = false,
        Callback = function(value)
            SpeedAuto = value

            task.spawn(function()
                while SpeedAuto do
                    Event:FireServer()
                    task.wait()
                end
            end)
        end
    })

    local Players = game:GetService("Players")
    local p = Players.LocalPlayer

    local AutoWin = false
    local SavedCFrame

    MTab:CreateToggle({
        Name = "Auto Win",
        CurrentValue = false,
        Callback = function(value)
            AutoWin = value

            local character = p.Character or p.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            if value then
                SavedCFrame = hrp.CFrame

                local thing

                if game.PlaceId == games["game1"] then
                    thing = workspace.Wins:WaitForChild("14")

                elseif game.PlaceId == games["game2"] then
                    thing = workspace.Wins:WaitForChild("13")
                end

                if thing then
                    task.spawn(function()
                        while AutoWin do
                            local character = p.Character or p.CharacterAdded:Wait()
                            local hrp = character:WaitForChild("HumanoidRootPart")

                            if thing:IsA("Model") then
                                hrp.CFrame = thing:GetPivot()
                            elseif thing:IsA("BasePart") then
                                hrp.CFrame = thing.CFrame
                            end

                            task.wait(0.01)
                        end
                    end)
                end
            elseif SavedCFrame then
                hrp.CFrame = SavedCFrame
            end
        end
    })

        local AutoTread = false

    MTab:CreateToggle({
        Name = "Auto Treadmil",
        CurrentValue = false,
        Callback = function(value)
            AutoTread = value

            if value then
                task.spawn(function()
                    local leaderstats = p:WaitForChild("leaderstats")
                    local Rebirth = leaderstats:WaitForChild("Rebirths")

                    local world1 = {
                        [0] = true,
                        [1] = true,
                        [2] = true,
                        [3] = true
                    }

                    local world2 = {
                        [4] = true,
                        [5] = true,
                        [6] = true,
                        [7] = true,
                        [8] = true,
                        [9] = true,
                        [10] = true
                    }

                    local function teleportTo(target)
                        local character = p.Character or p.CharacterAdded:Wait()
                        local hrp = character:WaitForChild("HumanoidRootPart")

                        if not target then
                            return
                        end

                        if target:IsA("Model") then
                            hrp.CFrame = target:GetPivot()
                        elseif target:IsA("BasePart") then
                            hrp.CFrame = target.CFrame
                        end
                    end

                    while AutoTread do
                        local rebirth = Rebirth.Value

                        if world1[rebirth] then
                            if rebirth == 0 then
                                teleportTo(workspace.Treadmills:GetChildren()[36])

                            elseif rebirth == 1 then
                                teleportTo(workspace.Treadmills:GetChildren()[33])

                            elseif rebirth == 2 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth2"))

                            elseif rebirth == 3 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth3"))
                            end

                        elseif world2[rebirth] then
                            if rebirth >= 4 and rebirth < 6 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth4"))

                            elseif rebirth >= 6 and rebirth < 8 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth6"))

                            elseif rebirth >= 8 and rebirth < 10 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth8"))

                            elseif rebirth >= 10 then
                                teleportTo(workspace.Treadmills:FindFirstChild("Rebirth10"))
                            end
                        end

                        task.wait(0.01)
                    end
                end)
            end
        end
    })

    local AutoRebirth = false
    MTab:CreateToggle({
        Name = "Auto Rebirth",
        CurrentValue = false,
        Callback = function(value)
            AutoRebirth = value

            local ReEvent = game:GetService("ReplicatedStorage").Modules.Shared.RemoteEventService.RebirthRemoteEvent

            if value then
                task.spawn(function()
                    while AutoRebirth do
                        ReEvent:FireServer()
                        task.wait(1)
                    end
                end)
            end
        end
    })

    local AutoEvolve = false
    MTab:CreateToggle({
        Name = "Auto Evolve",
        CurrentValue = false,
        Callback = function(value)
            AutoEvolve = value

            local EVO = game:GetService("ReplicatedStorage").Modules.Shared.RemoteEventService.EvolutionRemoteEvent

            if value then
                task.spawn(function()
                    while AutoEvolve do
                        EVO:FireServer({Action = "Evolve"})
                        task.wait(1)
                    end
                end)
            end
        end
    })

end

--demon slayer burning ashes
if game.PlaceId == 13985303823 then
local Tab = Window:CreateTab("Main", 4483362458)

-- Services
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

local running = false
local selectedModes = {"Off"}

-- Remote
local AttackEvent = ReplicatedStorage:WaitForChild("events", 5):WaitForChild("remote", 5)

local alignPosition, alignOrientation, attachment

-- Update on respawn
player.CharacterAdded:Connect(function()
    backpack = player:WaitForChild("Backpack")
end)

local function ensureConstraints(hrp)
    if attachment and attachment.Parent == hrp then return end

    attachment = Instance.new("Attachment")
    attachment.Name = "FlyAttachment"
    attachment.Parent = hrp

    alignPosition = Instance.new("AlignPosition")
    alignPosition.Name = "FlyAlignPos"
    alignPosition.Attachment0 = attachment
    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPosition.MaxForce = math.huge
    alignPosition.Responsiveness = 250
    alignPosition.RigidityEnabled = true
    alignPosition.Parent = hrp

    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Name = "FlyAlignOri"
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.MaxTorque = math.huge
    alignOrientation.Responsiveness = 250
    alignOrientation.RigidityEnabled = true
    alignOrientation.Parent = hrp
end

-- Noclip
local Noclip = nil
local Clip = true

local function noclip()
    Clip = false
    if Noclip then Noclip:Disconnect() end
    Noclip = game:GetService("RunService").Stepped:Connect(function()
        if not Clip and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function clip()
    Clip = true
    if Noclip then Noclip:Disconnect() Noclip = nil end
end

local function getTarget()
    if #selectedModes == 0 then return nil end

    -- Build set, skipping "Off" — exact name match only, no fuzzy logic
    local modeSet = {}
    local hasTarget = false
    for _, mode in ipairs(selectedModes) do
        if mode ~= "Off" then
            modeSet[mode] = true
            hasTarget = true
        end
    end
    if not hasTarget then return nil end

    local character = player.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local npcFolder = workspace:FindFirstChild("npc")
    local npcs = npcFolder and npcFolder:FindFirstChild("npcs")
    if not npcs then return nil end

    local closest, closestDistance = nil, math.huge

    for _, npc in ipairs(npcs:GetChildren()) do
        if modeSet[npc.Name] then
            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if npcHRP and humanoid and humanoid.Health > 0 then
                local distance = (hrp.Position - npcHRP.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = npc
                end
            end
        end
    end

    return closest
end

local function attack(npc)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local npcHumanoid = npc and npc:FindFirstChildOfClass("Humanoid")
    if not npcHumanoid then return end

    while npcHumanoid.Health >= 4 and running do
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:EquipTool(tool)
            end
        end

        -- Tools are parented to Character, not Humanoid
        local equippedTool = character:FindFirstChildOfClass("Tool")
        if equippedTool then
            for i = 1, 5 do
                equippedTool:Activate()
                task.wait(0.08)
            end
        end

        if AttackEvent then
            AttackEvent:FireServer("StrongAttack")
        end

        task.wait(0.1)
    end

    VIM:SendKeyEvent(true, Enum.KeyCode.B, false, game)
    task.wait(0.01)
    VIM:SendKeyEvent(false, Enum.KeyCode.B, false, game)
end

local function stopScript()
    running = false
    clip()
    if alignPosition then alignPosition.Enabled = false end
    if alignOrientation then alignOrientation.Enabled = false end

    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
        end
    end
end

local function movementLoop()
    while running do
        local success, err = pcall(function()
            local target = getTarget()
            if not target then return end

            local npcHRP = target:FindFirstChild("HumanoidRootPart")
            if not npcHRP then return end

            local character = player.Character
            if not character then return end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid then return end

            humanoid.AutoRotate = false
            humanoid.PlatformStand = true

            local abovePos = npcHRP.Position + Vector3.new(0, 9, 0)
            local targetCFrame = CFrame.lookAt(abovePos, npcHRP.Position)
            local distance = (hrp.Position - abovePos).Magnitude

            if distance > 200 then
                ensureConstraints(hrp)
                alignPosition.Enabled = true
                alignOrientation.Enabled = true
                alignPosition.Position = abovePos
                alignOrientation.CFrame = targetCFrame
            else
                if alignPosition then alignPosition.Enabled = false end
                if alignOrientation then alignOrientation.Enabled = false end
                hrp.CFrame = targetCFrame
            end
        end)

        if not success then warn("Movement Error:", err) end
        task.wait(0.01)
    end
end

local function attackLoop()
    while running do
        local success, err = pcall(function()
            local target = getTarget()
            if target then
                attack(target)
            end
        end)

        if not success then warn("Attack Error:", err) end
        task.wait(1.0)
    end
end

local function startLoop()
    running = true
    task.spawn(movementLoop)
    task.spawn(attackLoop)
    noclip()
end

-- UI
Tab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Flag = "AkumaHunterFly",
    Callback = function(Value)
        if Value then
            startLoop()
        else
            stopScript()
        end
    end,
})

Tab:CreateDropdown({
    Name = "Target Mode",
    Options = { "Off", "Akuma Hunter", "Akuma", "Strong Akuma Hunter", "Strong Akuma", " Flame Apprentice" },
    CurrentOption = {"Off"},
    MultipleOptions = true,
    Callback = function(option)
        selectedModes = option
    end,
})
end

--survive in area 51 remake
if game.PlaceId == 13811085661 then
    local Tab = Window:CreateTab("Main", 4483362458)
    local GTab = Window:CreateTab("Guns", 4483362458)
    local CTab = Window:CreateTab("Combat", 4483362458)

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local monstersFolder = workspace:WaitForChild("Monsters")

    local gun = nil
    local enemy = nil
    local active = false
    local range = 20

    -- Keep character/HRP reference fresh on respawn
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    end)

    local function getWeapon()
        for _, v in ipairs(player:GetChildren()) do
            if v:IsA("Tool") then return v end
        end
        if character then
            for _, v in ipairs(character:GetChildren()) do
                if v:IsA("Tool") then return v end
            end
        end
        return nil
    end

    local function getClosestEnemy()
        -- FIX 3: guard against a nil HRP during respawn
        if not humanoidRootPart then return nil end

        local closestEnemy = nil
        local shortestDistance = math.huge

        for _, monster in ipairs(monstersFolder:GetDescendants()) do
            if monster:IsA("Model") then
                local humanoid = monster:FindFirstChild("Humanoid")
                local head     = monster:FindFirstChild("Head")
                local root     = monster:FindFirstChild("HumanoidRootPart")

                -- FIX 2: skip dead enemies
                if humanoid and head and root and humanoid.Health > 0 then
                    local distance = (humanoidRootPart.Position - root.Position).Magnitude

                    -- FIX 4: respect range here so we never return an out-of-range target
                    if distance < shortestDistance and distance <= range then
                        shortestDistance = distance
                        closestEnemy = monster
                    end
                end
            end
        end

        return closestEnemy
    end

    -- Main loop
    RunService.Heartbeat:Connect(function()
        if not active then return end
        -- FIX 3: bail if HRP isn't ready yet
        if not humanoidRootPart then return end

        gun   = getWeapon()
        enemy = getClosestEnemy()

        if gun and enemy then
            -- FIX 1: store the Script reference first, then look up the event on it
            local gunScript = gun:FindFirstChild("GunScript_Server")
            local event     = gunScript and gunScript:FindFirstChild("InflictTarget")

            -- FIX 1: verify it's actually a RemoteEvent before firing
            if event and event:IsA("RemoteEvent") then
                event:FireServer(
                    "Head",
                    enemy.Humanoid,
                    enemy.Head,
                    gun,
                    Vector3.new(0.19337499141693, -0.0086270589381456, -0.98108690977097)
                )
            end
        end
    end)

    Tab:CreateButton({
        Name = "Portal",
        CurrentValue = fovLocked,
        Callback = function(state)
            humanoidRootPart.CFrame = CFrame.new(-71, 314.999023, -1621, 0, -1, -0, -1, 0, -0, 0, 0, -1)
        end,
    })

    -- UI Toggle
    CTab:CreateToggle({
        Name = "Auto Shoot",
        CurrentValue = false,
        Callback = function(state)
            active = state
            print("Auto shoot:", active and "ON" or "OFF")
        end,
    })

    -- Range Slider
    CTab:CreateSlider({
        Name = "Auto Shoot Range",
        Range = {10, 1000},
        Increment = 1,
        CurrentValue = 20,
        Callback = function(v)
            range = v
        end,
    })

end

--1+ speed attack on titan game idk this script useless
if game.PlaceId == 115934904098274 then
	local Tab = Window:CreateTab("Main", 4483362458)

	local active = false
	local Event = game:GetService("ReplicatedStorage").RemotesFolder.SpeedAmount

    Tab:CreateToggle({
        Name = "Auto Speed",
        CurrentValue = false,
        Callback = function(v)
			active = v 
			if v then
				while active do
					firesignal(Event.OnClientEvent, 
						1
					)
					task.wait()
				end
			end
        end
    })
end

if game.PlaceId == 78079451644610 then
	local Tab = Window:CreateTab("Main", 4483362458)

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")
	local CollectionService = game:GetService("CollectionService")

	local Loader = require(ReplicatedStorage.Packages.Loader)
	local ReplicaController = require(Loader.Shared.Utility.ReplicaController)
	local BooksData = require(Loader.Shared.Data.Books)

	local LibraryReplica = nil
	for _, r in pairs(ReplicaController._replicas) do
		if r.Class == "Library" then LibraryReplica = r break end
	end
	if not LibraryReplica then
		ReplicaController.ReplicaOfClassCreated("Library", function(replica) LibraryReplica = replica end)
		while not LibraryReplica do task.wait() end
	end

	local Library = Workspace.Library
	local BooksFolder = Library.Books
	local player = Players.LocalPlayer

	player.CameraMode = Enum.CameraMode.Classic
	player.CameraMinZoomDistance = 20
	task.spawn(function() task.wait(0.1) player.CameraMinZoomDistance = 0.5 end)

	local shelfModels = {}
	for _, shelfModel in ipairs(CollectionService:GetTagged("Shelf")) do
		shelfModels[shelfModel.Name] = shelfModel
	end

	local function getShelfAssignedSeries(shelfId)
		local shelfData = LibraryReplica.Data.Shelves[shelfId]
		if not shelfData then return nil end
		for _, placedBook in pairs(shelfData.Books) do
			local bookName = typeof(placedBook) == "Instance" and placedBook.Name or placedBook
			local seriesName = bookName:match("^(.-)_(.+)$")
			if seriesName then return seriesName end
		end
	end

	local function findShelfForSeries(seriesName, genreName, volumeCount)
		for shelfId, shelfData in pairs(LibraryReplica.Data.Shelves) do
			if not shelfData.Completed and shelfData.Category == genreName then
				local shelfModel = shelfModels[shelfId]
				if shelfModel and shelfModel:GetAttribute("Width") == volumeCount then
					if getShelfAssignedSeries(shelfId) == seriesName then return shelfModel end
				end
			end
		end
		for shelfId, shelfData in pairs(LibraryReplica.Data.Shelves) do
			if not shelfData.Completed and shelfData.Category == genreName then
				local shelfModel = shelfModels[shelfId]
				if shelfModel and shelfModel:GetAttribute("Width") == volumeCount then
					if not getShelfAssignedSeries(shelfId) and next(shelfData.Books) == nil then return shelfModel end
				end
			end
		end
	end

	local function teleportTo(obj)
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
		if root and part then
			root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
			task.wait(0.05)
		end
	end

	local active = false

	Tab:CreateToggle({
		Name = "Auto Place Books",
		CurrentValue = false,
		Callback = function(v)
			active = v

			if active then
				task.spawn(function()
					while active do
						for _, book in ipairs(BooksFolder:GetChildren()) do
							if not active then
								break
							end

							task.wait(0.02)

							local seriesName, volumeStr = book.Name:match("^(.-)_(.+)$")
							local volumeNum = tonumber(volumeStr)

							if seriesName and volumeNum then
								local genreName, bookInfo = BooksData.GetCategory(seriesName)

								if genreName and bookInfo then
									local shelfModel = findShelfForSeries(seriesName, genreName, bookInfo.VolumeCount)

									if shelfModel then
										local shelfData = LibraryReplica.Data.Shelves[shelfModel.Name]

										if not (shelfData and shelfData.Books[tostring(volumeNum)]) then
											teleportTo(book)
											LibraryReplica:FireServer("Grab", book)
											task.wait(0.1)

											teleportTo(shelfModel)
											LibraryReplica:FireServer("Place", shelfModel, volumeNum - 1)
											task.wait(0.4)
										end
									end
								end
							end
						end

						task.wait(0.5) -- Wait before scanning again
					end
				end)
			end
		end
	})
end

--micheal zombies
-- Add the Main Game ID AND any Sub-Game IDs to this list
local allowedGames = {
    ["8054462345"] = true, -- Main Descendants Game ID
    ["9544666096"] = true, -- (Example) Replace with the Sub-Game / Dungeon ID
    ["0987654321"] = true, -- (Example) Replace with another Sub-Game ID
}

local currentPlaceId = tostring(game.PlaceId)

-- If the current place matches ANY ID in the table, it will run
if allowedGames[currentPlaceId] then
	local MainTab = Window:CreateTab("Main", 4483362458) -- You can change the icon ID

	local Enabled = false
	local OldHook

	local function ApplyHook()
		if OldHook then return end
		
		OldHook = hookmetamethod(game, "__namecall", function(self, ...)
			local args = {...}
			local method = getnamecallmethod()
			
			if method == "FireServer" and self.Name == "ClientBulletHit" then
				if Enabled then
					args[1] = args[1].Parent:FindFirstChild("Head") or args[1]
					args[3] = 1
				end
			end
			
			return OldHook(self, unpack(args))
		end)
	end

	local function RemoveHook()
		if OldHook then
			hookmetamethod(game, "__namecall", OldHook)
			OldHook = nil
		end
	end

	-- MainTab:CreateToggle({
	-- 	Name = "Enable ClientBulletHit Mod",
	-- 	CurrentValue = false,
	-- 	Flag = "BulletHitToggle",
	-- 	Callback = function(Value)
	-- 		Enabled = Value
	-- 		if Value then
	-- 			ApplyHook()
	-- 			Rayfield:Notify({
	-- 				Title = "Mod Enabled",
	-- 				Content = "ClientBulletHit hook is now active",
	-- 				Duration = 3,
	-- 				Image = 4483362458
	-- 			})
	-- 		else
	-- 			RemoveHook()
	-- 			Rayfield:Notify({
	-- 				Title = "Mod Disabled",
	-- 				Content = "Hook has been removed",
	-- 				Duration = 3,
	-- 				Image = 4483362458
	-- 			})
	-- 		end
	-- 	end,
	-- })

	MainTab:CreateButton({
		Name = "auto headshot kinda",
		Callback = function()
			ApplyHook()
			Rayfield:Notify({
				Title = "Hook Applied",
				Content = "The hook has been manually applied",
				Duration = 2.5
			})
		end,
	})
end

--weird strict dad chapter 1
if game.PlaceId == 14787381917 then
local MainTab = Window:CreateTab("Main", 4483362458) -- You can change the icon ID

local Button = MainTab:CreateButton({
    Name = "do all chores",
    Callback = function()
        -- ==================== YOUR ORIGINAL SCRIPT STARTS HERE ====================
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        local trashdone = false
        local trashoutdone = false
        local fridgedone = false

        local function getHRP()
            local character = player.Character or player.CharacterAdded:Wait()
            return character:WaitForChild("HumanoidRootPart")
        end

        local function doTrash()
            local hrp = getHRP()
            if not trashdone then
                for _, trashCan in ipairs(workspace.Game.trashes:GetChildren()) do
                    hrp.CFrame = trashCan.CFrame
                    task.wait(0.1)
                    for _, obj in ipairs(trashCan:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            obj.HoldDuration = 0
                            obj.RequiresLineOfSight = false
                            fireproximityprompt(obj)
                        end
                    end
                end
                trashdone = true
            end
        end

        local function takeOutTrash()
            local hrp = getHRP()
            if not trashoutdone then
                for _, trashBin in ipairs(workspace.Game:GetChildren()) do
                    if trashBin.Name == "TrashBin" then
                        local highlight = trashBin:FindFirstChild("Highlight")
                        if not highlight or highlight.Enabled then
                            hrp.CFrame = trashBin.CFrame
                            task.wait(0.1)
                            for _, prompt in ipairs(trashBin:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    prompt.HoldDuration = 0
                                    prompt.RequiresLineOfSight = false
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end
                trashoutdone = true
            end
        end

        local fridge = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Kitchen"):WaitForChild("FridgeNoodles")

        local function doNoodles()
            if not fridgedone then
                local hrp = getHRP()
                for _, noodles in ipairs(fridge:GetDescendants()) do
                    if noodles:IsA("ProximityPrompt") and noodles.Parent.Name == "Primary" then
                        hrp.CFrame = noodles.Parent.CFrame
                        task.wait(0.1)
                        noodles.HoldDuration = 0
                        noodles.Enabled = true
                        noodles.RequiresLineOfSight = false
                        fireproximityprompt(noodles)
                    end
                end
                fridgedone = true
            end
        end

        local stoveModel = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Kitchen"):WaitForChild("Stove")
        local backpack = player:WaitForChild("Backpack")

        local function cookNoodles()
            local hrp = getHRP()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")

            local noodleTool = backpack:FindFirstChild("Raw Noodle") or character:FindFirstChild("Raw Noodle")
            if not noodleTool then return end

            humanoid:EquipTool(noodleTool)
            task.wait(0.2)

            for _, obj in ipairs(stoveModel:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Parent.Name == "Primary" then
                    hrp.CFrame = obj.Parent.CFrame
                    task.wait(0.1)
                    obj.HoldDuration = 0
                    obj.RequiresLineOfSight = false
                    obj.Enabled = true
                    fireproximityprompt(obj)
                    
                    repeat task.wait(0.2) until hasTool("Cooked Noodle")
                end
            end
        end

        local noodlePlace = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Kitchen"):WaitForChild("DiningTable"):WaitForChild("Noodles")
        local dadplate

        local function hasTool(toolName)
            local character = player.Character
            if backpack:FindFirstChild(toolName) or (character and character:FindFirstChild(toolName)) then
                return true
            end
            return false
        end

        task.spawn(function()
            while not dadplate do
                local plate = noodlePlace:FindFirstChild("Plate")
                if plate then
                    local plateDad = plate:FindFirstChild("platedad")
                    if plateDad then
                        dadplate = plateDad:FindFirstChild("DadPlate")
                    end
                end
                task.wait(0.5)
            end
        end)

        local function setupPrompt(prompt)
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.Enabled = true
            fireproximityprompt(prompt)
        end

        local function giveDadNoodle()
            repeat task.wait() until dadplate
            if hasTool("Cooked Noodle") then
                for _, prompt in ipairs(dadplate:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        setupPrompt(prompt)
                    end
                end
            end
        end

        local function placeNoodles()
            local hrp = getHRP()
            if not hasTool("Cooked Noodle") then return end
            giveDadNoodle()

            local noodles = {}
            for _, obj in ipairs(noodlePlace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    table.insert(noodles, obj)
                end
            end

            for _, prompt in ipairs(noodles) do
                hrp.CFrame = prompt.Parent.CFrame
                task.wait(0.1)
                setupPrompt(prompt)
            end
        end

        -- ==================== NOODLES (uncomment if you want them) ====================
        -- if not hasTool("Cooked Noodle") then
        --     if not hasTool("Raw Noodle") then
        --         doNoodles()
        --         task.wait(0.5)
        --     end
        --     if hasTool("Raw Noodle") then
        --         cookNoodles()
        --         task.wait(0.5)
        --     end
        -- end
        -- if hasTool("Cooked Noodle") then
        --     placeNoodles()
        -- end

        -- ==================== OTHER TASKS ====================
        local hasGas = false

        local function findGas()
            hasGas = false
            local character = player.Character
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool.Name:lower():find("gas") then hasGas = true return end
            end
            if character then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:lower():find("gas") then hasGas = true return end
                end
            end
        end

        local gasCan = workspace:WaitForChild("House"):WaitForChild("GasCans"):WaitForChild("GasCan"):WaitForChild("Primary"):WaitForChild("ProximityPrompt")
        local function getGas()
            local hrp = getHRP()
            hrp.CFrame = gasCan.Parent.CFrame
            if not hasGas then
                gasCan.HoldDuration = 0
                gasCan.RequiresLineOfSight = false
                gasCan.Enabled = true
                fireproximityprompt(gasCan)
            end
        end

        local gen = workspace:WaitForChild("House"):WaitForChild("Generator"):WaitForChild("Button"):WaitForChild("ProximityPrompt")
        local function gas()
            local hrp = getHRP()
            hrp.CFrame = gen.Parent.CFrame
            gen.HoldDuration = 0
            gen.RequiresLineOfSight = false
            gen.Enabled = true
            fireproximityprompt(gen)
        end

        local AC = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Bedroom"):WaitForChild("Remote"):WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
        local function airconditon()
            local hrp = getHRP()
            hrp.CFrame = AC.Parent.CFrame
            task.wait(0.1)
            AC.HoldDuration = 0
            AC.RequiresLineOfSight = false
            AC.Enabled = true
            fireproximityprompt(AC)
        end

        local bedsFolder = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Bedroom"):WaitForChild("Beds")
        local currentBed = 1

        local function tidyBed()
            local beds = bedsFolder:GetChildren()
            local bed = beds[currentBed]
            if not bed then return end

            local hrp = getHRP()
            hrp.CFrame = bed.PrimaryPart.CFrame
            task.wait(0.1)

            for _, obj in ipairs(bed:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                    obj.RequiresLineOfSight = false
                    fireproximityprompt(obj)
                end
            end
            currentBed += 1
        end

        local router = workspace:WaitForChild("House"):WaitForChild("Router"):WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
        local function doRouter()
            local hrp = getHRP()
            hrp.CFrame = router.Parent.CFrame
            router.HoldDuration = 0
            router.RequiresLineOfSight = false
            fireproximityprompt(router)
        end

        local tpPart = workspace:WaitForChild("Game"):WaitForChild("Socket"):WaitForChild("Model")
        local plug = workspace:WaitForChild("Game"):WaitForChild("Socket"):WaitForChild("Plug"):WaitForChild("MeshPart"):WaitForChild("ProximityPrompt")

        local function plugIn()
            local hrp = getHRP()
            hrp.CFrame = tpPart.CFrame
            task.wait(0.1)
            plug.HoldDuration = 0
            plug.RequiresLineOfSight = false
            plug.Enabled = true
            fireproximityprompt(plug)
        end

        local currentSwitch = 1
        local lights = workspace:WaitForChild("House"):WaitForChild("Lights")

        local function lightSwitch()
            local switches = {}
            for _, switch in ipairs(lights:GetDescendants()) do
                if switch:IsA("ProximityPrompt") and switch.Parent.Name == "Switch" then
                    table.insert(switches, switch)
                end
            end
            local switch = switches[currentSwitch]
            if not switch then return end

            local hrp = getHRP()
            hrp.CFrame = switch.Parent.CFrame
            task.wait(0.1)
            switch.HoldDuration = 0
            switch.RequiresLineOfSight = false
            switch.Enabled = true
            fireproximityprompt(switch)
            currentSwitch += 1
        end

        local cur = workspace:WaitForChild("House"):WaitForChild("Curtains")
        local currentCurtain = 1

        local function curtains()
            local curtains = {}
            for _, curtain in ipairs(cur:GetDescendants()) do
                if curtain:IsA("ProximityPrompt") and curtain.Parent.Name == "Prompt" then
                    table.insert(curtains, curtain)
                end
            end
            local curtain = curtains[currentCurtain]
            if not curtain then return end

            local hrp = getHRP()
            hrp.CFrame = curtain.Parent.CFrame
            task.wait(0.1)
            curtain.HoldDuration = 0
            curtain.RequiresLineOfSight = false
            curtain.Enabled = true
            fireproximityprompt(curtain)
            currentCurtain += 1
        end

        local remotePrompt = workspace:WaitForChild("Game"):WaitForChild("Remote"):WaitForChild("ProximityPrompt")

        local function pickupRemote()
            local hrp = getHRP()
            hrp.CFrame = remotePrompt.Parent.CFrame
            remotePrompt.HoldDuration = 0
            remotePrompt.RequiresLineOfSight = false
            remotePrompt.Enabled = true
            fireproximityprompt(remotePrompt)
        end

        local infrontDoor = workspace:WaitForChild("Game"):WaitForChild("SpawnFrontDoor")
        local door = workspace:WaitForChild("House"):WaitForChild("Doors"):WaitForChild("FrontDoor"):WaitForChild("Door"):WaitForChild("Door1"):WaitForChild("ProximityPrompt")

        local function checkDoor()
            local hrp = getHRP()
            hrp.CFrame = infrontDoor.CFrame
            task.wait(0.1)
            door.HoldDuration = 0
            door.RequiresLineOfSight = false
            door.Enabled = true
            fireproximityprompt(door)
        end

        local function goChair()
            local hrp = getHRP()
            local chair = workspace:WaitForChild("House"):WaitForChild("Rooms"):WaitForChild("Bedroom"):WaitForChild("Chair")
            hrp.CFrame = chair.CFrame
        end

        -- ==================== EXECUTE TASKS ====================
        doTrash()
        takeOutTrash()

        findGas()
        getGas()
        gas()

        airconditon()

        while bedsFolder:GetChildren()[currentBed] do
            tidyBed()
            task.wait(0.2)
        end

        lightSwitch()
        curtains()

        doRouter()
        plugIn()

        pickupRemote()
        checkDoor()
        goChair()

        Rayfield:Notify({
            Title = "Completed",
            Content = "All tasks finished! Look at cams to start.",
            Duration = 5
        })
    end
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Press the button to run all chores",
    Duration = 3
})
end
--life in prison
if game.PlaceId == 72659788689464 then
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")

	local lp = Players.LocalPlayer
	local character = lp.Character or lp.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local Tab = Window:CreateTab("Main", 4483362458)

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

Tab:CreateButton({
    Name = "Go to Random Police Spawn",
    Callback = function()
        local character = player.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local folder = workspace:FindFirstChild("Spawns")
        if not folder then
            warn("Spawns folder not found")
            return
        end
        
        folder = folder:FindFirstChild("PoliceSpawns")
        if not folder then
            warn("PoliceSpawns folder not found")
            return
        end
        
        local spawns = folder:GetChildren()
        if #spawns == 0 then
            warn("No spawns found")
            return
        end
        
        local spawn = spawns[math.random(1, #spawns)]
        if not spawn:IsA("BasePart") then
            warn("Spawn is not a BasePart")
            return
        end
        
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(0.2, Enum.EasingStyle.Linear),
            {
                CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            }
        )
        tween:Play()
    end
})


	Tab:CreateButton({
        Name = "Go to quad Launcher",
        CurrentValue = false,
        Callback = function(v)

			local player = Players.LocalPlayer
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")

			local quad = workspace.Interactable.Factory.Pickups:WaitForChild("Quad Launcher")

			local pivot = quad:GetPivot() --[[+ Vector3.new(0, 1, 0)]]
			local size = quad:GetExtentsSize()

			-- World-space up, ignores the model's rotation
			local targetPosition = pivot.Position + Vector3.new(0, size.Y / 2 + 3, 0)

			local tween = TweenService:Create(
				hrp,
				TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(targetPosition)
				}
			)

			tween:Play()
			tween.Completed:Wait()
        end
    })

Tab:CreateButton({
    Name = "Go to Minigun",
    CurrentValue = false,
    Callback = function(v)
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local minigun
        for i, v in ipairs(workspace.pickups:GetChildren()) do
            if v:IsA("Model") and v.Name == "Minigun" then
                minigun = v
                break
            end
        end

        if not minigun then
            warn("Minigun not found!")
            return
        end

        local pivot = minigun:GetPivot()
        local size = minigun:GetExtentsSize()

        -- World-space up, ignores the model's rotation
        local targetPosition = pivot.Position + Vector3.new(0, size.Y / 2 + 3, 0)

        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {
                CFrame = CFrame.new(targetPosition, pivot.Position)
            }
        )

        tween:Play()
        tween.Completed:Wait()
    end
})
end

if game.PlaceId == 6328880674 then
	local Tab = Window:CreateTab("Main", 4483362458)
	Tab:CreateToggle({
        Name = "Remove VHS effect",
        CurrentValue = false,
        Callback = function(v)
            if v then 
				for i,v in ipairs(game:GetDescendants()) do
				if v:lower():find("vhs") then
					v:destroy()
				else
					
				end
				end
			end
        end
    })
end

--HIDE
if game.PlaceId == 92556658033628 then
    local players = workspace:WaitForChild("Players")

    local PESPEnabled = false
    local MESPEnabled = false

    local function addPESP(v)
        if v:IsA("Model") and v:FindFirstChild("Animate") then
            if not v:FindFirstChild("Pesp") then
                local esp = Instance.new("Highlight")
                esp.Name = "Pesp"
                esp.Parent = v
                esp.FillColor = Color3.fromRGB(0, 30, 255)
                esp.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end

    local function addMESP(v)
        if v:IsA("Model") and not v:FindFirstChild("Animate") then
            if not v:FindFirstChild("Mesp") then
                local esp = Instance.new("Highlight")
                esp.Name = "Mesp"
                esp.Parent = v
                esp.FillColor = Color3.fromRGB(255, 0, 0)
                esp.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end

    local function removeESP(name)
        for _, v in ipairs(players:GetChildren()) do
            if v:FindFirstChild(name) then
                v[name]:Destroy()
            end
        end
    end

    local function updateESP()
        for _, v in ipairs(players:GetChildren()) do
            if PESPEnabled then
                addPESP(v)
            end

            if MESPEnabled then
                addMESP(v)
            end
        end
    end

    players.ChildAdded:Connect(function(v)
        task.wait(0.5)
        updateESP()
    end)

    local Tab = Window:CreateTab("ESP")

    Tab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Callback = function(Value)
            PESPEnabled = Value

            if Value then
                updateESP()
            else
                removeESP("Pesp")
            end
        end,
    })

    Tab:CreateToggle({
        Name = "Monster ESP",
        CurrentValue = false,
        Callback = function(Value)
            MESPEnabled = Value

            if Value then
                updateESP()
            else
                removeESP("Mesp")
            end
        end,
    })
end

--Critical tower defence
if game.PlaceId == 5543622168 then
    local Tab = Window:CreateTab("Main", "user")
    local TTab = Window:CreateTab("Tower", "user")
    local shopGUI = game:GetService("Players").LocalPlayer.PlayerGui.Menu.EquipmentFrame.Mainframe.TowersFrame.ListFrame.ScrollFrame
    local RunService = game:GetService("RunService")

    local showAllTowers = false
    local connection

    local function setTowersVisible()
        for _, v in ipairs(shopGUI:GetChildren()) do
            if v:IsA("TextButton") then
                v.Visible = true
            end
        end
    end

    -- Rayfield Toggle
    Tab:CreateToggle({
        Name = "Show All Towers",
        CurrentValue = false,
        Callback = function(Value)
            showAllTowers = Value

            if showAllTowers then
                connection = RunService.RenderStepped:Connect(function()
                    setTowersVisible()
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end,
    })

    local duck = workspace.NPCS.Talks.THEDUCK.Model.Duck
    Tab:CreateButton({
        Name = "Go to Duck",
        CurrentValue = false,
        Callback = function()
            hrp.CFrame = duck.CFrame
        end
    })

    Tab:CreateButton({
        Name = "Go to Black ordeal",
        CurrentValue = false,
        Callback = function()
            hrp.CFrame = -3.49692273, 136.424927, 211.938797
        end
    })

    Tab:CreateButton({
        Name = "Go to Fractured Reality",
        CurrentValue = false,
        Callback = function()
            hrp.CFrame = 79979.3672, 26589.5977, -125.481583
        end
    })

	local level = game:GetService("Players").LocalPlayer.PlayerData.Stats.Level

	local Input = Tab:CreateInput({
	    Name = "Set Level (Client)",
	    CurrentValue = "",
	    PlaceholderText = "Enter level",
	    RemoveTextAfterFocusLost = false,
	    Flag = "LevelInput",
	
	    Callback = function(Text)
	        local newLevel = tonumber(Text)
	
	        if newLevel then
	            level.Value = newLevel
	        end
	    end,
	})

    TTab:CreateButton({
        Name = "Get Hot Rash",
        CurrentValue = false,
        Callback = function()
            game:GetService("Players").LocalPlayer.PlayerGui.Misc.SecretLol["Hot Rash"].Value.Value.RemoteEvent:FireServer()
			workspace:WaitForChild("Map"):WaitForChild("Floaty2"):WaitForChild("Decor"):WaitForChild("Sign"):WaitForChild("baseplate"):WaitForChild("RemoteEvent"):FireServer()

        end
    })
end

--zombie attack
if game.PlaceId == 1240123653 then
local MainTab = Window:CreateTab("Main")

-- ================== ATTACK SETTINGS ==================
local ATTACK_DISTANCE = 50
local ATTACK_DELAY = 0.08
local USE_DICTIONARY_STYLE = false
-- ====================================================

-- ================== TELEPORT SETTINGS ==================
local TELEPORT_HEIGHT = 10
local TELEPORT_DELAY = 0.0001
-- =======================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local event = ReplicatedStorage:WaitForChild("forhackers")

local enemiesFolder = workspace:WaitForChild("enemies")
local bossFolder = workspace:WaitForChild("BossFolder")

-- ================== AUTO ATTACK ==================
local autoAttackEnabled = false
local attackConnection

local function getTool()
    local backpack = LocalPlayer.Backpack
    for _, v in ipairs(backpack:GetChildren()) do
        if v:IsA("Tool") then return v end
    end
    
    local char = LocalPlayer.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") then return v end
        end
    end
    return nil
end

local function equipTool()
    local tool = getTool()
    if tool then
        local character = LocalPlayer.Character
        if character and not tool.Parent == character then
            character:EquipTool(tool)
        end
        return tool
    end
    return nil
end

local function getClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local root = character.HumanoidRootPart
    local closest, shortest = nil, math.huge
    
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("humanoidRootPart")
        if hrp then
            local dist = (root.Position - hrp.Position).Magnitude
            if dist < shortest and dist <= ATTACK_DISTANCE then
                shortest = dist
                closest = hrp
            end
        end
    end
    return closest
end

local function startAttackLoop()
    if attackConnection then return end
    autoAttackEnabled = true
    
    attackConnection = task.spawn(function()
        while autoAttackEnabled do
            local tool = equipTool()   -- Auto equip every loop
            local enemyPart = getClosestEnemy()
            
            if tool and enemyPart then
                local args
                if USE_DICTIONARY_STYLE then
                    args = { [1] = "hit", [2] = tool, [3] = enemyPart }
                else
                    args = { "hit", "Basic Knife", enemyPart }
                end
                event:InvokeServer(unpack(args))
            end
            task.wait(ATTACK_DELAY)
        end
    end)
end

local function stopAttackLoop()
    autoAttackEnabled = false
    if attackConnection then
        task.cancel(attackConnection)
        attackConnection = nil
    end
end

-- ================== TELEPORT FUNCTIONS ==================
local function isDead(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0
end

local enemyLoopEnabled, bossLoopEnabled = false, false
local enemyConn, bossConn

local function startEnemyTeleport()
    if enemyConn then return end
    enemyLoopEnabled = true
    
    enemyConn = task.spawn(function()
        while enemyLoopEnabled do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(1) continue end
            
            local hrp = char.HumanoidRootPart
            for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                if isDead(enemy) then continue end
                local eHRP = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("humanoidRootPart")
                if not eHRP then continue end
                
                repeat
                    if char:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = eHRP.CFrame * CFrame.new(0, TELEPORT_HEIGHT, 0)
                        hrp.Velocity = Vector3.new(0, 25, 0)
                    end
                    task.wait(TELEPORT_DELAY)
                until isDead(enemy) or not enemy.Parent
            end
            task.wait(0.1)
        end
    end)
end

local function stopEnemyTeleport()
    enemyLoopEnabled = false
    if enemyConn then task.cancel(enemyConn) enemyConn = nil end
end

local function startBossTeleport()
    if bossConn then return end
    bossLoopEnabled = true
    
    bossConn = task.spawn(function()
        while bossLoopEnabled do
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then task.wait(1) continue end
            
            local hrp = char.HumanoidRootPart
            for _, boss in ipairs(bossFolder:GetChildren()) do
                if isDead(boss) then continue end
                local bHRP = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("humanoidRootPart")
                if not bHRP then continue end
                
                repeat
                    if char:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = bHRP.CFrame * CFrame.new(0, TELEPORT_HEIGHT, 0)
                        hrp.Velocity = Vector3.new(0, 25, 0)
                    end
                    task.wait(TELEPORT_DELAY)
                until isDead(boss) or not boss.Parent
            end
            task.wait(0.1)
        end
    end)
end

local function stopBossTeleport()
    bossLoopEnabled = false
    if bossConn then task.cancel(bossConn) bossConn = nil end
end

-- ================== UI ==================
MainTab:CreateToggle({
    Name = "Auto Attack (Auto Equip)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then 
            startAttackLoop() 
        else 
            stopAttackLoop() 
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Teleport Enemies",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startEnemyTeleport() else stopEnemyTeleport() end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Teleport Bosses",
    CurrentValue = false,
    Callback = function(Value)
        if Value then startBossTeleport() else stopBossTeleport() end
    end,
})

MainTab:CreateSlider({
    Name = "Teleport Height",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value)
        TELEPORT_HEIGHT = Value
    end,
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Auto Equip is now enabled on the attack toggle!",
    Duration = 6
})
end

--bean
if game.PlaceId == 102028012486873 then
    TTab:CreateButton({
        Name = "Goto stage 50",
        CurrentValue = false,
        Callback = function()
			local last = workspace.Checkpoints["50"]
			local p = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
			p.CFrame = last.CFrame + Vector3.new(0,10,0)
        end
    })
end

--george cooper shooters
if game.PlaceId == 134285251132058 then
	local Tab = Window:CreateTab("Main", 4483362458)

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	local LocalPlayer = Players.LocalPlayer
	local Enabled = false
	local ShootDistance = 20
	
	local function GetClosestTarget()
	    local myChar = LocalPlayer.Character
	    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	
	    local myRoot = myChar.HumanoidRootPart
	    local closestPlayer = nil
	    local closestDistance = math.huge
	
	    for _, player in ipairs(Players:GetPlayers()) do
	        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
	            local distance = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
	
	            if distance < closestDistance then
	                closestDistance = distance
	                closestPlayer = player
	            end
	        end
	    end
	
	    return closestPlayer
	end
	
	local function FireAtClosest()
	    local myChar = LocalPlayer.Character
	    if not myChar then return end
	
	    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	    local weapon = myChar:FindFirstChild("Sniper")
	
	    if not myRoot or not weapon then return end
	
	    local target = GetClosestTarget()
	    if not target or not target.Character then return end
	
	    local char = target.Character
	    local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	
	    if not targetPart then return end
	
	    local distance = (myRoot.Position - targetPart.Position).Magnitude
	
	    if distance <= ShootDistance then
	        local remote = ReplicatedStorage:FindFirstChild("WeaponsSystem", true)
	            and ReplicatedStorage.WeaponsSystem:FindFirstChild("Network", true)
	            and ReplicatedStorage.WeaponsSystem.Network:FindFirstChild("WeaponHit")
	
	        if remote then
	            local args = {
	                [1] = weapon,
	                [2] = {
	                    p = targetPart.Position,
	                    pid = 1,
	                    part = targetPart,
	                    d = distance,
	                    maxDist = distance + 0.5,
	                    h = char:FindFirstChild("Head"),
	                    m = targetPart.Material,
	                    sid = 2,
	                    t = tick() % 1,
	                    n = (targetPart.Position - myRoot.Position).Unit
	                }
	            }
	
	            remote:FireServer(unpack(args))
	        end
	    end
	end
	
	-- Rayfield Toggle
	Tab:CreateToggle({
	    Name = "Auto Shoot Closest",
	    CurrentValue = false,
	    Flag = "AutoShoot",
	    Callback = function(Value)
	        Enabled = Value
	
	        if Enabled then
	            task.spawn(function()
	                while Enabled do
	                    FireAtClosest()
	                    task.wait(0.1)
	                end
	            end)
	        end
	    end,
	})
	
	Tab:CreateSlider({
	    Name = "Shoot Distance",
	    Range = {5, 200},
	    Increment = 5,
	    Suffix = " studs",
	    CurrentValue = 20,
	    Flag = "ShootDistance",
	    Callback = function(Value)
	        ShootDistance = Value
	    end,
	})
end

--example 
--[[
if game == 0 then
    local Tab = Window:CreateTab("Main", 4483362458)

    PlayerTab:CreateToggle({
        Name = "Invisibility (V to toggle too)",
        CurrentValue = false,
        Callback = function(v)
            if v then becomeInvisible() else becomeVisible() end
        end
    })

end
]]
