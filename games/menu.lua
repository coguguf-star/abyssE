-- ============================================
-- AbyssE - menu.lua
-- Menu draggable + minimizable + toggle modul
-- ============================================

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local Stats   = game:GetService("Stats")

local PLR  = Players.LocalPlayer
local PGUI = PLR:WaitForChild("PlayerGui")
local BASE = getgenv().ABYSS_BASE or "https://raw.githubusercontent.com/coguguf-star/AbyssE/main/games/"

-- bersihin kalau di-load ulang
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

-- ================= LOG =================
local logLines = {}
local logLabel, logScroll

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
    Name = "AbyssE_Menu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
}, PGUI)
getgenv().ABYSS_MENU_GUI = gui

local main = mk("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 300, 0, 400),
    Position = UDim2.new(1, -312, 0, 90),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, main)
mk("UIStroke", { Color = C.line, Thickness = 1 }, main)

local header = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, header)

mk("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "AbyssE",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = C.txt,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 24),
    Position = UDim2.new(1, -36, 0, 5),
    BackgroundColor3 = C.off,
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = C.txt,
    BorderSizePixel = 0,
}, header)
mk("UICorner", { CornerRadius = UDim.new(0, 6) }, minBtn)

-- tab bar
local tabBar = mk("Frame", {
    Size = UDim2.new(1, -16, 0, 30),
    Position = UDim2.new(0, 8, 0, 40),
    BackgroundTransparency = 1,
}, main)
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
}, tabBar)

local content = mk("Frame", {
    Size = UDim2.new(1, -16, 1, -82),
    Position = UDim2.new(0, 8, 0, 76),
    BackgroundTransparency = 1,
}, main)

local pages = {}
local function addTab(name)
    local btn = mk("TextButton", {
        Size = UDim2.new(1/3, -4, 1, 0),
        BackgroundColor3 = C.off,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.txt,
        BorderSizePixel = 0,
    }, tabBar)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

    local page = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
    }, content)
    pages[name] = { btn = btn, page = page }
    return page
end

local function showTab(name)
    for n, p in pairs(pages) do
        local sel = (n == name)
        p.page.Visible = sel
        p.btn.BackgroundColor3 = sel and C.acc or C.off
    end
end

-- ================= DRAG =================
local function makeDraggable(frame, handle, onTap)
    local dragging, dragStart, startPos, moved = false, nil, nil, 0
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = 0
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = input.Position - dragStart
        moved = math.max(moved, math.abs(d.X) + math.abs(d.Y))
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
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

-- ================= MINI BUTTON (draggable juga) =================
local mini = mk("TextButton", {
    Size = UDim2.new(0, 48, 0, 48),
    Position = UDim2.new(1, -70, 0, 140),
    BackgroundColor3 = C.acc,
    Text = "A",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.new(1,1,1),
    BorderSizePixel = 0,
    Visible = false,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 12) }, mini)

makeDraggable(mini, mini, function()
    mini.Visible = false
    main.Visible = true
end)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

-- ================= TAB: PROFIL =================
local prof = addTab("PROFIL")
local profScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -80),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 400),
}, prof)

local infoLabel = mk("TextLabel", {
    Size = UDim2.new(1, -6, 0, 110),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    Text = "",
    Font = Enum.Font.Code,
    TextSize = 13,
    TextColor3 = C.txt,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, profScroll)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, infoLabel)
infoLabel.Text = "  memuat..."

mk("TextLabel", {
    Size = UDim2.new(1, -6, 0, 20),
    Position = UDim2.new(0, 0, 0, 118),
    BackgroundTransparency = 1,
    Text = "  PEMAIN DI SERVER",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
}, profScroll)

local playerList = mk("Frame", {
    Size = UDim2.new(1, -6, 0, 200),
    Position = UDim2.new(0, 0, 0, 142),
    BackgroundTransparency = 1,
}, profScroll)
mk("UIListLayout", { Padding = UDim.new(0, 4) }, playerList)

local fps, frames, lastFps = 0, 0, tick()
RS.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastFps >= 1 then
        fps = frames
        frames = 0
        lastFps = tick()
    end
end)

local function getPing()
    local ok, v = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and math.floor(v) or -1
end

task.spawn(function()
    while gui.Parent do
        local ch = PLR.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.new(0,0,0)
        infoLabel.Text = string.format(
            "  User    : %s\n  Ping    : %d ms\n  FPS     : %d\n  Server  : %d pemain\n  PlaceID : %d\n  Posisi  : %.1f, %.1f, %.1f\n  Kedalaman: %.0f M",
            PLR.Name, getPing(), fps, #Players:GetPlayers(), game.PlaceId,
            pos.X, pos.Y, pos.Z, pos.Y)

        for _, c in ipairs(playerList:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            local isMe = (p == PLR)
            mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = isMe and C.acc or C.panel,
                BorderSizePixel = 0,
                Text = "  " .. p.Name .. (isMe and "  (lu)" or ""),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = C.txt,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, playerList)
        end
        task.wait(1)
    end
end)

-- ================= TAB: FITUR =================
local feat = addTab("FITUR")
local featScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 460),
}, feat)

local function ensureModule(file, key)
    local m = getgenv()[key]
    if m and m.loaded then return m end
    local ok, err = pcall(function()
        local src = game:HttpGet(BASE .. file .. ".lua?v=" .. tostring(os.time()))
        local f = assert(loadstring(src))
        f()
    end)
    if not ok then
        LOG("[LOAD] gagal load " .. file .. " : " .. tostring(err))
        return nil
    end
    return getgenv()[key]
end

local function makeToggle(y, text, onChanged)
    local btn = mk("TextButton", {
        Size = UDim2.new(1, -10, 0, 36),
        Position = UDim2.new(0, 5, 0, y),
        BackgroundColor3 = C.off,
        Text = text .. "   OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = C.txt,
        BorderSizePixel = 0,
    }, featScroll)
    mk("UICorner", { CornerRadius = UDim.new(0, 8) }, btn)
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

local tripBtn, setTripVisual = makeToggle(6, "AUTO TRIP ABYSS", function(on)
    if on then
        local m = ensureModule("abyss", "ABYSS_TRIP")
        if m and m.start then m.start() else setTripVisual(false) end
    else
        local m = getgenv().ABYSS_TRIP
        if m and m.stop then m.stop() end
    end
end)

local lanjutBtn = mk("TextButton", {
    Size = UDim2.new(1, -10, 0, 32),
    Position = UDim2.new(0, 5, 0, 48),
    BackgroundColor3 = C.panel,
    Text = "LANJUT (lewat tali)",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = C.txt,
    BorderSizePixel = 0,
}, featScroll)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, lanjutBtn)
lanjutBtn.MouseButton1Click:Connect(function()
    getgenv().ABYSS_SKIP = true
    LOG("[TRIP] LANJUT ditekan")
end)

mk("TextLabel", {
    Size = UDim2.new(1, -10, 0, 22),
    Position = UDim2.new(0, 5, 0, 86),
    BackgroundTransparency = 1,
    Text = "  EXPLORE LAYER 4",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = C.dim,
    TextXAlignment = Enum.TextXAlignment.Left,
}, featScroll)

local l4Btn, setL4Visual = makeToggle(110, "LAYER 4 EXPLORER", function(on)
    if on then
        local m = ensureModule("layer4", "ABYSS_LAYER4")
        if m and m.start then m.start() else setL4Visual(false) end
    else
        local m = getgenv().ABYSS_LAYER4
        if m and m.stop then m.stop() end
    end
end)

local l4Btns = {}
local function mkBtn(text, y, fn)
    local b = mk("TextButton", {
        Size = UDim2.new(0.5, -8, 0, 32),
        Position = UDim2.new(0, 5 + (y % 2) * 0.5 * 300, 0, 0),
        BackgroundColor3 = C.panel,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = C.txt,
        BorderSizePixel = 0,
    }, featScroll)
    mk("UICorner", { CornerRadius = UDim.new(0, 8) }, b)
    b.MouseButton1Click:Connect(fn)
    table.insert(l4Btns, b)
    return b
end

local function callL4(fn)
    local m = getgenv().ABYSS_LAYER4
    if m and m[fn] then m[fn]() end
end

local rowY = 152
mkBtn("MODE FLY", 0, function() callL4("setFly") end).Position = UDim2.new(0, 5, 0, rowY)
mkBtn("MODE WALK", 1, function() callL4("setWalk") end).Position = UDim2.new(0.5, 0, 0, rowY)
rowY = rowY + 38
mkBtn("MODE FREEZE", 0, function() callL4("setFreeze") end).Position = UDim2.new(0, 5, 0, rowY)
mkBtn("TURUN 250", 1, function() callL4("moveDown") end).Position = UDim2.new(0.5, 0, 0, rowY)
rowY = rowY + 38
mkBtn("NAIK 250", 0, function() callL4("moveUp") end).Position = UDim2.new(0, 5, 0, rowY)
mkBtn("BALIK KE ATAS", 1, function() callL4("goBack") end).Position = UDim2.new(0.5, 0, 0, rowY)

-- ================= TAB: LOG =================
local logPage = addTab("LOG")
logScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -40),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    CanvasSize = UDim2.new(0, 0, 0, 400),
}, logPage)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, logScroll)

logLabel = mk("TextLabel", {
    Size = UDim2.new(1, -8, 0, 0),
    Position = UDim2.new(0, 4, 0, 4),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Text = "",
    Font = Enum.Font.Code,
    TextSize = 12,
    TextColor3 = C.txt,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, logScroll)

local logBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    Position = UDim2.new(0, 0, 1, -34),
    BackgroundTransparency = 1,
}, logPage)
mk("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, logBar)

local function logBarBtn(text, fn)
    local b = mk("TextButton", {
        Size = UDim2.new(1/3, -4, 1, 0),
        BackgroundColor3 = C.off,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = C.txt,
        BorderSizePixel = 0,
    }, logBar)
    mk("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
    b.MouseButton1Click:Connect(fn)
end

logBarBtn("CLEAR", function()
    logLines = {}
    logLabel.Text = ""
end)

logBarBtn("COPY", function()
    if setclipboard then pcall(function() setclipboard(table.concat(logLines, "\n")) end) end
    LOG("[LOG] dicopy ke clipboard")
end)

logBarBtn("SIMPAN .TXT", function()
    local txt = table.concat(logLines, "\n")
    local fname = "AbyssE_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    if writefile then
        local ok = pcall(function() writefile(fname, txt) end)
        LOG(ok and ("[LOG] disimpan: " .. fname) or "[LOG] gagal simpan (writefile error)")
    else
        LOG("[LOG] writefile ga ada, pake COPY aja")
    end
end)

-- ================= INIT =================
showTab("PROFIL")
pages["PROFIL"].btn.MouseButton1Click:Connect(function() showTab("PROFIL") end)
pages["FITUR"].btn.MouseButton1Click:Connect(function() showTab("FITUR") end)
pages["LOG"].btn.MouseButton1Click:Connect(function() showTab("LOG") end)

LOG("Menu AbyssE siap. Tekan FITUR buat nyalain modul.")

-- sinkron visual toggle kalau modul berhenti sendiri
task.spawn(function()
    while gui.Parent do
        task.wait(0.5)
        local t = getgenv().ABYSS_TRIP
        if t and t.isRunning and not t.isRunning() then setTripVisual(false) end
        local l = getgenv().ABYSS_LAYER4
        if l and l.isRunning and not l.isRunning() then setL4Visual(false) end
    end
end)
