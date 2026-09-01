--[[
    🍃 BLOX FRUITS AUTO FARM SCRIPT 2026 🍃
    Phiên bản: Ultimate v5.0 - FLY + HITBOX MODE
    Tối ưu cho: Delta, Xeno, Synapse Z, Krnl
]]

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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("Remote")
local CommF = Remotes and Remotes:FindFirstChild("CommF_") or ReplicatedStorage:FindFirstChild("CommF_")

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
    
    IsInCombat = function()
        return Humanoid:GetState() == Enum.HumanoidStateType.FallingDown or Humanoid:GetState() == Enum.HumanoidStateType.GettingUp
    end,
    
    EquipWeapon = function(weaponName)
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return false end
        
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and string.find(v.Name:lower(), weaponName:lower()) then
                LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(v)
                return true
            end
        end
        return false
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
        Library.Notify("📐", "Đã bật Hitbox Expander - Kích thước: " .. HitboxExpander.Size, 2)
        task.spawn(HitboxExpander.Loop)
    end,
    
    Stop = function()
        HitboxExpander.Enabled = false
        HitboxExpander.RestoreAll()
        Library.Notify("📐", "Đã tắt Hitbox Expander", 2)
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
        Library.Notify("✅", "Đã bật Auto Farm - FLY + HITBOX MODE", 2)
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

local GUI = {
    ScreenGui = nil,
    MainFrame = nil,
}

function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.Name = "BloxFruitsAutoFarm"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 480, 0, 720)
    mainFrame.Position = UDim2.new(0.5, -240, 0.5, -360)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.Parent = mainFrame
    uiCorner.CornerRadius = UDim.new(0, 12)
    
    local shadow = Instance.new("Frame")
    shadow.Parent = mainFrame
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    title.BackgroundTransparency = 0.3
    title.Text = "✈️ FLY + HITBOX MODE 2026 ✈️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Parent = mainFrame
    tabFrame.Size = UDim2.new(1, 0, 0.07, 0)
    tabFrame.Position = UDim2.new(0, 0, 0.08, 0)
    tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabFrame.BackgroundTransparency = 0.2
    tabFrame.BorderSizePixel = 0
    
    local tabs = {
        {name = "🏠 Home", id = "home"},
        {name = "⚡ Auto", id = "auto"},
        {name = "👑 Boss", id = "boss"},
        {name = "🍎 Fruit", id = "fruit"},
        {name = "⚙️ Settings", id = "settings"},
    }
    
    local tabButtons = {}
    local currentTab = "home"
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Parent = tabFrame
        btn.Size = UDim2.new(1 / #tabs, -2, 1, -2)
        btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = tab.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Name = tab.id
        
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentTab = tab.id
            UpdateTab(tab.id)
        end)
        
        table.insert(tabButtons, btn)
        if i == 1 then
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Parent = mainFrame
    contentFrame.Size = UDim2.new(1, -20, 0.82, -20)
    contentFrame.Position = UDim2.new(0, 10, 0.16, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local function AddToggle(parent, text, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 45)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Visible = true
        
        local corner = Instance.new("UICorner")
        corner.Parent = frame
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.7, -10, 1, 0)
        label.Position = UDim2.new(0.01, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        
        local btn = Instance.new("TextButton")
        btn.Parent = frame
        btn.Size = UDim2.new(0.25, -10, 0.8, -10)
        btn.Position = UDim2.new(0.73, 0, 0.1, 0)
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        btn.Text = default and "🟢 BẬT" or "🔴 TẮT"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        
        local state = default or false
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
            btn.Text = state and "🟢 BẬT" or "🔴 TẮT"
            if callback then callback(state) end
        end)
        
        return {
            SetState = function(newState)
                state = newState
                btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
                btn.Text = state and "🟢 BẬT" or "🔴 TẮT"
                if callback then callback(state) end
            end,
            GetState = function()
                return state
            end
        }
    end
    
    local function AddDropdown(parent, text, options, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -20, 0, 40)
        frame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 45)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.Parent = frame
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.4, -10, 1, 0)
        label.Position = UDim2.new(0.01, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        
        local dropdown = Instance.new("TextButton")
        dropdown.Parent = frame
        dropdown.Size = UDim2.new(0.5, -10, 0.8, -10)
        dropdown.Position = UDim2.new(0.48, 0, 0.1, 0)
        dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        dropdown.Text = default or options[1]
        dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.TextScaled = true
        dropdown.Font = Enum.Font.Gotham
        
        local menu = Instance.new("Frame")
        menu.Parent = frame
        menu.Size = UDim2.new(0.5, -10, 0, 0)
        menu.Position = UDim2.new(0.48, 0, 0.9, 0)
        menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        menu.BackgroundTransparency = 0.2
        menu.BorderSizePixel = 0
        menu.Visible = false
        menu.ClipsDescendants = true
        
        local menuCorner = Instance.new("UICorner")
        menuCorner.Parent = menu
        menuCorner.CornerRadius = UDim.new(0, 6)
        
        for i, option in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Parent = menu
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.Position = UDim2.new(0, 0, (i - 1) / #options, 0)
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            optBtn.Text = option
            optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            optBtn.TextScaled = true
            optBtn.Font = Enum.Font.Gotham
            
            optBtn.MouseButton1Click:Connect(function()
                dropdown.Text = option
                menu.Visible = false
                if callback then callback(option) end
            end)
        end
        
        dropdown.MouseButton1Click:Connect(function()
            menu.Visible = not menu.Visible
            if menu.Visible then
                menu.Size = UDim2.new(0.5, -10, #options * 30 + 10, 10)
                menu.Position = UDim2.new(0.48, 0, 0.9, 0)
            else
                menu.Size = UDim2.new(0.5, -10, 0, 0)
            end
        end)
        
        return {
            SetValue = function(value)
                dropdown.Text = value
                if callback then callback(value) end
            end,
            GetValue = function()
                return dropdown.Text
            end
        }
    end
    
    local function AddLabel(parent, text)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.Size = UDim2.new(1, -20, 0, 30)
        label.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 35)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        return label
    end
    
    local function AddSlider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -20, 0, 50)
        frame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.Parent = frame
        corner.CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. default
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        
        local slider = Instance.new("Frame")
        slider.Parent = frame
        slider.Size = UDim2.new(0.9, 0, 0.3, 0)
        slider.Position = UDim2.new(0.05, 0, 0.5, 0)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        slider.BorderSizePixel = 0
        
        local fill = Instance.new("Frame")
        fill.Parent = slider
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        fill.BorderSizePixel = 0
        
        local value = default
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local newValue = math.round(min + (pos / slider.AbsoluteSize.X) * (max - min))
                value = math.clamp(newValue, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
            end
        end)
        
        slider.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and input.Position then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local newValue = math.round(min + (pos / slider.AbsoluteSize.X) * (max - min))
                value = math.clamp(newValue, min, max)
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                label.Text = text .. ": " .. value
                if callback then callback(value) end
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
    
    local function ClearTab()
        for _, child in pairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
    
    local function UpdateTab(tab)
        ClearTab()
        
        if tab == "home" then
            AddLabel(contentFrame, "📊 Thông Tin Player")
            local infoLabel = AddLabel(contentFrame, "Level: " .. Utils.GetLevel() .. " | Mastery: " .. Utils.GetMastery())
            infoLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            
            AddLabel(contentFrame, "")
            AddLabel(contentFrame, "🛠️ Trạng Thái")
            AddLabel(contentFrame, "Auto Farm: " .. (AutoFarm.Enabled and "🟢 Đang chạy" or "🔴 Đã tắt"))
            AddLabel(contentFrame, "Auto Boss: " .. (AutoBoss.Enabled and "🟢 Đang chạy" or "🔴 Đã tắt"))
            AddLabel(contentFrame, "Auto Fruit: " .. (AutoFruit.Enabled and "🟢 Đang chạy" or "🔴 Đã tắt"))
            AddLabel(contentFrame, "Auto Raid: " .. (AutoRaid.Enabled and "🟢 Đang chạy" or "🔴 Đã tắt"))
            AddLabel(contentFrame, "Auto Chest: " .. (AutoChest.Enabled and "🟢 Đang chạy" or "🔴 Đã tắt"))
            
            AddLabel(contentFrame, "")
            AddLabel(contentFrame, "🎯 Quest Hiện Tại: " .. (AutoFarm.CurrentQuest or "None"))
            AddLabel(contentFrame, "👾 Target: " .. (AutoFarm.TargetMob and AutoFarm.TargetMob.Name or "None"))
            AddLabel(contentFrame, "✈️ Fly Mode: " .. (AutoFarm.FlyMode and "🟢 BẬT" or "🔴 TẮT"))
            AddLabel(contentFrame, "📐 Hitbox Expander: " .. (HitboxExpander.Enabled and "🟢 BẬT" or "🔴 TẮT"))
            AddLabel(contentFrame, "📏 Hitbox Size: " .. HitboxExpander.Size)
            AddLabel(contentFrame, "📏 Fly Height: " .. AutoFarm.FlyHeight)
            AddLabel(contentFrame, "⚡ Turbo Mode: " .. (AutoFarm.TurboMode and "🟢 BẬT" or "🔴 TẮT"))
            AddLabel(contentFrame, "💥 Super Turbo: " .. (AutoFarm.SuperTurbo and "🟢 BẬT" or "🔴 TẮT"))
            AddLabel(contentFrame, "📊 Attack Speed: " .. AutoFarm.AttackSpeed .. "s")
            
        elseif tab == "auto" then
            AddLabel(contentFrame, "✈️ FLY + HITBOX MODE")
            AddLabel(contentFrame, "─────────────────────")
            
            AddToggle(contentFrame, "🔰 Auto Farm", AutoFarm.Enabled, function(state)
                if state then AutoFarm.Start() else AutoFarm.Stop() end
            end)
            
            AddToggle(contentFrame, "✈️ Fly Mode (Bay lên đầu quái)", AutoFarm.FlyMode, function(state)
                AutoFarm.FlyMode = state
                Library.Notify("✈️", state and "Fly Mode BẬT - Bay lên đầu quái" or "Fly Mode TẮT", 2)
            end)
            
            AddSlider(contentFrame, "📏 Fly Height", 5, 50, 15, function(value)
                AutoFarm.FlyHeight = value
                Library.Notify("📏", "Độ cao bay: " .. value, 1)
            end)
            
            AddToggle(contentFrame, "📐 Hitbox Expander", HitboxExpander.Enabled, function(state)
                if state then 
                    HitboxExpander.Start() 
                    AutoFarm.AutoHitbox = true
                else 
                    HitboxExpander.Stop()
                    AutoFarm.AutoHitbox = false
                end
            end)
            
            AddSlider(contentFrame, "📏 Hitbox Size", 5, 50, 10, function(value)
                HitboxExpander.Size = value
                if HitboxExpander.Enabled then
                    Library.Notify("📐", "Kích thước hitbox mới: " .. value, 1)
                end
            end)
            
            AddToggle(contentFrame, "🔄 Bring Mobs", AutoFarm.BringMobs, function(state)
                AutoFarm.BringMobs = state
                if state then
                    AutoFarm.BringPoint = HumanoidRootPart.Position
                end
            end)
            
            AddDropdown(contentFrame, "🚀 Teleport Mode", {"Tween", "Instant"}, "Tween", function(value)
                AutoFarm.TeleportMode = value
            end)
            
            AddLabel(contentFrame, "")
            AddLabel(contentFrame, "🔥 M1 TURBO SETTINGS")
            AddLabel(contentFrame, "─────────────────────")
            
            AddToggle(contentFrame, "⚡ Turbo Mode (x8)", AutoFarm.TurboMode, function(state)
                AutoFarm.TurboMode = state
                Library.Notify("⚡", state and "Turbo Mode BẬT - 8 đòn/chu kỳ" or "Turbo Mode TẮT", 2)
            end)
            
            AddToggle(contentFrame, "💥 Super Turbo (x15)", AutoFarm.SuperTurbo, function(state)
                if state then
                    AutoFarm.TurboMode = true
                    AutoFarm.SuperTurbo = true
                else
                    AutoFarm.SuperTurbo = false
                end
                Library.Notify("💥", state and "SUPER TURBO BẬT - 15 đòn/chu kỳ" or "SUPER TURBO TẮT", 2)
            end)
            
            AddToggle(contentFrame, "🔱 Multi-Click (x3)", AutoFarm.MultiClick, function(state)
                AutoFarm.MultiClick = state
                Library.Notify("🔱", state and "Multi-Click BẬT - Mỗi click đánh 3 phát" or "Multi-Click TẮT", 2)
            end)
            
            AddSlider(contentFrame, "🎚️ Attack Speed", 0.001, 0.5, 0.01, function(value)
                AutoFarm.AttackSpeed = value
            end)
            
            AddLabel(contentFrame, "")
            AddLabel(contentFrame, "⚔️ Auto Raid & Chest")
            AddLabel(contentFrame, "─────────────────────")
            
            AddToggle(contentFrame, "⚔️ Auto Raid", AutoRaid.Enabled, function(state)
                if state then AutoRaid.Start() else AutoRaid.Stop() end
            end)
            
            AddToggle(contentFrame, "📦 Auto Chest", AutoChest.Enabled, function(state)
                if state then AutoChest.Start() else AutoChest.Stop() end
            end)
            
        elseif tab == "boss" then
            AddToggle(contentFrame, "👑 Auto Boss", AutoBoss.Enabled, function(state)
                if state then AutoBoss.Start() else AutoBoss.Stop() end
            end)
            
            AddLabel(contentFrame, "🎯 Boss Hiện Tại: " .. (AutoBoss.CurrentBoss and AutoBoss.CurrentBoss.Name or "None"))
            
            local bossList = {}
            for _, boss in ipairs(AutoBoss.BossList) do
                table.insert(bossList, boss.name .. " (Level " .. boss.level .. ")")
            end
            
            AddDropdown(contentFrame, "🎯 Boss Target", bossList, bossList[1], function(value)
                for _, boss in ipairs(AutoBoss.BossList) do
                    if value:find(boss.name) then
                        AutoBoss.CurrentBoss = boss
                        break
                    end
                end
            end)
            
        elseif tab == "fruit" then
            AddToggle(contentFrame, "🍎 Auto Fruit Sniper", AutoFruit.Enabled, function(state)
                if state then AutoFruit.Start() else AutoFruit.Stop() end
            end)
            
            AddToggle(contentFrame, "💾 Auto Store Fruit", AutoFarm.AutoStoreFruit, function(state)
                AutoFarm.AutoStoreFruit = state
            end)
            
            AddLabel(contentFrame, "🚫 Danh Sách Blacklist:")
            
            local blacklistInput = Instance.new("TextBox")
            blacklistInput.Parent = contentFrame
            blacklistInput.Size = UDim2.new(0.9, -20, 0, 30)
            blacklistInput.Position = UDim2.new(0.05, 0, 0, 0)
            blacklistInput.PlaceholderText = "Nhập tên trái cần blacklist (cách nhau bằng dấu phẩy)"
            blacklistInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            blacklistInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            blacklistInput.Font = Enum.Font.Gotham
            blacklistInput.TextScaled = true
            
            blacklistInput.FocusLost:Connect(function()
                local text = blacklistInput.Text
                if text ~= "" then
                    AutoFruit.BlacklistedFruits = {}
                    for _, name in ipairs(string.split(text, ",")) do
                        table.insert(AutoFruit.BlacklistedFruits, string.trim(name))
                    end
                    Library.Notify("📋", "Đã cập nhật danh sách blacklist", 2)
                end
            end)
            
        elseif tab == "settings" then
            AddLabel(contentFrame, "⚙️ Cài Đặt Chung")
            
            AddDropdown(contentFrame, "🌐 Language", {"Tiếng Việt", "English"}, "Tiếng Việt", function(value)
                Library.Notify("🌐", "Đã chọn ngôn ngữ: " .. value, 2)
            end)
            
            AddToggle(contentFrame, "🔔 Notifications", true, function(state)
            end)
            
            AddToggle(contentFrame, "🔄 Anti AFK", true, function(state)
            end)
            
            AddLabel(contentFrame, "")
            AddLabel(contentFrame, "📱 Executor Info")
            AddLabel(contentFrame, "Executor: " .. (synapse and "Synapse X" or krnl and "Krnl" or script and "Delta/Xeno" or "Unknown"))
            AddLabel(contentFrame, "Version: 5.0 - FLY + HITBOX MODE")
            
            local closeBtn = Instance.new("TextButton")
            closeBtn.Parent = contentFrame
            closeBtn.Size = UDim2.new(0.8, 0, 0.06, 0)
            closeBtn.Position = UDim2.new(0.1, 0, 0, 0)
            closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            closeBtn.Text = "🚫 Đóng Script"
            closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeBtn.TextScaled = true
            closeBtn.Font = Enum.Font.GothamBold
            
            closeBtn.MouseButton1Click:Connect(function()
                AutoFarm.Stop()
                AutoBoss.Stop()
                AutoFruit.Stop()
                AutoRaid.Stop()
                AutoChest.Stop()
                if HitboxExpander.Enabled then
                    HitboxExpander.Stop()
                end
                screenGui:Destroy()
                Library.Notify("👋", "Đã tắt toàn bộ tính năng", 2)
            end)
        end
        
        contentFrame.CanvasSize = UDim2.new(0, 0, #contentFrame:GetChildren() * 45 + 50, 50)
    end
    
    UpdateTab("home")
    
    task.spawn(function()
        while screenGui.Parent do
            pcall(function()
                if currentTab == "home" then
                    UpdateTab("home")
                end
                task.wait(5)
            end)
            task.wait()
        end
    end)
    
    Library.Notify("✅", "Script đã tải thành công! Bấm M để mở GUI", 3)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)
    
    return screenGui
end

task.wait(2)

local gui = CreateGUI()

Library.Notify("✈️", "FLY + HITBOX MODE 2026 đã sẵn sàng!", 4)
Library.Notify("⌨️", "Nhấn M để mở/đóng GUI", 3)

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