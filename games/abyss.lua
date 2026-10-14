-- ============================================
-- AbyssE - abyss.lua  (modul AUTO TRIP)
-- ON  -> M.start()   |   OFF -> M.stop()
-- ============================================

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local PLR     = Players.LocalPlayer
local LOG     = getgenv().ABYSS_LOG or function(m) print("[TRIP] "..tostring(m)) end

local M = {}
M.loaded = true
getgenv().ABYSS_TRIP = M

-- ====== CONFIG ======
local AMP          = 14
local WALK_SPEED   = 22
local LAND_TIMEOUT = 8
local ROPE_INDEX   = 13
local RESUME       = Vector3.new(-277.8, -1274.2, -57.0)

-- ====== JALUR (hasil rekaman manual) ======
local PATH = {
    Vector3.new(-180,    4, -30),
    Vector3.new(-200,    0, -40),
    Vector3.new(-215,  -60, -45),
    Vector3.new(-225, -140, -50),
    Vector3.new(-232, -230, -52),
    Vector3.new(-238, -330, -55),
    Vector3.new(-243, -430, -57),
    Vector3.new(-247, -530, -60),
    Vector3.new(-250, -630, -62),
    Vector3.new(-252, -730, -63),
    Vector3.new(-254, -820, -64),
    Vector3.new(-256, -870, -64.5),
    Vector3.new(-262.0, -898.4, -64.5),   -- [13] TALI
    RESUME,                               -- [14] setelah tali
    Vector3.new(-275, -1320, -55),
    Vector3.new(-270, -1370, -52),
    Vector3.new(-262, -1420, -50),
    Vector3.new(-250, -1460, -48),
    Vector3.new(-235, -1490, -46),
    Vector3.new(-215, -1510, -45),
    Vector3.new(-195, -1520, -44),
}

-- ====== STATE ======
local running = false
local conns = {}
local snakeConn = nil
local target = nil
local thread = nil

local function char()
    local c = PLR.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return nil end
    return c, h, r
end

local function add(c) table.insert(conns, c); return c end
local function clearConns()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}
end

-- ====== SNAKE ======
local function snakeStop()
    if snakeConn then pcall(function() snakeConn:Disconnect() end) end
    snakeConn = nil
end

local function snakeStart()
    if snakeConn then return end
    snakeConn = RS.RenderStepped:Connect(function()
        local _, h, r = char()
        if not h or not r or r.Anchored then return end

        local limit = 25
        if target then
            local d = (r.Position - target).Magnitude
            if d > 60 then limit = 80
            elseif d > 20 then limit = 30
            else limit = 10 end
        end

        local v = r.AssemblyLinearVelocity
        local ny = v.Y
        if ny < -limit then ny = -limit end

        r.AssemblyLinearVelocity = Vector3.new(
            math.random(-AMP, AMP), ny, math.random(-AMP, AMP))
    end)
end

-- ====== TELEPORT ======
local function tp(pos)
    local _, _, r = char()
    if not r then return end
    pcall(function() PLR:RequestStreamAroundAsync(pos) end)
    task.wait(0.15)
    r.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
end

local function waitLand()
    local t0 = tick()
    while tick() - t0 < LAND_TIMEOUT do
        if not running then return end
        local _, h, r = char()
        if not r then return end
        if h.FloorMaterial ~= Enum.Material.Air then return end
        task.wait(0.1)
    end
end

-- ====== LOOP JALUR ======
local function follow()
    local i = 1
    while i <= #PATH and running do
        if i == ROPE_INDEX then
            target = PATH[i]
            tp(PATH[i])
            task.wait(0.6)
            snakeStop()
            LOG("[TRIP] Sampai tali (" .. tostring(PATH[i]) .. "). Pakai tali manual, hold 0.5-1 dtk.")

            local t0 = tick()
            while running and tick() - t0 < 120 do
                if getgenv().ABYSS_SKIP then
                    getgenv().ABYSS_SKIP = false
                    LOG("[TRIP] LANJUT manual.")
                    break
                end
                local _, _, r = char()
                if not r then break end
                if r.Position.Y < PATH[i].Y - 150 then
                    LOG("[TRIP] Terdeteksi sudah turun. Lanjut.")
                    task.wait(1)
                    break
                end
                task.wait(0.2)
            end

            LOG("[TRIP] Resume di bawah tali.")
            target = RESUME
            tp(RESUME)
            task.wait(1)
            snakeStart()
            i = ROPE_INDEX + 2
        else
            if not running then break end
            target = PATH[i]
            LOG(string.format("[TRIP] titik %d/%d  (%.0f, %.0f, %.0f)", i, #PATH, PATH[i].X, PATH[i].Y, PATH[i].Z))
            tp(PATH[i])
            waitLand()
            task.wait(0.1)
            i = i + 1
        end
    end
    target = nil
    if running then
        LOG("[TRIP] Jalur selesai. Karakter di dasar abyss.")
        running = false
        snakeStop()
    end
end

-- ====== API ======
function M.isRunning() return running end

function M.start()
    if running then return end
    if not char() then LOG("[TRIP] Character belum spawn."); return end
    running = true
    getgenv().ABYSS_SKIP = false

    local _, h = char()
    if h then pcall(function() h.WalkSpeed = WALK_SPEED end) end

    thread = task.spawn(function()
        LOG("[TRIP] ON - snake mode nyala, bersiap...")
        task.wait(1.5)
        if not running then return end
        snakeStart()
        task.wait(1)
        local ok, err = pcall(follow)
        if not ok then LOG("[TRIP] error: " .. tostring(err)) end
    end)

    add(PLR.CharacterAdded:Connect(function()
        task.wait(1.5)
        if running then LOG("[TRIP] Respawn terdeteksi.") end
    end))
end

function M.stop()
    if not running and not snakeConn then return end
    running = false
    target = nil
    snakeStop()
    clearConns()
    local _, h, r = char()
    if h then pcall(function() h.WalkSpeed = 16 end) end
    if r then pcall(function() r.Anchored = false end) end
    LOG("[TRIP] OFF - balik ke mode normal Roblox.")
end
