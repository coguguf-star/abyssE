-- ============================================
-- AbyssE - layer4.lua  (modul EXPLORE LAYER 4)
-- ON -> M.start()  |  OFF -> M.stop()
-- ============================================

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local PLR     = Players.LocalPlayer
local LOG     = getgenv().ABYSS_LOG or function(m) print("[L4] "..tostring(m)) end

local M = {}
M.loaded = true
getgenv().ABYSS_LAYER4 = M

local FLY_SPEED = 90
local WALK_SPEED = 50
local STEP = 250

local running = false
local mode = "FREEZE"
local conn = nil
local savedCF = nil
local lastY = nil

local function char()
    local c = PLR.Character
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
        h.WalkSpeed = WALK_SPEED
        lastY = r.Position.Y
    else
        r.Anchored = true
        if h then h.WalkSpeed = 16 end
    end
end

function M.isRunning() return running end

function M.setFly()    mode = "FLY";    applyMode(); LOG("[L4] mode FLY")    end
function M.setWalk()   mode = "WALK";   applyMode(); LOG("[L4] mode WALK")   end
function M.setFreeze() mode = "FREEZE"; applyMode(); LOG("[L4] mode FREEZE") end

function M.moveDown()
    local _, _, r = char(); if not r then return end
    local p = r.Position - Vector3.new(0, STEP, 0)
    pcall(function() PLR:RequestStreamAroundAsync(p) end)
    task.wait(0.2)
    r.CFrame = CFrame.new(p)
    LOG("[L4] turun -> Y " .. math.floor(p.Y))
end

function M.moveUp()
    local _, _, r = char(); if not r then return end
    local p = r.Position + Vector3.new(0, STEP, 0)
    pcall(function() PLR:RequestStreamAroundAsync(p) end)
    task.wait(0.2)
    r.CFrame = CFrame.new(p)
    LOG("[L4] naik -> Y " .. math.floor(p.Y))
end

function M.goBack()
    local _, _, r = char(); if not r then return end
    if not savedCF then return end
    pcall(function() PLR:RequestStreamAroundAsync(savedCF.Position) end)
    task.wait(0.2)
    r.CFrame = savedCF
    LOG("[L4] balik ke posisi awal.")
end

function M.start()
    if running then return end
    local _, h, r = char()
    if not r then LOG("[L4] Character belum spawn."); return end

    savedCF = r.CFrame
    running = true
    mode = "FLY"
    applyMode()
    LOG("[L4] ON - FLY aktif. Pakai TURUN buat masuk Layer 4, analog buat gerak.")

    conn = RS.RenderStepped:Connect(function(dt)
        if not running then return end
        local _, hum, root = char()
        if not root then return end

        if mode == "FLY" then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0.05 then
                root.CFrame = root.CFrame + dir.Unit * FLY_SPEED * dt
            end
        elseif mode == "WALK" then
            local v = root.AssemblyLinearVelocity
            if v.Y < -60 then
                root.AssemblyLinearVelocity = Vector3.new(v.X, -60, v.Z)
            end
            if lastY and root.Position.Y < lastY - 300 then
                mode = "FREEZE"
                applyMode()
                LOG("[L4] jatuh > 300, di-FREEZE. Tekan FLY buat lanjut.")
            end
            lastY = math.max(lastY or root.Position.Y, root.Position.Y)
        end
    end)
end

function M.stop()
    if not running then return end
    running = false
    if conn then pcall(function() conn:Disconnect() end); conn = nil end
    local _, h, r = char()
    if h then pcall(function() h.WalkSpeed = 16 end) end
    if r then pcall(function() r.Anchored = false end) end
    LOG("[L4] OFF - balik ke mode normal Roblox.")
end
