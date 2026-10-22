-- ============================================================
-- BLACKOUT GUI v2 | RADAR UI | PURPLE DEFAULT | OUTLINE ESP
-- Updated: raised ESP labels, reliable continuous No Hack Failed
-- ============================================================
wait(2)
if game.PlaceId ~= 893973440 then return end

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
    or ReplicatedStorage:WaitForChild("RemoteEvent", 5)

-- ============================================================
-- THEMES (PURPLE is default)
-- ============================================================
local THEMES = {
    RED    = { accent = Color3.fromRGB(230, 30, 45),   dim = Color3.fromRGB(120, 15, 22),   border = Color3.fromRGB(34, 20, 22) },
    PURPLE = { accent = Color3.fromRGB(175, 90, 255),  dim = Color3.fromRGB(80, 40, 120),   border = Color3.fromRGB(40, 24, 55) },
    BLUE   = { accent = Color3.fromRGB(65, 130, 255),  dim = Color3.fromRGB(30, 60, 120),   border = Color3.fromRGB(22, 30, 48) },
    GREEN  = { accent = Color3.fromRGB(65, 220, 125),  dim = Color3.fromRGB(30, 110, 60),   border = Color3.fromRGB(20, 40, 28) },
    ORANGE = { accent = Color3.fromRGB(245, 130, 30),  dim = Color3.fromRGB(120, 60, 15),   border = Color3.fromRGB(45, 28, 15) },
    PINK   = { accent = Color3.fromRGB(255, 90, 180),  dim = Color3.fromRGB(130, 40, 90),   border = Color3.fromRGB(45, 22, 35) },
    WHITE  = { accent = Color3.fromRGB(235, 235, 235), dim = Color3.fromRGB(120, 120, 120), border = Color3.fromRGB(40, 40, 45) },
}
local currentTheme = "PURPLE"

local ACCENT     = THEMES.PURPLE.accent
local ACCENT_DIM = THEMES.PURPLE.dim
local BORDER     = THEMES.PURPLE.border
local BG         = Color3.fromRGB(8, 8, 11)
local BG_ITEM    = Color3.fromRGB(14, 14, 20)
local BG_HOVER   = Color3.fromRGB(24, 16, 32)
local TEXT       = Color3.fromRGB(255, 255, 255)
local TEXT_DIM   = Color3.fromRGB(150, 150, 160)
local TEXT_ON    = THEMES.PURPLE.accent
local STROKE_BG  = Color3.fromRGB(6, 6, 8)

-- ============================================================
-- ESP COLORS (lighter green / outline-only) — BEAST = LIGHT RED
-- ============================================================
local ESP_GREEN       = Color3.fromRGB(140, 255, 160)   -- Survival
local ESP_BEAST       = Color3.fromRGB(255, 85, 85)   -- Beast (more red)
local ESP_CAPTURED    = Color3.fromRGB(120, 200, 255)   -- Captured (light blue)
local ESP_DEFAULT     = Color3.fromRGB(200, 200, 200)
local ESP_COMPUTER    = Color3.fromRGB(180, 255, 200)   -- lighter green
local ESP_FREEZEPOD   = Color3.fromRGB(150, 220, 255)   -- light blue
local ESP_EXITDOOR    = Color3.fromRGB(200, 255, 150)   -- light lime

-- ============================================================
-- ESP LABEL HEIGHT ABOVE HEAD
-- ============================================================
local ESP_LABEL_HEIGHT = 3   -- studs above head (increase for higher)

-- ============================================================
-- ROOT
-- ============================================================
local guiParent
pcall(function() if gethui then guiParent = gethui() end end)
if not guiParent then pcall(function() guiParent = game:GetService("CoreGui") end) end
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackoutRadarUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 2147483647
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = guiParent

-- ============================================================
-- THEMED ELEMENT REGISTRY
-- ============================================================
local Themed = { toggles = {}, dropdowns = {}, buttons = {}, accentElements = {}, borderElements = {}, dimElements = {} }

-- ============================================================
-- HELPERS
-- ============================================================
local Genv = getgenv and getgenv() or _G
Genv.SHub = Genv.SHub or {}
Genv.SHub.Toggle = Genv.SHub.Toggle or {}
Genv.SHub.Notify = Genv.SHub.Notify or {}
Genv.SHub.WPlr = Genv.SHub.WPlr or {}
Genv.SHub.TaskSignal = Genv.SHub.TaskSignal or {}

local function find_instance(it, was)
    local love, cute = typeof(it), string.lower(was)
    if love and cute then
        local angel = (love == 'Instance' and it:FindFirstChild(was, true))
        if not angel then
            for _, baby in pairs(love == 'table' and it or it:GetDescendants()) do
                if string.lower(baby.Name) == cute then angel = baby; break end
            end
        end
        return angel, angel ~= nil
    end
    return nil, false
end

local function findroot_or(sorry, marries)
    if not (sorry and sorry.Parent) then return end
    local can, we, talk = nil, sorry:FindFirstChildWhichIsA('Humanoid')
    if not can then
        if we then
            talk = pcall(function() can = we.RootPart end)
            if not (talk and can) then pcall(function() can = we.Torso end) end
        end
        if not (talk and can) then
            can = sorry:FindFirstChild("HumanoidRootPart") or sorry:FindFirstChild("Torso") or sorry:FindFirstChild("UpperTorso")
        end
    end
    return not marries and can or we
end

local function ToNumV(v)
    if type(v) == "number" then return v end
    local n = tonumber(v); return n ~= nil and n or 0
end

local function Sround(num, np)
    local mult = 10 ^ (np or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function GetHiddenGui()
    local Tery_ui, gethui_ = nil, (gethui or (function() end))
    if type(gethui_) == "function" then
        local ok, r = pcall(gethui_)
        if ok then Tery_ui = r end
    end
    if not Tery_ui then
        local CG = game:GetService("CoreGui")
        if CG:FindFirstChild("RobloxGui") then Tery_ui = CG.RobloxGui
        elseif CG then Tery_ui = CG
        else Tery_ui = LocalPlayer:FindFirstChildOfClass("PlayerGui") end
    end
    return Tery_ui
end

local function getSafeParent(SName)
    local guiParent2 = GetHiddenGui()
    if not SName then SName = "nia = aura" end
    local fn = `SHub_ESP_{SName}`
    local folder = guiParent2:FindFirstChild(fn)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = fn
        folder.Parent = guiParent2
    end
    return folder
end

-- ============================================================
-- OUTLINE-ONLY ESP HIGHLIGHT
-- ============================================================
local function applyOutlineHighlight(part, color)
    local hl = part:FindFirstChild("S_Highlight")
    if hl then
        hl.OutlineColor = color
        return hl
    end
    hl = Instance.new("Highlight")
    hl.Name = "S_Highlight"
    hl.Adornee = part
    hl.FillColor = color
    hl.FillTransparency = 1          -- outline only (no chams fill)
    hl.OutlineColor = color
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = part
    return hl
end

-- ============================================================
-- HIGHLIGHT CLEANUP (called from Stop functions)
-- ============================================================
local function clearHighlightsOnMap(names)
    local map = GetCurrentMap()
    if map then
        for _, o in pairs(map:GetDescendants()) do
            local hl = o:FindFirstChild("S_Highlight")
            if hl and hl:IsA("Highlight") then hl:Destroy() end
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if names[obj.Name] then
            local hl = obj:FindFirstChild("S_Highlight")
            if hl and hl:IsA("Highlight") then hl:Destroy() end
        end
    end
end

local function createBillboard(part, IDorN, ESPContainer)
    local billboard = ESPContainer:FindFirstChild(IDorN)
    if billboard then billboard:Destroy() end
    billboard = Instance.new("BillboardGui")
    billboard.Name = IDorN
    billboard.Adornee = part
    billboard.StudsOffset = Vector3.new(0, ESP_LABEL_HEIGHT, 0)  -- raised above head
    billboard.Size = UDim2.new(5, 0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = ESPContainer
    local label = Instance.new("TextLabel")
    label.Name = "Text_Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextTransparency = 0.1
    label.TextStrokeTransparency = 0.1
    label.TextSize = 11
    label.Font = Enum.Font.FredokaOne
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = "Loading..."
    label.Parent = billboard
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow_Label"
    arrow.Size = UDim2.new(1, 0, 0, 20)
    arrow.Position = UDim2.new(0.5, 0, 0, 1)
    arrow.AnchorPoint = Vector2.new(0.5, 1)
    arrow.BackgroundTransparency = 1
    arrow.TextTransparency = 0.1
    arrow.TextColor3 = Color3.new(1, 1, 1)
    arrow.TextStrokeTransparency = 0.1
    arrow.Font = Enum.Font.FredokaOne
    arrow.TextScaled = true
    arrow.Rotation = 180
    arrow.Text = "^"
    arrow.Parent = billboard
    return billboard, label, arrow
end

local function GetESPId(inst) return `ESP_{inst:GetDebugId()}` end

function GetCurrentMap()
    local map
    local ov = find_instance(ReplicatedStorage, "CurrentMap")
    if ov and ov:IsA("ObjectValue") then
        local v = ov.Value
        if typeof(v) == "Instance" and v.Parent then map = v end
    end
    if not map then
        local comp = find_instance(Workspace, "ComputerTable")
        if comp and comp.Parent then map = comp.Parent end
    end
    if not map then
        local pod = find_instance(Workspace, "FreezePod")
        if pod and pod.Parent then map = pod.Parent end
    end
    return map
end

local LPC = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LPH, LPR = findroot_or(LPC, 0), findroot_or(LPC)
Genv.SHub.TaskSignal.LPCAdded = LocalPlayer.CharacterAdded:Connect(function(c)
    repeat RunService.Heartbeat:Wait()
        LPC, LPH, LPR = c, findroot_or(c, 0), findroot_or(c)
    until LPC and LPH and LPR
end)

local function IsWhilstPlayer(name) return Genv.SHub.WPlr[name] end

-- ============================================================
-- BUILD UI
-- ============================================================
local W, H = 660, 460
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = BORDER
MainStroke.Thickness = 1
table.insert(Themed.borderElements, MainStroke)

local BgFrame = Instance.new("Frame")
BgFrame.Size = UDim2.fromScale(1, 1)
BgFrame.BackgroundColor3 = BG
BgFrame.BorderSizePixel = 0
BgFrame.ZIndex = 1
BgFrame.Parent = Main
Instance.new("UICorner", BgFrame).CornerRadius = UDim.new(0, 10)
local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 11)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 8, 22)),
})
BgGrad.Rotation = 135
BgGrad.Parent = BgFrame

-- ============================================================
-- RADAR BACKDROP
-- ============================================================
local RadarContainer = Instance.new("Frame")
RadarContainer.Size = UDim2.fromScale(1, 1)
RadarContainer.BackgroundTransparency = 1
RadarContainer.ClipsDescendants = true
RadarContainer.ZIndex = 2
RadarContainer.Parent = Main
Instance.new("UICorner", RadarContainer).CornerRadius = UDim.new(0, 10)

local RadarCenter = Instance.new("Frame")
RadarCenter.Size = UDim2.fromOffset(700, 700)
RadarCenter.AnchorPoint = Vector2.new(0.5, 0.5)
RadarCenter.Position = UDim2.new(1, -80, 0.5, 0)
RadarCenter.BackgroundTransparency = 1
RadarCenter.ZIndex = 2
RadarCenter.Parent = RadarContainer

local RadarRings = {}
for i = 1, 5 do
    local ring = Instance.new("Frame")
    local s = i * 110
    ring.Size = UDim2.fromOffset(s, s)
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 2
    ring.Parent = RadarCenter
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local ringStroke = Instance.new("UIStroke", ring)
    ringStroke.Color = ACCENT
    ringStroke.Thickness = 1
    ringStroke.Transparency = 0.85 - (i * 0.03)
    RadarRings[i] = { stroke = ringStroke }
    table.insert(Themed.accentElements, { obj = ringStroke, prop = "Color" })
end

local CrossH = Instance.new("Frame")
CrossH.Size = UDim2.new(1, 0, 0, 1)
CrossH.Position = UDim2.new(0, 0, 0.5, 0)
CrossH.BackgroundColor3 = ACCENT
CrossH.BackgroundTransparency = 0.85
CrossH.BorderSizePixel = 0
CrossH.ZIndex = 2
CrossH.Parent = RadarCenter
table.insert(Themed.accentElements, { obj = CrossH, prop = "BackgroundColor3" })

local CrossV = Instance.new("Frame")
CrossV.Size = UDim2.new(0, 1, 1, 0)
CrossV.Position = UDim2.new(0.5, 0, 0, 0)
CrossV.BackgroundColor3 = ACCENT
CrossV.BackgroundTransparency = 0.85
CrossV.BorderSizePixel = 0
CrossV.ZIndex = 2
CrossV.Parent = RadarCenter
table.insert(Themed.accentElements, { obj = CrossV, prop = "BackgroundColor3" })

local Sweep = Instance.new("Frame")
Sweep.Size = UDim2.fromOffset(340, 340)
Sweep.AnchorPoint = Vector2.new(0.5, 0.5)
Sweep.Position = UDim2.new(0.5, 0, 0.5, 0)
Sweep.BackgroundTransparency = 1
Sweep.ZIndex = 2
Sweep.Parent = RadarCenter

local SweepLine = Instance.new("Frame")
SweepLine.Size = UDim2.new(0, 2, 0.5, 0)
SweepLine.Position = UDim2.new(0.5, -1, 0, 0)
SweepLine.BackgroundColor3 = ACCENT
SweepLine.BackgroundTransparency = 0.1
SweepLine.BorderSizePixel = 0
SweepLine.ZIndex = 3
SweepLine.Parent = Sweep
table.insert(Themed.accentElements, { obj = SweepLine, prop = "BackgroundColor3" })

local SweepGlow = Instance.new("UIStroke", SweepLine)
SweepGlow.Color = ACCENT
SweepGlow.Thickness = 8
SweepGlow.Transparency = 0.6
table.insert(Themed.accentElements, { obj = SweepGlow, prop = "Color" })

local WedgeContainer = Instance.new("Frame")
WedgeContainer.Size = UDim2.fromOffset(340, 340)
WedgeContainer.AnchorPoint = Vector2.new(0.5, 0.5)
WedgeContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
WedgeContainer.BackgroundTransparency = 1
WedgeContainer.ZIndex = 2
WedgeContainer.Parent = RadarCenter

local WedgeLines = {}
for i = 1, 18 do
    local angle = (i / 18) * 60
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 0.5, 0)
    line.Position = UDim2.new(0.5, -1, 0, 0)
    line.AnchorPoint = Vector2.new(0, 0)
    line.BackgroundColor3 = ACCENT
    line.BackgroundTransparency = 0.55 + (i / 18) * 0.45
    line.BorderSizePixel = 0
    line.Rotation = -angle
    line.ZIndex = 2
    line.Parent = WedgeContainer
    WedgeLines[i] = line
    table.insert(Themed.accentElements, { obj = line, prop = "BackgroundColor3" })
end

local Blips = {}
for i = 1, 6 do
    local blip = Instance.new("Frame")
    blip.Size = UDim2.fromOffset(6, 6)
    blip.AnchorPoint = Vector2.new(0.5, 0.5)
    blip.BackgroundColor3 = ACCENT
    blip.BorderSizePixel = 0
    blip.BackgroundTransparency = 1
    blip.ZIndex = 4
    blip.Parent = RadarCenter
    Instance.new("UICorner", blip).CornerRadius = UDim.new(1, 0)
    local blipGlow = Instance.new("UIStroke", blip)
    blipGlow.Color = ACCENT
    blipGlow.Thickness = 4
    blipGlow.Transparency = 1
    Blips[i] = {
        frame = blip, stroke = blipGlow,
        angle = math.random() * math.pi * 2,
        radius = 60 + math.random() * 240,
        life = 0, maxLife = 1.5 + math.random(),
    }
    table.insert(Themed.accentElements, { obj = blip, prop = "BackgroundColor3" })
    table.insert(Themed.accentElements, { obj = blipGlow, prop = "Color" })
end

local PulseContainer = Instance.new("Frame")
PulseContainer.Size = UDim2.fromOffset(700, 700)
PulseContainer.AnchorPoint = Vector2.new(0.5, 0.5)
PulseContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
PulseContainer.BackgroundTransparency = 1
PulseContainer.ZIndex = 2
PulseContainer.Parent = RadarCenter

local function SpawnPulse()
    local pulse = Instance.new("Frame")
    pulse.Size = UDim2.fromOffset(20, 20)
    pulse.AnchorPoint = Vector2.new(0.5, 0.5)
    pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
    pulse.BackgroundTransparency = 1
    pulse.ZIndex = 2
    pulse.Parent = PulseContainer
    Instance.new("UICorner", pulse).CornerRadius = UDim.new(1, 0)
    local ps = Instance.new("UIStroke", pulse)
    ps.Color = ACCENT
    ps.Thickness = 3
    ps.Transparency = 0.2
    TweenService:Create(pulse, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.fromOffset(680, 680)}):Play()
    TweenService:Create(ps, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Transparency = 1, Thickness = 1}):Play()
    task.delay(3.1, function() if pulse then pulse:Destroy() end end)
end

local Scan = Instance.new("Frame")
Scan.Size = UDim2.fromScale(1, 1)
Scan.BackgroundTransparency = 1
Scan.ZIndex = 5
Scan.Parent = Main
Instance.new("UICorner", Scan).CornerRadius = UDim.new(0, 10)
for i = 0, 90 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, i * 5)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.985
    line.BorderSizePixel = 0
    line.ZIndex = 5
    line.Parent = Scan
end

local Vignette = Instance.new("Frame")
Vignette.Size = UDim2.fromScale(1, 1)
Vignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Vignette.BackgroundTransparency = 0.55
Vignette.BorderSizePixel = 0
Vignette.ZIndex = 4
Vignette.Parent = Main
Instance.new("UICorner", Vignette).CornerRadius = UDim.new(0, 10)
local vigGrad = Instance.new("UIGradient", Vignette)
vigGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.4),
    NumberSequenceKeypoint.new(0.5, 0.9),
    NumberSequenceKeypoint.new(1, 0.4),
})

-- ============================================================
-- HEADER
-- ============================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(14, 8, 18)
Header.BackgroundTransparency = 0.25
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = Main
local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 14, 46)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 6, 16)),
})
HeaderGrad.Parent = Header

local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 10, 0, 10)
LogoDot.Position = UDim2.new(0, 20, 0.5, -5)
LogoDot.BackgroundColor3 = ACCENT
LogoDot.BorderSizePixel = 0
LogoDot.ZIndex = 12
LogoDot.Parent = Header
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)
table.insert(Themed.accentElements, { obj = LogoDot, prop = "BackgroundColor3" })

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BLACKOUT"
Title.TextColor3 = TEXT
Title.Font = Enum.Font.Code
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Header
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = STROKE_BG

local Ver = Instance.new("TextLabel")
Ver.Size = UDim2.new(0, 60, 1, 0)
Ver.Position = UDim2.new(0, 185, 0, 2)
Ver.BackgroundTransparency = 1
Ver.Text = "v2"
Ver.TextColor3 = ACCENT
Ver.Font = Enum.Font.Code
Ver.TextSize = 12
Ver.TextXAlignment = Enum.TextXAlignment.Left
Ver.ZIndex = 11
Ver.Parent = Header
table.insert(Themed.accentElements, { obj = Ver, prop = "TextColor3" })

local StatDot = Instance.new("Frame")
StatDot.Size = UDim2.new(0, 8, 0, 8)
StatDot.Position = UDim2.new(1, -150, 0.5, -4)
StatDot.BackgroundColor3 = Color3.fromRGB(65, 220, 125)
StatDot.BorderSizePixel = 0
StatDot.ZIndex = 12
StatDot.Parent = Header
Instance.new("UICorner", StatDot).CornerRadius = UDim.new(1, 0)

local StatLbl = Instance.new("TextLabel")
StatLbl.Size = UDim2.new(0, 80, 1, 0)
StatLbl.Position = UDim2.new(1, -138, 0, 0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "LOADED"
StatLbl.TextColor3 = Color3.fromRGB(65, 220, 125)
StatLbl.Font = Enum.Font.Code
StatLbl.TextSize = 10
StatLbl.TextXAlignment = Enum.TextXAlignment.Left
StatLbl.ZIndex = 11
StatLbl.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -72, 0.5, -14)
MinBtn.BackgroundColor3 = Color3.fromRGB(24, 16, 32)
MinBtn.Text = "–"
MinBtn.TextColor3 = TEXT_DIM
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 12
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 24)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(240, 100, 100)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 18
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 6, 16)
Sidebar.BackgroundTransparency = 0.45
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 8
Sidebar.Parent = Main
local SideGrad = Instance.new("UIGradient")
SideGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 10, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 4, 12)),
})
SideGrad.Rotation = 90
SideGrad.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 4)
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingLeft = UDim.new(0, 8)
SidePad.PaddingRight = UDim.new(0, 8)
SidePad.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -50)
Content.Position = UDim2.new(0, 140, 0, 50)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = false
Content.ZIndex = 9
Content.Parent = Main

local TabRefs = {}
local CurrentTab = nil

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BG_ITEM
    btn.BackgroundTransparency = 0.4
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.ZIndex = 9
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local activeBar = Instance.new("Frame")
    activeBar.Size = UDim2.new(0, 3, 0, 0)
    activeBar.Position = UDim2.new(0, 0, 0.5, 0)
    activeBar.AnchorPoint = Vector2.new(0, 0.5)
    activeBar.BackgroundColor3 = ACCENT
    activeBar.BorderSizePixel = 0
    activeBar.ZIndex = 11
    activeBar.Parent = btn
    Instance.new("UICorner", activeBar).CornerRadius = UDim.new(1, 0)
    table.insert(Themed.accentElements, { obj = activeBar, prop = "BackgroundColor3" })

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(name)
    label.TextColor3 = TEXT_DIM
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = btn
    label.TextStrokeTransparency = 0.65
    label.TextStrokeColor3 = STROKE_BG

    local page = Instance.new("Frame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 9
    page.Parent = Content
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 10)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = ACCENT_DIM
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ClipsDescendants = false
    scroll.ZIndex = 9
    scroll.Parent = page
    table.insert(Themed.dimElements, { obj = scroll, prop = "ScrollBarImageColor3" })

    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local ref = { Button = btn, Page = page, Scroll = scroll, Layout = list, ActiveBar = activeBar, Label = label, Name = name }
    local isActive = false

    ref.SetActive = function(active)
        isActive = active
        if active then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, BackgroundColor3 = ACCENT_DIM}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = TEXT}):Play()
            TweenService:Create(activeBar, TweenInfo.new(0.25), {Size = UDim2.new(0, 3, 0, 24)}):Play()
            page.Visible = true
            page.Position = UDim2.new(0, 20, 0, 0)
            TweenService:Create(page, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 0, 0, 0)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4, BackgroundColor3 = BG_ITEM}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = TEXT_DIM}):Play()
            TweenService:Create(activeBar, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            page.Visible = false
        end
    end

    btn.MouseEnter:Connect(function()
        if not isActive then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.15, BackgroundColor3 = BG_HOVER}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = TEXT}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not isActive then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4, BackgroundColor3 = BG_ITEM}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = TEXT_DIM}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if CurrentTab and CurrentTab ~= ref then CurrentTab.SetActive(false) end
        ref.SetActive(true)
        CurrentTab = ref
    end)

    return ref
end

-- ============================================================
-- BUILDERS
-- ============================================================
local function AddSection(page, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = "── " .. string.upper(text)
    lbl.TextColor3 = ACCENT
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0.65
    lbl.TextStrokeColor3 = STROKE_BG
    lbl.ZIndex = 10
    lbl.Parent = page.Scroll
    table.insert(Themed.accentElements, { obj = lbl, prop = "TextColor3" })
end

local function AddToggle(page, name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = BG_ITEM
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 10
    btn.Parent = page.Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = BORDER
    stroke.Thickness = 1

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 16)
    bar.Position = UDim2.new(0, 0, 0.5, -8)
    bar.BackgroundColor3 = BORDER
    bar.BorderSizePixel = 0
    bar.ZIndex = 10
    bar.Parent = btn
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(name)
    label.TextColor3 = TEXT
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = btn
    label.TextStrokeTransparency = 0.65
    label.TextStrokeColor3 = STROKE_BG

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 40, 1, 0)
    status.Position = UDim2.new(1, -45, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = TEXT_DIM
    status.Font = Enum.Font.Code
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.ZIndex = 10
    status.Parent = btn
    status.TextStrokeTransparency = 0.65
    status.TextStrokeColor3 = STROKE_BG

    local state = defaultState or false
    local function Render(animate)
        local c = state and ACCENT or BORDER
        local t = state and ACCENT or TEXT
        local st = state and "ON" or "OFF"
        local sc = state and ACCENT or TEXT_DIM
        local bg = state and Color3.fromRGB(30, 16, 40) or BG_ITEM
        if animate then
            TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = c}):Play()
            TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = t}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = bg}):Play()
        else
            bar.BackgroundColor3 = c
            stroke.Color = c
            label.TextColor3 = t
            btn.BackgroundColor3 = bg
        end
        status.Text = st
        status.TextColor3 = sc
    end
    Render(false)

    btn.MouseEnter:Connect(function()
        if not state then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_HOVER}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if not state then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_ITEM}):Play() end
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        Render(true)
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("[Blackout] " .. tostring(err)) end
        end
    end)

    table.insert(Themed.toggles, { Render = Render })
end

-- ============================================================
-- DROPDOWN (FIXED: click-catcher instead of GetMouseLocation)
-- ============================================================
local function AddDropdown(page, name, value, options, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = BG_ITEM
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 10
    btn.Parent = page.Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = BORDER
    stroke.Thickness = 1

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 16)
    bar.Position = UDim2.new(0, 0, 0.5, -8)
    bar.BackgroundColor3 = BORDER
    bar.BorderSizePixel = 0
    bar.ZIndex = 10
    bar.Parent = btn
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(name)
    label.TextColor3 = TEXT
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = btn
    label.TextStrokeTransparency = 0.65
    label.TextStrokeColor3 = STROKE_BG

    local valTxt = Instance.new("TextLabel")
    valTxt.Size = UDim2.new(0.4, 0, 1, 0)
    valTxt.Position = UDim2.new(0.58, 0, 0, 0)
    valTxt.BackgroundTransparency = 1
    valTxt.Text = tostring(value)
    valTxt.TextColor3 = ACCENT
    valTxt.Font = Enum.Font.Code
    valTxt.TextSize = 11
    valTxt.TextXAlignment = Enum.TextXAlignment.Right
    valTxt.ZIndex = 10
    valTxt.Parent = btn
    valTxt.TextStrokeTransparency = 0.65
    valTxt.TextStrokeColor3 = STROKE_BG
    table.insert(Themed.accentElements, { obj = valTxt, prop = "TextColor3" })

    local current = value
    local open = false

    local catcher = Instance.new("TextButton")
    catcher.Size = UDim2.fromScale(1, 1)
    catcher.BackgroundTransparency = 1
    catcher.Text = ""
    catcher.AutoButtonColor = false
    catcher.BorderSizePixel = 0
    catcher.Visible = false
    catcher.ZIndex = 4999
    catcher.Parent = ScreenGui

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 200, 0, #options * 26 + 8)
    menu.BackgroundColor3 = Color3.fromRGB(18, 10, 24)
    menu.BackgroundTransparency = 0.05
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 5000
    menu.Parent = ScreenGui
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 4)
    local menuStroke = Instance.new("UIStroke", menu)
    menuStroke.Color = ACCENT_DIM
    menuStroke.Thickness = 1
    table.insert(Themed.dimElements, { obj = menuStroke, prop = "Color" })

    local mList = Instance.new("UIListLayout", menu)
    mList.Padding = UDim.new(0, 2)
    mList.SortOrder = Enum.SortOrder.LayoutOrder
    local mPad = Instance.new("UIPadding", menu)
    mPad.PaddingTop = UDim.new(0, 4)
    mPad.PaddingBottom = UDim.new(0, 4)
    mPad.PaddingLeft = UDim.new(0, 4)
    mPad.PaddingRight = UDim.new(0, 4)

    local function closeMenu()
        open = false
        menu.Visible = false
        catcher.Visible = false
    end

    local optButtons = {}
    for i, opt in ipairs(options) do
        local o = Instance.new("TextButton")
        o.Size = UDim2.new(1, 0, 0, 22)
        o.BackgroundColor3 = Color3.fromRGB(24, 16, 32)
        o.BorderSizePixel = 0
        o.AutoButtonColor = false
        o.Text = "  " .. tostring(opt)
        o.TextColor3 = (opt == current) and ACCENT or TEXT
        o.Font = Enum.Font.Code
        o.TextSize = 11
        o.TextXAlignment = Enum.TextXAlignment.Left
        o.LayoutOrder = i
        o.ZIndex = 5001
        o.Parent = menu
        Instance.new("UICorner", o).CornerRadius = UDim.new(0, 3)
        o.MouseEnter:Connect(function()
            TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
        end)
        o.MouseLeave:Connect(function()
            TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 16, 32)}):Play()
        end)
        o.MouseButton1Click:Connect(function()
            current = opt
            valTxt.Text = tostring(opt)
            for _, ob in ipairs(optButtons) do
                ob.TextColor3 = (ob.Text == "  " .. tostring(opt)) and ACCENT or TEXT
            end
            closeMenu()
            if callback then
                local ok, err = pcall(callback, opt)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)
        optButtons[i] = o
    end

    catcher.MouseButton1Click:Connect(function()
        closeMenu()
    end)

    local function openMenu()
        if open then closeMenu() return end
        open = true
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        local menuHeight = #options * 26 + 8
        local screenY = pos.Y + size.Y + 4
        local guiHeight = ScreenGui.AbsoluteSize.Y
        if screenY + menuHeight > guiHeight then
            screenY = pos.Y - menuHeight - 4
        end
        menu.Position = UDim2.fromOffset(pos.X, screenY)
        menu.Size = UDim2.fromOffset(math.max(size.X, 180), menuHeight)
        catcher.Visible = true
        menu.Visible = true
    end

    btn.MouseButton1Click:Connect(openMenu)

    table.insert(Themed.dropdowns, { btn = btn, stroke = stroke, bar = bar, label = label, valTxt = valTxt })
end

local function AddButton(page, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = BG_ITEM
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 10
    btn.Parent = page.Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = BORDER
    stroke.Thickness = 1

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 16)
    bar.Position = UDim2.new(0, 0, 0.5, -8)
    bar.BackgroundColor3 = BORDER
    bar.BorderSizePixel = 0
    bar.ZIndex = 10
    bar.Parent = btn
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.upper(name)
    label.TextColor3 = TEXT
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 10
    label.Parent = btn
    label.TextStrokeTransparency = 0.65
    label.TextStrokeColor3 = STROKE_BG

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_HOVER}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = ACCENT}):Play()
        TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_ITEM}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = BORDER}):Play()
        TweenService:Create(bar, TweenInfo.new(0.15), {BackgroundColor3 = BORDER}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[Blackout] " .. tostring(err)) end
        end
    end)
end

local function AddSlider(page, name, minV, maxV, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = BG_ITEM
    Container.BorderSizePixel = 0
    Container.Parent = page.Scroll
    Container.ZIndex = 10
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = BORDER; Stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 14)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = string.upper(name); Label.TextColor3 = TEXT
    Label.Font = Enum.Font.Code; Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size = UDim2.new(0, 50, 0, 14)
    ValLbl.Position = UDim2.new(1, -56, 0, 4)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text = tostring(default); ValLbl.TextColor3 = ACCENT
    ValLbl.Font = Enum.Font.Code; ValLbl.TextSize = 11
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    ValLbl.Parent = Container
    table.insert(Themed.accentElements, { obj = ValLbl, prop = "TextColor3" })

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 4)
    Track.Position = UDim2.new(0, 12, 1, -12)
    Track.BackgroundColor3 = BORDER; Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    Fill.BackgroundColor3 = ACCENT; Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    table.insert(Themed.accentElements, { obj = Fill, prop = "BackgroundColor3" })

    local dragging = false
    local function SetFromX(x)
        local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor((minV + (maxV - minV) * rel) * 10 + 0.5) / 10
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; SetFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function AddInput(page, name, placeholder, numeric, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = BG_ITEM; Container.BorderSizePixel = 0
    Container.Parent = page.Scroll
    Container.ZIndex = 10
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = BORDER; Stroke.Thickness = 1

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 0, 12)
    Label.Position = UDim2.new(0, 12, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = string.upper(name); Label.TextColor3 = TEXT_DIM
    Label.Font = Enum.Font.Code; Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 0, 18)
    Box.Position = UDim2.new(0, 12, 0, 16)
    Box.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
    Box.BorderSizePixel = 0
    Box.Text = ""
    Box.PlaceholderText = placeholder
    Box.TextColor3 = TEXT
    Box.PlaceholderColor3 = TEXT_DIM
    Box.Font = Enum.Font.Code; Box.TextSize = 11
    Box.ClearTextOnFocus = false
    Box.Parent = Container
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)

    Box.FocusLost:Connect(function()
        local v = Box.Text
        if callback then pcall(callback, numeric and ToNumV(v) or v) end
    end)
end

-- ============================================================
-- THEME APPLIER
-- ============================================================
local function ApplyTheme(name)
    local t = THEMES[name]
    if not t then return end
    currentTheme = name
    ACCENT     = t.accent
    ACCENT_DIM = t.dim
    BORDER     = t.border
    TEXT_ON    = t.accent

    MainStroke.Color = BORDER
    for _, e in ipairs(Themed.accentElements) do
        pcall(function() e.obj[e.prop] = ACCENT end)
    end
    for _, e in ipairs(Themed.dimElements) do
        pcall(function() e.obj[e.prop] = ACCENT_DIM end)
    end
    for _, e in ipairs(Themed.borderElements) do
        pcall(function() e.obj[e.prop] = BORDER end)
    end
    for _, tog in ipairs(Themed.toggles) do
        if tog.Render then pcall(tog.Render, false) end
    end
    for _, b in ipairs(Blips) do
        b.frame.BackgroundColor3 = ACCENT
        b.stroke.Color = ACCENT
    end
end

-- ============================================================
-- FEATURE IMPLEMENTATIONS
-- ============================================================

-- -------------------- ESP PLAYER (OUTLINE) --------------------
local function StartPlayerESP()
    Genv.SHub.Toggle.PEspEnable = true
    local espConnection
    local espContainer = getSafeParent("Player")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("S_Highlight")
                if hl then hl:Destroy() end
            end
        end
    end
    local function GetPlayerStats(stats)
        if not stats then return ESP_DEFAULT end
        local isBeast, Captured, health = stats:FindFirstChild("IsBeast"), stats:FindFirstChild("Captured"), stats:FindFirstChild("Health")
        if not (isBeast and Captured and health) then return ESP_DEFAULT end
        return (isBeast.Value and ESP_BEAST) or (Captured.Value and ESP_CAPTURED) or (health.Value <= 0 and ESP_DEFAULT) or ESP_GREEN
    end
    local function updateESP()
        for _, u in pairs(espContainer:GetChildren()) do
            if u:IsA('BillboardGui') and not u.Adornee then u:Destroy() end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local head = char:FindFirstChild("Head")
                local root = findroot_or(char)
                if not (head and root and LPR) then continue end
                local stats = player:FindFirstChild("TempPlayerStatsModule")
                local PlayerStats = GetPlayerStats(stats)
                local espGui = espContainer:FindFirstChild(player.Name)
                if not espGui then
                    createBillboard(head, player.Name, espContainer)
                    espGui = espContainer:FindFirstChild(player.Name)
                else
                    espGui.Adornee = head
                    espGui.StudsOffset = Vector3.new(0, ESP_LABEL_HEIGHT, 0)
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    if label then
                        local distance_Lp = Sround((root.Position - LPR.Position).Magnitude, 1)
                        label.Text = string.format("Name: %s • Studs: %d", player.Name, distance_Lp)
                        label.TextColor3 = PlayerStats
                    end
                    if arrow then arrow.TextColor3 = PlayerStats end
                end
                applyOutlineHighlight(char, PlayerStats)
            end
        end
    end
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        if not Genv.SHub.Toggle.PEspEnable then
            clearESP(); espConnection:Disconnect(); espConnection = nil; return
        end
        pcall(updateESP)
    end)
    Genv.SHub.TaskSignal.PESPConn = espConnection
end

local function StopPlayerESP()
    Genv.SHub.Toggle.PEspEnable = false
    if Genv.SHub.TaskSignal.PESPConn then
        Genv.SHub.TaskSignal.PESPConn:Disconnect()
        Genv.SHub.TaskSignal.PESPConn = nil
    end
    local espContainer = getSafeParent("Player")
    for _, c in pairs(espContainer:GetChildren()) do c:Destroy() end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = player.Character:FindFirstChild("S_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

-- -------------------- ESP COMPUTER (OUTLINE) --------------------
local function StartComputerESP()
    Genv.SHub.Toggle.PCCEspEnable = true
    local espConnection
    local espContainer = getSafeParent("Computer")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
    end
    local function updateESP()
        local map = GetCurrentMap()
        if not map then clearESP() return end
        for _, o in pairs(map:GetChildren()) do
            if o.Name == "ComputerTable" then
                local part = o:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local screen = o:FindFirstChild("Screen")
                local espColor = (screen and screen:IsA("BasePart")) and screen.Color or ESP_COMPUTER
                local id = GetESPId(o)
                local espGui = espContainer:FindFirstChild(id)
                if not espGui then
                    createBillboard(o, id, espContainer)
                    espGui = espContainer:FindFirstChild(id)
                end
                if espGui and LPR then
                    espGui.Adornee = o
                    espGui.StudsOffset = Vector3.new(0, ESP_LABEL_HEIGHT, 0)
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("Computer • %d Studs", dist)
                        label.TextColor3 = espColor
                    end
                    if arrow then arrow.TextColor3 = espColor end
                end
                applyOutlineHighlight(o, espColor)
            end
        end
    end
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        if not Genv.SHub.Toggle.PCCEspEnable then
            clearESP(); espConnection:Disconnect(); espConnection = nil; return
        end
        pcall(updateESP)
    end)
    Genv.SHub.TaskSignal.PCCConn = espConnection
end

local function StopComputerESP()
    Genv.SHub.Toggle.PCCEspEnable = false
    if Genv.SHub.TaskSignal.PCCConn then
        Genv.SHub.TaskSignal.PCCConn:Disconnect()
        Genv.SHub.TaskSignal.PCCConn = nil
    end
    local espContainer = getSafeParent("Computer")
    for _, c in pairs(espContainer:GetChildren()) do c:Destroy() end
    clearHighlightsOnMap({ ComputerTable = true })
end

-- -------------------- ESP FREEZEPOD (OUTLINE) --------------------
local function StartFreezePodESP()
    Genv.SHub.Toggle.FreezePodEspEnable = true
    local espConnection
    local color = ESP_FREEZEPOD
    local espContainer = getSafeParent("FreezePod")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
    end
    local function updateESP()
        local map = GetCurrentMap()
        if not map then clearESP() return end
        for _, o in pairs(map:GetChildren()) do
            if o.Name == "FreezePod" then
                local part = o:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local id = GetESPId(o)
                local espGui = espContainer:FindFirstChild(id)
                if not espGui then
                    createBillboard(o, id, espContainer)
                    espGui = espContainer:FindFirstChild(id)
                end
                if espGui and LPR then
                    espGui.Adornee = o
                    espGui.StudsOffset = Vector3.new(0, ESP_LABEL_HEIGHT, 0)
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("FreezePod • %d Studs", dist)
                        label.TextColor3 = color
                    end
                    if arrow then arrow.TextColor3 = color end
                end
                applyOutlineHighlight(o, color)
            end
        end
    end
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        if not Genv.SHub.Toggle.FreezePodEspEnable then
            clearESP(); espConnection:Disconnect(); espConnection = nil; return
        end
        pcall(updateESP)
    end)
    Genv.SHub.TaskSignal.FPConn = espConnection
end

local function StopFreezePodESP()
    Genv.SHub.Toggle.FreezePodEspEnable = false
    if Genv.SHub.TaskSignal.FPConn then
        Genv.SHub.TaskSignal.FPConn:Disconnect()
        Genv.SHub.TaskSignal.FPConn = nil
    end
    local espContainer = getSafeParent("FreezePod")
    for _, c in pairs(espContainer:GetChildren()) do c:Destroy() end
    clearHighlightsOnMap({ FreezePod = true })
end

-- -------------------- ESP EXITDOOR (OUTLINE) --------------------
local function StartExitDoorESP()
    Genv.SHub.Toggle.ExitDoorEspEnable = true
    local espConnection
    local espContainer = getSafeParent("ExitDoor")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
    end
    local function updateESP()
        local map = GetCurrentMap()
        if not map then clearESP() return end
        for _, o in pairs(map:GetChildren()) do
            if o.Name == "ExitDoor" then
                local part = o:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local light = o:FindFirstChild("Light")
                local color = (light and light:IsA("BasePart")) and light.Color or ESP_EXITDOOR
                local id = GetESPId(o)
                local espGui = espContainer:FindFirstChild(id)
                if not espGui then
                    createBillboard(o, id, espContainer)
                    espGui = espContainer:FindFirstChild(id)
                end
                if espGui and LPR then
                    espGui.Adornee = o
                    espGui.StudsOffset = Vector3.new(0, ESP_LABEL_HEIGHT, 0)
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("ExitDoor • %d Studs", dist)
                        label.TextColor3 = color
                    end
                    if arrow then arrow.TextColor3 = color end
                end
                applyOutlineHighlight(o, color)
            end
        end
    end
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(function()
        if not Genv.SHub.Toggle.ExitDoorEspEnable then
            clearESP(); espConnection:Disconnect(); espConnection = nil; return
        end
        pcall(updateESP)
    end)
    Genv.SHub.TaskSignal.EDConn = espConnection
end

local function StopExitDoorESP()
    Genv.SHub.Toggle.ExitDoorEspEnable = false
    if Genv.SHub.TaskSignal.EDConn then
        Genv.SHub.TaskSignal.EDConn:Disconnect()
        Genv.SHub.TaskSignal.EDConn = nil
    end
    local espContainer = getSafeParent("ExitDoor")
    for _, c in pairs(espContainer:GetChildren()) do c:Destroy() end
    clearHighlightsOnMap({ ExitDoor = true })
end

-- -------------------- HIT AURA --------------------
local function StartHitAura()
    Genv.SHub.Toggle.HitAura = true
    task.spawn(function()
        while Genv.SHub.Toggle.HitAura and task.wait(0.15) do
            local LHammerEvent = LPC and LPC:FindFirstChild("HammerEvent", true)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not IsWhilstPlayer(p.Name) then
                    local Stats = p:FindFirstChild("TempPlayerStatsModule")
                    if not Stats then continue end
                    local PisRagdoll, PisCaptured = Stats:FindFirstChild("Ragdoll"), Stats:FindFirstChild("Captured")
                    if not (PisRagdoll and PisCaptured) then continue end
                    if not (PisRagdoll.Value or PisCaptured.Value) then
                        local root = findroot_or(p.Character)
                        if root and LPC and LPR and LHammerEvent then
                            if (root.Position - LPR.Position).Magnitude <= (Genv.SHub.HitAuraRange or 10) then
                                LHammerEvent:FireServer("HammerHit", root)
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function StopHitAura() Genv.SHub.Toggle.HitAura = false end

-- -------------------- AUTO TIE --------------------
local function StartAutoTie()
    Genv.SHub.Toggle.AutoTie = true
    task.spawn(function()
        while Genv.SHub.Toggle.AutoTie and task.wait(0.15) do
            local LHammerEvent = LPC and LPC:FindFirstChild("HammerEvent", true)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not IsWhilstPlayer(p.Name) then
                    local Stats = p:FindFirstChild("TempPlayerStatsModule")
                    if not Stats then continue end
                    local PisRagdoll, PisCaptured = Stats:FindFirstChild("Ragdoll"), Stats:FindFirstChild("Captured")
                    if not (PisRagdoll and PisCaptured) then continue end
                    if (PisRagdoll.Value and not PisCaptured.Value) then
                        local root = findroot_or(p.Character)
                        if root and LPC and LPR and LHammerEvent then
                            if (root.Position - LPR.Position).Magnitude <= (Genv.SHub.TiePlayerRange or 5) then
                                local pos = (typeof(root.Position) == "Vector3" and root.Position) or Vector3.zero
                                LHammerEvent:FireServer("HammerTieUp", root, pos)
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function StopAutoTie() Genv.SHub.Toggle.AutoTie = false end

-- -------------------- NO COMPUTER HACK FAILED (RELIABLE) --------------------
-- Fires continuously while toggled. Re-resolves RemoteEvent if it goes stale,
-- and sends the "success" result on every heartbeat tick.
local function StartNoTaskFailed()
    Genv.SHub.Toggle.Antitaskfailed = true
    if Genv.SHub.TaskSignal.NoTaskFailedConn then
        Genv.SHub.TaskSignal.NoTaskFailedConn:Disconnect()
        Genv.SHub.TaskSignal.NoTaskFailedConn = nil
    end
    Genv.SHub.TaskSignal.NoTaskFailedConn = RunService.Heartbeat:Connect(function()
        if not Genv.SHub.Toggle.Antitaskfailed then
            if Genv.SHub.TaskSignal.NoTaskFailedConn then
                Genv.SHub.TaskSignal.NoTaskFailedConn:Disconnect()
                Genv.SHub.TaskSignal.NoTaskFailedConn = nil
            end
            return
        end
        local re = RemoteEvent
        if not re or not re.Parent then
            re = ReplicatedStorage:FindFirstChild("RemoteEvent")
            RemoteEvent = re
        end
        if re then
            pcall(function()
                re:FireServer("SetPlayerMinigameResult", true)
            end)
        end
    end)
    -- Also fire once immediately so there's no delay
    if RemoteEvent then
        pcall(function() RemoteEvent:FireServer("SetPlayerMinigameResult", true) end)
    end
end
local function StopNoTaskFailed()
    Genv.SHub.Toggle.Antitaskfailed = false
    if Genv.SHub.TaskSignal.NoTaskFailedConn then
        Genv.SHub.TaskSignal.NoTaskFailedConn:Disconnect()
        Genv.SHub.TaskSignal.NoTaskFailedConn = nil
    end
end

-- -------------------- AUTO HELP CAPTURED (SILENT) --------------------
local function StartAutoHelpSilent()
    Genv.SHub.Toggle.AutoHelpCP_silent = true
    task.spawn(function()
        local Stats_LP = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
        local Local_H = Stats_LP and Stats_LP:FindFirstChild("Health")
        local Local_R = Stats_LP and Stats_LP:FindFirstChild("Ragdoll")
        local Local_C = Stats_LP and Stats_LP:FindFirstChild("Captured")
        while Genv.SHub.Toggle.AutoHelpCP_silent and task.wait(0.05) do
            if not (Local_H and Local_R and Local_C) then continue end
            if Local_H.Value <= 0 or Local_R.Value or Local_C.Value then continue end
            local map = GetCurrentMap()
            if not map then continue end
            for _, p in pairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local Stats = p:FindFirstChild("TempPlayerStatsModule")
                local Captured = Stats and Stats:FindFirstChild("Captured")
                if not (Captured and Captured:IsA("BoolValue") and Captured.Value) then continue end
                local event
                for _, o in pairs(map:GetChildren()) do
                    if o.Name ~= "FreezePod" then continue end
                    local PodTrigger = o:FindFirstChild("PodTrigger", true)
                    if PodTrigger then
                        local CapturedTorso = PodTrigger:FindFirstChild("CapturedTorso")
                        local Event = PodTrigger:FindFirstChild("Event")
                        if CapturedTorso and Event and CapturedTorso:IsA("ObjectValue") and CapturedTorso.Value then
                            event = Event; break
                        end
                    end
                end
                if not event then continue end
                repeat
                    task.wait(0.05)
                    RemoteEvent:FireServer("Input", "Trigger", true, event)
                    RemoteEvent:FireServer("Input", "Action", true)
                until not (Captured.Value and Genv.SHub.Toggle.AutoHelpCP_silent)
                break
            end
        end
    end)
end
local function StopAutoHelpSilent() Genv.SHub.Toggle.AutoHelpCP_silent = false end

-- -------------------- AUTO HELP CAPTURED (TP) --------------------
local function StartAutoHelpTP()
    Genv.SHub.Toggle.AutoHelpCP = true
    task.spawn(function()
        local function DoHelpCFrame(root)
            return root.CFrame * CFrame.new(0, -4.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        end
        local oldCFrame, helping = nil, false
        local Stats_LP = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
        local Local_H = Stats_LP and Stats_LP:FindFirstChild("Health")
        local Local_R = Stats_LP and Stats_LP:FindFirstChild("Ragdoll")
        local Local_C = Stats_LP and Stats_LP:FindFirstChild("Captured")
        while Genv.SHub.Toggle.AutoHelpCP and task.wait(0.05) do
            if not (LPC and LPR and Local_H and Local_R and Local_C) then continue end
            if Local_H.Value <= 0 or Local_R.Value or Local_C.Value then continue end
            for _, p in pairs(Players:GetPlayers()) do
                if p == LocalPlayer or helping then continue end
                local Stats = p:FindFirstChild("TempPlayerStatsModule")
                local Captured = Stats and Stats:FindFirstChild("Captured")
                if not (Captured and Captured:IsA("BoolValue") and Captured.Value) then continue end
                local root = findroot_or(p.Character)
                if not root then continue end
                helping = true
                oldCFrame = oldCFrame or LPR.CFrame
                LPR.CFrame = DoHelpCFrame(root)
                repeat
                    task.wait(0.05)
                    LPR.CFrame = DoHelpCFrame(root)
                    RemoteEvent:FireServer("Input", "Action", true)
                until not (Captured.Value and Genv.SHub.Toggle.AutoHelpCP) or (Local_R.Value or Local_C.Value or Local_H.Value <= 0)
                if oldCFrame and LPC then LPC:PivotTo(oldCFrame) end
                oldCFrame, helping = nil, false
                break
            end
        end
    end)
end
local function StopAutoHelpTP() Genv.SHub.Toggle.AutoHelpCP = false end

-- -------------------- ANTI FLING --------------------
local function StartAntiFling()
    Genv.SHub.Toggle.AntiFling = true
    task.spawn(function()
        while Genv.SHub.Toggle.AntiFling and RunService.Heartbeat:Wait() do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, c in pairs(p.Character:GetDescendants()) do
                        if c:IsA("BasePart") and c.CanCollide then
                            c.CanCollide = false
                        end
                    end
                end
            end
        end
    end)
end
local function StopAntiFling() Genv.SHub.Toggle.AntiFling = false end

-- -------------------- TOUCH FLING --------------------
local function StartTouchFling()
    Genv.SHub.Toggle.TouchFling = true
    task.spawn(function()
        local vel, movel = nil, 0.05
        while Genv.SHub.Toggle.TouchFling do
            RunService.Heartbeat:Wait()
            if not LPR then continue end
            vel = LPR.Velocity; LPR.Velocity = (vel * 9e8) + Vector3.new(0, 9e8, 0)
            RunService.RenderStepped:Wait()
            if LPC and LPR then LPR.Velocity = vel end
            RunService.Stepped:Wait()
            if LPC and LPR then
                LPR.Velocity, movel = vel + Vector3.new(0, movel, 0), movel * -1
            end
        end
    end)
end
local function StopTouchFling() Genv.SHub.Toggle.TouchFling = false end

-- -------------------- NOCLIP CAMERA --------------------
local function StartNoclipCam()
    Genv.SHub.Toggle.CamNoclip = true
    task.spawn(function()
        while Genv.SHub.Toggle.CamNoclip and task.wait(.1) do
            if LocalPlayer.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            end
        end
        if not Genv.SHub.Toggle.CamNoclip then
            LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end
    end)
end
local function StopNoclipCam() Genv.SHub.Toggle.CamNoclip = false end

-- -------------------- CAMERA MODE --------------------
local function StartCamMode()
    Genv.SHub.Toggle.CamDMode = true
    task.spawn(function()
        while Genv.SHub.Toggle.CamDMode and task.wait(.1) do
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
            end
        end
    end)
end
local function StopCamMode() Genv.SHub.Toggle.CamDMode = false end

-- -------------------- CAMERA ZOOM --------------------
local function StartCamZoom()
    Genv.SHub.Toggle.CamMaxZoom = true
    task.spawn(function()
        while Genv.SHub.Toggle.CamMaxZoom and task.wait(.1) do
            if LocalPlayer.CameraMaxZoomDistance ~= (Genv.SHub.CamMaxZoomDis or 100) then
                LocalPlayer.CameraMaxZoomDistance = Genv.SHub.CamMaxZoomDis or 100
            end
        end
    end)
end
local function StopCamZoom() Genv.SHub.Toggle.CamMaxZoom = false end

-- -------------------- FULLBRIGHT --------------------
local FB_Original
local function StartFullbright()
    Genv.SHub.Toggle.FullBright = true
    FB_Original = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient
    }
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then FB_Original.AtmosphereDensity = atm.Density end
    task.spawn(function()
        while Genv.SHub.Toggle.FullBright and task.wait() do
            local a = Lighting:FindFirstChildOfClass("Atmosphere")
            if a then a.Density = 0 end
            Lighting.Brightness = 1.5
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            Lighting.Ambient = Color3.fromRGB(80, 80, 80)
        end
    end)
end
local function StopFullbright()
    Genv.SHub.Toggle.FullBright = false
    task.wait(0.25)
    if not FB_Original then return end
    for prop, value in pairs(FB_Original) do
        if prop == "AtmosphereDensity" then
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then atm.Density = value end
        else
            Lighting[prop] = value
        end
    end
end

-- -------------------- INFINITE JUMP --------------------
local function StartInfJump() Genv.SHub.Toggle.InfJump = true end
local function StopInfJump() Genv.SHub.Toggle.InfJump = false end

Genv.SHub.TaskSignal.InfJump = UserInputService.JumpRequest:Connect(function()
    if Genv.SHub.Toggle.InfJump and LPH then
        LPH:ChangeState("Jumping")
    end
end)

-- -------------------- NOCLIP --------------------
local function StartNoclip()
    Genv.SHub.Toggle.Noclip = true
    task.spawn(function()
        while Genv.SHub.Toggle.Noclip and RunService.Heartbeat:Wait() do
            if not LPC then continue end
            for _, c in pairs(LPC:GetDescendants()) do
                if c:IsA("BasePart") and c.CanCollide then
                    c.CanCollide = false
                end
            end
        end
    end)
end
local function StopNoclip()
    Genv.SHub.Toggle.Noclip = false
    if LPC then
        for _, c in pairs(LPC:GetDescendants()) do
            if c:IsA("BasePart") then c.CanCollide = true end
        end
    end
end

-- -------------------- NOTIFY ADMIN --------------------
local function StartNotifyAdmin()
    Genv.SHub.Notify.NotifyAdmin = true
    task.spawn(function()
        local creId, cretype = game.CreatorId, game.CreatorType
        while Genv.SHub.Notify.NotifyAdmin and task.wait(2.5) do
            for _, p in pairs(Players:GetPlayers()) do
                if cretype == Enum.CreatorType.Group then
                    pcall(function()
                        local rank = p:GetRankInGroup(creId)
                        if rank >= 2 then
                            local role = p:GetRoleInGroup(creId)
                            print(`[Blackout] {p.Name} joined! Role: {role} | Rank: {rank}`)
                        end
                    end)
                elseif cretype == Enum.CreatorType.User and p.UserId == creId then
                    print(`[Blackout] {p.Name} (Game Owner) joined!`)
                end
            end
        end
    end)
end
local function StopNotifyAdmin() Genv.SHub.Notify.NotifyAdmin = false end

-- -------------------- ANTI AFK --------------------
local anti_afkconnection
local function StartAntiAfk()
    Genv.SHub.Toggle.Antiafk = true
    if not anti_afkconnection then
        anti_afkconnection = LocalPlayer.Idled:Connect(function()
            local VU = game:GetService("VirtualUser")
            VU:CaptureController()
            VU:ClickButton2(Vector2.zero)
        end)
    end
end
local function StopAntiAfk()
    Genv.SHub.Toggle.Antiafk = false
    if anti_afkconnection then anti_afkconnection:Disconnect(); anti_afkconnection = nil end
end

-- -------------------- ANTI RAGDOLL --------------------
local function StartAntiRagdoll()
    Genv.SHub.Toggle.AntiRagdoll = true
    task.spawn(function()
        while Genv.SHub.Toggle.AntiRagdoll and task.wait() do
            pcall(function()
                if not LPH then return end
                LPH:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                LPH:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                LPH:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                local Stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
                local Ragdoll = Stats and Stats:FindFirstChild("Ragdoll")
                if Ragdoll and Ragdoll:IsA("BoolValue") and Ragdoll.Value then
                    repeat task.wait()
                        LPH:ChangeState(6); LPH:ChangeState(8)
                    until LPH:GetState() == Enum.HumanoidStateType.Running
                end
            end)
        end
    end)
end
local function StopAntiRagdoll() Genv.SHub.Toggle.AntiRagdoll = false end

-- ============================================================
-- BUILD TABS & FEATURES
-- ============================================================
local Tabs = {}
Tabs.Visuals  = CreateTab("Visuals", 1)
Tabs.Utility  = CreateTab("Utility", 2)
Tabs.Combat   = CreateTab("Combat", 3)
Tabs.Beast    = CreateTab("Beast", 4)
Tabs.Theme    = CreateTab("Theme", 5)

-- ---- VISUALS ----
AddSection(Tabs.Visuals, "esp")
AddToggle(Tabs.Visuals, "ESP Player", false, function(s)
    if s then StartPlayerESP() else StopPlayerESP() end
end)
AddToggle(Tabs.Visuals, "ESP Computer", false, function(s)
    if s then StartComputerESP() else StopComputerESP() end
end)
AddToggle(Tabs.Visuals, "ESP FreezePod", false, function(s)
    if s then StartFreezePodESP() else StopFreezePodESP() end
end)
AddToggle(Tabs.Visuals, "ESP ExitDoor", false, function(s)
    if s then StartExitDoorESP() else StopExitDoorESP() end
end)
AddSection(Tabs.Visuals, "lighting")
AddToggle(Tabs.Visuals, "Fullbright", false, function(s)
    if s then StartFullbright() else StopFullbright() end
end)

-- ---- UTILITY ----
AddSection(Tabs.Utility, "camera")
AddToggle(Tabs.Utility, "Noclip Camera", false, function(s)
    if s then StartNoclipCam() else StopNoclipCam() end
end)
AddToggle(Tabs.Utility, "Default Camera Mode", false, function(s)
    if s then StartCamMode() else StopCamMode() end
end)
AddInput(Tabs.Utility, "Camera Max Zoom", "set max zoom", true, function(v)
    Genv.SHub.CamMaxZoomDis = v
    LocalPlayer.CameraMaxZoomDistance = v
end)
AddToggle(Tabs.Utility, "Auto Zoom Distance", false, function(s)
    if s then StartCamZoom() else StopCamZoom() end
end)

AddSection(Tabs.Utility, "movement")
AddToggle(Tabs.Utility, "Noclip", false, function(s)
    if s then StartNoclip() else StopNoclip() end
end)
AddToggle(Tabs.Utility, "Infinite Jump", false, function(s)
    if s then StartInfJump() else StopInfJump() end
end)

AddSection(Tabs.Utility, "anti")
AddToggle(Tabs.Utility, "Anti Fling", false, function(s)
    if s then StartAntiFling() else StopAntiFling() end
end)
AddToggle(Tabs.Utility, "Touch Fling", false, function(s)
    if s then StartTouchFling() else StopTouchFling() end
end)
AddToggle(Tabs.Utility, "Anti AFK", false, function(s)
    if s then StartAntiAfk() else StopAntiAfk() end
end)
AddToggle(Tabs.Utility, "Anti Ragdoll", false, function(s)
    if s then StartAntiRagdoll() else StopAntiRagdoll() end
end)

-- ---- COMBAT ----
AddSection(Tabs.Combat, "game")
AddToggle(Tabs.Combat, "No Hack Failed", false, function(s)
    if s then StartNoTaskFailed() else StopNoTaskFailed() end
end)
AddToggle(Tabs.Combat, "Auto Help (Silent)", false, function(s)
    if s then StartAutoHelpSilent() else StopAutoHelpSilent() end
end)
AddToggle(Tabs.Combat, "Auto Help (TP)", false, function(s)
    if s then StartAutoHelpTP() else StopAutoHelpTP() end
end)

AddSection(Tabs.Combat, "notify")
AddToggle(Tabs.Combat, "Notify Admin Join", true, function(s)
    if s then StartNotifyAdmin() else StopNotifyAdmin() end
end)

-- ---- BEAST ----
AddSection(Tabs.Beast, "beast")
AddToggle(Tabs.Beast, "Hit Aura", false, function(s)
    if s then StartHitAura() else StopHitAura() end
end)
AddSlider(Tabs.Beast, "Hit Aura Range", 5, 15, 10, function(v)
    Genv.SHub.HitAuraRange = v
end)
AddToggle(Tabs.Beast, "Auto Tie", false, function(s)
    if s then StartAutoTie() else StopAutoTie() end
end)
AddSlider(Tabs.Beast, "Auto Tie Range", 5, 100, 5, function(v)
    Genv.SHub.TiePlayerRange = v
end)

-- ---- THEME ----
AddSection(Tabs.Theme, "theme color")
AddDropdown(Tabs.Theme, "Theme Color", "PURPLE",
    {"RED", "PURPLE", "BLUE", "GREEN", "ORANGE", "PINK", "WHITE"}, function(v)
    ApplyTheme(v)
end)

Tabs.Visuals.SetActive(true)
CurrentTab = Tabs.Visuals

ApplyTheme("PURPLE")

-- ============================================================
-- ANIMATION LOOPS
-- ============================================================
task.spawn(function()
    while ScreenGui.Parent do
        Sweep.Rotation = (tick() * 180) % 360
        task.wait(0.016)
    end
end)

task.spawn(function()
    task.wait(0.5)
    while ScreenGui.Parent do
        SpawnPulse()
        task.wait(2)
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        local sweepAngle = (tick() * 180) % 360
        for _, b in ipairs(Blips) do
            b.life = b.life + 0.016
            if b.life > b.maxLife then
                b.life = 0
                b.angle = math.random() * math.pi * 2
                b.radius = 60 + math.random() * 240
                b.maxLife = 1.5 + math.random()
            end
            local x = 0.5 + math.cos(b.angle) * (b.radius / 700)
            local y = 0.5 + math.sin(b.angle) * (b.radius / 700)
            b.frame.Position = UDim2.new(x, 0, y, 0)
            local blipAngleDeg = math.deg(b.angle) % 360
            local diff = math.abs(((sweepAngle - blipAngleDeg + 180) % 360) - 180)
            local proximity = math.clamp(1 - diff / 90, 0, 1)
            local lifeFade = math.sin((b.life / b.maxLife) * math.pi)
            local alpha = proximity * lifeFade
            b.frame.BackgroundTransparency = 1 - alpha
            b.stroke.Transparency = 1 - (alpha * 0.7)
        end
        task.wait(0.016)
    end
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- KEYBIND
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- ============================================================
-- START DEFAULT NOTIFY ADMIN
-- ============================================================
StartNotifyAdmin()

print("[Blackout] Radar UI updated. Purple default. RightShift toggles GUI.")
