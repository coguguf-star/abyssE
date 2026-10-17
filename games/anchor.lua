-- ============================================
-- AbyssE - anchor.lua
-- Anchor HumanoidRootPart biar ga mati di tengah jalan.
-- API: ABYSS_ANCHOR.set(bool) / start() / stop() / isOn()
-- Kalau respawn pas anchor ON, otomatis di-anchor lagi.
-- ============================================

local Players = game:GetService("Players")
local plr     = Players.LocalPlayer

local function LOG(m)
    local f = getgenv().ABYSS_LOG
    if f then f(m) else print("[ANCHOR] " .. tostring(m)) end
end

local M = {}
M.loaded = true
getgenv().ABYSS_ANCHOR = M

local on    = false
local token = 0

local function getRoot()
    local c = plr.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function apply()
    local r = getRoot()
    if r and r.Anchored ~= on then
        pcall(function()
            r.AssemblyLinearVelocity  = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            r.Anchored = on
        end)
    end
end

-- jaga-jaga kalau game/script lain ngelepas anchor
local function watchdog(myToken)
    while on and token == myToken do
        apply()
        task.wait(0.5)
    end
end

function M.isOn() return on end
function M.isRunning() return on end

function M.set(v)
    v = v and true or false
    if v == on then apply(); return end
    on = v
    token = token + 1
    apply()
    LOG("[ANCHOR] " .. (on and "ON" or "OFF"))
    if on then task.spawn(watchdog, token) end
end

function M.start() M.set(true)  end
function M.stop()  M.set(false) end

-- respawn pas anchor ON -> anchor lagi karakter baru
if getgenv().ABYSS_ANCHOR_CONN then
    pcall(function() getgenv().ABYSS_ANCHOR_CONN:Disconnect() end)
end
getgenv().ABYSS_ANCHOR_CONN = plr.CharacterAdded:Connect(function(c)
    if not on then return end
    local r = c:WaitForChild("HumanoidRootPart", 10)
    if r and on then
        task.wait(0.1)
        apply()
    end
end)
