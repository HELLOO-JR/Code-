local Players=game:GetService("Players")local RunService=game:GetService("RunService")local UserInputService=game:GetService("UserInputService")local ReplicatedStorage=game:GetService("ReplicatedStorage")local Lighting=game:GetService("Lighting")local CollectionService=game:GetService("CollectionService")local TweenService=game:GetService("TweenService")local Workspace=game:GetWorkspace()local Player=Players.LocalPlayer
local ScreenGui=Instance.new("ScreenGui")ScreenGui.Parent=Player.PlayerGui ScreenGui.Name="NguVlUltra" ScreenGui.ResetOnSpawn=false
local Main=Instance.new("Frame")Main.Parent=ScreenGui Main.BackgroundColor3=Color3.fromRGB(18,18,28) Main.BackgroundTransparency=0.05 Main.BorderSizePixel=0 Main.Position=UDim2.new(0.5,-160,0.5,-140) Main.Size=UDim2.new(0,320,0,280) Main.Active=true Main.Draggable=true Main.ClipsDescendants=true
local MC=Instance.new("UICorner")MC.Parent=Main MC.CornerRadius=UDim.new(0,16)
local Grad=Instance.new("UIGradient")Grad.Parent=Main Grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,28,48)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,16,28))})
local Shadow=Instance.new("Frame")Shadow.Parent=Main Shadow.BackgroundColor3=Color3.fromRGB(0,0,0) Shadow.BackgroundTransparency=0.7 Shadow.BorderSizePixel=0 Shadow.Position=UDim2.new(0.04,0,0.04,0) Shadow.Size=UDim2.new(0.96,0,0.96,0) Shadow.ZIndex=-1 local SC=Instance.new("UICorner")SC.Parent=Shadow SC.CornerRadius=UDim.new(0,16)
local Title=Instance.new("TextLabel")Title.Parent=Main Title.BackgroundTransparency=1 Title.Position=UDim2.new(0.04,0,0.02,0) Title.Size=UDim2.new(0.5,0,0.18,0) Title.Text="⚡ NGU VL v4.0" Title.TextColor3=Color3.fromRGB(255,210,80) Title.TextScaled=true Title.Font=Enum.Font.GothamBold Title.TextXAlignment=Enum.TextXAlignment.Left
local Stats=Instance.new("TextLabel")Stats.Parent=Main Stats.BackgroundTransparency=1 Stats.Position=UDim2.new(0.55,0,0.02,0) Stats.Size=UDim2.new(0.4,0,0.18,0) Stats.Text="0 detections" Stats.TextColor3=Color3.fromRGB(180,180,200) Stats.TextScaled=true Stats.Font=Enum.Font.Gotham Stats.TextXAlignment=Enum.TextXAlignment.Right
local StatusDot=Instance.new("Frame")StatusDot.Parent=Main StatusDot.BackgroundColor3=Color3.fromRGB(255,80,80) StatusDot.BorderSizePixel=0 StatusDot.Position=UDim2.new(0.04,0,0.22,0) StatusDot.Size=UDim2.new(0,12,0,12) local SDC=Instance.new("UICorner")SDC.Parent=StatusDot SDC.CornerRadius=UDim.new(1,0)
local StatusText=Instance.new("TextLabel")StatusText.Parent=Main StatusText.BackgroundTransparency=1 StatusText.Position=UDim2.new(0.1,0,0.20,0) StatusText.Size=UDim2.new(0.4,0,0.16,0) StatusText.Text="Offline" StatusText.TextColor3=Color3.fromRGB(255,120,120) StatusText.TextScaled=true StatusText.Font=Enum.Font.Gotham StatusText.TextXAlignment=Enum.TextXAlignment.Left

local ToggleBtn=Instance.new("Frame")ToggleBtn.Parent=Main ToggleBtn.BackgroundColor3=Color3.fromRGB(60,60,90) ToggleBtn.BorderSizePixel=0 ToggleBtn.Position=UDim2.new(0.76,0,0.20,0) ToggleBtn.Size=UDim2.new(0,54,0,28) local TBC=Instance.new("UICorner")TBC.Parent=ToggleBtn TBC.CornerRadius=UDim.new(1,0)
local ToggleInd=Instance.new("Frame")ToggleInd.Parent=ToggleBtn ToggleInd.BackgroundColor3=Color3.fromRGB(200,200,200) ToggleInd.BorderSizePixel=0 ToggleInd.Position=UDim2.new(0.06,0,0.1,0) ToggleInd.Size=UDim2.new(0.38,0,0.8,0) local TIC=Instance.new("UICorner")TIC.Parent=ToggleInd TIC.CornerRadius=UDim.new(1,0)
local ToggleText=Instance.new("TextLabel")ToggleText.Parent=ToggleBtn ToggleText.BackgroundTransparency=1 ToggleText.Size=UDim2.new(1,0,1,0) ToggleText.Text="OFF" ToggleText.TextColor3=Color3.fromRGB(255,255,255) ToggleText.TextScaled=true ToggleText.Font=Enum.Font.GothamBold

local function makeToggle(parent,posY,label,default,onChange)
local cont=Instance.new("Frame")cont.Parent=parent cont.BackgroundTransparency=1 cont.Position=UDim2.new(0.04,0,posY,0) cont.Size=UDim2.new(0.92,0,0.12,0)
local lbl=Instance.new("TextLabel")lbl.Parent=cont lbl.BackgroundTransparency=1 lbl.Position=UDim2.new(0,0,0,0) lbl.Size=UDim2.new(0.6,0,1,0) lbl.Text=label lbl.TextColor3=Color3.fromRGB(200,200,220) lbl.TextScaled=true lbl.Font=Enum.Font.Gotham lbl.TextXAlignment=Enum.TextXAlignment.Left
local btn=Instance.new("Frame")btn.Parent=cont btn.BackgroundColor3=Color3.fromRGB(50,50,80) btn.BorderSizePixel=0 btn.Position=UDim2.new(0.8,0,0.1,0) btn.Size=UDim2.new(0,40,0,22) local BNC=Instance.new("UICorner")BNC.Parent=btn BNC.CornerRadius=UDim.new(1,0)
local ind=Instance.new("Frame")ind.Parent=btn ind.BackgroundColor3=Color3.fromRGB(180,180,180) ind.BorderSizePixel=0 ind.Position=UDim2.new(0.08,0,0.1,0) ind.Size=UDim2.new(0.35,0,0.8,0) local INC=Instance.new("UICorner")INC.Parent=ind INC.CornerRadius=UDim.new(1,0)
local txt=Instance.new("TextLabel")txt.Parent=btn txt.BackgroundTransparency=1 txt.Size=UDim2.new(1,0,1,0) txt.Text=default and "ON" or "OFF" txt.TextColor3=Color3.fromRGB(255,255,255) txt.TextScaled=true txt.Font=Enum.Font.GothamBold
local state=default
local function update()
if state then btn.BackgroundColor3=Color3.fromRGB(80,200,120) ind.Position=UDim2.new(0.55,0,0.1,0) ind.BackgroundColor3=Color3.fromRGB(255,255,255) txt.Text="ON" else btn.BackgroundColor3=Color3.fromRGB(50,50,80) ind.Position=UDim2.new(0.08,0,0.1,0) ind.BackgroundColor3=Color3.fromRGB(180,180,180) txt.Text="OFF" end
if onChange then onChange(state) end
end
btn.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then state=not state update()end end)
update()
return function()return state end,function(v)state=v update()end
end

local function makeSlider(parent,posY,label,minVal,maxVal,defaultVal,onChange)
local cont=Instance.new("Frame")cont.Parent=parent cont.BackgroundTransparency=1 cont.Position=UDim2.new(0.04,0,posY,0) cont.Size=UDim2.new(0.92,0,0.14,0)
local lbl=Instance.new("TextLabel")lbl.Parent=cont lbl.BackgroundTransparency=1 lbl.Position=UDim2.new(0,0,0,0) lbl.Size=UDim2.new(0.5,0,0.5,0) lbl.Text=label lbl.TextColor3=Color3.fromRGB(200,200,220) lbl.TextScaled=true lbl.Font=Enum.Font.Gotham lbl.TextXAlignment=Enum.TextXAlignment.Left
local valLbl=Instance.new("TextLabel")valLbl.Parent=cont valLbl.BackgroundTransparency=1 valLbl.Position=UDim2.new(0.85,0,0,0) valLbl.Size=UDim2.new(0.15,0,0.5,0) valLbl.Text=tostring(defaultVal) valLbl.TextColor3=Color3.fromRGB(255,210,80) valLbl.TextScaled=true valLbl.Font=Enum.Font.Gotham valLbl.TextXAlignment=Enum.TextXAlignment.Right
local slider=Instance.new("Frame")slider.Parent=cont slider.BackgroundColor3=Color3.fromRGB(60,60,90) slider.BorderSizePixel=0 slider.Position=UDim2.new(0,0,0.55,0) slider.Size=UDim2.new(1,0,0.35,0) local SLC=Instance.new("UICorner")SLC.Parent=slider SLC.CornerRadius=UDim.new(0,4)
local fill=Instance.new("Frame")fill.Parent=slider fill.BackgroundColor3=Color3.fromRGB(255,210,80) fill.BorderSizePixel=0 fill.Size=UDim2.new((defaultVal-minVal)/(maxVal-minVal),0,1,0) local FLC=Instance.new("UICorner")FLC.Parent=fill FLC.CornerRadius=UDim.new(0,4)
local function update(val)local c=math.clamp(val,minVal,maxVal)fill.Size=UDim2.new((c-minVal)/(maxVal-minVal),0,1,0)valLbl.Text=string.format("%.2f",c)if onChange then onChange(c)end end
slider.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then local con con=RunService.Heartbeat:Connect(function()local m=UserInputService:GetMouseLocation()local p=slider.AbsolutePosition local s=slider.AbsoluteSize local x=math.clamp((m.X-p.X)/s.X,0,1) update(minVal+x*(maxVal-minVal))end)i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then con:Disconnect()end end)end end)
update(defaultVal)return update
end

local getAuto,setAuto=makeToggle(Main,0.36,"Auto Harvest",true)
local getSniffer,setSniffer=makeToggle(Main,0.50,"Packet Sniffer",true)
local getDeep,setDeep=makeToggle(Main,0.64,"Deep Hook",false)
local getCount,setCount=makeToggle(Main,0.78,"Countdown",true)
local sliderUpdate=makeSlider(Main,0.92,"Threshold",0.0,1.0,0.8)

local detCount=0
local harvestCount=0
local scriptEnabled=false
local countdownActive=false
local detectionCooldown=1.5
local lastDetection=0
local knownEvents={}
local lightningCache={}
local eventConnections={}
local isHooked=false

local CountdownLabel=Instance.new("TextLabel")CountdownLabel.Parent=ScreenGui CountdownLabel.BackgroundTransparency=1 CountdownLabel.Position=UDim2.new(0.5,-80,0.3,0) CountdownLabel.Size=UDim2.new(0,160,0,120) CountdownLabel.Text="" CountdownLabel.TextColor3=Color3.fromRGB(255,60,60) CountdownLabel.TextScaled=true CountdownLabel.Font=Enum.Font.GothamBold CountdownLabel.Visible=false

local function showCountdown()
if not getCount() or countdownActive then return end
countdownActive=true CountdownLabel.Visible=true
for i=3,1,-1 do CountdownLabel.Text=tostring(i) task.wait(1) end
CountdownLabel.Text="⚡" task.wait(0.6) CountdownLabel.Visible=false countdownActive=false
end

local function harvestTreeByPos(pos)
local nearest,dist=nil,math.huge
local container=Workspace:FindFirstChild("Trees")
if container then for _,t in ipairs(container:GetChildren()) do local p=t:FindFirstChild("Position") if p then local d=(p.Value-pos).Magnitude if d<dist then dist=d nearest=t end end end end
if nearest then local ev=ReplicatedStorage:FindFirstChild("Harvest")or ReplicatedStorage:FindFirstChild("ClaimTree") if ev and ev:IsA("RemoteEvent") then ev:FireServer(nearest) harvestCount=harvestCount+1 end end
showCountdown()
end

local function getTrees()
local trees={}
local container=Workspace:FindFirstChild("Trees") if not container then return trees end
for _,t in ipairs(container:GetChildren())do
local owner=t:FindFirstChild("Owner") if owner and owner.Value==Player then
local growth=t:FindFirstChild("Growth") if growth and growth.Value>=sliderUpdate then table.insert(trees,t) end
end end
return trees
end

local function harvestTree(t)
local ev=t:FindFirstChild("Harvest") if ev then if ev:IsA("RemoteEvent")then ev:FireServer() elseif ev:IsA("BindableFunction")then ev:Invoke() end harvestCount=harvestCount+1 end
end

local function detectViaTag()
for _,o in ipairs(CollectionService:GetTagged("Lightning"))do if not lightningCache[o]then lightningCache[o]=os.time() return true end end return false
end

local function detectViaInstances()
local kw={"lightning","bolt","strike","thunder","flash","storm","electric","shock","zap"}
for _,c in ipairs(Workspace:GetDescendants())do
if c:IsA("BasePart")or c:IsA("ParticleEmitter")or c:IsA("Beam")or c:IsA("Attachment")then
local n=c.Name:lower() for _,k in ipairs(kw)do if n:find(k)then if not lightningCache[c]then lightningCache[c]=os.time() return true end end end
end end return false
end

local function detectViaRemote()
local names={"LightningEvent","WeatherEvent","StormEvent","TreeStrike","LightningStrike","StrikeEvent"}
for _,n in ipairs(names)do local ev=ReplicatedStorage:FindFirstChild(n) if ev then
if ev:IsA("RemoteEvent")then
if not knownEvents[ev]then knownEvents[ev]=true
ev.OnClientEvent:Connect(function(...)local a={...} if getSniffer()then if type(a[1])=="userdata"and a[1]:IsA("Vector3")then harvestTreeByPos(a[1]) elseif type(a[2])=="userdata"and a[2]:IsA("Vector3")then harvestTreeByPos(a[2])else showCountdown()end end end)
end
if ev:GetAttribute("Active")or ev:GetAttribute("Triggered")then return true end
elseif ev:IsA("BoolValue")or ev:IsA("IntValue")then if ev.Value==true or ev.Value==1 then return true end end
end end return false
end

local function detectViaLighting()
if Lighting:FindFirstChild("Lightning")or Lighting:FindFirstChild("Storm")then return true end
local w=Lighting:GetAttribute("Weather") if w and (w:lower():find("storm")or w:lower():find("lightning"))then return true end return false
end

local function detectViaTime()
local t=ReplicatedStorage:FindFirstChild("LastLightningTime") if t and t:IsA("NumberValue")then if os.time()-t.Value<3 then return true end end return false
end

local function detectViaSky()
local sky=Lighting:FindFirstChild("Sky") if sky then local b=sky:GetAttribute("Brightness") if b and b<0.5 then return true end end return false
end

local function checkAndEvade()
if not scriptEnabled or not getAuto() then return end
if tick()-lastDetection<detectionCooldown then return end
local detected=false
local methods={detectViaTag,detectViaInstances,detectViaRemote,detectViaLighting,detectViaTime,detectViaSky}
for _,m in ipairs(methods)do if m()then detected=true break end end
if detected then
lastDetection=tick() detCount=detCount+1
local trees=getTrees() for _,t in ipairs(trees)do harvestTree(t)end
showCountdown()
Stats.Text=detCount.." detections | "..harvestCount.." harvested"
end
end

local function hookAllRemoteEvents()
if isHooked then return end
isHooked=true
for _,c in ipairs(ReplicatedStorage:GetChildren())do
if c:IsA("RemoteEvent")then
local n=c.Name:lower()
if n:find("lightning")or n:find("strike")or n:find("thunder")or n:find("weather")or n:find("storm")or n:find("bolt")or n:find("electric")or n:find("shock")then
if not knownEvents[c]then knownEvents[c]=true
c.OnClientEvent:Connect(function(...)local a={...} if getSniffer()then if type(a[1])=="userdata"and a[1]:IsA("Vector3")then harvestTreeByPos(a[1]) elseif type(a[2])=="userdata"and a[2]:IsA("Vector3")then harvestTreeByPos(a[2])else showCountdown()end end end)
end
end
end
end
end

local function applyDeepHook()
if not getDeep()then return end
local orig=RBXScriptSignal.Connect
function RBXScriptSignal:Connect(cb)
local p=self:FindFirstAncestorOfClass("RemoteEvent")
if p and p:IsA("RemoteEvent")then
local n=p.Name:lower()
if n:find("lightning")or n:find("strike")or n:find("thunder")or n:find("weather")or n:find("storm")or n:find("bolt")then
if not knownEvents[p]then knownEvents[p]=true
local wrap=function(...)local a={...} if getSniffer()then if a[1] and type(a[1])=="userdata"and a[1]:IsA("Vector3")then harvestTreeByPos(a[1]) elseif a[2] and type(a[2])=="userdata"and a[2]:IsA("Vector3")then harvestTreeByPos(a[2])else showCountdown()end end cb(...)end
return orig(self,wrap)
end
end
end return orig(self,cb)
end
end

local function cleanCache()
local now=os.time() for k,v in pairs(lightningCache)do if now-v>10 then lightningCache[k]=nil end end
end

local function toggleScript()
scriptEnabled=not scriptEnabled
if scriptEnabled then
hookAllRemoteEvents() applyDeepHook()
StatusDot.BackgroundColor3=Color3.fromRGB(80,220,120)
StatusText.Text="Active" StatusText.TextColor3=Color3.fromRGB(120,255,120)
ToggleBtn.BackgroundColor3=Color3.fromRGB(80,200,120)
ToggleInd.Position=UDim2.new(0.55,0,0.1,0) ToggleInd.BackgroundColor3=Color3.fromRGB(255,255,255)
ToggleText.Text="ON"
else
StatusDot.BackgroundColor3=Color3.fromRGB(255,80,80)
StatusText.Text="Offline" StatusText.TextColor3=Color3.fromRGB(255,120,120)
ToggleBtn.BackgroundColor3=Color3.fromRGB(60,60,90)
ToggleInd.Position=UDim2.new(0.06,0,0.1,0) ToggleInd.BackgroundColor3=Color3.fromRGB(200,200,200)
ToggleText.Text="OFF"
end
end

ToggleBtn.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then toggleScript()end end)

local lastTick=0
RunService.Heartbeat:Connect(function(dt)
if scriptEnabled then
lastTick=lastTick+dt
if lastTick>=0.4 then lastTick=0 checkAndEvade() end
if lastTick%10==0 then cleanCache() end
end
end)

setAuto(true) setSniffer(true) setDeep(false) setCount(true)