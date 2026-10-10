-- ============================================================
-- BLACKOUT GUI v2 | RED EDITION | TRACERY PORT
-- Re-skinned to Blackout triple-panel layout
-- ============================================================
wait(2)
if game.PlaceId ~= 893973440 then return end


local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local LocalPlayer        = Players.LocalPlayer

local RemoteEvent        = ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:WaitForChild("RemoteEvent", 5)

-- ============================================================
-- COLORS
-- ============================================================
local BG          = Color3.fromRGB(6, 6, 7)
local BG_ITEM     = Color3.fromRGB(13, 13, 15)
local BG_HOVER    = Color3.fromRGB(22, 14, 16)
local BORDER      = Color3.fromRGB(34, 20, 22)
local ACCENT      = Color3.fromRGB(230, 30, 45)
local ACCENT_DIM  = Color3.fromRGB(120, 15, 22)
local TEXT        = Color3.fromRGB(255, 255, 255)
local TEXT_DIM    = Color3.fromRGB(170, 170, 178)
local TEXT_ON     = Color3.fromRGB(255, 90, 100)

-- ============================================================
-- ROOT
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackoutTripleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- HELPERS (ported from Tracery)
-- ============================================================
local Genv = getgenv and getgenv() or _G
Genv.SHub = Genv.SHub or {}
Genv.SHub.Toggle = Genv.SHub.Toggle or {}
Genv.SHub.Notify = Genv.SHub.Notify or {}
Genv.SHub.WPlr = Genv.SHub.WPlr or {}

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
            if not (talk and can) then
                pcall(function() can = we.Torso end)
            end
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

local function GetPlayerList(lyname)
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        table.insert(list, lyname and p.Name or p)
    end
    return list
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
    local guiParent = GetHiddenGui()
    if not SName then SName = "nia = aura" end
    local fn = `SHub_ESP_{SName}`
    local folder = guiParent:FindFirstChild(fn)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = fn
        folder.Parent = guiParent
    end
    return folder
end

local function applyHighlight(part)
    local hl = part:FindFirstChild("S_Highlight")
    if hl then return hl end
    hl = Instance.new("Highlight")
    hl.Name = "S_Highlight"
    hl.Adornee = part
    hl.FillColor = Color3.new(0, 0, 0)
    hl.OutlineColor = Color3.new(0, 0, 0)
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.50
    hl.OutlineTransparency = 0.85
    hl.Parent = part
    return hl
end

local function createBillboard(part, IDorN, ESPContainer)
    local billboard = ESPContainer:FindFirstChild(IDorN)
    if billboard then billboard:Destroy() end
    billboard = Instance.new("BillboardGui")
    billboard.Name = IDorN
    billboard.Adornee = part
    billboard.Size = UDim2.new(5, 0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = ESPContainer
    local label = Instance.new("TextLabel")
    label.Name = "Text_Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextTransparency = 0.25
    label.TextStrokeTransparency = 0.25
    label.TextSize = 11
    label.Font = Enum.Font.FredokaOne
    label.TextColor3 = Color3.new(0, 0, 0)
    label.Text = "Loading..."
    label.Parent = billboard
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow_Label"
    arrow.Size = UDim2.new(1, 0, 0, 20)
    arrow.Position = UDim2.new(0.5, 0, 0, 1)
    arrow.AnchorPoint = Vector2.new(0.5, 1)
    arrow.BackgroundTransparency = 1
    arrow.TextTransparency = 0.25
    arrow.TextColor3 = Color3.new(1, 1, 1)
    arrow.TextStrokeTransparency = 0.25
    arrow.Font = Enum.Font.FredokaOne
    arrow.TextScaled = true
    arrow.Rotation = 180
    arrow.Text = "^"
    arrow.Parent = billboard
    return billboard, label, arrow
end

local function GetESPId(inst)
    return `ESP_{inst:GetDebugId()}`
end

local function GetCurrentMap()
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
Genv.SHub.TaskSignal = Genv.SHub.TaskSignal or {}
Genv.SHub.TaskSignal.LPCAdded = LocalPlayer.CharacterAdded:Connect(function(c)
    repeat RunService.Heartbeat:Wait()
        LPC, LPH, LPR = c, findroot_or(c, 0), findroot_or(c)
    until LPC and LPH and LPR
end)

local function IsWhilstPlayer(name)
    return Genv.SHub.WPlr[name]
end

-- ============================================================
-- LOADING SPLASH SCREEN
-- ============================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "BlackoutLoader"
LoadGui.ResetOnSpawn = false
LoadGui.IgnoreGuiInset = true
LoadGui.DisplayOrder = 999
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local LoadBG = Instance.new("Frame")
LoadBG.Size = UDim2.new(1, 0, 1, 0)
LoadBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadBG.BorderSizePixel = 0
LoadBG.BackgroundTransparency = 1
LoadBG.Parent = LoadGui

local LoadCenter = Instance.new("Frame")
LoadCenter.Size = UDim2.new(0, 400, 0, 160)
LoadCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadCenter.AnchorPoint = Vector2.new(0.5, 0.5)
LoadCenter.BackgroundTransparency = 1
LoadCenter.Parent = LoadBG

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1, 0, 0, 70)
LogoLbl.BackgroundTransparency = 1
LogoLbl.Text = ""
LogoLbl.Font = Enum.Font.Code
LogoLbl.TextSize = 48
LogoLbl.TextColor3 = ACCENT
LogoLbl.TextTransparency = 1
LogoLbl.TextStrokeTransparency = 1
LogoLbl.TextStrokeColor3 = Color3.fromRGB(255, 90, 100)
LogoLbl.Parent = LoadCenter

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, 0, 0, 20)
SubLbl.Position = UDim2.new(0, 0, 0, 76)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "LOADING // PLEASE WAIT"
SubLbl.Font = Enum.Font.Code
SubLbl.TextSize = 12
SubLbl.TextColor3 = ACCENT_DIM
SubLbl.TextTransparency = 1
SubLbl.Parent = LoadCenter

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0, 320, 0, 4)
BarBg.Position = UDim2.new(0.5, -160, 0, 112)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
BarBg.BorderSizePixel = 0
BarBg.BackgroundTransparency = 1
BarBg.Parent = LoadCenter
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = ACCENT
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local PctLbl = Instance.new("TextLabel")
PctLbl.Size = UDim2.new(1, 0, 0, 14)
PctLbl.Position = UDim2.new(0, 0, 0, 122)
PctLbl.BackgroundTransparency = 1
PctLbl.Text = "0%"
PctLbl.Font = Enum.Font.Code
PctLbl.TextSize = 10
PctLbl.TextColor3 = TEXT_DIM
PctLbl.TextTransparency = 1
PctLbl.Parent = LoadCenter

local function RunLoadingSequence()
    TweenService:Create(LoadBG, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
    task.wait(0.1)
    local text = "BLACKOUT"
    LogoLbl.Text = ""
    TweenService:Create(LogoLbl, TweenInfo.new(0.3), {TextTransparency = 0, TextStrokeTransparency = 0.4}):Play()
    TweenService:Create(SubLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(BarBg,  TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(PctLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    for i = 1, #text do LogoLbl.Text = string.sub(text, 1, i); task.wait(0.04) end
    for _ = 1, 3 do
        LogoLbl.TextColor3 = Color3.fromRGB(255, 200, 200); task.wait(0.05)
        LogoLbl.TextColor3 = ACCENT; task.wait(0.05)
    end
    local steps = 40
    for i = 0, steps do
        local pct = i / steps
        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        PctLbl.Text = math.floor(pct * 100) .. "%"
        task.wait(1.0 / steps)
    end
    task.wait(0.15)
    local fi = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LogoLbl, fi, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TweenService:Create(SubLbl, fi, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, fi, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PctLbl, fi, {TextTransparency = 1}):Play()
    TweenService:Create(BarFill, fi, {BackgroundTransparency = 1}):Play()
    local bgT = TweenService:Create(LoadBG, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    bgT:Play(); bgT.Completed:Wait(); task.wait(0.05)
    LoadGui:Destroy()
end

-- ============================================================
-- WINDOW BUILDER
-- ============================================================
local AllWindows = {}

local function CreateWindow(title, posX, posY)
    local Win = {}
    local WIDTH = 230

    local Main = Instance.new("Frame")
    Main.Name = title
    Main.Size = UDim2.new(0, WIDTH, 0, 0)
    Main.Position = UDim2.new(0, posX, 0, posY)
    Main.BackgroundColor3 = BG
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = BORDER; MainStroke.Thickness = 1; MainStroke.Parent = Main

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 1)
    Glow.BackgroundColor3 = ACCENT; Glow.BorderSizePixel = 0; Glow.Parent = Main
    local GlowGrad = Instance.new("UIGradient")
    GlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    GlowGrad.Parent = Glow

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = BG; Header.Text = ""
    Header.AutoButtonColor = false; Header.BorderSizePixel = 0; Header.Parent = Main

    local TitleDot = Instance.new("Frame")
    TitleDot.Size = UDim2.new(0, 5, 0, 5)
    TitleDot.Position = UDim2.new(0, 11, 0.5, -2)
    TitleDot.BackgroundColor3 = ACCENT; TitleDot.BorderSizePixel = 0; TitleDot.Parent = Header
    Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 22, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title; TitleLbl.TextColor3 = TEXT
    TitleLbl.Font = Enum.Font.Code; TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.Parent = Header

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    MinimizeBtn.BackgroundColor3 = BG_ITEM
    MinimizeBtn.Text = "–"; MinimizeBtn.TextColor3 = TEXT_DIM
    MinimizeBtn.Font = Enum.Font.Code; MinimizeBtn.TextSize = 14
    MinimizeBtn.AutoButtonColor = false; MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = Header
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 3)

    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = ACCENT}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = TEXT_DIM}):Play()
    end)

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -16, 0, 1)
    Divider.Position = UDim2.new(0, 8, 0, 30)
    Divider.BackgroundColor3 = BORDER; Divider.BorderSizePixel = 0; Divider.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "Scroll"
    Scroll.Size = UDim2.new(1, 0, 0, 0)
    Scroll.Position = UDim2.new(0, 0, 0, 31)
    Scroll.BackgroundTransparency = 1; Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3; Scroll.ScrollBarImageColor3 = ACCENT_DIM
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 6)
    Pad.PaddingBottom = UDim.new(0, 8)
    Pad.PaddingLeft = UDim.new(0, 7)
    Pad.PaddingRight = UDim.new(0, 7)
    Pad.Parent = Scroll

    local function CreateSection(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 0, 16)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = "── " .. string.upper(text)
        Lbl.TextColor3 = ACCENT_DIM
        Lbl.Font = Enum.Font.Code; Lbl.TextSize = 9
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Scroll
        return Lbl
    end

    local function CreateToggle(name, defaultState, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM; Btn.Text = ""
        Btn.AutoButtonColor = false; Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER; Stroke.Thickness = 1; Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER; Bar.BorderSizePixel = 0; Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name); Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code; Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Btn

        local StatusTxt = Instance.new("TextLabel")
        StatusTxt.Size = UDim2.new(0, 30, 1, 0)
        StatusTxt.Position = UDim2.new(1, -36, 0, 0)
        StatusTxt.BackgroundTransparency = 1
        StatusTxt.Text = "OFF"; StatusTxt.TextColor3 = TEXT_DIM
        StatusTxt.Font = Enum.Font.Code; StatusTxt.TextSize = 10
        StatusTxt.TextXAlignment = Enum.TextXAlignment.Right; StatusTxt.Parent = Btn

        local state = defaultState or false
        local function Render(animate)
            local tColor  = state and ACCENT or BORDER
            local tText   = state and TEXT_ON or TEXT
            local tStatus = state and "ON" or "OFF"
            local tStatC  = state and ACCENT or TEXT_DIM
            local tBg     = state and Color3.fromRGB(20, 10, 12) or BG_ITEM
            if animate then
                TweenService:Create(Bar, TweenInfo.new(0.15), {BackgroundColor3 = tColor}):Play()
                TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = tColor}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = tText}):Play()
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = tBg}):Play()
            else
                Bar.BackgroundColor3 = tColor; Stroke.Color = tColor
                Label.TextColor3 = tText; Btn.BackgroundColor3 = tBg
            end
            StatusTxt.Text = tStatus; StatusTxt.TextColor3 = tStatC
        end
        Render(false)

        Btn.MouseEnter:Connect(function()
            if not state then TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play() end
        end)
        Btn.MouseLeave:Connect(function()
            if not state then TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play() end
        end)
        Btn.MouseButton1Click:Connect(function()
            state = not state
            Render(true)
            if callback then
                local ok, err = pcall(callback, state)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)
        return Btn
    end

    local function CreateButton(name, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM; Btn.Text = ""
        Btn.AutoButtonColor = false; Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER; Stroke.Thickness = 1; Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER; Bar.BorderSizePixel = 0; Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name); Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code; Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = ACCENT}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = ACCENT}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = BORDER}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = BORDER}):Play()
        end)
        Btn.MouseButton1Click:Connect(function()
            Bar.BackgroundColor3 = TEXT_ON; Label.TextColor3 = TEXT_ON
            task.delay(0.15, function()
                Bar.BackgroundColor3 = ACCENT; Label.TextColor3 = TEXT
            end)
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)
        return Btn
    end

    local function CreateSlider(name, minV, maxV, default, callback)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 34)
        Container.BackgroundColor3 = BG_ITEM; Container.BorderSizePixel = 0
        Container.Parent = Scroll
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 3)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER; Stroke.Thickness = 1; Stroke.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -16, 0, 14)
        Label.Position = UDim2.new(0, 8, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name); Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code; Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Container

        local ValLbl = Instance.new("TextLabel")
        ValLbl.Size = UDim2.new(0, 40, 0, 14)
        ValLbl.Position = UDim2.new(1, -48, 0, 2)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = tostring(default); ValLbl.TextColor3 = TEXT_ON
        ValLbl.Font = Enum.Font.Code; ValLbl.TextSize = 10
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.Parent = Container

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -16, 0, 4)
        Track.Position = UDim2.new(0, 8, 1, -10)
        Track.BackgroundColor3 = BORDER; Track.BorderSizePixel = 0
        Track.Parent = Container
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
        Fill.BackgroundColor3 = ACCENT; Fill.BorderSizePixel = 0
        Fill.Parent = Track
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

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
        return Container
    end

    local function CreateInput(name, placeholder, numeric, callback)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 34)
        Container.BackgroundColor3 = BG_ITEM; Container.BorderSizePixel = 0
        Container.Parent = Scroll
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 3)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER; Stroke.Thickness = 1; Stroke.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -16, 0, 12)
        Label.Position = UDim2.new(0, 8, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name); Label.TextColor3 = TEXT_DIM
        Label.Font = Enum.Font.Code; Label.TextSize = 9
        Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -16, 0, 16)
        Box.Position = UDim2.new(0, 8, 0, 15)
        Box.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.PlaceholderText = placeholder
        Box.TextColor3 = TEXT
        Box.PlaceholderColor3 = TEXT_DIM
        Box.Font = Enum.Font.Code; Box.TextSize = 10
        Box.ClearTextOnFocus = false
        Box.Parent = Container
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 2)

        Box.FocusLost:Connect(function()
            local v = Box.Text
            if callback then pcall(callback, numeric and ToNumV(v) or v) end
        end)
        return Container
    end

    local function CreateDropdown(name, values, multi, callback)
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 24)
        Container.BackgroundColor3 = BG_ITEM; Container.BorderSizePixel = 0
        Container.ClipsDescendants = true
        Container.Parent = Scroll
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 3)
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER; Stroke.Thickness = 1; Stroke.Parent = Container

        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 24)
        Header.BackgroundTransparency = 1; Header.Text = ""
        Header.AutoButtonColor = false; Header.Parent = Container

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -30, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name); Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code; Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Header

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(1, -22, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"; Arrow.TextColor3 = TEXT_DIM
        Arrow.Font = Enum.Font.Code; Arrow.TextSize = 9
        Arrow.Parent = Header

        local Options = Instance.new("Frame")
        Options.Size = UDim2.new(1, -10, 0, 0)
        Options.Position = UDim2.new(0, 5, 0, 25)
        Options.BackgroundTransparency = 1
        Options.Parent = Container
        local OL = Instance.new("UIListLayout")
        OL.Padding = UDim.new(0, 1); OL.Parent = Options

        local open = false
        local selected = {}
        local optionButtons = {}

        local function Refresh()
            for _, b in pairs(optionButtons) do b:Destroy() end
            optionButtons = {}
            for _, v in ipairs(values) do
                local o = Instance.new("TextButton")
                o.Size = UDim2.new(1, 0, 0, 18)
                o.BackgroundColor3 = selected[v] and Color3.fromRGB(30, 12, 14) or BG_ITEM
                o.Text = ""
                o.AutoButtonColor = false; o.BorderSizePixel = 0
                o.Parent = Options
                Instance.new("UICorner", o).CornerRadius = UDim.new(0, 2)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -8, 1, 0)
                l.Position = UDim2.new(0, 6, 0, 0)
                l.BackgroundTransparency = 1
                l.Text = v
                l.TextColor3 = selected[v] and TEXT_ON or TEXT_DIM
                l.Font = Enum.Font.Code; l.TextSize = 9
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = o
                o.MouseButton1Click:Connect(function()
                    if multi then
                        selected[v] = not selected[v] or nil
                    else
                        selected = { [v] = true }
                    end
                    Refresh()
                    if callback then pcall(callback, selected) end
                end)
                table.insert(optionButtons, o)
            end
            local h = #values * 19
            Options.Size = UDim2.new(1, -10, 0, h)
            Container.Size = UDim2.new(1, 0, 0, 24 + (open and h + 2 or 0))
        end

        Header.MouseButton1Click:Connect(function()
            open = not open
            Arrow.Text = open and "▲" or "▼"
            Refresh()
        end)
        Refresh()
        Container.Size = UDim2.new(1, 0, 0, 24)
        return Container
    end

    do
        local dragging, startPos, startInput
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; startInput = input.Position; startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - startInput
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end

    local minimized = false
    local MAX_CONTENT_HEIGHT = 340
    local function UpdateSize()
        local targetHeight
        if minimized then targetHeight = 31
        else
            local contentH = Layout.AbsoluteContentSize.Y + 16
            if contentH > MAX_CONTENT_HEIGHT then contentH = MAX_CONTENT_HEIGHT end
            targetHeight = 31 + contentH
            Scroll.Size = UDim2.new(1, 0, 0, contentH)
            Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
        end
        TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, WIDTH, 0, targetHeight)}):Play()
    end
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MinimizeBtn.Text = minimized and "+" or "–"
        UpdateSize()
    end)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not minimized then UpdateSize() end
    end)
    task.defer(function() task.wait(0.05); UpdateSize() end)

    Win.CreateSection = CreateSection
    Win.CreateToggle = CreateToggle
    Win.CreateButton = CreateButton
    Win.CreateSlider = CreateSlider
    Win.CreateInput = CreateInput
    Win.CreateDropdown = CreateDropdown
    Win.Main = Main
    table.insert(AllWindows, Main)
    return Win
end

-- ============================================================
-- FEATURE IMPLEMENTATIONS
-- ============================================================

-- -------------------- ESP PLAYER --------------------
local function StartPlayerESP()
    Genv.SHub.Toggle.PEspEnable = true
    local espConnection
    local roleColors = {
        Beast = Color3.fromRGB(255, 0, 0),
        Survival_Captured = Color3.fromRGB(0, 0, 255),
        Survival = Color3.fromRGB(0, 255, 0),
        Default = Color3.fromRGB(200, 200, 200)
    }
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
        if not stats then return roleColors.Default end
        local isBeast, Captured, health = stats:FindFirstChild("IsBeast"), stats:FindFirstChild("Captured"), stats:FindFirstChild("Health")
        if not (isBeast and Captured and health) then return roleColors.Default end
        return (isBeast.Value and roleColors.Beast) or (Captured.Value and roleColors.Survival_Captured) or (health.Value <= 0 and roleColors.Default) or roleColors.Survival
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
                    local label, Arrow_Label = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    if label then
                        local distance_Lp = Sround((root.Position - LPR.Position).Magnitude, 1)
                        label.Text = string.format("Name: %s • Studs: %d", player.Name, distance_Lp)
                        label.TextColor3 = PlayerStats
                    end
                    if Arrow_Label then Arrow_Label.TextColor3 = PlayerStats end
                end
                local hl = char:FindFirstChild("S_Highlight")
                if not hl then applyHighlight(char); hl = char:FindFirstChild("S_Highlight") end
                if hl then hl.FillColor = PlayerStats end
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
end

-- -------------------- ESP COMPUTER --------------------
local function StartComputerESP()
    Genv.SHub.Toggle.PCCEspEnable = true
    local espConnection
    local espContainer = getSafeParent("Computer")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
        local Map = GetCurrentMap()
        if not Map then return end
        for _, o in pairs(Map:GetChildren()) do
            if o.Name == "ComputerTable" then
                local hl = o:FindFirstChild("S_Highlight", true)
                if hl then hl:Destroy() end
            end
        end
    end
    local function updateESP()
        local map = GetCurrentMap()
        if not map then clearESP() return end
        for _, o in pairs(map:GetChildren()) do
            if o.Name == "ComputerTable" then
                local part = o:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local screen = o:FindFirstChild("Screen")
                local espColor = (screen and screen:IsA("BasePart")) and screen.Color or Color3.fromRGB(255, 255, 0)
                local id = GetESPId(o)
                local espGui = espContainer:FindFirstChild(id)
                if not espGui then
                    createBillboard(o, id, espContainer)
                    espGui = espContainer:FindFirstChild(id)
                end
                if espGui and LPR then
                    espGui.Adornee = o
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("Computer • %d Studs", dist)
                        label.TextColor3 = espColor
                    end
                    if arrow then arrow.TextColor3 = espColor end
                end
                local hl = o:FindFirstChild("S_Highlight")
                if not hl then applyHighlight(o); hl = o:FindFirstChild("S_Highlight") end
                if hl then hl.FillColor = espColor end
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
end

-- -------------------- ESP FREEZEPOD --------------------
local function StartFreezePodESP()
    Genv.SHub.Toggle.FreezePodEspEnable = true
    local espConnection
    local color = Color3.fromRGB(0, 0, 245)
    local espContainer = getSafeParent("FreezePod")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
        local Map = GetCurrentMap()
        if not Map then return end
        for _, o in pairs(Map:GetChildren()) do
            if o.Name == "FreezePod" then
                local hl = o:FindFirstChild("S_Highlight", true)
                if hl then hl:Destroy() end
            end
        end
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
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("FreezePod • %d Studs", dist)
                        label.TextColor3 = color
                    end
                    if arrow then arrow.TextColor3 = color end
                end
                local hl = o:FindFirstChild("S_Highlight")
                if not hl then applyHighlight(o); hl = o:FindFirstChild("S_Highlight") end
                if hl then hl.FillColor = color end
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
end

-- -------------------- ESP EXITDOOR --------------------
local function StartExitDoorESP()
    Genv.SHub.Toggle.ExitDoorEspEnable = true
    local espConnection
    local espContainer = getSafeParent("ExitDoor")
    local function clearESP()
        for _, child in pairs(espContainer:GetChildren()) do child:Destroy() end
        local Map = GetCurrentMap()
        if not Map then return end
        for _, o in pairs(Map:GetChildren()) do
            if o.Name == "ExitDoor" then
                local hl = o:FindFirstChild("S_Highlight", true)
                if hl then hl:Destroy() end
            end
        end
    end
    local function updateESP()
        local map = GetCurrentMap()
        if not map then clearESP() return end
        for _, o in pairs(map:GetChildren()) do
            if o.Name == "ExitDoor" then
                local part = o:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local light = o:FindFirstChild("Light")
                local color = (light and light:IsA("BasePart")) and light.Color or Color3.fromRGB(255, 255, 0)
                local id = GetESPId(o)
                local espGui = espContainer:FindFirstChild(id)
                if not espGui then
                    createBillboard(o, id, espContainer)
                    espGui = espContainer:FindFirstChild(id)
                end
                if espGui and LPR then
                    espGui.Adornee = o
                    local label, arrow = espGui:FindFirstChild("Text_Label"), espGui:FindFirstChild("Arrow_Label")
                    local dist = Sround((part.Position - LPR.Position).Magnitude, 1)
                    if label then
                        label.Text = string.format("ExitDoor • %d Studs", dist)
                        label.TextColor3 = color
                    end
                    if arrow then arrow.TextColor3 = color end
                end
                local hl = o:FindFirstChild("S_Highlight")
                if not hl then applyHighlight(o); hl = o:FindFirstChild("S_Highlight") end
                if hl then hl.FillColor = color end
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

-- -------------------- NO COMPUTER HACK FAILED --------------------
local function StartNoTaskFailed()
    Genv.SHub.Toggle.Antitaskfailed = true
    task.spawn(function()
        while Genv.SHub.Toggle.Antitaskfailed and task.wait(0.5) do
            if RemoteEvent then RemoteEvent:FireServer("SetPlayerMinigameResult", true) end
        end
    end)
end
local function StopNoTaskFailed() Genv.SHub.Toggle.Antitaskfailed = false end

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
        LPH:ChangeState "Jumping"
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
-- RUN LOADER, THEN BUILD PANELS
-- ============================================================
RunLoadingSequence()

-- ============================================================
-- PANEL 1 — VISUALS (left)
-- ============================================================
local MainPanel = CreateWindow("BLACKOUT // VISUALS", 20, 20)

MainPanel.CreateSection("esp")
MainPanel.CreateToggle("ESP Player", false, function(s)
    if s then StartPlayerESP() else StopPlayerESP() end
end)
MainPanel.CreateToggle("ESP Computer", false, function(s)
    if s then StartComputerESP() else StopComputerESP() end
end)
MainPanel.CreateToggle("ESP FreezePod", false, function(s)
    if s then StartFreezePodESP() else StopFreezePodESP() end
end)
MainPanel.CreateToggle("ESP ExitDoor", false, function(s)
    if s then StartExitDoorESP() else StopExitDoorESP() end
end)

MainPanel.CreateSection("beast")
MainPanel.CreateToggle("Hit Aura", false, function(s)
    if s then StartHitAura() else StopHitAura() end
end)
MainPanel.CreateSlider("Hit Aura Range", 5, 15, 10, function(v)
    Genv.SHub.HitAuraRange = v
end)
MainPanel.CreateToggle("Auto Tie", false, function(s)
    if s then StartAutoTie() else StopAutoTie() end
end)
MainPanel.CreateSlider("Auto Tie Range", 5, 100, 5, function(v)
    Genv.SHub.TiePlayerRange = v
end)

-- ============================================================
-- PANEL 2 — UTILITY (middle)
-- ============================================================
local UtilityPanel = CreateWindow("BLACKOUT // UTILITY", 260, 20)

UtilityPanel.CreateSection("camera")
UtilityPanel.CreateToggle("Noclip Camera", false, function(s)
    if s then StartNoclipCam() else StopNoclipCam() end
end)
UtilityPanel.CreateToggle("Default Camera Mode", false, function(s)
    if s then StartCamMode() else StopCamMode() end
end)
UtilityPanel.CreateInput("Camera Max Zoom", "set max zoom", true, function(v)
    Genv.SHub.CamMaxZoomDis = v
    LocalPlayer.CameraMaxZoomDistance = v
end)
UtilityPanel.CreateToggle("Auto Zoom Distance", false, function(s)
    if s then StartCamZoom() else StopCamZoom() end
end)

UtilityPanel.CreateSection("lighting")
UtilityPanel.CreateToggle("Fullbright", false, function(s)
    if s then StartFullbright() else StopFullbright() end
end)

UtilityPanel.CreateSection("movement")
UtilityPanel.CreateToggle("Noclip", false, function(s)
    if s then StartNoclip() else StopNoclip() end
end)
UtilityPanel.CreateToggle("Infinite Jump", false, function(s)
    if s then StartInfJump() else StopInfJump() end
end)

UtilityPanel.CreateSection("anti")
UtilityPanel.CreateToggle("Anti Fling", false, function(s)
    if s then StartAntiFling() else StopAntiFling() end
end)
UtilityPanel.CreateToggle("Touch Fling", false, function(s)
    if s then StartTouchFling() else StopTouchFling() end
end)
UtilityPanel.CreateToggle("Anti AFK", false, function(s)
    if s then StartAntiAfk() else StopAntiAfk() end
end)
UtilityPanel.CreateToggle("Anti Ragdoll", false, function(s)
    if s then StartAntiRagdoll() else StopAntiRagdoll() end
end)

-- ============================================================
-- PANEL 3 — COMBAT (right)
-- ============================================================
local CombatPanel = CreateWindow("BLACKOUT // COMBAT", 500, 20)

CombatPanel.CreateSection("game")
CombatPanel.CreateToggle("No Hack Failed", false, function(s)
    if s then StartNoTaskFailed() else StopNoTaskFailed() end
end)
CombatPanel.CreateToggle("Auto Help (Silent)", false, function(s)
    if s then StartAutoHelpSilent() else StopAutoHelpSilent() end
end)
CombatPanel.CreateToggle("Auto Help (TP)", false, function(s)
    if s then StartAutoHelpTP() else StopAutoHelpTP() end
end)

CombatPanel.CreateSection("notify")
CombatPanel.CreateToggle("Notify Admin Join", true, function(s)
    if s then StartNotifyAdmin() else StopNotifyAdmin() end
end)
CombatPanel.CreateButton("Refresh Game Status", function()
    local isActive = find_instance(ReplicatedStorage, "IsGameActive")
    local map = GetCurrentMap()
    print(`[Blackout] GameActive: {isActive and isActive.Value and "Yes" or "No"} | Map: {tostring(map)}`)
end)

-- ============================================================
-- OPEN BY DEFAULT
-- ============================================================
ScreenGui.Enabled = true

-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("[Blackout] Tracery port loaded. RightShift = toggle GUI")
