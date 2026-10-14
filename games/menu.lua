-- ============================================
-- AbyssE - menu.lua
-- Menu draggable + animasi + server hop
-- ============================================

local Players  = game:GetService("Players")
local RS       = game:GetService("RunService")
local UIS      = game:GetService("UserInputService")
local Stats    = game:GetService("Stats")
local Tween    = game:GetService("TweenService")
local Teleport = game:GetService("TeleportService")
local Http     = game:GetService("HttpService")

local PLR  = Players.LocalPlayer
local PGUI = PLR:WaitForChild("PlayerGui")
local BASE = getgenv().ABYSS_BASE or "https://raw.githubusercontent.com/coguguf-star/AbyssE/main/games/"

if getgenv().ABYSS_MENU_GUI then pcall(function() getgenv().ABYSS_MENU_GUI:Destroy() end) end
if getgenv().ABYSS_TRIP   and getgenv().ABYSS_TRIP.stop   then pcall(getgenv().ABYSS_TRIP.stop) end
if getgenv().ABYSS_LAYER4 and getgenv().ABYSS_LAYER4.stop then pcall(getgenv().ABYSS_LAYER4.stop) end

local C = {
    bg    = Color3.fromRGB(16,17,22),
    panel = Color3.fromRGB(26,28,36),
    line  = Color3.fromRGB(45,48,60),
    acc   = Color3.fromRGB(80,130,255),
    on    = Color3.fromRGB(38,160,90),
    off   = Color3.fromRGB(55,58,70),
    txt   = Color3.fromRGB(235,238,245),
    dim   = Color3.fromRGB(150,155,170),
}

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function addPress(btn)
    local s = mk("UIScale", {}, btn)
    btn.MouseButton1Down:Connect(function()
        Tween:Create(s, TweenInfo.new(0.07), {Scale = 0.94}):Play()
    end)
    local function back()
        Tween:Create(s, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
    btn.MouseButton1Up:Connect(back)
    btn.MouseLeave:Connect(back)
end

-- ================= LOG =================
local logLines, logLabel, logScroll = {}, nil, nil

getgenv().ABYSS_LOG = function(msg)
    local line = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(msg)
    table.insert(logLines, line)
    if #logLines > 250 then table.remove(logLines, 1) end
    if logLabel then
        logLabel.Text = table.concat(logLines, "\n")
        task.defer(function()
            if logScroll then logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y) end
        end)
    end
end
local LOG = getgenv().ABYSS_LOG

-- ================= GUI =================
local gui = mk("ScreenGui", {
    Name = "AbyssE_Menu", ResetOnSpawn = false,
    IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, PGUI)
getgenv().ABYSS_MENU_GUI = gui

local main = mk("Frame", {
    Size = UDim2.new(0, 320, 0, 430),
    Position = UDim2.new(1, -332, 0, 80),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 12) }, main)
mk("UIStroke", { Color = C.line, Thickness = 1 }, main)
local mainScale = mk("UIScale", { Scale = 0 }, main)

local header = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = C.panel, BorderSizePixel = 0,
}, main)
mk("UICorner", { CornerRadius = UDim.new(0, 12) }, header)
mk("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1, Text = "AbyssE",
    Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = C.txt,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 24), Position = UDim2.new(1, -68, 0, 6),
    BackgroundColor3 = C.off, Text = "-", Font = Enum.Font.GothamBold,
    TextSize = 16, TextColor3 = C.txt, BorderSizePixel = 0,
}, header)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, minBtn)
addPress(minBtn)

local hideBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 24), Position = UDim2.new(1, -36, 0, 6),
    BackgroundColor3 = C.off, Text = "x", Font = Enum.Font.GothamBold,
    TextSize = 14, TextColor3 = C.txt, BorderSizePixel = 0,
}, header)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, hideBtn)
addPress(hideBtn)

local tabBar = mk("Frame", {
    Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 42),
    BackgroundTransparency = 1,
}, main)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4) }, tabBar)

local content = mk("Frame", {
    Size = UDim2.new(1, -16, 1, -84), Position = UDim2.new(0, 8, 0, 76),
    BackgroundTransparency = 1, ClipsDescendants = true,
}, main)

local pages = {}

local function addTab(name)
    local btn = mk("TextButton", {
        Size = UDim2.new(0.2, -4, 1, 0), BackgroundColor3 = C.off,
        Text = name, Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = C.txt, BorderSizePixel = 0,
    }, tabBar)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
    addPress(btn)

    local page = mk("CanvasGroup", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Visible = false, GroupTransparency = 1,
    }, content)
    pages[name] = { btn = btn, page = page }
    return page
end

local function showTab(name)
    for n, p in pairs(pages) do
        if n == name then
            p.page.Visible = true
            p.page.GroupTransparency = 1
            p.page.Position = UDim2.new(0, 16, 0, 0)
            Tween:Create(p.page, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }):Play()
            Tween:Create(p.btn, TweenInfo.new(0.15), { BackgroundColor3 = C.acc }):Play()
        else
            local pg = p.page
            if pg.Visible then
                Tween:Create(pg, TweenInfo.new(0.14), { GroupTransparency = 1 }):Play()
                task.delay(0.14, function()
                    if pg.GroupTransparency > 0.9 then pg.Visible = false end
                end)
            end
            Tween:Create(p.btn, TweenInfo.new(0.15), { BackgroundColor3 = C.off }):Play()
        end
    end
end

-- ================= DRAG =================
local function makeDraggable(frame, handle, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, 0
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, 0
            dragStart, startPos = input.Position, frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        moved = math.max(moved, math.abs(d.X) + math.abs(d.Y))
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false
        if onTap and moved < 12 then onTap() end
    end)
end

makeDraggable(main, header)

-- ================= MINI BUTTON =================
local mini = mk("TextButton", {
    Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(1, -70, 0, 130),
    BackgroundColor3 = C.acc, Text = "A", Font = Enum.Font.GothamBold,
    TextSize = 20, TextColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
    Visible = false,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 14) }, mini)
local miniScale = mk("UIScale", { Scale = 1 }, mini)
makeDraggable(mini, mini, function() openMain() end)

local function openMain()
    mini.Visible = false
    main.Visible = true
    mainScale.Scale = 0.72
    Tween:Create(mainScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

local function closeMain()
    Tween:Create(mainScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 }):Play()
    task.delay(0.17, function()
        if mainScale.Scale < 0.1 then
            main.Visible = false
            mini.Visible = true
            miniScale.Scale = 0
            Tween:Create(miniScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        end
    end)
end

minBtn.MouseButton1Click:Connect(closeMain)
hideBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

-- ================= TAB: PROFIL =================
local prof = addTab("PROFIL")
local profScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 420),
}, prof)

local infoLabel = mk("TextLabel", {
    Size = UDim2.new(1, -6, 0, 112), BackgroundColor3 = C.panel, BorderSizePixel = 0,
    Text = "  memuat...", Font = Enum.Font.Code, TextSize = 13, TextColor3 = C.txt,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, profScroll)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, infoLabel)

mk("TextLabel", {
    Size = UDim2.new(1, -6, 0, 20), Position = UDim2.new(0, 0, 0, 120),
    BackgroundTransparency = 1, Text = "  PEMAIN DI SERVER",
    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profScroll)

local playerList = mk("Frame", {
    Size = UDim2.new(1, -6, 0, 220), Position = UDim2.new(0, 0, 0, 144),
    BackgroundTransparency = 1,
}, profScroll)
mk("UIListLayout", { Padding = UDim.new(0, 4) }, playerList)

local fps, frames, lastFps = 0, 0, tick()
RS.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastFps >= 1 then fps, frames, lastFps = frames, 0, tick() end
end)

local function getPing()
    local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    return ok and math.floor(v) or -1
end

task.spawn(function()
    while gui.Parent do
        local ch  = PLR.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.new(0,0,0)
        infoLabel.Text = string.format(
            "  User     : %s\n  Ping     : %d ms\n  FPS      : %d\n  Server   : %d pemain\n  JobId    : %s\n  Posisi   : %.1f, %.1f, %.1f\n  Kedalaman: %.0f M",
            PLR.Name, getPing(), fps, #Players:GetPlayers(),
            string.sub(game.JobId, 1, 8) .. "...", pos.X, pos.Y, pos.Z, pos.Y)

        for _, c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            local isMe = (p == PLR)
            mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = isMe and C.acc or C.panel, BorderSizePixel = 0,
                Text = "  " .. p.Name .. (isMe and "  (lu)" or ""),
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.txt,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, playerList)
        end
        task.wait(1)
    end
end)

-- ================= HELPER: MODUL =================
local function ensureModule(file, key)
    local m = getgenv()[key]
    if m and m.loaded then return m end
    local ok, err = pcall(function()
        local src = game:HttpGet(BASE .. file .. ".lua?v=" .. tostring(os.time()))
        local f = assert(loadstring(src))
        f()
    end)
    if not ok then LOG("[LOAD] gagal load " .. file .. " : " .. tostring(err)); return nil end
    return getgenv()[key]
end

local tripVisual, l4Visual

local function setTrip(on)
    if on then
        local m = ensureModule("abyss", "ABYSS_TRIP")
        if m and m.start then m.start() else if tripVisual then tripVisual(false) end end
    else
        local m = getgenv().ABYSS_TRIP
        if m and m.stop then m.stop() end
    end
end

local function setL4(on)
    if on then
        local m = ensureModule("layer4", "ABYSS_LAYER4")
        if m and m.start then m.start() else if l4Visual then l4Visual(false) end end
    else
        local m = getgenv().ABYSS_LAYER4
        if m and m.stop then m.stop() end
    end
end

local function callL4(fn)
    local m = getgenv().ABYSS_LAYER4
    if not m or not m.loaded then
        setL4(true)
        m = getgenv().ABYSS_LAYER4
    end
    if m and m[fn] then m[fn]() end
end

local function fullBtn(parent, y, text, fn)
    local b = mk("TextButton", {
        Size = UDim2.new(1, -10, 0, 34), Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = C.panel, Text = text, Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = C.txt, BorderSizePixel = 0,
    }, parent)
    mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
    addPress(b)
    b.MouseButton1Click:Connect(fn)
    return b
end

local function halfBtn(parent, col, y, text, fn)
    local b = mk("TextButton", {
        Size = UDim2.new(0.5, -8, 0, 32),
        Position = (col == 0) and UDim2.new(0, 5, 0, y) or UDim2.new(0.5, 3, 0, y),
        BackgroundColor3 = C.panel, Text = text, Font = Enum.Font.Gotham,
        TextSize = 12, TextColor3 = C.txt, BorderSizePixel = 0,
    }, parent)
    mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
    addPress(b)
    b.MouseButton1Click:Connect(fn)
    return b
end

local function sectionLabel(parent, y, text)
    mk("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 5, 0, y),
        BackgroundTransparency = 1, Text = "  " .. text,
        Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function makeToggle(parent, y, text, onChanged)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, -10, 0, 38), Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = C.off, Text = text .. "   OFF",
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.txt,
        BorderSizePixel = 0,
    }, parent)
    mk("UICorner", { CornerRadius = UDim.new(0, 8) }, btn)
    addPress(btn)
    local state = false
    local function paint()
        btn.BackgroundColor3 = state and C.on or C.off
        btn.Text = text .. "   " .. (state and "ON" or "OFF")
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        paint()
        onChanged(state)
    end)
    return btn, function(v) state = v; paint() end
end

-- ================= TAB: AUTO TRIP =================
local trip = addTab("TRIP")
local tripScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 300),
}, trip)

local _, setTripVis = makeToggle(tripScroll, 6, "AUTO TRIP ABYSS", setTrip)
tripVisual = setTripVis

fullBtn(tripScroll, 52, "LANJUT (lewat tali)", function()
    getgenv().ABYSS_SKIP = true
    LOG("[TRIP] LANJUT ditekan")
end)

sectionLabel(tripScroll, 96, "CATATAN")
mk("TextLabel", {
    Size = UDim2.new(1, -10, 0, 130), Position = UDim2.new(0, 5, 0, 118),
    BackgroundColor3 = C.panel, BorderSizePixel = 0, TextWrapped = true,
    Text = "  Modul jalan sendiri ngikutin jalur rekaman.\n  Pas nyampe tali, snake mati & nunggu lu pakai tali manual (hold 0.5-1 dtk).\n  Kalau lu udah turun, tekan LANJUT.\n\n  Kalau mati, dia otomatis mulai dari titik terdekat.",
    Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.dim,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, tripScroll)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, tripScroll:GetChildren()[#tripScroll:GetChildren()])

-- ================= TAB: LAYER 4 =================
local l4 = addTab("LAYER4")
local l4Scroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 360),
}, l4)

local _, setL4Vis = makeToggle(l4Scroll, 6, "LAYER 4 EXPLORER", setL4)
l4Visual = setL4Vis

local modeLabel = mk("TextLabel", {
    Size = UDim2.new(1, -10, 0, 22), Position = UDim2.new(0, 5, 0, 52),
    BackgroundTransparency = 1, Text = "  MODE: -",
    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.acc,
    TextXAlignment = Enum.TextXAlignment.Left,
}, l4Scroll)

sectionLabel(l4Scroll, 78, "GERAK (analog buat terbang)")
halfBtn(l4Scroll, 0, 98,  "MODE FLY",    function() callL4("setFly")    end)
halfBtn(l4Scroll, 1, 98,  "MODE WALK",   function() callL4("setWalk")   end)
halfBtn(l4Scroll, 0, 134, "MODE FREEZE", function() callL4("setFreeze") end)

sectionLabel(l4Scroll, 176, "PINDAH POSISI")
halfBtn(l4Scroll, 0, 196, "TURUN 250",  function() callL4("moveDown") end)
halfBtn(l4Scroll, 1, 196, "NAIK 250",   function() callL4("moveUp")   end)
halfBtn(l4Scroll, 0, 232, "TURUN 1000", function() callL4("moveDownBig") end)
halfBtn(l4Scroll, 1, 232, "NAIK 1000",  function() callL4("moveUpBig")   end)
fullBtn(l4Scroll, 274, "BALIK KE POSISI AWAL", function() callL4("goBack") end)

RS.RenderStepped:Connect(function()
    local m = getgenv().ABYSS_LAYER4
    if m and m.getMode then
        modeLabel.Text = "  MODE: " .. m.getMode() .. (m.isRunning() and "" or "  (OFF)")
    end
end)

-- ================= TAB: SERVER =================
local srv = addTab("SERVER")
local srvScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 320),
}, srv)

local srvInfo = mk("TextLabel", {
    Size = UDim2.new(1, -10, 0, 60), Position = UDim2.new(0, 5, 0, 6),
    BackgroundColor3 = C.panel, BorderSizePixel = 0, Text = "  memuat...",
    Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.txt,
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, srvScroll)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, srvInfo)

local hopping = false

local function fetchServers()
    local list, cursor = {}, ""
    for _ = 1, 3 do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s")
            :format(game.PlaceId, cursor)
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if not ok then break end
        local ok2, data = pcall(function() return Http:JSONDecode(res) end)
        if not ok2 then break end
        for _, s in ipairs(data.data or {}) do
            if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 100) then
                table.insert(list, s)
            end
        end
        cursor = data.nextPageCursor
        if not cursor or cursor == "" then break end
    end
    return list
end

local function doHop(mode)
    if hopping then LOG("[HOP] masih proses..."); return end
    hopping = true
    LOG("[HOP] nyari server " .. (mode == "full" and "RAME" or "SEPI") .. "...")

    task.spawn(function()
        local ok, servers = pcall(fetchServers)
        if not ok or not servers or #servers == 0 then
            LOG("[HOP] ga nemu server lain.")
            hopping = false
            return
        end
        table.sort(servers, function(a, b)
            local pa, pb = a.playing or 0, b.playing or 0
            if mode == "full" then return pa > pb else return pa < pb end
        end)
        local pick = servers[math.random(1, math.min(5, #servers))]
        LOG(("[HOP] pindah -> %d/%d pemain"):format(pick.playing or 0, pick.maxPlayers or 100))
        local okT, err = pcall(function()
            Teleport:TeleportToPlaceInstance(game.PlaceId, pick.id, PLR)
        end)
        if not okT then
            LOG("[HOP] gagal teleport: " .. tostring(err))
            hopping = false
        end
    end)
end

fullBtn(srvScroll, 74,  "KE SERVER RAME (penuh)", function() doHop("full")  end)
fullBtn(srvScroll, 114, "KE SERVER SEPI",         function() doHop("empty") end)
fullBtn(srvScroll, 154, "REJOIN SERVER INI", function()
    LOG("[HOP] rejoin server ini...")
    pcall(function() Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, PLR) end)
end)
fullBtn(srvScroll, 194, "REFRESH INFO", function() end)

Teleport.TeleportInitFailed:Connect(function(_, result)
    LOG("[HOP] gagal: " .. tostring(result))
    hopping = false
end)

task.spawn(function()
    while gui.Parent do
        srvInfo.Text = string.format("  Server ini : %d pemain\n  JobId      : %s\n  PlaceId    : %d",
            #Players:GetPlayers(), string.sub(game.JobId, 1, 10) .. "...", game.PlaceId)
        task.wait(2)
    end
end)

-- ================= TAB: LOG =================
local logPage = addTab("LOG")
logScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -40), BackgroundColor3 = C.panel,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0, 0, 0, 400),
}, logPage)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, logScroll)

logLabel = mk("TextLabel", {
    Size = UDim2.new(1, -8, 0, 0), Position = UDim2.new(0, 4, 0, 4),
    BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, Text = "",
    Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.txt,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, logScroll)

local logBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 1, -34),
    BackgroundTransparency = 1,
}, logPage)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, logBar)

local function logBarBtn(text, fn)
    local b = mk("TextButton", {
        Size = UDim2.new(1/3, -4, 1, 0), BackgroundColor3 = C.off, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.txt, BorderSizePixel = 0,
    }, logBar)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
    addPress(b)
    b.MouseButton1Click:Connect(fn)
end

logBarBtn("CLEAR", function() logLines = {}; logLabel.Text = "" end)
logBarBtn("COPY", function()
    if setclipboard then pcall(function() setclipboard(table.concat(logLines, "\n")) end) end
    LOG("[LOG] dicopy")
end)
logBarBtn("SIMPAN .TXT", function()
    local fname = "AbyssE_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    if writefile then
        local ok = pcall(function() writefile(fname, table.concat(logLines, "\n")) end)
        LOG(ok and ("[LOG] disimpan: " .. fname) or "[LOG] gagal simpan")
    else
        LOG("[LOG] writefile ga ada")
    end
end)

-- ================= INIT =================
for name, p in pairs(pages) do
    p.btn.MouseButton1Click:Connect(function() showTab(name) end)
end

showTab("PROFIL")
openMain()
LOG("Menu AbyssE siap.")

task.spawn(function()
    while gui.Parent do
        task.wait(0.5)
        local t = getgenv().ABYSS_TRIP
        if t and t.isRunning and not t.isRunning() and tripVisual then tripVisual(false) end
        local l = getgenv().ABYSS_LAYER4
        if l and l.isRunning and not l.isRunning() and l4Visual then l4Visual(false) end
    end
end)
