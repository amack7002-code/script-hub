--ui docs (https://docs.sirius.ienu/rayfield)
print("ran")

--REMEMBER TO ADD THE SCRIPT LOADSTRING TO THE QUEUE ON TELEPORT

local CoreGui = game:GetService("CoreGui")

local rayfield = CoreGui:FindFirstChild("Rayfield")

if rayfield then
    rayfield:Destroy()
else
    for _, v in ipairs(game:GetDescendants()) do
        if v.Name == "Rayfield" then
            v:Destroy()
        end
    end
end

--========================================================
-- Rayfield UI Setup
--========================================================
getgenv().RAYFIELD_SECURE = true
getgenv().RAYFIELD_ASSET_ID = nil -- your re-uploaded model

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
   Name = "Universal script hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use icon (default).
   LoadingTitle = "Game Hub",
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

local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateLabel("ALWAYS USE ALT ACCOUNT")
HomeTab:CreateLabel("if there is nothing that appears then the game is not supported")

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

HomeTab:CreateButton({ Name = "Remote Spy",         Callback = function() loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))() end })

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

HomeTab:CreateButton({
    Name = "Dex++",
    Callback = function()
        local gethui = gethui or get_hidden_gui

        if not gethui then
            warn("Your executor doesn't support gethui().")
            return
        end

        local hiddenGui = gethui()

        local folder = Instance.new("Folder")
        folder.Name = "[Dumped] HiddenGui"
        folder.Parent = game

        for _, instance in ipairs(hiddenGui:GetChildren()) do
            pcall(function()
                instance:Clone().Parent = folder
            end)
        end

        local success, source = pcall(function()
            return game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua")
        end)


        if success then
            loadstring(source)()
        else
            warn("Failed to download Dex++:", source)
        end
    end
})
HomeTab:CreateButton({ Name = "Executor Tester",         Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GmilerlolYT/ExecutorTester/refs/heads/main/Hi"))() end })

HomeTab:CreateButton({
    Name = "Cobalt (rspy)",
    Callback = function()
		-- https://discord.gg/FJcJMuze7S
		loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
    end
})

HomeTab:CreateDivider()


HomeTab:CreateButton({
    Name = "Copy Place Id",
    Callback = function()
		setclipboard(tostring(game.PlaceId))
    end
})

HomeTab:CreateButton({
    Name = "Copy Job Id",
    Callback = function()
		setclipboard(tostring(game.JobId))
    end
})

local function downloadGame()
  
end
