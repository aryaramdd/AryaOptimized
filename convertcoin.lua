-- Settings
local COIN_TYPES = {"MagmaCoin", "GalaxyCoin", "FrozenCoin"}
local INTERVAL = 300 -- Dalam detik (300 detik = 5 menit)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local ConvertRemote = Remotes.ConvertCoins

print("Auto Convert Started!")

-- Loop Abadi
task.spawn(function()
    while true do
        for _, coinKey in ipairs(COIN_TYPES) do
            -- Kita kirim nil di argumen kedua supaya server otomatis convert SEMUA coin yang ada
            -- Berdasarkan logika script lu: v_u_18:InvokeServer(v_u_47.key, v70)
            -- Jika v70 nil, server biasanya menganggap itu "Convert All"
            
            local success, msg, amount = ConvertRemote:InvokeServer(coinKey, nil)
            
            if success then
                print("Successfully converted " .. coinKey)
            else
                print("Failed to convert " .. coinKey .. " or no coins available.")
            end
        end
        
        print("Waiting 5 minutes for next conversion...")
        task.wait(INTERVAL)
    end
end)
