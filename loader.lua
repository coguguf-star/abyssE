-- ============================================
-- AbyssE Loader  (repo: coguguf-star/AbyssE)
-- Hanya membuka MENU. Modul game di-load dari toggle.
-- ============================================

local BASE = "https://raw.githubusercontent.com/coguguf-star/AbyssE/main/games/"
getgenv().ABYSS_BASE = BASE

local url = BASE .. "menu.lua?v=" .. tostring(os.time())
local ok, src = pcall(function() return game:HttpGet(url) end)

if not ok or not src or #src < 10 then
    warn("[AbyssE] gagal ambil menu.lua -> " .. url)
    return
end

local f, err = loadstring(src)
if not f then
    warn("[AbyssE] syntax error menu.lua: " .. tostring(err))
    return
end

local ok2, err2 = pcall(f)
if not ok2 then
    warn("[AbyssE] runtime error menu.lua: " .. tostring(err2))
end
