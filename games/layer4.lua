-- ============================================
-- AbyssE - layer4.lua
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr        = Players.LocalPlayer
local LOG        = getgenv().ABYSS_LOG or function(m) print("[L4] " .. tostring(m)) end

local M = {}
M.loaded = true
getgenv().ABYSS_LAYER4 = M

local FLY_SPEED  = 90
local WALK_SPEED = 50
local STEP       = 250
local MAX_FALL   = 60

local running = false
local mode    = "FREEZE"
local conn, charAddedConn, savedCF, lowestY

local function char()
    local c = plr.Character
    if not c then return nil end
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return nil end
    return c, h, r
end

local function applyMode()
    local _, h, r = char()
    if not r then return end
    if mode == "WALK" then
        r.Anchored = false
        if h then h.WalkSpeed = WALK_SPEED end
        lowestY = r.Position.Y
    else
        r.Anchored = true
        if h then h.WalkSpeed = 16 end
    end
end

function M.isRunning() return running end
function M.getMode()    return mode    end

function M.setFly()    mode = "FLY";    applyMode(); LOG("[L4] mode FLY")    end
function M.setWalk()   mode = "WALK";   applyMode(); LOG("[L4] mode WALK")   end
function M.setFreeze() mode = "FREEZE"; applyMode(); LOG("[L4] mode FREEZE") end

-- FIX: selalu anchor saat pindah, apapun modenya, biar ga ditarik gravitasi
local function shift(dy, label)
    local _, _, r = char()
    if not r then LOG("[L4] karakter belum ada"); return end
    local wasWalk = (mode == "WALK")
    r.Anchored = true
    local p = r.Position + Vector3.new(0, dy, 0)
    pcall(function() plr:RequestStreamAroundAsync(p) end)
    task.wait(0.15)
    r.CFrame = CFrame.new(p)
    lowestY = p.Y
    if wasWalk then r.Anchored = false end
    LOG(("[L4] %s %.0f -> Y %.0f"):format(label, math.abs(dy), p.Y))
end

function M.moveDown()    shift(-STEP,     "turun") end
function M.moveUp()      shift( STEP,     "naik")  end
function M.moveDownBig() shift(-STEP * 4, "turun") end
function M.moveUpBig()   shift( STEP * 4, "naik")  end

function M.goBack()
    local _, _, r = char()
    if not r or not savedCF then LOG("[L4] posisi awal belum kesimpen"); return end
    r.Anchored = true
    pcall(function() plr:RequestStreamAroundAsync(savedCF.Position) end)
    task.wait(0.15)
    r.CFrame = savedCF
    lowestY = savedCF.Position.Y
    if mode == "WALK" then r.Anchored = false end
    LOG("[L4] balik ke posisi awal.")
end

function M.start()
    if running then return end
    local _, _, r = char()
    if not r then LOG("[L4] Character belum spawn."); return end

    savedCF = r.CFrame
    running = true
    mode = "FLY"
    applyMode()
    LOG("[L4] ON - FLY aktif. Analog buat gerak, tombol TURUN buat masuk Layer 4.")

    conn = RunService.RenderStepped:Connect(function(dt)
        if not running then return end
        local _, hum, root = char()
        if not root or not hum then return end

        if mode == "FLY" then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0.05 then
                root.CFrame = root.CFrame + dir.Unit * FLY_SPEED * dt
            end
        elseif mode == "WALK" then
            local v = root.AssemblyLinearVelocity
            if v.Y < -MAX_FALL then
                root.AssemblyLinearVelocity = Vector3.new(v.X, -MAX_FALL, v.Z)
            end
            if lowestY and root.Position.Y < lowestY - 300 then
                mode = "FREEZE"
                applyMode()
                LOG("[L4] jatuh > 300 stud, di-FREEZE. Tekan FLY buat lanjut.")
            end
            lowestY = math.min(lowestY or root.Position.Y, root.Position.Y)
        end
    end)

    charAddedConn = plr.CharacterAdded:Connect(function()
        task.wait(1.5)
        if running then applyMode() end
    end)
end

function M.stop()
    if not running then return end
    running = false
    if conn then pcall(function() conn:Disconnect() end); conn = nil end
    if charAddedConn then pcall(function() charAddedConn:Disconnect() end); charAddedConn = nil end
    local _, h, r = char()
    if h then pcall(function() h.WalkSpeed = 16 end) end
    if r then pcall(function() r.Anchored = false end) end
    LOG("[L4] OFF - balik ke mode normal Roblox.")
end
