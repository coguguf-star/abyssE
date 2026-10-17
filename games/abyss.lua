-- ============================================
-- AbyssE - abyss.lua
-- Basis: AUTO TRIP v17 (logika asli, ga diubah)
-- + API start()/stop() + auto-start kalau ga lewat menu
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr        = Players.LocalPlayer
local LOG        = getgenv().ABYSS_LOG or function(m) print("[TRIP] " .. tostring(m)) end

local M = {}
M.loaded = true
getgenv().ABYSS_TRIP = M

-- ===== TUNING SNAKE (sama kaya v17) =====
local AMP         = 14
local NO_FALL     = true
local MAX_FALL    = 10
local SNAKE_AKTIF = true
-- ========================================

local running   = false
local snakeConn = nil
local char, hrp, hum
local idx = 1

local function V(x, y, z) return Vector3.new(x, y, z) end

local ROPES     = { V(-262.0, -898.4, -64.5) }
local ROPE_EXIT = V(-277.8, -1274.2, -57.0)

local PATH = {
-- ===== COORDINATE BARU (sampai Y -1292.1) =====
V(-168.6,161.9,-373.4), V(-170.1,161.9,-373.7), V(-195.1,161.9,-368.0), V(-196.1,157.1,-322.4),
V(-183.9,157.2,-308.4), V(-148.1,156.0,-282.4), V(-111.8,152.8,-274.7), V(-65.8,149.0,-258.4),
V(-37.6,143.6,-248.1), V(0.0,132.1,-224.6), V(20.5,121.1,-203.1), V(48.2,108.5,-174.6),
V(77.6,92.2,-148.9), V(103.6,83.2,-118.6), V(112.2,65.8,-74.0), V(112.6,52.4,-41.8),
V(114.2,42.6,0.2), V(115.3,39.9,49.5), V(118.4,45.0,91.9), V(136.6,41.1,126.5),
V(138.2,36.7,164.1), V(131.6,43.7,197.4), V(115.3,47.8,234.8), V(93.7,39.7,268.6),
V(68.3,30.1,308.7), V(40.3,16.8,323.2), V(6.3,-3.3,334.1), V(-30.2,-12.9,349.3),
V(-66.0,-19.5,361.0), V(-113.9,-23.5,367.8), V(-153.8,-33.0,363.3), V(-192.1,-52.9,352.3),
V(-220.8,-69.9,332.9), V(-236.9,-93.9,305.5), V(-239.4,-122.5,261.0), V(-256.1,-135.6,236.3),
V(-277.4,-168.2,210.8), V(-313.6,-192.5,212.0), V(-300.1,-195.8,227.5), V(-285.5,-214.8,260.1),
V(-274.2,-238.3,300.4), V(-299.8,-259.4,310.2), V(-337.1,-273.1,300.4), V(-367.0,-291.6,292.6),
V(-384.0,-308.8,270.6), V(-405.1,-312.4,253.6), V(-392.5,-327.4,215.1), V(-391.9,-333.9,176.4),
V(-383.9,-329.8,130.7), V(-377.9,-319.9,104.4), V(-364.0,-292.8,66.6), V(-352.0,-270.8,38.4),
V(-345.3,-265.4,12.3), V(-342.1,-254.0,-17.7), V(-345.1,-248.9,-63.3), V(-357.3,-249.2,-96.8),
V(-377.9,-259.1,-125.0), V(-373.6,-257.7,-149.5), V(-357.7,-257.5,-177.2), V(-348.2,-264.2,-210.0),
V(-336.6,-274.4,-256.1), V(-330.6,-277.9,-273.8), V(-319.8,-278.7,-280.5), V(-310.5,-279.0,-286.3),
V(-269.4,-268.8,-308.1), V(-232.2,-261.7,-317.4), V(-205.5,-253.6,-285.3), V(-175.4,-245.0,-266.3),
V(-135.1,-238.6,-280.6), V(-135.2,-236.5,-312.8), V(-135.3,-249.4,-331.1), V(-128.1,-257.3,-348.7),
V(-111.1,-266.7,-360.6), V(-68.8,-282.8,-364.1), V(-34.1,-299.3,-370.5), V(-7.1,-325.0,-384.4),
V(8.8,-336.1,-417.1), V(41.2,-347.6,-441.5), V(64.4,-370.6,-429.0), V(91.3,-392.7,-420.5),
V(123.4,-411.4,-400.2), V(144.5,-421.6,-379.4), V(137.7,-449.8,-354.3), V(141.4,-448.0,-346.8),
V(145.0,-448.3,-336.2), V(127.7,-475.1,-346.1), V(102.5,-488.3,-378.7), V(87.1,-512.4,-408.4),
V(60.5,-529.4,-394.3), V(19.3,-559.0,-395.7), V(-16.9,-574.9,-390.3), V(-30.1,-593.9,-373.5),
V(-30.0,-601.8,-367.5), V(-41.9,-599.7,-353.6), V(-64.1,-601.3,-348.9), V(-99.8,-617.0,-330.5),
V(-128.1,-625.8,-314.0), V(-166.5,-606.4,-305.5), V(-203.1,-599.1,-298.0), V(-246.2,-591.9,-278.8),
V(-280.2,-590.8,-264.2), V(-314.8,-585.1,-244.5), V(-334.0,-568.0,-239.3), V(-358.4,-569.3,-201.8),
V(-372.4,-565.8,-165.3), V(-401.2,-575.8,-140.0), V(-412.5,-573.0,-122.7), V(-428.7,-576.0,-89.6),
V(-438.9,-582.7,-74.3), V(-436.4,-587.2,-61.1), V(-407.7,-605.3,-33.0), V(-400.4,-614.1,0.2),
V(-430.0,-629.9,26.5), V(-448.1,-621.7,38.5), V(-452.2,-617.3,72.2), V(-447.9,-624.0,115.5),
V(-435.1,-631.5,148.5), V(-421.3,-645.0,184.3), V(-412.0,-647.2,225.0), V(-402.1,-638.8,256.4),
V(-383.3,-632.7,289.4), V(-380.2,-632.8,330.2), V(-359.4,-630.2,371.0), V(-348.4,-640.6,403.8),
V(-328.1,-640.1,414.5), V(-299.4,-644.4,420.9), V(-259.1,-670.0,418.0), V(-219.2,-677.8,417.8),
V(-182.0,-679.9,434.5), V(-144.0,-681.9,449.1), V(-104.3,-688.2,456.7), V(-63.6,-687.4,468.0),
V(-17.5,-691.8,459.6), V(8.3,-684.4,444.5), V(42.4,-672.2,411.9), V(65.7,-662.4,381.4),
V(94.3,-652.0,361.8), V(128.6,-654.1,358.4), V(122.6,-652.6,358.5), V(78.1,-660.9,374.9),
V(70.1,-656.4,357.9), V(54.1,-679.6,330.1), V(23.8,-705.3,323.6), V(9.2,-729.8,343.6),
V(26.7,-742.2,367.6), V(63.0,-754.2,371.5), V(77.5,-758.6,360.4), V(82.9,-764.3,319.7),
V(88.8,-756.1,305.2), V(64.7,-774.8,290.7), V(56.7,-788.0,282.3), V(51.1,-802.5,271.6),
V(44.7,-811.6,264.4), V(40.2,-817.4,259.9), V(33.9,-823.9,258.5), V(28.9,-827.8,258.2),
V(21.3,-831.6,261.3), V(30.7,-831.4,273.2), V(41.3,-838.4,279.8), V(48.4,-843.7,288.2),
V(48.8,-848.5,303.2), V(43.9,-848.8,308.9), V(45.0,-855.4,322.5), V(61.1,-870.5,347.8),
V(58.2,-853.6,388.8), V(51.7,-820.1,411.5), V(85.7,-840.8,429.2), V(121.9,-874.4,434.3),
V(144.4,-912.0,458.5), V(170.0,-933.2,471.2), V(179.5,-946.0,427.9), V(137.4,-961.6,419.0),
V(93.2,-976.2,425.2), V(117.9,-992.8,438.9), V(160.6,-1006.5,420.4), V(197.8,-1023.5,393.6),
V(239.7,-1039.2,372.8), V(258.7,-1065.8,336.5), V(280.1,-1078.4,301.1), V(320.4,-1072.0,306.2),
V(328.6,-1076.7,340.7), V(314.6,-1107.4,351.9), V(312.4,-1142.3,319.5), V(316.4,-1156.0,289.7),
V(344.3,-1177.3,270.9), V(384.1,-1187.9,281.5), V(395.1,-1210.4,288.1), V(379.1,-1228.0,306.6),
V(352.0,-1249.4,330.5), V(319.9,-1271.3,355.8), V(293.9,-1285.4,352.8), V(256.0,-1310.6,334.0),
V(228.8,-1304.7,316.9), V(189.5,-1291.9,316.0), V(148.1,-1280.3,313.1), V(158.5,-1279.7,323.6),
V(163.4,-1260.2,359.7), V(127.0,-1264.0,365.8), V(78.8,-1258.6,357.9), V(63.8,-1258.6,384.5),
V(54.4,-1261.8,416.2), V(29.7,-1244.7,448.4), V(-0.4,-1233.8,473.0), V(-23.3,-1237.2,454.6),
-- (titik jatuh ke jamur beracun sudah dibuang)
V(-19.8,-1237.4,447.8), V(-49.3,-1248.3,437.2), V(-56.2,-1255.2,466.1), V(-72.0,-1280.0,466.6),
V(-81.3,-1283.7,446.0), V(-107.6,-1302.0,410.4), V(-143.3,-1314.9,397.6), V(-188.8,-1316.8,398.5),
V(-229.7,-1305.4,399.1), V(-269.4,-1312.4,401.3), V(-306.6,-1314.4,383.6), V(-334.8,-1304.4,358.3),
V(-359.2,-1288.5,323.7), V(-363.2,-1276.5,294.3), V(-392.1,-1278.7,266.1), V(-409.8,-1281.5,268.1),
V(-435.6,-1290.7,283.8), V(-470.0,-1295.8,268.8), V(-469.0,-1285.5,233.9), V(-469.8,-1265.7,206.7),
V(-482.9,-1247.8,171.1), V(-471.7,-1251.1,127.8), V(-447.5,-1245.9,120.7), V(-425.3,-1250.2,97.0),
V(-447.1,-1256.6,69.8), V(-469.8,-1254.9,62.8), V(-509.1,-1258.4,32.6), V(-511.9,-1250.9,3.1),
V(-530.7,-1242.8,-22.5), V(-540.6,-1235.9,-51.8), V(-527.3,-1218.3,-86.6), V(-503.9,-1211.5,-110.1),
V(-486.7,-1211.5,-123.1), V(-488.1,-1211.9,-135.8), V(-500.7,-1222.2,-168.7), V(-475.4,-1231.7,-196.2),
V(-452.4,-1257.8,-184.6), V(-462.5,-1268.9,-143.4), V(-447.0,-1256.4,-127.5), V(-412.8,-1267.9,-113.2),
V(-378.1,-1269.2,-114.8), V(-358.3,-1280.9,-122.1), V(-329.5,-1290.4,-138.4), V(-316.2,-1294.0,-146.0),
V(-299.6,-1303.1,-185.6), V(-267.7,-1291.5,-205.8), V(-238.3,-1285.8,-203.8), V(-208.9,-1274.8,-189.7),
V(-185.8,-1261.2,-168.6), V(-156.4,-1261.2,-130.1), V(-134.2,-1267.0,-101.4), V(-112.3,-1275.5,-78.6),
V(-105.5,-1289.6,-115.6), V(-99.4,-1292.1,-149.4), V(-97.0,-1292.1,-174.6),
-- ===== SAMPAI SINI COORDINATE BARU; DI BAWAH = COORDINATE LAMA AbyssE (tidak diubah) =====
V(-104.0,-1292.1,-170.9), V(-106.0,-1292.1,-168.2), V(-107.8,-1292.1,-169.7), V(-112.4,-1292.1,-192.2),
V(-129.7,-1296.4,-211.8), V(-159.6,-1307.4,-208.8), V(-170.1,-1325.7,-192.6), V(-167.0,-1336.9,-177.1),
V(-145.7,-1344.1,-165.6), V(-135.7,-1378.4,-179.5), V(-115.3,-1376.1,-178.6), V(-88.2,-1381.2,-162.9),
V(-90.2,-1412.4,-146.7), V(-90.6,-1431.5,-138.3), V(-81.9,-1431.3,-121.0), V(-66.6,-1444.5,-111.5),
V(-73.9,-1462.7,-96.4), V(-63.8,-1473.6,-86.9), V(-70.8,-1474.9,-82.8), V(-82.5,-1498.7,-75.5),
V(-72.3,-1499.5,-63.7), V(-51.6,-1511.0,-70.8), V(-35.7,-1523.0,-94.6), V(-37.5,-1530.4,-121.6),
V(-41.0,-1542.1,-141.8), V(-29.9,-1560.4,-144.6), V(-40.8,-1586.2,-121.6), V(-67.0,-1589.2,-116.2),
V(-92.0,-1602.3,-110.2), V(-113.7,-1625.5,-108.1), V(-92.0,-1643.5,-106.4), V(-81.5,-1644.0,-115.7),
V(-89.9,-1642.0,-98.1), V(-90.7,-1654.1,-69.4), V(-98.1,-1660.2,-63.9), V(-124.2,-1659.2,-65.9),
V(-142.2,-1664.2,-63.7), V(-157.6,-1668.3,-51.1), V(-154.0,-1679.4,-32.3), V(-158.5,-1677.8,-24.8),
V(-159.9,-1685.4,-15.5), V(-162.2,-1723.3,-19.6), V(-171.6,-1727.5,-31.0), V(-177.5,-1743.4,-12.6),
V(-181.6,-1765.9,-21.5), V(-157.3,-1784.6,-13.8), V(-146.8,-1797.8,-29.3), V(-157.2,-1803.2,-56.9),
V(-150.7,-1813.3,-73.0), V(-131.6,-1835.8,-82.2), V(-118.9,-1848.5,-101.8), V(-99.5,-1860.2,-111.9),
V(-69.8,-1859.0,-116.6), V(-59.8,-1861.0,-102.1), V(-53.7,-1866.7,-87.7), V(-56.1,-1869.7,-85.9),
V(-54.4,-1860.6,-100.1), V(-58.1,-1855.9,-115.9), V(-68.5,-1857.8,-117.9), V(-94.8,-1863.1,-113.2),
V(-103.7,-1860.4,-105.7), V(-100.8,-1860.4,-103.4), V(-82.0,-1864.0,-114.4), V(-62.6,-1855.9,-117.9),
V(-39.6,-1846.1,-127.1), V(-19.9,-1830.2,-130.5), V(-22.7,-1821.8,-139.3), V(-31.4,-1838.3,-130.5),
V(-52.0,-1852.3,-119.3), V(-74.9,-1860.6,-114.6), V(-100.5,-1864.1,-116.9), V(-108.1,-1855.9,-108.0),
V(-126.3,-1843.2,-94.7), V(-134.3,-1833.8,-80.1), V(-148.5,-1815.9,-73.8), V(-158.5,-1801.7,-53.9),
V(-158.5,-1800.0,-48.1), V(-149.6,-1811.6,-71.3), V(-131.9,-1835.9,-83.3), V(-127.9,-1841.5,-93.3),
V(-126.3,-1842.2,-98.4), V(-106.7,-1856.6,-110.9), V(-100.3,-1859.7,-102.6), V(-82.7,-1865.1,-112.6),
V(-64.5,-1858.6,-105.1), V(-67.0,-1858.0,-95.1), V(-82.4,-1875.2,-84.4), V(-86.8,-1876.5,-82.7),
V(-93.4,-1884.2,-87.1), V(-93.4,-1905.3,-85.6), V(-95.8,-1907.0,-86.8), V(-96.6,-1908.3,-86.5),
V(-100.5,-1920.9,-92.4), V(-90.0,-1926.5,-107.8), V(-100.4,-1934.8,-121.2), V(-107.5,-1946.3,-126.7),
V(-113.1,-1959.8,-128.2), V(-92.2,-1963.0,-149.9), V(-63.7,-1963.8,-153.3), V(-40.5,-1968.4,-139.2),
V(-17.9,-1971.0,-126.2), V(2.0,-1973.2,-124.9), V(22.9,-1995.8,-119.2), V(49.8,-2004.5,-120.6),
V(71.9,-2017.9,-121.1), V(63.8,-2036.2,-111.5), V(36.6,-2045.3,-122.5), V(17.1,-2052.7,-122.4),
V(-0.1,-2070.0,-109.4), V(-6.8,-2074.9,-106.6), V(-16.7,-2076.8,-103.1), V(-22.9,-2077.1,-103.0),
V(-31.2,-2078.0,-102.0), V(-40.3,-2079.3,-99.6), V(-50.1,-2080.1,-99.7), V(-55.1,-2084.6,-104.6),
V(-60.1,-2086.1,-110.8), V(-66.1,-2088.0,-117.7), V(-78.4,-2093.8,-127.7), V(-103.9,-2095.6,-111.7),
V(-130.7,-2093.9,-97.7), V(-146.7,-2092.5,-71.7), V(-123.5,-2089.3,-60.3), V(-119.9,-2086.6,-63.1),
V(-116.3,-2083.9,-69.2), V(-116.3,-2086.2,-69.2),
}

-- ============== UTIL ==============
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
    if not hrp or not hrp.Parent then return end
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

-- ============== INI YANG KETINGGALAN DI VERSI GUA ==============
-- Tiap respawn, cari ulang titik terdekat. Kalau ga, idx nyangkut
-- di titik dalam sementara karakter ada di atas -> moveTo nembus terrain.
local function refreshChar()
    local c = plr.Character
    if c and c ~= char then
        char = c
        hrp = c:WaitForChild("HumanoidRootPart")
        hum = c:WaitForChild("Humanoid")
        local bestD = math.huge
        for j = 1, #PATH do
            local d = (PATH[j] - hrp.Position).Magnitude
            if d < bestD then bestD = d; idx = j end
        end
        status("respawn - lanjut dari titik " .. idx)
    end
end

-- ============== SNAKE ==============
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

-- ============== STEP ==============
local function stepOnce()
    refreshChar()
    if not hrp or not hum or not hrp.Parent then return end

    if hum.Health <= 0 then
        status("MATI di titik " .. idx .. " - tunggu respawn")
        local t = 0
        while hum.Health <= 0 and t < 20 and running do
            task.wait(0.25); t = t + 0.25
        end
        return
    end

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
                if not hrp or not hrp.Parent then return end
                if hum.Health <= 0 then break end
                if getgenv().ABYSS_SKIP then getgenv().ABYSS_SKIP = false; break end
                local y = hrp.Position.Y
                if math.abs(y - lastY) < 0.5 then stable = stable + 0.2 else stable = 0 end
                lastY = y
                status(("DI TALI (turun %.0f) - pakai tali / LANJUT"):format(startY - y))
                if (startY - y) > 20 and stable > 1.0 then break end
                task.wait(0.2); t = t + 0.2
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

    idx = idx + 1
end

-- ============== API ==============
function M.isRunning() return running end

function M.start()
    if running then return end

    local c = plr.Character
    if not c then status("Character belum spawn."); return end
    char = c
    hrp  = c:FindFirstChild("HumanoidRootPart")
    hum  = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then status("HumanoidRootPart/Humanoid belum ada."); return end

    while hum.Health <= 0 do task.wait(0.25) end

    running = true
    getgenv().ABYSS_SKIP = false

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
                idx = idx + 1
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

-- kalau di-paste langsung (bukan lewat menu), auto start
if not getgenv().ABYSS_MENU_GUI then
    task.wait(1)
    M.start()
end
