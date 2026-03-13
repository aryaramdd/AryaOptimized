local player = game.Players.LocalPlayer
local RemoteRestock = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("Networking"):WaitForChild("RF/ListBoothOffering")

-- Fungsi Filter Nama (Logic dari lu biar dapet nama asli)
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

-- KONFIGURASI JUALAN
local HARGA = 15 
local JEDA_ANTAR_ITEM = 10 -- Jeda tiap naruh 1 barang (biar gak spam)
local JEDA_SCAN_ULANG = 30 -- Jeda nunggu setelah satu tas beres di-scan

print("--- AUTO RESTOCK TRADING PLAZA START ---")

while true do
    local bp = player:FindFirstChild("Backpack")
    
    if bp then
        local items = bp:GetChildren()
        print("Mengecek " .. #items .. " item di tas...")
        
        for i, item in pairs(items) do
            local cleanName = getPureName(item)
            local itemUUID = item:GetAttribute("UUID") or item:GetAttribute("uuid") or item.Name
            
            -- Cek apakah UUID valid (format 8b6edd10-...)
            if itemUUID and string.match(itemUUID, "%-") then
                -- EKSEKUSI JUALAN
                local success, res = pcall(function()
                    return RemoteRestock:InvokeServer(itemUUID, HARGA)
                end)
                
                if success then
                    print("✅ Berhasil List: " .. cleanName)
                    -- Kasih jeda setelah berhasil naruh satu barang
                    task.wait(JEDA_ANTAR_ITEM)
                else
                    -- Kalau gagal (biasanya booth penuh), gak perlu jeda lama, lanjut cek item berikutnya
                    warn("❌ Skip/Penuh: " .. cleanName)
                end
            end
        end
    end
    
    print("--- Scan selesai. Nunggu " .. JEDA_SCAN_ULANG .. " detik buat restock ulang ---")
    task.wait(JEDA_SCAN_ULANG)
end
