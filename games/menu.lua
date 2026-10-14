-- OUROBOROS MENU
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local plr = Players.LocalPlayer

local BASE = getgenv().ABYSS_BASE or "https://raw.githubusercontent.com/coguguf-star/AbyssE/main/games/"

local ACCENT = Color3.fromRGB(140, 100, 255)
local BG     = Color3.fromRGB(18, 18, 24)
local BG2    = Color3.fromRGB(26, 26, 34)

local old = CoreGui:FindFirstChild("OuroMenu"); if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "OuroMenu"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.Parent = CoreGui

local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end

local W = math.min(330, workspace.CurrentCamera.ViewportSize.X - 20)
local frame = mk("Frame", {
    Size = UDim2.new(0, W, 0, 268),
    Position = UDim2.new(0, 10, 0, 90),
    BackgroundColor3 = BG, BorderSizePixel = 0,
}, gui)
corner(frame, 12)

local header = mk("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = BG2, BorderSizePixel = 0}, frame)
corner(header, 12)

mk("TextLabel", {
    Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1,
    Text = "OUROBOROS", TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local btnMin = mk("TextButton", {
    Size = UDim2.new(0,30,0,24), Position = UDim2.new(1,-36,0,5),
    BackgroundColor3 = ACCENT, Text = "-", TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold, TextSize = 16,
}, header)
corner(btnMin, 6)

local tabBar = mk("Frame", {Size = UDim2.new(1,-20,0,28), Position = UDim2.new(0,10,0,42), BackgroundColor3 = BG2, BorderSizePixel = 0}, frame)
corner(tabBar, 8)

local content = mk("Frame", {Size = UDim2.new(1,-20,1,-82), Position = UDim2.new(0,10,0,76), BackgroundTransparency = 1}, frame)

local pages = {}
local function makeTab(name, key)
    local b = mk("TextButton", {
        Size = UDim2.new(0.5,-4,1,0), Position = UDim2.new(key == "profil" and 0 or 0.5, 2, 0, 0),
        BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(150,150,165),
        Font = Enum.Font.GothamBold, TextSize = 12,
    }, tabBar)
    local page = mk("Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false}, content)
    pages[key] = {btn = b, page = page}
    b.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do
            p.page.Visible = (k == key)
            p.btn.TextColor3 = (k == key) and ACCENT or Color3.fromRGB(150,150,165)
        end
    end)
    return page
end

local pageProfil = makeTab("PROFIL", "profil")
local pageFitur  = makeTab("FITUR", "fitur")
pages.profil.page.Visible = true
pages.profil.btn.TextColor3 = ACCENT

local function scroller(parent)
    local s = mk("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, parent)
    mk("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, s)
    return s
end

-- PROFIL
local profilScroll = scroller(pageProfil)
local profilRows = {}
local function profilRow(label)
    local row = mk("Frame", {Size = UDim2.new(1,-6,0,26), BackgroundColor3 = BG2, BorderSizePixel = 0}, profilScroll)
    corner(row, 6)
    mk("TextLabel", {
        Size = UDim2.new(0.5,-10,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1,
        Text = label, TextColor3 = Color3.fromRGB(150,150,165), Font = Enum.Font.Gotham,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local val = mk("TextLabel", {
        Size = UDim2.new(0.5,-10,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1,
        Text = "-", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold,
        TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    profilRows[label] = val
end

profilRow("Nama"); profilRow("Display"); profilRow("User ID"); profilRow("Umur Akun")
profilRow("Pemain di Server"); profilRow("Ping"); profilRow("FPS"); profilRow("Posisi")

-- FITUR
local fiturScroll = scroller(pageFitur)

local function makeToggle(label, defaultOn, onChange)
    local row = mk("Frame", {Size = UDim2.new(1,-6,0,34), BackgroundColor3 = BG2, BorderSizePixel = 0}, fiturScroll)
    corner(row, 6)
    mk("TextLabel", {
        Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1,
        Text = label, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.Gotham,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = mk("Frame", {Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-50,0.5,-10), BackgroundColor3 = Color3.fromRGB(60,60,75), BorderSizePixel = 0}, row)
    corner(track, 10)
    local dot = mk("Frame", {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0.5,-8), BackgroundColor3 = Color3.fromRGB(180,180,190), BorderSizePixel = 0}, track)
    corner(dot, 8)

    local on = defaultOn
    local function render()
        track.BackgroundColor3 = on and ACCENT or Color3.fromRGB(60,60,75)
        dot.Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        dot.BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(180,180,190)
    end
    render()

    local btn = mk("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, row)
    btn.MouseButton1Click:Connect(function()
        on = not on; render()
        if onChange then pcall(onChange, on) end
    end)
    return function() return on end
end

local function makeButton(label, callback)
    local b = mk("TextButton", {
        Size = UDim2.new(1,-6,0,32), BackgroundColor3 = BG2, Text = label,
        TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 12,
    }, fiturScroll)
    corner(b, 6)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- ===== SNAKE (biar toggle-nya jalan) =====
local snakeConn
local AMP, MAX_FALL = 14, 10
local function snakeOn()
    if snakeConn then return end
    snakeConn = RunService.RenderStepped:Connect(function()
        local c = plr.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        local v = h.AssemblyLinearVelocity
        v = v + Vector3.new((math.random()-0.5)*2*AMP, (math.random()-0.5)*2*AMP, (math.random()-0.5)*2*AMP)
        if v.Y < -MAX_FALL then v = Vector3.new(v.X, -MAX_FALL, v.Z) end
        h.AssemblyLinearVelocity = v
    end)
end
local function snakeOff()
    if snakeConn then snakeConn:Disconnect(); snakeConn = nil end
end

-- ===== FITUR LIST =====
makeToggle("Auto Trip", false, function(on)
    if on then
        loadstring(game:HttpGet(BASE .. "abyss.lua"))()
    else
        getgenv().ABYSS_SKIP = true
    end
end)

makeToggle("Snake Mode", false, function(on)
    if on then snakeOn() else snakeOff() end
end)

makeButton("Explore Layer 4", function()
    loadstring(game:HttpGet(BASE .. "layer4.lua"))()
end)

makeButton("Hop Server Terendah", function()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)))
    end)
    if not ok or not res or not res.data then return end
    local best
    for _, s in ipairs(res.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            if not best or s.playing < best.playing then best = s end
        end
    end
    if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, plr) end
end)

makeButton("Hop Server Terame", function()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(game.PlaceId)))
    end)
    if not ok or not res or not res.data then return end
    local best
    for _, s in ipairs(res.data) do
        if s.id ~= game.JobId then
            if not best or s.playing > best.playing then best = s end
        end
    end
    if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, plr) end
end)

-- MINIMIZE
local floatBtn = mk("TextButton", {
    Size = UDim2.new(0,44,0,44), Position = UDim2.new(0,10,0,90),
    BackgroundColor3 = ACCENT, Text = "O", TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold, TextSize = 18, Visible = false,
}, gui)
corner(floatBtn, 22)

btnMin.MouseButton1Click:Connect(function() frame.Visible = false; floatBtn.Visible = true end)
floatBtn.MouseButton1Click:Connect(function() frame.Visible = true; floatBtn.Visible = false end)

-- DRAG
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- UPDATE PROFIL
local fpsCount, fpsTime = 0, 0
RunService.RenderStepped:Connect(function(dt) fpsCount += 1; fpsTime += dt end)

task.spawn(function()
    while task.wait(0.5) do
        local ok = pcall(function()
            profilRows["Nama"].Text = plr.Name
            profilRows["Display"].Text = plr.DisplayName
            profilRows["User ID"].Text = tostring(plr.UserId)
            profilRows["Umur Akun"].Text = tostring(math.floor(plr.AccountAge)) .. " hari"
            profilRows["Pemain di Server"].Text = tostring(#Players:GetPlayers())
            profilRows["Ping"].Text = string.format("%.0f ms", Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            if fpsTime >= 1 then profilRows["FPS"].Text = tostring(fpsCount); fpsCount, fpsTime = 0, 0 end
            local c = plr.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            profilRows["Posisi"].Text = h and string.format("%.0f, %.0f, %.0f", h.Position.X, h.Position.Y, h.Position.Z) or "-"
        end)
        if not ok then break end
    end
end)
