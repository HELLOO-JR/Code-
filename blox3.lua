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

local Menu = {
    ScreenGui = nil,
    MainFrame = nil,
    IsOpen = false,
}

function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "AutoFarmMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local menuSize = IsMobile and 360 or 400
    local menuHeight = IsMobile and 480 or 550
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, menuSize, 0, menuHeight)
    mainFrame.Position = UDim2.new(0.5, -menuSize/2, 0.5, -menuHeight/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.ZIndex = 100
    mainFrame.Active = true
    mainFrame.Selectable = true
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.Parent = mainFrame
    frameCorner.CornerRadius = UDim.new(0, 16)
    
    local frameShadow = Instance.new("Frame")
    frameShadow.Parent = mainFrame
    frameShadow.Size = UDim2.new(1, 20, 1, 20)
    frameShadow.Position = UDim2.new(0, -10, 0, -10)
    frameShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frameShadow.BackgroundTransparency = 0.6
    frameShadow.BorderSizePixel = 0
    frameShadow.ZIndex = -1
    frameShadow.ClipsDescendants = true
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.Parent = frameShadow
    shadowCorner.CornerRadius = UDim.new(0, 20)
    
    local titleBar = Instance.new("Frame")
    titleBar.Parent = mainFrame
    titleBar.Size = UDim2.new(1, 0, 0, IsMobile and 55 or 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 101
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 16)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ AUTO FARM 2026 ⚡"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = IsMobile and 20 or 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.ZIndex = 102
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.Size = UDim2.new(0, IsMobile and 35 or 30, 0, IsMobile and 35 or 30)
    closeBtn.Position = UDim2.new(1, -IsMobile and 42 or 38, 0.5, -IsMobile and 17.5 or 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = IsMobile and 22 or 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 103
    closeBtn.AutoButtonColor = true
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeBtn
    closeCorner.CornerRadius = UDim.new(1, 0)
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        Menu.IsOpen = false
    end)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = mainFrame
    scrollFrame.Size = UDim2.new(1, -20, 1, -IsMobile and 70 or 65)
    scrollFrame.Position = UDim2.new(0, 10, 0, IsMobile and 60 or 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = IsMobile and 8 or 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ZIndex = 101
    scrollFrame.Active = true
    scrollFrame.Selectable = true
    
    local function CreateToggle(text, icon, callback, color)
        local btn = Instance.new("TextButton")
        btn.Parent = scrollFrame
        btn.Size = UDim2.new(1, -10, 0, IsMobile and 50 or 45)
        btn.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 50))
        btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text = icon .. " " .. text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = IsMobile and 16 or 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextScaled = true
        btn.ZIndex = 102
        btn.AutoButtonColor = true
        btn.Selectable = true
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.Parent = btn
        btnCorner.CornerRadius = UDim.new(0, 8)
        
        local status = Instance.new("TextLabel")
        status.Parent = btn
        status.Size = UDim2.new(0, 35, 1, -10)
        status.Position = UDim2.new(1, -40, 0.5, -IsMobile and 17 or 15)
        status.BackgroundTransparency = 1
        status.Text = "🔴"
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        status.TextSize = IsMobile and 20 or 16
        status.Font = Enum.Font.GothamBold
        status.TextScaled = true
        status.ZIndex = 103
        
        local state = false
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            status.Text = state and "🟢" or "🔴"
            status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            if callback then callback(state) end
        end)
        
        return {
            SetState = function(newState)
                state = newState
                status.Text = state and "🟢" or "🔴"
                status.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                if callback then callback(state) end
            end,
            GetState = function()
                return state
            end
        }
    end
    
    local function CreateSlider(text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = scrollFrame
        frame.Size = UDim2.new(1, -10, 0, IsMobile and 50 or 45)
        frame.Position = UDim2.new(0, 5, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 50))
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.ZIndex = 101
        
        local frameCorner2 = Instance.new("UICorner")
        frameCorner2.Parent = frame
        frameCorner2.CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.45, -5, 1, 0)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = IsMobile and 14 or 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.ZIndex = 102
        
        local slider = Instance.new("Frame")
        slider.Parent = frame
        slider.Size = UDim2.new(0.5, -10, 0.35, 0)
        slider.Position = UDim2.new(0.48, 0, 0.32, 0)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        slider.BorderSizePixel = 0
        slider.ZIndex = 102
        
        local fill = Instance.new("Frame")
        fill.Parent = slider
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        fill.BorderSizePixel = 0
        fill.ZIndex = 103
        
        local value = default
        local isDragging = false
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                value = math.round(min + pos * (max - min))
                fill.Size = UDim2.new(pos, 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end
        end)
        
        slider.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                value = math.round(min + pos * (max - min))
                fill.Size = UDim2.new(pos, 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end
        end)
        
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        return {
            SetValue = function(newValue)
                value = math.clamp(newValue, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end,
            GetValue = function()
                return value
            end
        }
    end
    
    local toggles = {}
    
    toggles.farm = CreateToggle("Auto Farm", "⚡", function(state)
        if state then AutoFarm.Start() else AutoFarm.Stop() end
    end, Color3.fromRGB(255, 50, 50))
    
    toggles.fly = CreateToggle("Fly Mode", "✈️", function(state)
        AutoFarm.FlyMode = state
        Library.Notify("✈️", state and "Fly Mode BẬT" or "Fly Mode TẮT", 1)
    end, Color3.fromRGB(50, 150, 255))
    
    toggles.hitbox = CreateToggle("Hitbox Expander", "📐", function(state)
        if state then 
            HitboxExpander.Start()
            AutoFarm.AutoHitbox = true
        else 
            HitboxExpander.Stop()
            AutoFarm.AutoHitbox = false
        end
        Library.Notify("📐", state and "Hitbox BẬT" or "Hitbox TẮT", 1)
    end, Color3.fromRGB(255, 200, 50))
    
    toggles.turbo = CreateToggle("Turbo Mode", "🚀", function(state)
        AutoFarm.TurboMode = state
        if state then AutoFarm.SuperTurbo = false end
        Library.Notify("🚀", state and "Turbo BẬT" or "Turbo TẮT", 1)
    end, Color3.fromRGB(50, 255, 100))
    
    toggles.super = CreateToggle("Super Turbo", "💥", function(state)
        AutoFarm.SuperTurbo = state
        if state then AutoFarm.TurboMode = true end
        Library.Notify("💥", state and "Super Turbo BẬT" or "Super Turbo TẮT", 1)
    end, Color3.fromRGB(255, 100, 0))
    
    toggles.multiclick = CreateToggle("Multi Click", "🔱", function(state)
        AutoFarm.MultiClick = state
        Library.Notify("🔱", state and "Multi Click BẬT" or "Multi Click TẮT", 1)
    end, Color3.fromRGB(200, 50, 255))
    
    toggles.bring = CreateToggle("Bring Mobs", "🔄", function(state)
        AutoFarm.BringMobs = state
        if state then AutoFarm.BringPoint = HumanoidRootPart.Position end
        Library.Notify("🔄", state and "Bring Mobs BẬT" or "Bring Mobs TẮT", 1)
    end, Color3.fromRGB(100, 200, 255))
    
    toggles.boss = CreateToggle("Auto Boss", "👑", function(state)
        if state then AutoBoss.Start() else AutoBoss.Stop() end
    end, Color3.fromRGB(255, 100, 100))
    
    toggles.fruit = CreateToggle("Auto Fruit", "🍎", function(state)
        if state then AutoFruit.Start() else AutoFruit.Stop() end
    end, Color3.fromRGB(255, 150, 50))
    
    toggles.raid = CreateToggle("Auto Raid", "⚔️", function(state)
        if state then AutoRaid.Start() else AutoRaid.Stop() end
    end, Color3.fromRGB(200, 50, 50))
    
    toggles.chest = CreateToggle("Auto Chest", "📦", function(state)
        if state then AutoChest.Start() else AutoChest.Stop() end
    end, Color3.fromRGB(255, 200, 0))
    
    local sliderHeight = CreateSlider("📏 Độ cao bay", 5, 50, 15, function(value)
        AutoFarm.FlyHeight = value
    end)
    
    local sliderHitbox = CreateSlider("📐 Kích thước Hitbox", 5, 50, 10, function(value)
        HitboxExpander.Size = value
        if HitboxExpander.Enabled then
            Library.Notify("📐", "Hitbox size: " .. value, 1)
        end
    end)
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, #scrollFrame:GetChildren() * (IsMobile and 55 or 50) + 50, 50)
    
    local function ToggleMenu()
        mainFrame.Visible = not mainFrame.Visible
        Menu.IsOpen = mainFrame.Visible
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
            ToggleMenu()
        end
    end)
    
    Menu.ScreenGui = screenGui
    Menu.MainFrame = mainFrame
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Toggles = toggles,
        ToggleMenu = ToggleMenu
    }
end

task.wait(2)

local menu = CreateMenu()

Library.Notify("🚀", "Auto Farm 2026 đã sẵn sàng!", 3)
Library.Notify("⌨️", "Nhấn phím M để mở/đóng menu", 3)

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