local Library = {
    Flags = {},
    Notify = function(title, text, duration)
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = duration or 3
            })
        end)
    end
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Remote")
local CommF = Remotes and Remotes:FindFirstChild("CommF_") or ReplicatedStorage:FindFirstChild("CommF_")

local ScreenSize = workspace.CurrentCamera.ViewportSize
local IsMobile = UserInputService.TouchEnabled or ScreenSize.X < 800

local Utils = {
    FindNPC = function(name)
        local nearest = nil
        local minDist = math.huge
        local npcs = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Npcs")
        if not npcs then return nil end
        
        for _, v in pairs(npcs:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and string.find(v.Name:lower(), name:lower()) then
                local dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = v
                end
            end
        end
        return nearest
    end,
    
    FindMob = function(name, minLevel, maxLevel)
        local nearest = nil
        local minDist = math.huge
        local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
        if not enemies then return nil end
        
        for _, v in pairs(enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                local mobLevel = tonumber(v:FindFirstChild("Level") and v.Level.Value or 0)
                if (not name or string.find(v.Name:lower(), name:lower())) and (not minLevel or mobLevel >= minLevel) and (not maxLevel or mobLevel <= maxLevel) then
                    local dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = v
                    end
                end
            end
        end
        return nearest
    end,
    
    FindMobsInRadius = function(position, radius, name)
        local mobs = {}
        local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
        if not enemies then return mobs end
        
        for _, v in pairs(enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                if (not name or string.find(v.Name:lower(), name:lower())) then
                    local dist = (v.HumanoidRootPart.Position - position).Magnitude
                    if dist <= radius then
                        table.insert(mobs, v)
                    end
                end
            end
        end
        return mobs
    end,
    
    FindBoss = function(name)
        local bosses = workspace:FindFirstChild("Bosses") or workspace:FindFirstChild("Boss")
        if not bosses then return nil end
        
        for _, v in pairs(bosses:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and string.find(v.Name:lower(), name:lower()) then
                return v
            end
        end
        return nil
    end,
    
    FindFruit = function()
        local fruits = workspace:FindFirstChild("Fruits") or workspace:FindFirstChild("Fruit")
        if not fruits then return nil end
        
        for _, v in pairs(fruits:GetChildren()) do
            if v:FindFirstChild("Handle") or v:FindFirstChild("Part") then
                return v
            end
        end
        return nil
    end,
    
    GetLevel = function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Level") then
            return data.Level.Value
        end
        return 0
    end,
    
    GetMastery = function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Mastery") then
            return data.Mastery.Value
        end
        return 0
    end,
    
    TweenTo = function(position, duration)
        if not HumanoidRootPart then return end
        duration = duration or 0.5
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
        tween:Play()
        return tween
    end,
    
    TeleportTo = function(position)
        if not HumanoidRootPart then return end
        HumanoidRootPart.CFrame = CFrame.new(position)
    end,
    
    FlyToHead = function(target, height)
        if not target or not target:FindFirstChild("HumanoidRootPart") then return end
        local headPos = target.HumanoidRootPart.Position + Vector3.new(0, height or AutoFarm.FlyHeight, 0)
        if AutoFarm.TeleportMode == "Tween" then
            Utils.TweenTo(headPos)
        else
            Utils.TeleportTo(headPos)
        end
    end,
    
    Attack = function(position)
        if CommF then
            CommF:InvokeServer("Attack", {position})
        end
    end,
    
    StartQuest = function(questName)
        if CommF then
            CommF:InvokeServer("StartQuest", questName)
        end
    end
}

local questData = {
    {level = 1, npc = "MarineQuest", mob = "Marine", name = "Lính Hải Quân"},
    {level = 15, npc = "BanditQuest", mob = "Bandit", name = "Cướp Biển"},
    {level = 30, npc = "GorillaQuest", mob = "Gorilla", name = "Khỉ Đột"},
    {level = 50, npc = "CursedQuest", mob = "Cursed", name = "Bị Nguyền Rủa"},
    {level = 75, npc = "PirateQuest", mob = "Pirate", name = "Hải Tặc"},
    {level = 100, npc = "MarineCaptainQuest", mob = "MarineCaptain", name = "Đại Úy Hải Quân"},
    {level = 150, npc = "SavageQuest", mob = "Savage", name = "Dã Man"},
    {level = 200, npc = "IceQuest", mob = "Ice", name = "Băng Tặc"},
    {level = 250, npc = "DragonQuest", mob = "Dragon", name = "Rồng"},
    {level = 300, npc = "MobLeaderQuest", mob = "MobLeader", name = "Thủ Lĩnh Băng Đảng"},
    {level = 350, npc = "PirateKingQuest", mob = "PirateKing", name = "Vua Hải Tặc"},
    {level = 400, npc = "DarkDragonQuest", mob = "DarkDragon", name = "Rồng Đen"},
    {level = 450, npc = "DemonQuest", mob = "Demon", name = "Quỷ"},
    {level = 500, npc = "FallenQuest", mob = "Fallen", name = "Thần Bị Ngã"},
    {level = 550, npc = "GodQuest", mob = "God", name = "Thần"},
    {level = 600, npc = "DivineQuest", mob = "Divine", name = "Thần Thánh"},
}

local HitboxExpander = {
    Enabled = false,
    Size = 10,
    OriginalSizes = {},
    
    ExpandHitbox = function(mob)
        if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
        pcall(function()
            local hrp = mob.HumanoidRootPart
            if not HitboxExpander.OriginalSizes[mob] then
                HitboxExpander.OriginalSizes[mob] = hrp.Size
            end
            hrp.Size = Vector3.new(HitboxExpander.Size, HitboxExpander.Size, HitboxExpander.Size)
        end)
    end,
    
    RestoreHitbox = function(mob)
        if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
        pcall(function()
            local hrp = mob.HumanoidRootPart
            if HitboxExpander.OriginalSizes[mob] then
                hrp.Size = HitboxExpander.OriginalSizes[mob]
                HitboxExpander.OriginalSizes[mob] = nil
            end
        end)
    end,
    
    ExpandAllMobs = function()
        if not HitboxExpander.Enabled then return end
        local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
        if not enemies then return end
        
        for _, v in pairs(enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                HitboxExpander.ExpandHitbox(v)
            end
        end
    end,
    
    RestoreAll = function()
        for mob, _ in pairs(HitboxExpander.OriginalSizes) do
            HitboxExpander.RestoreHitbox(mob)
        end
        HitboxExpander.OriginalSizes = {}
    end,
    
    Loop = function()
        while HitboxExpander.Enabled do
            pcall(function()
                HitboxExpander.ExpandAllMobs()
                task.wait(0.5)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if HitboxExpander.Enabled then return end
        HitboxExpander.Enabled = true
        task.spawn(HitboxExpander.Loop)
    end,
    
    Stop = function()
        HitboxExpander.Enabled = false
        HitboxExpander.RestoreAll()
    end
}

local AutoFarm = {
    Enabled = false,
    CurrentQuest = nil,
    TargetMob = nil,
    BringMobs = false,
    BringPoint = nil,
    TeleportMode = "Tween",
    Radius = 100,
    AutoStoreFruit = false,
    TurboMode = false,
    AttackSpeed = 0.01,
    MultiClick = false,
    SuperTurbo = false,
    FlyMode = false,
    FlyHeight = 15,
    AutoHitbox = false,
    
    AutoQuest = function()
        local level = Utils.GetLevel()
        local bestQuest = nil
        
        for _, q in ipairs(questData) do
            if level >= q.level then
                bestQuest = q
            end
        end
        
        if bestQuest and (not AutoFarm.CurrentQuest or AutoFarm.CurrentQuest ~= bestQuest.npc) then
            local npc = Utils.FindNPC(bestQuest.npc)
            if npc and npc:FindFirstChild("HumanoidRootPart") then
                if AutoFarm.TeleportMode == "Tween" then
                    Utils.TweenTo(npc.HumanoidRootPart.Position)
                else
                    Utils.TeleportTo(npc.HumanoidRootPart.Position)
                end
                task.wait(0.5)
                Utils.StartQuest(bestQuest.npc)
                AutoFarm.CurrentQuest = bestQuest.npc
                Library.Notify("📋 Quest", "Đã nhận: " .. bestQuest.name, 2)
            end
        end
    end,
    
    BringMobsToPoint = function()
        if not AutoFarm.BringMobs or not AutoFarm.BringPoint then return end
        local mobs = Utils.FindMobsInRadius(AutoFarm.BringPoint, AutoFarm.Radius * 2)
        for _, mob in pairs(mobs) do
            pcall(function()
                if mob.Humanoid.Health > 0 then
                    mob.HumanoidRootPart.CFrame = CFrame.new(AutoFarm.BringPoint + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                end
            end)
        end
    end,
    
    AttackMob = function(mob)
        if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
        if mob.Humanoid.Health <= 0 then return end
        
        local targetPos = mob.HumanoidRootPart.Position
        local distance = (targetPos - HumanoidRootPart.Position).Magnitude
        
        if AutoFarm.FlyMode then
            local headPos = targetPos + Vector3.new(0, AutoFarm.FlyHeight, 0)
            if (headPos - HumanoidRootPart.Position).Magnitude > 5 then
                if AutoFarm.TeleportMode == "Tween" then
                    Utils.TweenTo(headPos)
                else
                    Utils.TeleportTo(headPos)
                end
                task.wait(0.05)
            end
        else
            if distance > 20 then
                if AutoFarm.TeleportMode == "Tween" then
                    Utils.TweenTo(targetPos + Vector3.new(0, 0, 5))
                else
                    Utils.TeleportTo(targetPos + Vector3.new(0, 0, 5))
                end
                task.wait(0.05)
            end
        end
        
        if AutoFarm.AutoHitbox and not HitboxExpander.Enabled then
            HitboxExpander.Start()
        end
        
        if AutoFarm.SuperTurbo then
            for i = 1, 15 do
                Utils.Attack(targetPos)
                if AutoFarm.MultiClick then
                    Utils.Attack(targetPos)
                    Utils.Attack(targetPos)
                    Utils.Attack(targetPos)
                    Utils.Attack(targetPos)
                end
                task.wait(AutoFarm.AttackSpeed)
            end
        elseif AutoFarm.TurboMode then
            for i = 1, 8 do
                Utils.Attack(targetPos)
                if AutoFarm.MultiClick then
                    Utils.Attack(targetPos)
                    Utils.Attack(targetPos)
                    Utils.Attack(targetPos)
                end
                task.wait(AutoFarm.AttackSpeed)
            end
        else
            Utils.Attack(targetPos)
            if AutoFarm.MultiClick then
                Utils.Attack(targetPos)
                Utils.Attack(targetPos)
            end
            task.wait(AutoFarm.AttackSpeed)
        end
    end,
    
    FarmLoop = function()
        while AutoFarm.Enabled do
            pcall(function()
                AutoFarm.AutoQuest()
                
                local targetName = nil
                if AutoFarm.CurrentQuest then
                    for _, q in ipairs(questData) do
                        if q.npc == AutoFarm.CurrentQuest then
                            targetName = q.mob
                            break
                        end
                    end
                end
                
                if targetName then
                    local mob = Utils.FindMob(targetName)
                    if mob then
                        AutoFarm.TargetMob = mob
                        AutoFarm.AttackMob(mob)
                    else
                        local npc = Utils.FindNPC(AutoFarm.CurrentQuest)
                        if npc then
                            local spawnPos = npc.HumanoidRootPart.Position + Vector3.new(0, 0, 50)
                            if AutoFarm.TeleportMode == "Tween" then
                                Utils.TweenTo(spawnPos)
                            else
                                Utils.TeleportTo(spawnPos)
                            end
                        end
                    end
                end
                
                if AutoFarm.BringMobs then
                    AutoFarm.BringMobsToPoint()
                end
                
                if HumanoidRootPart then
                    local pos = HumanoidRootPart.Position
                    HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2)))
                end
                
                task.wait(0.2)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if AutoFarm.Enabled then return end
        AutoFarm.Enabled = true
        AutoFarm.BringPoint = HumanoidRootPart.Position
        Library.Notify("✅", "Đã bật Auto Farm", 2)
        task.spawn(AutoFarm.FarmLoop)
    end,
    
    Stop = function()
        AutoFarm.Enabled = false
        AutoFarm.CurrentQuest = nil
        AutoFarm.TargetMob = nil
        if HitboxExpander.Enabled then
            HitboxExpander.Stop()
        end
        Library.Notify("⛔", "Đã tắt Auto Farm", 2)
    end
}

local AutoBoss = {
    Enabled = false,
    CurrentBoss = nil,
    BossList = {
        {name = "Diamond", level = 100, location = Vector3.new(100, 0, 100)},
        {name = "Don Swan", level = 150, location = Vector3.new(200, 0, 200)},
        {name = "Saber Expert", level = 200, location = Vector3.new(300, 0, 300)},
        {name = "Ice Admiral", level = 250, location = Vector3.new(400, 0, 400)},
        {name = "Cake Queen", level = 300, location = Vector3.new(500, 0, 500)},
        {name = "Rip Indra", level = 350, location = Vector3.new(600, 0, 600)},
        {name = "Dark Beard", level = 400, location = Vector3.new(700, 0, 700)},
        {name = "God King", level = 450, location = Vector3.new(800, 0, 800)},
        {name = "Demon Lord", level = 500, location = Vector3.new(900, 0, 900)},
        {name = "Fallen Angel", level = 550, location = Vector3.new(1000, 0, 1000)},
        {name = "Divine Being", level = 600, location = Vector3.new(1100, 0, 1100)},
    },
    
    FindAndKillBoss = function()
        local level = Utils.GetLevel()
        local targetBoss = nil
        
        for _, boss in ipairs(AutoBoss.BossList) do
            if level >= boss.level then
                targetBoss = boss
            end
        end
        
        if targetBoss then
            local boss = Utils.FindBoss(targetBoss.name)
            if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                AutoBoss.CurrentBoss = boss
                if AutoFarm.FlyMode then
                    Utils.FlyToHead(boss)
                else
                    if AutoFarm.TeleportMode == "Tween" then
                        Utils.TweenTo(boss.HumanoidRootPart.Position)
                    else
                        Utils.TeleportTo(boss.HumanoidRootPart.Position)
                    end
                end
                task.wait(0.3)
                AutoFarm.AttackMob(boss)
            else
                if AutoFarm.TeleportMode == "Tween" then
                    Utils.TweenTo(targetBoss.location)
                else
                    Utils.TeleportTo(targetBoss.location)
                end
            end
        end
    end,
    
    Loop = function()
        while AutoBoss.Enabled do
            pcall(function()
                AutoBoss.FindAndKillBoss()
                task.wait(1)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if AutoBoss.Enabled then return end
        AutoBoss.Enabled = true
        Library.Notify("👑", "Đã bật Auto Boss", 2)
        task.spawn(AutoBoss.Loop)
    end,
    
    Stop = function()
        AutoBoss.Enabled = false
        AutoBoss.CurrentBoss = nil
        Library.Notify("⛔", "Đã tắt Auto Boss", 2)
    end
}

local AutoRaid = {
    Enabled = false,
    CurrentRaid = nil,
    RaidLocations = {
        {name = "Flame", location = Vector3.new(200, 0, 200)},
        {name = "Ice", location = Vector3.new(300, 0, 300)},
        {name = "Light", location = Vector3.new(400, 0, 400)},
        {name = "Dark", location = Vector3.new(500, 0, 500)},
    },
    
    JoinRaid = function()
        if CommF then
            CommF:InvokeServer("JoinRaid")
        end
    end,
    
    CompleteRaid = function()
        if not AutoRaid.CurrentRaid then
            for _, raid in ipairs(AutoRaid.RaidLocations) do
                local pos = raid.location
                if AutoFarm.TeleportMode == "Tween" then
                    Utils.TweenTo(pos)
                else
                    Utils.TeleportTo(pos)
                end
                task.wait(0.5)
                AutoRaid.JoinRaid()
                AutoRaid.CurrentRaid = raid
                Library.Notify("⚔️", "Đã tham gia Raid: " .. raid.name, 2)
                break
            end
        else
            local enemies = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("Mobs")
            if enemies then
                for _, v in pairs(enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        if AutoFarm.FlyMode then
                            Utils.FlyToHead(v)
                        else
                            if AutoFarm.TeleportMode == "Tween" then
                                Utils.TweenTo(v.HumanoidRootPart.Position)
                            else
                                Utils.TeleportTo(v.HumanoidRootPart.Position)
                            end
                        end
                        task.wait(0.1)
                        AutoFarm.AttackMob(v)
                    end
                end
            end
        end
    end,
    
    Loop = function()
        while AutoRaid.Enabled do
            pcall(function()
                AutoRaid.CompleteRaid()
                task.wait(0.5)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if AutoRaid.Enabled then return end
        AutoRaid.Enabled = true
        Library.Notify("⚔️", "Đã bật Auto Raid", 2)
        task.spawn(AutoRaid.Loop)
    end,
    
    Stop = function()
        AutoRaid.Enabled = false
        AutoRaid.CurrentRaid = nil
        Library.Notify("⛔", "Đã tắt Auto Raid", 2)
    end
}

local AutoFruit = {
    Enabled = false,
    BlacklistedFruits = {},
    
    Loop = function()
        while AutoFruit.Enabled do
            pcall(function()
                local fruit = Utils.FindFruit()
                if fruit and fruit:FindFirstChild("Handle") then
                    local fruitName = fruit.Name
                    local isBlacklisted = false
                    for _, name in ipairs(AutoFruit.BlacklistedFruits) do
                        if string.find(fruitName:lower(), name:lower()) then
                            isBlacklisted = true
                            break
                        end
                    end
                    
                    if not isBlacklisted then
                        if AutoFarm.TeleportMode == "Tween" then
                            Utils.TweenTo(fruit.Handle.Position)
                        else
                            Utils.TeleportTo(fruit.Handle.Position)
                        end
                        task.wait(0.3)
                        
                        if CommF then
                            CommF:InvokeServer("CollectFruit", fruitName)
                        end
                        
                        if AutoFarm.AutoStoreFruit then
                            Library.Notify("🍎", "Đã lưu trái: " .. fruitName, 2)
                        else
                            Library.Notify("🍎", "Đã nhặt trái: " .. fruitName, 2)
                        end
                        task.wait(2)
                    end
                end
                task.wait(0.5)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if AutoFruit.Enabled then return end
        AutoFruit.Enabled = true
        Library.Notify("🍎", "Đã bật Auto Fruit Sniper", 2)
        task.spawn(AutoFruit.Loop)
    end,
    
    Stop = function()
        AutoFruit.Enabled = false
        Library.Notify("⛔", "Đã tắt Auto Fruit Sniper", 2)
    end
}

local AutoChest = {
    Enabled = false,
    
    Loop = function()
        while AutoChest.Enabled do
            pcall(function()
                local chests = workspace:FindFirstChild("Chests") or workspace:FindFirstChild("Chest")
                if chests then
                    for _, v in pairs(chests:GetChildren()) do
                        if v:FindFirstChild("Handle") or v:FindFirstChild("Part") then
                            if AutoFarm.TeleportMode == "Tween" then
                                Utils.TweenTo(v.Position)
                            else
                                Utils.TeleportTo(v.Position)
                            end
                            task.wait(0.3)
                            if CommF then
                                CommF:InvokeServer("CollectChest", v.Name)
                            end
                            Library.Notify("📦", "Đã nhặt rương", 2)
                            task.wait(1)
                        end
                    end
                end
                task.wait(2)
            end)
            task.wait()
        end
    end,
    
    Start = function()
        if AutoChest.Enabled then return end
        AutoChest.Enabled = true
        Library.Notify("📦", "Đã bật Auto Chest", 2)
        task.spawn(AutoChest.Loop)
    end,
    
    Stop = function()
        AutoChest.Enabled = false
        Library.Notify("⛔", "Đã tắt Auto Chest", 2)
    end
}

local BubbleMenu = {
    ScreenGui = nil,
    MainFrame = nil,
    IsOpen = false,
    Dragging = false,
    DragStart = nil,
    DragOffset = nil,
}

function CreateBubbleMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "BubbleMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local bubbleBtn = Instance.new("ImageButton")
    bubbleBtn.Parent = screenGui
    bubbleBtn.Size = UDim2.new(0, IsMobile and 70 or 60, 0, IsMobile and 70 or 60)
    bubbleBtn.Position = UDim2.new(0.9, -35, 0.5, -35)
    bubbleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    bubbleBtn.BackgroundTransparency = 0.15
    bubbleBtn.BorderSizePixel = 0
    bubbleBtn.Image = "rbxassetid://1203794519"
    bubbleBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
    bubbleBtn.ImageRectSize = Vector2.new(256, 256)
    bubbleBtn.ImageRectOffset = Vector2.new(0, 0)
    bubbleBtn.ZIndex = 100
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.Parent = bubbleBtn
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    
    local bubbleShadow = Instance.new("ImageLabel")
    bubbleShadow.Parent = bubbleBtn
    bubbleShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
    bubbleShadow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    bubbleShadow.BackgroundTransparency = 1
    bubbleShadow.Image = "rbxassetid://1316045217"
    bubbleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    bubbleShadow.ImageTransparency = 0.5
    bubbleShadow.ZIndex = -1
    
    local glow = Instance.new("ImageLabel")
    glow.Parent = bubbleBtn
    glow.Size = UDim2.new(1.8, 0, 1.8, 0)
    glow.Position = UDim2.new(-0.4, 0, -0.4, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1316045217"
    glow.ImageColor3 = Color3.fromRGB(255, 50, 50)
    glow.ImageTransparency = 0.7
    glow.ZIndex = -1
    
    local pulse = Instance.new("ImageLabel")
    pulse.Parent = bubbleBtn
    pulse.Size = UDim2.new(1, 0, 1, 0)
    pulse.BackgroundTransparency = 1
    pulse.Image = "rbxassetid://1316045217"
    pulse.ImageColor3 = Color3.fromRGB(255, 255, 255)
    pulse.ImageTransparency = 0.5
    pulse.ZIndex = -1
    
    task.spawn(function()
        while bubbleBtn.Parent do
            for i = 1, 30 do
                local scale = 1 + (i / 30) * 0.5
                pulse.Size = UDim2.new(scale, 0, scale, 0)
                pulse.Position = UDim2.new((1 - scale) / 2, 0, (1 - scale) / 2, 0)
                pulse.ImageTransparency = 0.5 - (i / 30) * 0.5
                task.wait(0.03)
            end
            task.wait(0.5)
        end
    end)
    
    local bubbleLabel = Instance.new("TextLabel")
    bubbleLabel.Parent = bubbleBtn
    bubbleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    bubbleLabel.Position = UDim2.new(0, 0, 0.7, 0)
    bubbleLabel.BackgroundTransparency = 1
    bubbleLabel.Text = "MENU"
    bubbleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    bubbleLabel.TextSize = IsMobile and 12 or 10
    bubbleLabel.Font = Enum.Font.GothamBold
    bubbleLabel.TextScaled = true
    
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    
    bubbleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = bubbleBtn.Position
        end
    end)
    
    bubbleBtn.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale + delta.X / screenGui.AbsoluteSize.X,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale + delta.Y / screenGui.AbsoluteSize.Y,
                startPos.Y.Offset + delta.Y
            )
            bubbleBtn.Position = newPos
        end
    end)
    
    bubbleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    local menuSize = IsMobile and 350 or 300
    local menuPos = IsMobile and 0.5 or 0.5
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, menuSize, 0, menuSize * 1.4)
    mainFrame.Position = UDim2.new(menuPos, -menuSize/2, 0.5, -menuSize * 0.7)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ZIndex = 50
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.Parent = mainFrame
    menuCorner.CornerRadius = UDim.new(0, 16)
    
    local menuShadow = Instance.new("Frame")
    menuShadow.Parent = mainFrame
    menuShadow.Size = UDim2.new(1, 10, 1, 10)
    menuShadow.Position = UDim2.new(0, -5, 0, -5)
    menuShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    menuShadow.BackgroundTransparency = 0.5
    menuShadow.BorderSizePixel = 0
    menuShadow.ZIndex = -1
    menuShadow.ClipsDescendants = true
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.Parent = menuShadow
    shadowCorner.CornerRadius = UDim.new(0, 20)
    
    local header = Instance.new("Frame")
    header.Parent = mainFrame
    header.Size = UDim2.new(1, 0, 0, IsMobile and 50 or 45)
    header.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.Parent = header
    headerCorner.CornerRadius = UDim.new(0, 16)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = header
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 30, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ AUTO FARM ⚡"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = IsMobile and 18 or 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = header
    closeBtn.Size = UDim2.new(0, IsMobile and 35 or 30, 0, IsMobile and 35 or 30)
    closeBtn.Position = UDim2.new(1, -IsMobile and 40 or 35, 0.5, -IsMobile and 17.5 or 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = IsMobile and 20 or 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeBtn
    closeCorner.CornerRadius = UDim.new(1, 0)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        BubbleMenu.IsOpen = false
    end)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = mainFrame
    scrollFrame.Size = UDim2.new(1, -20, 1, -IsMobile and 60 or 55)
    scrollFrame.Position = UDim2.new(0, 10, 0, IsMobile and 50 or 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = IsMobile and 8 or 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local function CreateMenuButton(text, icon, callback, color)
        local btn = Instance.new("TextButton")
        btn.Parent = scrollFrame
        btn.Size = UDim2.new(1, -10, 0, IsMobile and 50 or 40)
        btn.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 45))
        btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
        btn.BackgroundTransparency = 0.2
        btn.Text = icon .. " " .. text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = IsMobile and 16 or 13
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextScaled = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 8)
        
        local status = Instance.new("TextLabel")
        status.Parent = btn
        status.Size = UDim2.new(0, 30, 1, -10)
        status.Position = UDim2.new(1, -35, 0.5, -IsMobile and 15 or 12)
        status.BackgroundTransparency = 1
        status.Text = "⚪"
        status.TextColor3 = Color3.fromRGB(100, 100, 100)
        status.TextSize = IsMobile and 18 or 14
        status.Font = Enum.Font.GothamBold
        status.TextScaled = true
        
        local state = false
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            status.Text = state and "🟢" or "⚪"
            status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
            if callback then callback(state) end
        end)
        
        return {
            SetState = function(newState)
                state = newState
                status.Text = state and "🟢" or "⚪"
                status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 100)
                if callback then callback(state) end
            end,
            GetState = function()
                return state
            end
        }
    end
    
    local buttons = {}
    
    buttons.farm = CreateMenuButton("Auto Farm", "⚡", function(state)
        if state then AutoFarm.Start() else AutoFarm.Stop() end
    end, Color3.fromRGB(255, 50, 50))
    
    buttons.fly = CreateMenuButton("Fly Mode", "✈️", function(state)
        AutoFarm.FlyMode = state
        Library.Notify("✈️", state and "Fly Mode BẬT" or "Fly Mode TẮT", 1)
    end, Color3.fromRGB(50, 150, 255))
    
    buttons.hitbox = CreateMenuButton("Hitbox Expander", "📐", function(state)
        if state then 
            HitboxExpander.Start()
            AutoFarm.AutoHitbox = true
        else 
            HitboxExpander.Stop()
            AutoFarm.AutoHitbox = false
        end
        Library.Notify("📐", state and "Hitbox BẬT" or "Hitbox TẮT", 1)
    end, Color3.fromRGB(255, 200, 50))
    
    buttons.turbo = CreateMenuButton("Turbo Mode", "🚀", function(state)
        AutoFarm.TurboMode = state
        if state then AutoFarm.SuperTurbo = false end
        Library.Notify("🚀", state and "Turbo BẬT" or "Turbo TẮT", 1)
    end, Color3.fromRGB(50, 255, 100))
    
    buttons.super = CreateMenuButton("Super Turbo", "💥", function(state)
        AutoFarm.SuperTurbo = state
        if state then AutoFarm.TurboMode = true end
        Library.Notify("💥", state and "Super Turbo BẬT" or "Super Turbo TẮT", 1)
    end, Color3.fromRGB(255, 100, 0))
    
    buttons.multiclick = CreateMenuButton("Multi Click", "🔱", function(state)
        AutoFarm.MultiClick = state
        Library.Notify("🔱", state and "Multi Click BẬT" or "Multi Click TẮT", 1)
    end, Color3.fromRGB(200, 50, 255))
    
    buttons.bring = CreateMenuButton("Bring Mobs", "🔄", function(state)
        AutoFarm.BringMobs = state
        if state then AutoFarm.BringPoint = HumanoidRootPart.Position end
        Library.Notify("🔄", state and "Bring Mobs BẬT" or "Bring Mobs TẮT", 1)
    end, Color3.fromRGB(100, 200, 255))
    
    buttons.boss = CreateMenuButton("Auto Boss", "👑", function(state)
        if state then AutoBoss.Start() else AutoBoss.Stop() end
    end, Color3.fromRGB(255, 100, 100))
    
    buttons.fruit = CreateMenuButton("Auto Fruit", "🍎", function(state)
        if state then AutoFruit.Start() else AutoFruit.Stop() end
    end, Color3.fromRGB(255, 150, 50))
    
    buttons.raid = CreateMenuButton("Auto Raid", "⚔️", function(state)
        if state then AutoRaid.Start() else AutoRaid.Stop() end
    end, Color3.fromRGB(200, 50, 50))
    
    buttons.chest = CreateMenuButton("Auto Chest", "📦", function(state)
        if state then AutoChest.Start() else AutoChest.Stop() end
    end, Color3.fromRGB(255, 200, 0))
    
    local settingsLabel = Instance.new("TextLabel")
    settingsLabel.Parent = scrollFrame
    settingsLabel.Size = UDim2.new(1, -10, 0, IsMobile and 35 or 30)
    settingsLabel.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 45))
    settingsLabel.BackgroundTransparency = 1
    settingsLabel.Text = "⚙️ Cài Đặt"
    settingsLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
    settingsLabel.TextSize = IsMobile and 16 or 13
    settingsLabel.Font = Enum.Font.GothamBold
    settingsLabel.TextScaled = true
    
    local heightFrame = Instance.new("Frame")
    heightFrame.Parent = scrollFrame
    heightFrame.Size = UDim2.new(1, -10, 0, IsMobile and 45 or 35)
    heightFrame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 45))
    heightFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    heightFrame.BackgroundTransparency = 0.3
    heightFrame.BorderSizePixel = 0
    
    local heightCorner = Instance.new("UICorner")
    heightCorner.Parent = heightFrame
    heightCorner.CornerRadius = UDim.new(0, 6)
    
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Parent = heightFrame
    heightLabel.Size = UDim2.new(0.4, -5, 1, 0)
    heightLabel.Position = UDim2.new(0.02, 0, 0, 0)
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "📏 Bay: 15"
    heightLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    heightLabel.TextSize = IsMobile and 14 or 11
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.TextScaled = true
    
    local heightSlider = Instance.new("Frame")
    heightSlider.Parent = heightFrame
    heightSlider.Size = UDim2.new(0.5, -10, 0.4, 0)
    heightSlider.Position = UDim2.new(0.45, 0, 0.3, 0)
    heightSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    heightSlider.BorderSizePixel = 0
    
    local heightFill = Instance.new("Frame")
    heightFill.Parent = heightSlider
    heightFill.Size = UDim2.new(0.5, 0, 1, 0)
    heightFill.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    heightFill.BorderSizePixel = 0
    
    local heightValue = 15
    local isHeightDragging = false
    
    heightSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHeightDragging = true
            local pos = math.clamp((input.Position.X - heightSlider.AbsolutePosition.X) / heightSlider.AbsoluteSize.X, 0, 1)
            heightValue = math.round(5 + pos * 45)
            heightFill.Size = UDim2.new(pos, 0, 1, 0)
            heightLabel.Text = "📏 Bay: " .. heightValue
            AutoFarm.FlyHeight = heightValue
        end
    end)
    
    heightSlider.InputChanged:Connect(function(input)
        if isHeightDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = math.clamp((input.Position.X - heightSlider.AbsolutePosition.X) / heightSlider.AbsoluteSize.X, 0, 1)
            heightValue = math.round(5 + pos * 45)
            heightFill.Size = UDim2.new(pos, 0, 1, 0)
            heightLabel.Text = "📏 Bay: " .. heightValue
            AutoFarm.FlyHeight = heightValue
        end
    end)
    
    heightSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHeightDragging = false
        end
    end)
    
    local hitboxFrame = Instance.new("Frame")
    hitboxFrame.Parent = scrollFrame
    hitboxFrame.Size = UDim2.new(1, -10, 0, IsMobile and 45 or 35)
    hitboxFrame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 45))
    hitboxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    hitboxFrame.BackgroundTransparency = 0.3
    hitboxFrame.BorderSizePixel = 0
    
    local hitboxCorner = Instance.new("UICorner")
    hitboxCorner.Parent = hitboxFrame
    hitboxCorner.CornerRadius = UDim.new(0, 6)
    
    local hitboxLabel = Instance.new("TextLabel")
    hitboxLabel.Parent = hitboxFrame
    hitboxLabel.Size = UDim2.new(0.4, -5, 1, 0)
    hitboxLabel.Position = UDim2.new(0.02, 0, 0, 0)
    hitboxLabel.BackgroundTransparency = 1
    hitboxLabel.Text = "📐 Size: 10"
    hitboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hitboxLabel.TextSize = IsMobile and 14 or 11
    hitboxLabel.Font = Enum.Font.Gotham
    hitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    hitboxLabel.TextScaled = true
    
    local hitboxSlider = Instance.new("Frame")
    hitboxSlider.Parent = hitboxFrame
    hitboxSlider.Size = UDim2.new(0.5, -10, 0.4, 0)
    hitboxSlider.Position = UDim2.new(0.45, 0, 0.3, 0)
    hitboxSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    hitboxSlider.BorderSizePixel = 0
    
    local hitboxFill = Instance.new("Frame")
    hitboxFill.Parent = hitboxSlider
    hitboxFill.Size = UDim2.new(0.5, 0, 1, 0)
    hitboxFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    hitboxFill.BorderSizePixel = 0
    
    local hitboxValue = 10
    local isHitboxDragging = false
    
    hitboxSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHitboxDragging = true
            local pos = math.clamp((input.Position.X - hitboxSlider.AbsolutePosition.X) / hitboxSlider.AbsoluteSize.X, 0, 1)
            hitboxValue = math.round(5 + pos * 45)
            hitboxFill.Size = UDim2.new(pos, 0, 1, 0)
            hitboxLabel.Text = "📐 Size: " .. hitboxValue
            HitboxExpander.Size = hitboxValue
            if HitboxExpander.Enabled then
                Library.Notify("📐", "Hitbox size: " .. hitboxValue, 1)
            end
        end
    end)
    
    hitboxSlider.InputChanged:Connect(function(input)
        if isHitboxDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = math.clamp((input.Position.X - hitboxSlider.AbsolutePosition.X) / hitboxSlider.AbsoluteSize.X, 0, 1)
            hitboxValue = math.round(5 + pos * 45)
            hitboxFill.Size = UDim2.new(pos, 0, 1, 0)
            hitboxLabel.Text = "📐 Size: " .. hitboxValue
            HitboxExpander.Size = hitboxValue
        end
    end)
    
    hitboxSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isHitboxDragging = false
        end
    end)
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 45) + 50, 50)
    
    bubbleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        BubbleMenu.IsOpen = mainFrame.Visible
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
            mainFrame.Visible = not mainFrame.Visible
            BubbleMenu.IsOpen = mainFrame.Visible
        end
    end)
    
    BubbleMenu.ScreenGui = screenGui
    BubbleMenu.MainFrame = mainFrame
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        BubbleBtn = bubbleBtn,
        Buttons = buttons
    }
end

task.wait(2)

local menu = CreateBubbleMenu()

Library.Notify("🚀", "Auto Farm 2026 Mobile đã sẵn sàng!", 3)
Library.Notify("💡", "Chạm vào nút tròn để mở menu", 3)
Library.Notify("⌨️", "Hoặc nhấn M để mở/đóng", 2)

task.spawn(function()
    while true do
        pcall(function()
            if HumanoidRootPart then
                local pos = HumanoidRootPart.Position
                HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
            end
            task.wait(60)
        end)
        task.wait()
    end
end)