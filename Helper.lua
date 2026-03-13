local Rayfield = loadstring(game:HttpGet('\104\116\116\112\115\58\47\47\115\105\114\105\117\115\46\109\101\110\117\47\114\97\121\102\105\101\108\100'))()

local Window = Rayfield:CreateWindow({
   Name = "\65\114\121\97\114\97\109\100\100\32\72\101\108\112\101\114",
   LoadingTitle = "\66\101\32\82\101\97\100\121\32\46\46\46",
   LoadingSubtitle = "\98\121\32\68\105\115\99\111\114\100\32\58\32\65\114\121\97\114\97\109\100\100",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- --- INITIAL SETUP (FPS GUI) ---
local ScreenGui = Instance.new("ScreenGui")
local FPSLabel = Instance.new("TextLabel")
ScreenGui.Name = "AryaFPS"
ScreenGui.Parent = game:GetService("\67\111\114\101\71\117\105")
ScreenGui.Enabled = false
FPSLabel.Parent = ScreenGui
FPSLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FPSLabel.BackgroundTransparency = 0.5
FPSLabel.Position = UDim2.new(0.5, -40, 0, 50)
FPSLabel.Size = UDim2.new(0, 80, 0, 30)
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextSize = 18
FPSLabel.Font = Enum.Font.Code

local f = 0
local t = tick()
game:GetService("RunService").RenderStepped:Connect(function()
    f = f + 1
    if tick() - t >= 1 then
        FPSLabel.Text = "FPS: "..f
        f = 0
        t = tick()
    end
end)

local MainTab = Window:CreateTab("\72\101\108\112\101\114\32\84\111\111\108\115", 4483362458)

-- 1. FPS TOGGLE
MainTab:CreateToggle({
   Name = "\83\104\111\119\32\70\80\83\32\67\111\117\110\116\101\114",
   CurrentValue = false,
   Callback = function(Value)
       ScreenGui.Enabled = Value
   end,
})

-- 2. 3D RENDER (ANTI LAG PARAH)
MainTab:CreateToggle({
   Name = "\51\68\32\82\101\110\100\101\114\105\110\103\32\40\79\70\70\32\61\32\76\97\103\45\70\105\120\41",
   CurrentValue = true,
   Callback = function(Value)
       game:GetService("RunService"):Set3dRenderingEnabled(Value)
   end,
})

-- 3. PERFORMANCE MODE (SEMEN MODE)
MainTab:CreateButton({
   Name = "\69\110\97\98\108\101\32\80\101\114\102\111\114\109\97\110\99\101\32\77\111\100\101",
   Callback = function()
       -- Matikan bayangan & turunkan kualitas
       settings().Rendering.QualityLevel = 1
       game.Lighting.GlobalShadows = false
       
       local function Clean(v)
           if v:IsA("BasePart") then
               v.Material = Enum.Material.SmoothPlastic
               v.Color = Color3.fromRGB(163, 162, 165)
           elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
               v:Destroy()
           end
       end

       for _, v in pairs(game.Workspace:GetDescendants()) do Clean(v) end
       game.Workspace.DescendantAdded:Connect(Clean)
       
       Rayfield:Notify({Title = "Status", Content = "Dunia jadi semen!", Duration = 2})
   end,
})

-- 4. REJOIN
MainTab:CreateButton({
   Name = "\82\101\106\111\105\110\32\83\101\114\118\101\114",
   Callback = function()
       local ts = game:GetService("TeleportService")
       local p = game.Players.LocalPlayer
       ts:Teleport(game.PlaceId, p)
   end,
})
