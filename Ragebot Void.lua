--AC--

local _stbl; _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
    if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
        local tr = debug.traceback()
        if tr:find("MiscellaneousController") then
            return _stbl({1,2,3}, {})
        end
    end
    return _stbl(tbl, mt)
end))

coroutine.wrap(function()
    pcall(function()
        local function _proc(o)
            pcall(function()
                if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                    local _s, nm = pcall(function() return o.Name:lower() end)
                    if not _s or not nm then return end
                    local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
                    for _i = 1, #_tags do
                        if nm:find(_tags[_i]) then
                            pcall(function() o.Disabled = true end)
                            break
                        end
                    end
                end
            end)
        end
        pcall(function()
            local _desc = game:GetDescendants()
            for _i = 1, #_desc do _proc(_desc[_i]) end
        end)
        pcall(function() game.DescendantAdded:Connect(_proc) end)
    end)
    pcall(function()
        local _nc = game:GetService("NetworkClient")
        if not _nc then return end
        _nc.ChildAdded:Connect(function(ch)
            pcall(function()
                local _ok, _n = pcall(function() return ch.Name:lower() end)
                if _ok and _n then
                    if _n:find("anticheat") or _n:find("detection") then
                        pcall(function() ch:Destroy() end)
                    end
                end
            end)
        end)
    end)
end)()

local _fakeEv
pcall(function()
    _fakeEv = Instance.new("RemoteEvent")
    _fakeEv.Name = "ClientAlert"
    _fakeEv.Parent = LocalPlayer
end)

pcall(function()
    local _rf = game:GetService("ReplicatedFirst")
    local _tgt = _rf:WaitForChild("LocalScript3", 10)
    local _ct = 0
    local _gc = getgc(false)
    for _i = 1, #_gc do
        local _fn = _gc[_i]
        if type(_fn) ~= "function" then continue end
        local _ok1, _env = pcall(getfenv, _fn)
        if not _ok1 or type(_env) ~= "table" then continue end
        local _ok2, _scr = pcall(function() return rawget(_env, "script") end)
        if not _ok2 or not _scr or typeof(_scr) ~= "Instance" then continue end
        local _ok3, _ss = pcall(tostring, _scr)
        if not _ok3 then continue end
        if not (_scr == _tgt or (type(_ss) == "string" and _ss:find("LoadingScreen"))) then continue end
        local _ok4, _consts = pcall(debug.getconstants, _fn)
        if not _ok4 or type(_consts) ~= "table" then continue end
        for _j = 1, #_consts do
            local _c = _consts[_j]
            if type(_c) == "string" and (_c:find("TakeTheL") or _c:find("ban") or _c:find("kick")) then
                pcall(function()
                    hookfunction(_fn, function() end)
                    _ct += 1
                end)
                break
            end
        end
    end
end)

task.wait(0.2)

---code---

-- RageBot >< void / killing Text Animation
-- Runs on ANY game. Kill detection only active on game ID 6035872082.

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local TARGET_GAME_ID = 6035872082

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RageBotVoidGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create TextLabel
local textLabel = Instance.new("TextLabel")
textLabel.Name = "RageBotVoidText"
textLabel.Size = UDim2.new(0, 300, 0, 24)
textLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 18
textLabel.Font = Enum.Font.Code
textLabel.TextStrokeTransparency = 0
textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
textLabel.TextXAlignment = Enum.TextXAlignment.Center
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Text = "RageBot >< void"
textLabel.Parent = screenGui

-- State
local baseText = "RageBot >< void"
local dots = {".", "..", "..."}
local dotIndex = 1
local timer = 0
local interval = 0.35

local killMessage = nil
local killTimer = 0
local killDuration = 3

-- Animate
RunService.RenderStepped:Connect(function(deltaTime)
    if killMessage then
        killTimer = killTimer + deltaTime
        textLabel.Text = killMessage
        if killTimer >= killDuration then
            killMessage = nil
            killTimer = 0
        end
    else
        timer = timer + deltaTime
        if timer >= interval then
            timer = 0
            dotIndex = dotIndex + 1
            if dotIndex > #dots then
                dotIndex = 1
            end
            textLabel.Text = baseText .. dots[dotIndex]
        end
    end
end)

-- ============================================================
-- KILL DETECTION — only runs on game ID 6035872082
-- ============================================================
if game.GameId == TARGET_GAME_ID then

    local mouse = player:GetMouse()

    local function isEnemy(otherPlayer)
        if not otherPlayer or otherPlayer == player then return false end
        if player.Team and otherPlayer.Team and player.Team == otherPlayer.Team then
            return false
        end
        return true
    end

    local function showKill(enemyName)
        killMessage = 'RageBot >< killing ("' .. enemyName .. '")'
        killTimer = 0
    end

    -- Method 1: Raycast from camera toward mouse on left click
    local function raycastShot()
        local character = player.Character
        if not character then return end
        local head = character:FindFirstChild("Head")
        if not head then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}

        local rayOrigin = camera.CFrame.Position
        local targetPos = mouse.Hit and mouse.Hit.Position or (rayOrigin + camera.CFrame.LookVector * 1000)
        local rayDir = (targetPos - rayOrigin).Unit * 1000
        local result = workspace:Raycast(rayOrigin, rayDir, params)

        if result and result.Instance then
            local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
            if hitModel then
                local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
                if isEnemy(hitPlayer) then
                    showKill(hitPlayer.Name)
                end
            end
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            raycastShot()
        end
    end)

    -- Method 2: Watch enemy humanoid health
    local function watchCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        local lastHealth = humanoid.Health

        humanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < lastHealth and newHealth <= 0 then
                local otherPlayer = Players:GetPlayerFromCharacter(character)
                if isEnemy(otherPlayer) then
                    showKill(otherPlayer.Name)
                end
            end
            lastHealth = newHealth
        end)
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            task.spawn(watchCharacter, otherPlayer.Character)
        end
        otherPlayer.CharacterAdded:Connect(function(char)
            if otherPlayer ~= player then
                watchCharacter(char)
            end
        end)
    end

    Players.PlayerAdded:Connect(function(otherPlayer)
        otherPlayer.CharacterAdded:Connect(function(char)
            if otherPlayer ~= player then
                watchCharacter(char)
            end
        end)
    end)
end
