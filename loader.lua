-- loader.lua
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local BASE = "https://raw.githubusercontent.com/coguguf-star/felixi/main/games/"

local places = {
    [93387271767638] = "menu.lua",   -- Abyss Expedition
    -- kalau mau nambah game lain, tambahin di sini:
    -- [PLACEID] = "namafile.lua",
}

local file = places[game.PlaceId]

if file then
    task.wait(math.random() * 0.5)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(BASE .. file))()
    end)
    if not ok then
        local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
        local l = Instance.new("TextLabel", gui)
        l.Size = UDim2.new(0, 340, 0, 130)
        l.Position = UDim2.new(0, 8, 0, 200)
        l.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        l.TextColor3 = Color3.new(1, 1, 1)
        l.TextWrapped = true
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.Text = "LOADER ERROR:\n" .. tostring(err)
    end
end
