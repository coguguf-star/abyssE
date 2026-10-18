-- ============================================
-- AbyssE - farm.lua
-- Orkestrator AFK:
--   ANCHOR ON -> AUTO TRIP (abyss.lua) -> sampai dasar
--   -> tunggu 1-3 dtk -> ANCHOR OFF -> patroli bolak-balik
--   sampai "End of Expedition" muncul (TripFinishedEvent)
--   -> tunggu 2-3 dtk -> RESPAWN -> ulang
-- Butuh modul: ABYSS_ANCHOR (anchor.lua) & ABYSS_TRIP (abyss.lua)
-- API: ABYSS_FARM.start() / stop() / isRunning() / getPhase() / getCycles()
-- ============================================

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local plr     = Players.LocalPlayer

local function LOG(m)
    local f = getgenv().ABYSS_LOG
    if f then f(m) else print("[FARM] " .. tostring(m)) end
end

-- ===== SETTING =====
local CFG = {
    BOTTOM_WAIT       = { 1, 3 },  -- nunggu di dasar sebelum anchor dilepas
    AFTER_FINISH_WAIT = { 2, 3 },  -- nunggu setelah "End of Expedition" muncul sebelum respawn
    RESPAWN_TIMEOUT   = 30,        -- batas nunggu karakter baru
    SETTLE            = 1.5,       -- jeda setelah respawn sebelum mulai lagi
    MAX_TRIP          = 600,       -- batas aman satu kali turun (detik)

    -- titik patroli bolak-balik (urutan dipakai muter)
    PACE_POINTS = {
        Vector3.new(-155, -2093, -74),
        Vector3.new(-126.0, -2091.7, -51.8),
    },
    WALK_RADIUS  = 3.5,            -- dianggap sampai kalau jarak (XZ) <= ini
    PACE_TIMEOUT = 90,             -- batas patroli kalau tulisan ga muncul-muncul

    FINISH_EVENT = "TripFinishedEvent", -- nama RemoteEvent di ReplicatedStorage
    FINISH_GUI   = "TripFinishGui",     -- nama ScreenGui di PlayerGui
}
-- ===================

local M = {}
M.loaded = true
getgenv().ABYSS_FARM = M

local running = false
local runId   = 0
local phase   = "-"
local cycles  = 0

-- ============== DETEKSI "END OF EXPEDITION" ==============
local finished   = false
local finishConn = nil

local function hookFinish()
    if finishConn then
        pcall(function() finishConn:Disconnect() end)
        finishConn = nil
    end
    local ev = RS:FindFirstChild(CFG.FINISH_EVENT)
    if ev and ev:IsA("RemoteEvent") then
        finishConn = ev.OnClientEvent:Connect(function() finished = true end)
        return true
    end
    return false
end

local function guiShown()
    local pg  = plr:FindFirstChild("PlayerGui")
    local g   = pg and pg:FindFirstChild(CFG.FINISH_GUI)
    local img = g and g:FindFirstChildWhichIsA("ImageLabel", true)
    return img ~= nil and img.Visible and img.ImageTransparency < 0.9
end

-- ============== UTIL ==============
local function alive(id) return running and id == runId end

local function rand(r) return r[1] + math.random() * (r[2] - r[1]) end

-- sleep yang bisa diputus kalau farm di-stop
local function sleep(t, id)
    local e = 0
    while e < t do
        if not alive(id) then return false end
        task.wait(0.25)
        e = e + 0.25
    end
    return alive(id)
end

local function rig()
    local c = plr.Character
    if not c or not c.Parent then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if h and r then return c, h, r end
end

-- tunggu ada karakter hidup (dan bukan karakter `notChar`)
local function waitAlive(id, timeout, notChar)
    local t = 0
    while t < timeout do
        if not alive(id) then return false end
        local c, h = rig()
        if c and h.Health > 0 and c ~= notChar then return true end
        task.wait(0.25)
        t = t + 0.25
    end
    return false
end

-- patroli bolak-balik sampai tulisan muncul. true = muncul, false = timeout/mati
local function pace(id)
    local pts      = CFG.PACE_POINTS
    local i        = 1
    local t        = 0
    local baseShown = guiShown()   -- kalau GUI udah "keliatan" dari awal, jangan dipercaya

    while t < CFG.PACE_TIMEOUT do
        if not alive(id) then return false end
        if finished or (not baseShown and guiShown()) then return true end

        local _, h, r = rig()
        if not h or h.Health <= 0 then return false end

        local tgt = pts[i]
        local d = Vector3.new(r.Position.X - tgt.X, 0, r.Position.Z - tgt.Z).Magnitude
        if d <= CFG.WALK_RADIUS then
            i = i % #pts + 1
            tgt = pts[i]
        end
        h:MoveTo(tgt)

        task.wait(0.25)
        t = t + 0.25
    end
    return false
end

-- ============== SATU SIKLUS ==============
local function cycle(id)
    local anchor = getgenv().ABYSS_ANCHOR
    local trip   = getgenv().ABYSS_TRIP
    if not anchor or not trip then
        LOG("[FARM] modul anchor/trip belum ke-load")
        sleep(3, id)
        return
    end
    if not finishConn then hookFinish() end

    -- 1. tunggu karakter siap
    phase = "TUNGGU KARAKTER"
    if not waitAlive(id, 60) then
        if alive(id) then LOG("[FARM] karakter ga muncul, coba lagi") end
        return
    end

    -- 2. anchor dulu
    phase = "ANCHOR ON"
    anchor.set(true)
    finished = false   -- reset penanda, event yang masuk selama siklus ini dihitung
    if not sleep(0.5, id) then return end

    -- 3. auto trip turun
    phase = "TURUN (AUTO)"
    trip.start()
    if not trip.isRunning() then
        LOG("[FARM] trip gagal start, coba lagi 3 dtk")
        sleep(3, id)
        return
    end

    local t0 = tick()
    while alive(id) and trip.isRunning() do
        if tick() - t0 > CFG.MAX_TRIP then
            LOG("[FARM] turun kelamaan (timeout), paksa lanjut")
            pcall(trip.stop)
            break
        end
        task.wait(0.5)
    end
    if not alive(id) then return end

    -- 4. udah di dasar, tunggu bentar
    phase = "DI DASAR"
    local w1 = rand(CFG.BOTTOM_WAIT)
    LOG(("[FARM] di dasar, tunggu %.1f dtk"):format(w1))
    if not sleep(w1, id) then return end

    -- 5. lepas anchor, patroli sampai "End of Expedition" muncul
    local bottomChar = plr.Character
    anchor.set(false)
    if not sleep(0.5, id) then return end

    phase = "PATROLI (CARI TRIGGER)"
    local got = pace(id)
    if not alive(id) then return end
    if got then
        LOG("[FARM] End of Expedition muncul")
    else
        LOG("[FARM] tulisan ga muncul (timeout/mati), lanjut respawn")
    end

    phase = "NUNGGU RESPAWN"
    local w2 = rand(CFG.AFTER_FINISH_WAIT)
    LOG(("[FARM] respawn %.1f dtk lagi"):format(w2))
    if not sleep(w2, id) then return end

    -- 6. respawn
    phase = "RESPAWN"
    if plr.Character == bottomChar then
        local _, h = rig()
        if h and h.Health > 0 then
            pcall(function() h.Health = 0 end)
            task.wait(1)
            if plr.Character == bottomChar and h.Health > 0 then
                pcall(function() bottomChar:BreakJoints() end)
            end
        end
    end
    if not waitAlive(id, CFG.RESPAWN_TIMEOUT, bottomChar) then
        if alive(id) then LOG("[FARM] respawn timeout, ulang dari awal") end
        return
    end
    if not sleep(CFG.SETTLE, id) then return end

    cycles = cycles + 1
    LOG("[FARM] siklus #" .. cycles .. " selesai")
end

-- ============== API ==============
function M.isRunning() return running end
function M.getPhase()  return phase end
function M.getCycles() return cycles end

function M.start()
    if running then return end
    running = true
    runId   = runId + 1
    cycles  = 0
    finished = false
    local id = runId

    if not hookFinish() then
        LOG("[FARM] RemoteEvent " .. CFG.FINISH_EVENT .. " ga ketemu, pakai deteksi GUI aja")
    end

    -- bersihin state lama biar mulai dari nol
    local trip = getgenv().ABYSS_TRIP
    if trip and trip.stop then pcall(trip.stop) end

    LOG("[FARM] ON")
    task.spawn(function()
        while alive(id) do
            local ok, err = pcall(cycle, id)
            if not ok then
                LOG("[FARM] ERR: " .. tostring(err))
                sleep(3, id)
            end
            task.wait(0.2)
        end
    end)
end

function M.stop()
    if not running then return end
    running = false
    runId   = runId + 1
    phase   = "-"

    if finishConn then
        pcall(function() finishConn:Disconnect() end)
        finishConn = nil
    end

    local trip   = getgenv().ABYSS_TRIP
    local anchor = getgenv().ABYSS_ANCHOR
    if trip   and trip.stop  then pcall(trip.stop) end
    if anchor and anchor.set then pcall(anchor.set, false) end
    LOG("[FARM] OFF")
end
