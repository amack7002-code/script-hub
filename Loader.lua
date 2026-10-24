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
    Icon = 0,
    LoadingTitle = "Game Hub",
    LoadingSubtitle = "by sky",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "universal script hub",
        FileName = "Hub"
    },

    Discord = {
        Enabled = true,
        Invite = "rVQPFjjJ",
        RememberJoins = false
    },

    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "The key is Hello",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateLabel("ALWAYS USE ALT ACCOUNT")
HomeTab:CreateLabel("if there is nothing that appears then the game is not supported")

-- Inf Yield
HomeTab:CreateButton({
    Name = "Inf Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- AI SMART Inf Yield (Fixed URL)
HomeTab:CreateButton({
    Name = "AI SMART Inf Yield (might not work)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.lua"))()
    end
})

-- Dex
HomeTab:CreateButton({
    Name = "Dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

-- Simple Spy Lite (Fixed formatting)
HomeTab:CreateButton({
    Name = "Remote Spy/Simple Spy for bad executors",
    Callback = function()
        local settings = {
            SaveDecompileLogs = true,
            SaveScanLogs = true,
            ScanForNewInstance = true,
            InterceptUntilRan = true,
            CursorOffset = -15,
            PathToDump = {game.Players.LocalPlayer, game:GetService('ReplicatedStorage')}
        }
        _G.data = settings
        loadstring(game:HttpGet('https://raw.githubusercontent.com/ScriptSkiddie69/RemoteHook/refs/heads/main/SimpleSpyLite.lua'))()
    end
})

-- Simple Spy Beta
HomeTab:CreateButton({
    Name = "Remote Spy",
    Callback = function()
        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
    end
})

-- JasonSpy (FIXED: Removed invalid CurrentValue property)
HomeTab:CreateButton({
    Name = "JasonSpy",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/8Pa2QRY8"))()
    end
})

-- Medal Decompiler
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
            return request({
                Url = "http://localhost:3000/decompile",
                Method = "POST",
                Body = encoded
            }).Body
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

-- Script Dumper (FIXED: Removed incomplete "en[...]")
HomeTab:CreateButton({
    Name = "Script Dumper",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterTD/Script.Dumper/refs/heads/main/Debugger.lua"))()
    end
})

-- Dex++
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

-- Executor Tester
HomeTab:CreateButton({
    Name = "Executor Tester",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GmilerlolYT/ExecutorTester/refs/heads/main/Hi"))()
    end
})

-- Cobalt
HomeTab:CreateButton({
    Name = "Cobalt (rspy)",
    Callback = function()
        loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
    end
})

HomeTab:CreateDivider()

-- Copy Place Id
HomeTab:CreateButton({
    Name = "Copy Place Id",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
    end
})

-- Copy Job Id
HomeTab:CreateButton({
    Name = "Copy Job Id",
    Callback = function()
        setclipboard(tostring(game.JobId))
    end
})

-- After creating Window, store it in getgenv
getgenv().RayfieldWindow = Window
getgenv().RayfieldLib = Rayfield

-- Then your download function
local function downloadGame(url)
    url = url or "https://raw.githubusercontent.com/amack7002-code/script-hub/refs/heads/main/games/games.lua"

    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not res or res == "" then
        Rayfield:Notify({
            Title = "Download",
            Content = "Failed to download games.lua",
            Duration = 4,
        })
        return false
    end

    local fn, loadErr = loadstring(res)
    if not fn then
        Rayfield:Notify({
            Title = "Download",
            Content = "Loadstring error: " .. tostring(loadErr),
            Duration = 4,
        })
        return false
    end

    -- Execute the downloaded script
    local success, runErr = pcall(fn)
    if not success then
        Rayfield:Notify({
            Title = "Download",
            Content = "Runtime error: " .. tostring(runErr),
            Duration = 4,
        })
        return false
    end

    Rayfield:Notify({
        Title = "Download",
        Content = "games.lua loaded successfully",
        Duration = 3,
    })

    return true
end

pcall(function()
    downloadGame()
end)
