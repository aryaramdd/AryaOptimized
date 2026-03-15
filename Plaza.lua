local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Setup Data & Variabel
_G.WebhookURL = "https://webhook.lewisakura.moe/api/webhooks/1482698230113239247/k7JIguRr2Xo7Ktu4MVK0xRQP7iski23HgP0LbLaIWDmfCj0NhOZLDjGJA7FxTj4DT8aD"
_G.LoggerEnabled = false
_G.HargaJual = 21 -- Harga default awal
local Player = game:GetService("Players").LocalPlayer
local TokenPath = Player:WaitForChild("leaderstats"):WaitForChild("Trade Tokens")

-- Remote Paths
local RemoteNotify = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Networking"):WaitForChild("RE/Misc/DisplayPopup")
local RemoteRestock = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Networking"):WaitForChild("RF/ListBoothOffering")

local Window = Rayfield:CreateWindow({
   Name = "Arya Saumagodin | Trade Hub",
   LoadingTitle = "Logger & Auto Restock",
   ConfigurationSaving = { Enabled = true, FolderName = "AryaScripts", FileName = "TradeHubConfig" },
   KeySystem = false
})

local MainTab = Window:CreateTab("Control Panel", 4483362458)

-- ================= FUNGSI UTILITY =================

local function getInvCount()
    local str = "N/A"
    pcall(function()
        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and string.find(v.Text, "/") then
                local txt = v.Text
                if string.find(txt, "/100") and not string.find(txt:lower(), "points") and not string.find(txt, "25") then
                    str = txt
                    break
                end
            end
        end
    end)
    return str
end

local function getPureName(item)
    local foundName = ""
    for _, v in pairs(item:GetDescendants()) do
        local txt = (v:IsA("TextLabel") and v.Text) or (v:IsA("StringValue") and v.Value) or ""
        if txt ~= "" and not string.match(txt, "%-") and not string.match(txt, "^%s*$") then
            foundName = txt
            break
        end
    end
    if foundName == "" then 
        local attr = item:GetAttribute("DisplayName") or item:GetAttribute("ItemName")
        foundName = attr and tostring(attr) or item.Name 
    end
    return tostring(foundName)
end

-- ================= FUNGSI WEBHOOK =================

local function sendDiscord(msg, isTest)
    local finalURL = _G.WebhookURL:gsub("discord.com", "webhook.lewisakura.moe")
    local data = {
        ["embeds"] = {{
            ["title"] = isTest and "Test Koneksi ✅" or "Item Sold! ✅",
            ["description"] = "### " .. msg,
            ["color"] = isTest and 0xff0000 or 0x2ecc71,
            ["fields"] = {
                {["name"] = "🎒 Isi Tas", ["value"] = "` " .. getInvCount() .. " `", ["inline"] = true},
                {["name"] = "💳 Saldo Sekarang", ["value"] = "**" .. tostring(TokenPath.Value) .. "**", ["inline"] = true}
            },
            ["footer"] = {["text"] = "Arya Saumagodin System"},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    local body = game:GetService("HttpService"):JSONEncode(data)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then req({Url = finalURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body})
    else pcall(function() game:GetService("HttpService"):PostAsync(finalURL, body) end) end
end

-- ================= UI ELEMENTS =================

MainTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = "Paste URL...",
   Callback = function(Text) _G.WebhookURL = Text end,
})

-- KOLOM INPUT HARGA BARU
MainTab:CreateInput({
   Name = "Set Harga Jual",
   PlaceholderText = "Default: 21",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       local num = tonumber(Text)
       if num then
           _G.HargaJual = num
           Rayfield:Notify({Title = "Harga Diupdate!", Content = "Sekarang barang akan dijual seharga: " .. num, Duration = 3})
       end
   end,
})

MainTab:CreateToggle({
   Name = "Enable Discord Logger",
   CurrentValue = false,
   Callback = function(Value) _G.LoggerEnabled = Value end,
})

MainTab:CreateButton({
   Name = "Start Auto Restock (One-Click)",
   Callback = function()
       Rayfield:Notify({Title = "Restock Active!", Content = "Sistem otomatis mulai memajang barang.", Duration = 5})
       
       task.spawn(function()
           local JEDA_ANTAR_ITEM = 10
           local JEDA_SCAN_ULANG = 30
           
           while true do
               local bp = Player:FindFirstChild("Backpack")
               if bp then
                   local items = bp:GetChildren()
                   for _, item in pairs(items) do
                       local cleanName = getPureName(item)
                       local itemUUID = item:GetAttribute("UUID") or item:GetAttribute("uuid") or item.Name
                       
                       if itemUUID and string.match(itemUUID, "%-") then
                           local success = pcall(function()
                               -- Menggunakan _G.HargaJual yang diinput di UI
                               return RemoteRestock:InvokeServer(itemUUID, _G.HargaJual)
                           end)
                           if success then
                               print("✅ Berhasil List: " .. cleanName .. " @ " .. _G.HargaJual)
                               task.wait(JEDA_ANTAR_ITEM)
                           else
                               warn("❌ Skip/Penuh: " .. cleanName)
                           end
                       end
                   end
               end
               task.wait(JEDA_SCAN_ULANG)
           end
       end)
   end,
})

MainTab:CreateButton({
   Name = "Test Connection",
   Callback = function()
       sendDiscord("Tes Berhasil! Logger lu siap memantau.", true)
   end,
})

-- ================= LOGIC LOGGER =================

RemoteNotify.OnClientEvent:Connect(function(...)
    if _G.LoggerEnabled then
        local args = {...}
        for _, v in pairs(args) do
            local s = tostring(v)
            if string.find(s:lower(), "purchased") then
                sendDiscord(s, false)
                break
            end
        end
    end
end)

Rayfield:LoadConfiguration()
