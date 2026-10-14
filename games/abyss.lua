-- ============================================
-- AbyssE - abyss.lua  (modul AUTO TRIP)
-- Basis: AUTO TRIP v17 (logika asli, 100% dipertahankan)
-- Tambahan: API start()/stop() buat toggle menu
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr        = Players.LocalPlayer
local LOG        = getgenv().ABYSS_LOG or function(m) print("[TRIP] " .. tostring(m)) end

local M = {}
M.loaded = true
getgenv().ABYSS_TRIP = M

-- ===== TUNING SNAKE (sama persis kaya v17) =====
local AMP         = 14
local NO_FALL     = true
local MAX_FALL    = 10
local SNAKE_AKTIF = true
-- ===============================================

local running   = false
local snakeConn = nil
local char, hrp, hum

local function V(x, y, z) return Vector3.new(x, y, z) end

local ROPES     = { V(-262.0, -898.4, -64.5) }
local ROPE_EXIT = V(-277.8, -1274.2, -57.0)

local PATH = {
V(-169.7,161.9,-379.3), V(-182.8,161.9,-379.4), V(-202.2,161.9,-354.6), V(-192.1,156.4,-326.0),
V(-173.4,156.8,-299.9), V(-149.1,155.3,-279.6), V(-117.8,153.0,-275.8), V(-86.2,152.7,-274.4),
V(-58.8,148.0,-262.4), V(-42.0,144.7,-255.7), V(-18.9,139.7,-243.5), V(0.0,134.0,-233.6),
V(11.7,125.6,-211.0), V(25.3,118.0,-198.1), V(45.6,110.3,-179.3), V(64.4,101.5,-163.8),
V(83.8,89.4,-143.4), V(99.8,83.0,-119.0), V(110.1,74.3,-90.8), V(113.4,60.8,-63.5),
V(114.7,49.7,-33.4), V(113.9,44.3,-10.1), V(115.2,40.5,17.4), V(117.4,39.9,49.6),
V(118.0,44.3,81.2), V(136.4,48.8,107.6), V(141.0,41.3,137.7), V(140.4,36.6,166.4),
V(131.0,35.4,190.9), V(124.8,45.5,215.1), V(111.2,48.7,243.4), V(95.3,40.5,265.4),
V(77.0,35.0,290.8), V(63.1,26.7,307.3), V(40.7,16.9,322.1), V(15.9,1.9,334.9),
V(-6.3,-4.4,341.0), V(-34.8,-13.8,350.9), V(-63.7,-20.1,360.7), V(-84.5,-19.3,369.8),
V(-116.0,-23.7,371.1), V(-146.4,-32.4,369.6), V(-175.8,-42.8,365.1), V(-203.0,-56.2,355.7),
V(-224.6,-72.3,338.2), V(-237.7,-89.6,315.3), V(-240.6,-111.6,289.1), V(-249.4,-121.5,261.4),
V(-258.5,-133.6,241.3), V(-271.2,-159.4,218.5), V(-293.2,-178.6,206.7), V(-301.8,-195.5,217.3),
V(-293.3,-202.7,246.6), V(-284.8,-219.4,267.6), V(-283.0,-236.2,294.7), V(-297.6,-257.9,303.8),
V(-322.6,-266.9,304.2), V(-351.7,-279.9,301.5), V(-367.0,-289.5,295.6), V(-376.7,-302.9,278.1),
V(-400.1,-310.1,263.7), V(-403.7,-321.0,248.2), V(-401.9,-331.9,218.8), V(-402.8,-329.6,191.3),
V(-403.8,-324.8,175.8), V(-393.5,-327.5,148.0), V(-385.1,-327.0,123.6), V(-379.1,-319.7,104.5),
V(-378.6,-301.9,79.6), V(-380.1,-291.5,59.6), V(-377.6,-277.2,32.0), V(-376.7,-267.9,30.5),
V(-359.2,-271.5,6.8), V(-354.6,-261.1,-16.9), V(-340.0,-249.0,-34.2), V(-345.8,-248.6,-60.9),
V(-354.4,-251.5,-82.0), V(-372.4,-251.8,-108.0), V(-386.7,-257.8,-125.9), V(-391.8,-255.8,-148.7),
V(-367.8,-257.5,-157.5), V(-349.0,-259.7,-182.6), V(-346.3,-263.7,-208.1), V(-342.4,-269.4,-238.9),
V(-333.6,-278.0,-264.6), V(-320.0,-278.7,-280.3), V(-295.9,-277.4,-294.0), V(-268.4,-268.2,-305.9),
V(-242.6,-262.7,-316.2), V(-219.3,-258.8,-298.2), V(-200.6,-250.8,-275.4), V(-174.4,-244.5,-265.7),
V(-144.7,-238.7,-271.8), V(-136.1,-235.0,-301.3), V(-129.9,-246.1,-325.1), V(-127.8,-255.8,-344.9),
V(-112.3,-262.8,-365.7), V(-87.9,-279.8,-356.6), V(-63.9,-283.0,-366.7), V(-40.8,-294.2,-370.8),
V(-24.0,-310.4,-371.5), V(-5.4,-325.5,-386.2), V(9.2,-335.4,-408.9), V(24.8,-339.8,-434.6),
V(52.0,-353.4,-439.7), V(55.2,-367.9,-419.8), V(63.5,-384.2,-403.6), V(87.0,-393.8,-394.1),
V(110.5,-403.5,-394.5), V(130.4,-420.0,-390.7), V(145.9,-423.7,-376.1), V(142.0,-435.0,-363.4),
V(133.6,-448.8,-360.4), V(123.7,-453.8,-358.0), V(128.4,-454.2,-358.8), V(145.2,-446.5,-344.2),
V(141.0,-465.3,-335.9), V(115.5,-478.3,-343.8), V(88.6,-493.0,-357.6), V(70.6,-512.1,-375.9),
V(56.1,-527.4,-392.4), V(33.8,-558.8,-395.6), V(3.1,-562.9,-395.8), V(-22.1,-570.1,-393.1),
V(-28.9,-587.7,-380.6), V(-32.2,-598.2,-370.2), V(-30.7,-596.4,-365.3), V(-50.7,-600.7,-355.8),
V(-73.4,-603.2,-342.5), V(-92.9,-617.1,-330.4), V(-106.7,-620.3,-315.6), V(-128.7,-624.5,-310.5),
V(-148.2,-615.2,-304.7), V(-176.9,-603.8,-299.1), V(-201.7,-599.1,-293.5), V(-231.9,-591.7,-289.0),
V(-256.0,-590.9,-303.1), V(-267.4,-590.9,-294.8), V(-265.7,-590.9,-291.7), V(-250.5,-591.8,-276.9),
V(-241.0,-600.6,-255.6), V(-248.9,-611.9,-229.9), V(-249.2,-634.2,-203.9), V(-246.3,-630.3,-208.4),
V(-249.8,-611.5,-231.7), V(-246.5,-598.3,-256.1), V(-245.2,-592.8,-283.5), V(-247.8,-593.3,-289.1),
V(-248.2,-593.2,-290.9), V(-243.4,-593.3,-278.7), V(-244.9,-600.8,-252.3), V(-249.8,-615.4,-224.2),
V(-245.8,-635.7,-198.6), V(-234.0,-646.9,-179.3), V(-214.1,-665.2,-163.2), V(-189.7,-681.4,-157.0),
V(-160.1,-691.5,-158.5), V(-148.7,-699.8,-186.5), V(-144.6,-706.7,-204.1), V(-135.2,-723.3,-229.3),
V(-115.6,-739.2,-243.0), V(-111.8,-755.7,-266.0), V(-115.2,-764.7,-295.9), V(-91.1,-768.4,-297.3),
V(-67.2,-783.0,-281.7), V(-56.6,-794.4,-257.7), V(-45.4,-802.8,-233.6), V(-32.3,-802.0,-218.1),
V(-30.4,-818.0,-206.3), V(-39.2,-835.7,-191.5), V(-48.5,-845.1,-190.0), V(-58.3,-849.1,-188.1),
V(-64.3,-850.4,-189.4), V(-70.0,-850.4,-192.1), V(-78.0,-838.8,-199.0), V(-90.6,-856.0,-186.9),
V(-106.8,-869.9,-162.6), V(-113.6,-865.7,-165.2), V(-133.2,-852.6,-173.9), V(-156.1,-832.0,-180.8),
V(-178.9,-817.0,-180.3), V(-191.1,-819.7,-170.4), V(-207.8,-835.4,-162.6), V(-223.3,-867.5,-149.9),
V(-236.2,-885.1,-127.5), V(-245.5,-893.8,-97.7), V(-254.7,-887.6,-68.4),
V(-266.4,-898.8,-59.4), V(-278.7,-903.7,-52.2), V(-278.7,-971.1,-52.2), V(-278.7,-1104.6,-52.2),
V(-278.7,-1216.1,-52.2), V(-278.7,-1269.6,-52.2), V(-277.8,-1274.2,-57.2), V(-258.3,-1270.8,-63.0),
V(-245.1,-1287.9,-67.2), V(-224.1,-1295.9,-58.8), V(-210.0,-1292.1,-68.6), V(-203.8,-1300.2,-95.0),
V(-190.7,-1309.0,-107.3), V(-171.3,-1345.2,-117.8), V(-162.6,-1344.0,-119.9), V(-158.8,-1344.3,-128.0),
V(-167.2,-1343.3,-146.7), V(-176.3,-1343.0,-176.8), V(-174.3,-1326.9,-195.4), V(-157.9,-1306.2,-211.3),
V(-127.9,-1296.3,-213.0), V(-114.4,-1292.1,-191.9), V(-104.0,-1292.1,-170.9), V(-106.0,-1292.1,-168.2),
V(-107.8,-1292.1,-169.7), V(-112.4,-1292.1,-192.2), V(-129.7,-1296.4,-211.8), V(-159.6,-1307.4,-208.8),
V(-170.1,-1325.7,-192.6), V(-167.0,-1336.9,-177.1), V(-145.7,-1344.1,-165.6), V(-135.7,-1378.4,-179.5),
V(-115.3,-1376.1,-178.6), V(-88.2,-1381.2,-162.9), V(-90.2,-1412.4,-146.7), V(-90.6,-1431.5,-138.3),
V(-81.9,-1431.3,-121.0), V(-66.6,-1444.5,-111.5), V(-73.9,-1462.7,-96.4), V(-63.8,-1473.6,-86.9),
V(-70.8,-1474.9,-82.8), V(-82.5,-1498.7,-75.5), V(-72.3,-1499.5,-63.7), V(-51.6,-1511.0,-70.8),
V(-35.7,-1523.0,-94.6), V(-37.5,-1530.4,-121.6), V(-41.0,-1542.1,-141.8), V(-29.9,-1560.4,-144.6),
V(-40.8,-1586.2,-121.6), V(-67.0,-1589.2,-116.2), V(-92.0,-1602.3,-110.2), V(-113.7,-1625.5,-108.1),
V(-92.0,-1643.5,-106.4), V(-81.5,-1644.0,-115.7), V(-89.9,-1642.0,-98.1), V(-90.7,-1654.1,-69.4),
V(-98.1,-1660.2,-63.9), V(-124.2,-1659.2,-65.9), V(-142.2,-1664.2,-63.7), V(-157.6,-1668.3,-51.1),
V(-154.0,-1679.4,-32.3), V(-158.5,-1677.8,-24.8), V(-159.9,-1685.4,-15.5), V(-162.2,-1723.3,-19.6),
V(-171.6,-1727.5,-31.0), V(-177.5,-1743.4,-12.6), V(-181.6,-1765.9,-21.5), V(-157.3,-1784.6,-13.8),
V(-146.8,-1797.8,-29.3), V(-157.2,-1803.2,-56.9), V(-150.7,-1813.3,-73.0), V(-131.6,-1835.8,-82.2),
V(-118.9,-1848.5,-101.8), V(-99.5,-1860.2,-111.9), V(-69.8,-1859.0,-116.6), V(-59.8,-1861.0,-102.1),
V(-53.7,-1866.7,-87.7), V(-56.1,-1869.7,-85.9), V(-54.4,-1860.6,-100.1), V(-58.1,-1855.9,-115.9),
V(-68.5,-1857.8,-117.9), V(-94.8,-1863.1,-113.2), V(-103.7,-1860.4,-105.7), V(-100.8,-1860.4,-103.4),
V(-82.0,-1864.0,-114.4), V(-62.6,-1855.9,-117.9), V(-39.6,-1846.1,-127.1), V(-19.9,-1830.2,-130.5),
V(-22.7,-1821.8,-139.3), V(-31.4,-1838.3,-130.5), V(-52.0,-1852.3,-119.3), V(-74.9,-1860.6,-114.6),
V(-100.5,-1864.1,-116.9), V(-108.1,-1855.9,-108.0), V(-126.3,-1843.2,-94.7), V(-134.3,-1833.8,-80.1),
V(-148.5,-1815.9,-73.8), V(-158.5,-1801.7,-53.9), V(-158.5,-1800.0,-48.1), V(-149.6,-1811.6,-71.3),
V(-131.9,-1835.9,-83.3), V(-127.9,-1841.5,-93.3), V(-126.3,-1842.2,-98.4), V(-106.7,-1856.6,-110.9),
V(-100.3,-1859.7,-102.6), V(-82.7,-1865.1,-112.6), V(-64.5,-1858.6,-105.1), V(-67.0,-1858.0,-95.1),
V(-82.4,-1875.2,-84.4), V(-86.8,-1876.5,-82.7), V(-93.4,-1884.2,-87.1), V(-93.4,-1905.3,-85.6),
V(-95.8,-1907.0,-86.8), V(-96.6,-1908.3,-86.5), V(-100.5,-1920.9,-92.4), V(-90.0,-1926.5,-107.8),
V(-100.4,-1934.8,-121.2), V(-107.5,-1946.3,-126.7), V(-113.1,-1959.8,-128.2), V(-92.2,-1963.0,-149.9),
V(-63.7,-1963.8,-153.3), V(-40.5,-1968.4,-139.2), V(-17.9,-1971.0,-126.2), V(2.0,-1973.2,-124.9),
V(22.9,-1995.8,-119.2), V(49.8,-2004.5,-120.6), V(71.9,-2017.9,-121.1), V(63.8,-2036.2,-111.5),
V(36.6,-2045.3,-122.5), V(17.1,-2052.7,-122.4), V(-0.1,-2070.0,-109.4), V(-6.8,-2074.9,-106.6),
V(-16.7,-2076.8,-103.1), V(-22.9,-2077.1,-103.0), V(-31.2,-2078.0,-102.0), V(-40.3,-2079.3,-99.6),
V(-50.1,-2080.1,-99.7), V(-55.1,-2084.6,-104.6), V(-60.1,-2086.1,-110.8), V(-66.1,-2088.0,-117.7),
V(-78.4,-2093.8,-127.7), V(-103.9,-2095.6,-111.7), V(-130.7,-2093.9,-97.7), V(-146.7,-2092.5,-71.7),
V(-123.5,-2089.3,-60.3), V(-119.9,-2086.6,-63.1), V(-116.3,-2083.9,-69.2), V(-116.3,-2086.2,-69.2),
}

-- ================== UTIL ==================
local function status(t)
    local hp = (hum and math.floor(hum.Health)) or 0
    LOG(("%s | HP %d"):format(t, hp))
end

local function nearRope(p)
    for _, r in ipairs(ROPES) do
        if (r - p).Magnitude < 20 then return r end
    end
    return nil
end

local function moveTo(dest)
    local from = hrp.Position
    local dist = (dest - from).Magnitude
    local steps = math.max(1, math.ceil(dist / 40))
    for s = 1, steps do
        if not hrp or not hrp.Parent then return end
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(from:Lerp(dest, s / steps))
        task.wait(0.05)
    end
end

local function refreshChar()
    local c = plr.Character
    if c and c ~= char then
        char = c
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChildOfClass("Humanoid")
        if not r or not h then return end
        hrp, hum = r, h
        status("respawn terdeteksi")
    end
end

-- ================== SNAKE (anti-stale) ==================
local function snakeStart()
    if snakeConn or not SNAKE_AKTIF then return end
    snakeConn = RunService.RenderStepped:Connect(function()
        local c = plr.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local v = h.AssemblyLinearVelocity
        v = v + Vector3.new(
            (math.random() - 0.5) * 2 * AMP,
            (math.random() - 0.5) * 2 * AMP,
            (math.random() - 0.5) * 2 * AMP)
        if NO_FALL and v.Y < -MAX_FALL then
            v = Vector3.new(v.X, -MAX_FALL, v.Z)
        end
        h.AssemblyLinearVelocity = v
    end)
end

local function snakeStop()
    if snakeConn then
        pcall(function() snakeConn:Disconnect() end)
        snakeConn = nil
    end
end

-- ================== STEP ==================
local idx = 1

local function stepOnce()
    refreshChar()
    if not hrp or not hum then return end
    if hum.Health <= 0 then status("MATI di titik " .. idx); return end

    local p    = PATH[idx]
    local rope = nearRope(p)

    if rope then
        if hrp.Position.Y < ROPE_EXIT.Y + 40 then
            status("udah lewat tali")
        else
            snakeStop()
            status("SNAKE OFF - ke tali")
            task.wait(0.8)

            moveTo(rope)
            task.wait(1.0)

            local startY = hrp.Position.Y
            local lastY  = startY
            local stable = 0
            local t = 0
            while t < 120 do
                if not running then return end
                if hum.Health <= 0 then break end
                if getgenv().ABYSS_SKIP then getgenv().ABYSS_SKIP = false; break end
                local y = hrp.Position.Y
                if math.abs(y - lastY) < 0.5 then stable += 0.2 else stable = 0 end
                lastY = y
                status(("DI TALI (turun %.0f) - pakai tali / LANJUT"):format(startY - y))
                if (startY - y) > 20 and stable > 1.0 then break end
                task.wait(0.2); t += 0.2
            end
        end

        local bestI, bestD = idx, math.huge
        for j = idx, math.min(idx + 40, #PATH) do
            local d = (PATH[j] - ROPE_EXIT).Magnitude
            if d < bestD then bestD = d; bestI = j end
        end
        idx = bestI

        if SNAKE_AKTIF then
            status("SNAKE ON - tunggu 1.5s")
            snakeStart()
            task.wait(1.5)
        end
        status("lanjut titik " .. idx)
        task.wait(0.5)
    else
        if idx % 10 == 0 then
            status(("titik %d/%d | Y %.0f"):format(idx, #PATH, hrp.Position.Y))
        end
        moveTo(p)
    end

    idx += 1
end

-- ================== API ==================
function M.isRunning() return running end

function M.start()
    if running then return end

    local c = plr.Character
    if not c then status("Character belum spawn."); return end
    char = c
    hrp  = c:FindFirstChild("HumanoidRootPart")
    hum  = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then status("HumanoidRootPart/Humanoid belum ada."); return end

    running = true
    getgenv().ABYSS_SKIP = false

    -- cari titik terdekat
    idx = 1
    local bestD = math.huge
    for j = 1, #PATH do
        local d = (PATH[j] - hrp.Position).Magnitude
        if d < bestD then bestD = d; idx = j end
    end
    if bestD > 90 then idx = 1 end

    if SNAKE_AKTIF then
        status("SNAKE ON - tunggu 1.5s")
        snakeStart()
        task.wait(1.5)
    end

    status("mulai dari titik " .. idx .. " / " .. #PATH)

    task.spawn(function()
        while idx <= #PATH and running do
            local ok, err = pcall(stepOnce)
            if not ok then
                status("ERR titik " .. idx .. ": " .. tostring(err))
                idx += 1
            end
            task.wait(0.05)
        end
        if running then
            snakeStop()
            status("SELESAI - udah di dasar. pakai relic manual")
            running = false
        end
    end)
end

function M.stop()
    if not running and not snakeConn then return end
    running = false
    snakeStop()
    local c = plr.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.WalkSpeed = 16 end) end
    end
    LOG("[TRIP] OFF - balik ke mode normal Roblox.")
end
