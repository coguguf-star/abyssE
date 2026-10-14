-- LAYER 4 EXPLORER (analog + mode jalan)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("L4GUI"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui"); gui.Name="L4GUI"; gui.ResetOnSpawn=false; gui.Parent=CoreGui

local POS_L4    = Vector3.new(-38, -2189, 48)
local POS_BALIK = Vector3.new(-116.3, -2086.2, -69.2)

local mode = "fly"        -- "fly" | "walk" | "freeze"
local speed = 60
local upHeld, downHeld = false, false
local pos = POS_L4

local function getChar()
    local c = plr.Character
    if not c or not c.Parent then return nil end
    return c
end
local function hrp()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyMode()
    local h = hrp(); if not h then return end
    if mode == "walk" then
        h.Anchored = false
    else
        h.Anchored = true
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
        h.CFrame = CFrame.new(pos)
    end
end

local function setPos(p)
    pos = p
    if mode ~= "walk" then
        local h = hrp()
        if h then h.CFrame = CFrame.new(pos) end
    end
end

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 250, 0, 46); lbl.Position = UDim2.new(0, 8, 0, 8)
lbl.BackgroundColor3 = Color3.fromRGB(12,12,16); lbl.BackgroundTransparency = 0.25
lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Code; lbl.TextSize = 11
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top
lbl.TextWrapped = true; lbl.Parent = gui
Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

local function mkBtn(txt, x, y, w, col, fn)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1)
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Parent = gui
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    if fn then b.MouseButton1Click:Connect(fn) end
    return b
end

mkBtn("KE LAYER 4", 8, 60, 110, Color3.fromRGB(80, 60, 160), function()
    mode = "fly"
    setPos(POS_L4)
    applyMode()
end)

mkBtn("BALIK", 124, 60, 70, Color3.fromRGB(160, 90, 40), function()
    mode = "walk"
    local h = hrp()
    if h then h.Anchored = false; h.CFrame = CFrame.new(POS_BALIK) end
end)

mkBtn("SPEED 60", 200, 60, 80, Color3.fromRGB(60, 100, 140), function()
    speed = (speed == 60) and 150 or 60
end)

-- MODE
local bFly = mkBtn("FLY", 8, 96, 85, Color3.fromRGB(60, 130, 90), function()
    mode = "fly"; applyMode()
end)
local bWalk = mkBtn("WALK", 100, 96, 85, Color3.fromRGB(130, 110, 60), function()
    mode = "walk"; applyMode()
end)
local bFreeze = mkBtn("FREEZE", 192, 96, 85, Color3.fromRGB(90, 70, 130), function()
    mode = "freeze"; applyMode()
end)

-- naik / turun (tahan)
local bUp = mkBtn("NAIK (tahan)", 8, 132, 130, Color3.fromRGB(50,50,70), nil)
bUp.MouseButton1Down:Connect(function() upHeld = true end)
bUp.MouseButton1Up:Connect(function() upHeld = false end)
bUp.MouseLeave:Connect(function() upHeld = false end)

local bDown = mkBtn("TURUN (tahan)", 145, 132, 130, Color3.fromRGB(50,50,70), nil)
bDown.MouseButton1Down:Connect(function() downHeld = true end)
bDown.MouseButton1Up:Connect(function() downHeld = false end)
bDown.MouseLeave:Connect(function() downHeld = false end)

pcall(function() workspace.StreamingTargetRadius = 2048 end)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    applyMode()
end)

-- FLY: gerak pakai analog (MoveDirection)
RunService.RenderStepped:Connect(function(dt)
    if mode ~= "fly" then return end
    local h = hrp(); local hum = getHum()
    if not h or not hum then return end

    local move = hum.MoveDirection
    local vel = move * speed
    if upHeld then vel = vel + Vector3.yAxis * speed end
    if downHeld then vel = vel - Vector3.yAxis * speed end

    if vel.Magnitude > 0.1 then
        h.CFrame = h.CFrame + vel * dt
    end
    pos = h.Position
end)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    local h = hrp()
    lbl.Text = ("MODE: %s | speed %d\nPOS %.0f, %.0f, %.0f\nHP %s | %s"):format(
        string.upper(mode), speed, pos.X, pos.Y, pos.Z,
        hum and math.floor(hum.Health) or "?",
        h and (h.Anchored and "terkunci" or "bebas") or "-")
end)-- LAYER 4 EXPLORER (analog + mode jalan)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("L4GUI"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui"); gui.Name="L4GUI"; gui.ResetOnSpawn=false; gui.Parent=CoreGui

local POS_L4    = Vector3.new(-38, -2189, 48)
local POS_BALIK = Vector3.new(-116.3, -2086.2, -69.2)

local mode = "fly"        -- "fly" | "walk" | "freeze"
local speed = 60
local upHeld, downHeld = false, false
local pos = POS_L4

local function getChar()
    local c = plr.Character
    if not c or not c.Parent then return nil end
    return c
end
local function hrp()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyMode()
    local h = hrp(); if not h then return end
    if mode == "walk" then
        h.Anchored = false
    else
        h.Anchored = true
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
        h.CFrame = CFrame.new(pos)
    end
end

local function setPos(p)
    pos = p
    if mode ~= "walk" then
        local h = hrp()
        if h then h.CFrame = CFrame.new(pos) end
    end
end

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 250, 0, 46); lbl.Position = UDim2.new(0, 8, 0, 8)
lbl.BackgroundColor3 = Color3.fromRGB(12,12,16); lbl.BackgroundTransparency = 0.25
lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Code; lbl.TextSize = 11
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top
lbl.TextWrapped = true; lbl.Parent = gui
Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

local function mkBtn(txt, x, y, w, col, fn)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1)
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Parent = gui
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    if fn then b.MouseButton1Click:Connect(fn) end
    return b
end

mkBtn("KE LAYER 4", 8, 60, 110, Color3.fromRGB(80, 60, 160), function()
    mode = "fly"
    setPos(POS_L4)
    applyMode()
end)

mkBtn("BALIK", 124, 60, 70, Color3.fromRGB(160, 90, 40), function()
    mode = "walk"
    local h = hrp()
    if h then h.Anchored = false; h.CFrame = CFrame.new(POS_BALIK) end
end)

mkBtn("SPEED 60", 200, 60, 80, Color3.fromRGB(60, 100, 140), function()
    speed = (speed == 60) and 150 or 60
end)

-- MODE
local bFly = mkBtn("FLY", 8, 96, 85, Color3.fromRGB(60, 130, 90), function()
    mode = "fly"; applyMode()
end)
local bWalk = mkBtn("WALK", 100, 96, 85, Color3.fromRGB(130, 110, 60), function()
    mode = "walk"; applyMode()
end)
local bFreeze = mkBtn("FREEZE", 192, 96, 85, Color3.fromRGB(90, 70, 130), function()
    mode = "freeze"; applyMode()
end)

-- naik / turun (tahan)
local bUp = mkBtn("NAIK (tahan)", 8, 132, 130, Color3.fromRGB(50,50,70), nil)
bUp.MouseButton1Down:Connect(function() upHeld = true end)
bUp.MouseButton1Up:Connect(function() upHeld = false end)
bUp.MouseLeave:Connect(function() upHeld = false end)

local bDown = mkBtn("TURUN (tahan)", 145, 132, 130, Color3.fromRGB(50,50,70), nil)
bDown.MouseButton1Down:Connect(function() downHeld = true end)
bDown.MouseButton1Up:Connect(function() downHeld = false end)
bDown.MouseLeave:Connect(function() downHeld = false end)

pcall(function() workspace.StreamingTargetRadius = 2048 end)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    applyMode()
end)

-- FLY: gerak pakai analog (MoveDirection)
RunService.RenderStepped:Connect(function(dt)
    if mode ~= "fly" then return end
    local h = hrp(); local hum = getHum()
    if not h or not hum then return end

    local move = hum.MoveDirection
    local vel = move * speed
    if upHeld then vel = vel + Vector3.yAxis * speed end
    if downHeld then vel = vel - Vector3.yAxis * speed end

    if vel.Magnitude > 0.1 then
        h.CFrame = h.CFrame + vel * dt
    end
    pos = h.Position
end)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    local h = hrp()
    lbl.Text = ("MODE: %s | speed %d\nPOS %.0f, %.0f, %.0f\nHP %s | %s"):format(
        string.upper(mode), speed, pos.X, pos.Y, pos.Z,
        hum and math.floor(hum.Health) or "?",
        h and (h.Anchored and "terkunci" or "bebas") or "-")
end)-- LAYER 4 EXPLORER (analog + mode jalan)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

local CoreGui = game:GetService("CoreGui")
local old = CoreGui:FindFirstChild("L4GUI"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui"); gui.Name="L4GUI"; gui.ResetOnSpawn=false; gui.Parent=CoreGui

local POS_L4    = Vector3.new(-38, -2189, 48)
local POS_BALIK = Vector3.new(-116.3, -2086.2, -69.2)

local mode = "fly"        -- "fly" | "walk" | "freeze"
local speed = 60
local upHeld, downHeld = false, false
local pos = POS_L4

local function getChar()
    local c = plr.Character
    if not c or not c.Parent then return nil end
    return c
end
local function hrp()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function applyMode()
    local h = hrp(); if not h then return end
    if mode == "walk" then
        h.Anchored = false
    else
        h.Anchored = true
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
        h.CFrame = CFrame.new(pos)
    end
end

local function setPos(p)
    pos = p
    if mode ~= "walk" then
        local h = hrp()
        if h then h.CFrame = CFrame.new(pos) end
    end
end

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(0, 250, 0, 46); lbl.Position = UDim2.new(0, 8, 0, 8)
lbl.BackgroundColor3 = Color3.fromRGB(12,12,16); lbl.BackgroundTransparency = 0.25
lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.Code; lbl.TextSize = 11
lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top
lbl.TextWrapped = true; lbl.Parent = gui
Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

local function mkBtn(txt, x, y, w, col, fn)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1)
    b.Text = txt; b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Parent = gui
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    if fn then b.MouseButton1Click:Connect(fn) end
    return b
end

mkBtn("KE LAYER 4", 8, 60, 110, Color3.fromRGB(80, 60, 160), function()
    mode = "fly"
    setPos(POS_L4)
    applyMode()
end)

mkBtn("BALIK", 124, 60, 70, Color3.fromRGB(160, 90, 40), function()
    mode = "walk"
    local h = hrp()
    if h then h.Anchored = false; h.CFrame = CFrame.new(POS_BALIK) end
end)

mkBtn("SPEED 60", 200, 60, 80, Color3.fromRGB(60, 100, 140), function()
    speed = (speed == 60) and 150 or 60
end)

-- MODE
local bFly = mkBtn("FLY", 8, 96, 85, Color3.fromRGB(60, 130, 90), function()
    mode = "fly"; applyMode()
end)
local bWalk = mkBtn("WALK", 100, 96, 85, Color3.fromRGB(130, 110, 60), function()
    mode = "walk"; applyMode()
end)
local bFreeze = mkBtn("FREEZE", 192, 96, 85, Color3.fromRGB(90, 70, 130), function()
    mode = "freeze"; applyMode()
end)

-- naik / turun (tahan)
local bUp = mkBtn("NAIK (tahan)", 8, 132, 130, Color3.fromRGB(50,50,70), nil)
bUp.MouseButton1Down:Connect(function() upHeld = true end)
bUp.MouseButton1Up:Connect(function() upHeld = false end)
bUp.MouseLeave:Connect(function() upHeld = false end)

local bDown = mkBtn("TURUN (tahan)", 145, 132, 130, Color3.fromRGB(50,50,70), nil)
bDown.MouseButton1Down:Connect(function() downHeld = true end)
bDown.MouseButton1Up:Connect(function() downHeld = false end)
bDown.MouseLeave:Connect(function() downHeld = false end)

pcall(function() workspace.StreamingTargetRadius = 2048 end)

plr.CharacterAdded:Connect(function()
    task.wait(1)
    applyMode()
end)

-- FLY: gerak pakai analog (MoveDirection)
RunService.RenderStepped:Connect(function(dt)
    if mode ~= "fly" then return end
    local h = hrp(); local hum = getHum()
    if not h or not hum then return end

    local move = hum.MoveDirection
    local vel = move * speed
    if upHeld then vel = vel + Vector3.yAxis * speed end
    if downHeld then vel = vel - Vector3.yAxis * speed end

    if vel.Magnitude > 0.1 then
        h.CFrame = h.CFrame + vel * dt
    end
    pos = h.Position
end)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    local h = hrp()
    lbl.Text = ("MODE: %s | speed %d\nPOS %.0f, %.0f, %.0f\nHP %s | %s"):format(
        string.upper(mode), speed, pos.X, pos.Y, pos.Z,
        hum and math.floor(hum.Health) or "?",
        h and (h.Anchored and "terkunci" or "bebas") or "-")
end)
