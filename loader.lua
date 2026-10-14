-- ============================================
-- AbyssE Loader
-- repo : coguguf-star/AbyssE
-- ============================================

local BASE = "https://raw.githubusercontent.com/coguguf-star/AbyssE/main/games/"

-- PlaceId game yang didukung
local GAMES = {
    [93387271767638] = "abyss",   -- Abyss Expedition
}

-- biar menu.lua & file lain bisa baca BASE yang sama
getgenv().ABYSS_BASE = BASE

local function fetch(name)
    local url = BASE .. name .. ".lua?v=" .. tostring(os.time())
    local ok, src = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not src or #src < 5 then
        warn("[AbyssE] gagal ambil: " .. url)
        return nil
    end
    return src
end

local function run(name)
    local src = fetch(name)
    if not src then return end
    local f, err = loadstring(src)
    if not f then
        warn("[AbyssE] syntax error di " .. name .. ": " .. tostring(err))
        return
    end
    local ok, err2 = pcall(f)
    if not ok then
        warn("[AbyssE] runtime error di " .. name .. ": " .. tostring(err2))
    end
end

-- 1) Menu selalu di-load duluan
run("menu")

-- 2) Baru file game sesuai PlaceId
local target = GAMES[game.PlaceId]
if target then
    run(target)
else
    warn("[AbyssE] PlaceId " .. tostring(game.PlaceId) .. " belum didukung")
end
