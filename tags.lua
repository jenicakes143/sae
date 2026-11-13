-- Jen Finder tag system (self-contained, loaded by the main loader)
local Players = game:GetService("Players")
local GENV    = (getgenv and getgenv()) or _G

local OWNER_USERID   = 3774632092
local OWNER_NAME     = "salmarando"
local DEVELOPER_NAME = "deftocean12234"

-- === EDIT THIS LIST TO ADD / REMOVE USERS ===
local USER_NAMES = {
    ["danthe943"]   = true,
    ["era_stealzz"] = true,
    ["aisyooof"]    = true,
    ["keoyeoks"]    = true,
    ["justfay122"]  = true,
    ["remote_0330"] = true,
    ["EldePlaysThisz"] = true,
    ["Dhruv_20103"] = true, 
}
-- ===========================================

local DEBUG_TAGS = false

local function norm(s) return (s or ""):lower() end
local function isUser(p)
    return USER_NAMES[norm(p.Name)] or USER_NAMES[norm(p.DisplayName)]
end

local function roleOf(p)
    if p.UserId == OWNER_USERID or norm(p.Name) == norm(OWNER_NAME) then return "owner" end
    if norm(p.Name) == norm(DEVELOPER_NAME) then return "dev" end
    if isUser(p) then return "user" end
    return nil
end

local function waitForHead(char, timeout)
    timeout = timeout or 10
    local head = char:FindFirstChild("Head")
    local waited = 0
    while (not head) and char.Parent and waited < timeout do
        task.wait(0.1); waited = waited + 0.1
        head = char:FindFirstChild("Head")
    end
    return head
end

local function makeTag(role)
    local text, color, strokeColor
    if role == "owner" then
        text, color, strokeColor = "[Owner] Jen Finder",
            Color3.fromRGB(255,215,0), Color3.fromRGB(200,140,0)
    elseif role == "dev" then
        text, color, strokeColor = "[Developer] Jen Finder",
            Color3.fromRGB(139,0,0), Color3.fromRGB(80,0,0)
    else
        text, color, strokeColor = "Jen Finder User",
            Color3.fromRGB(255,105,180), Color3.fromRGB(180,20,90)
    end

    local lbl = Instance.new("TextLabel")
    lbl.Name = "TagLabel"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 14
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = strokeColor
    stroke.Parent = lbl
    return lbl
end

local function drawTag(player)
    local role = roleOf(player)
    local char = player.Character
    local head = char and char:FindFirstChild("Head")

    if not role then
        if head then
            local e = head:FindFirstChild("JenFinderNameTag")
            if e then e:Destroy() end
        end
        return
    end
    if char and not head then head = waitForHead(char, 10) end
    if not head then return end
    if head:FindFirstChild("JenFinderNameTag") then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "JenFinderNameTag"
    bg.Size = UDim2.fromOffset(240, 32)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
    bg.MaxDistance = 500
    bg.ResetOnSpawn = false
    bg.Parent = head

    makeTag(role).Parent = bg
end

local function clearTag(player)
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        local t = head:FindFirstChild("JenFinderNameTag")
        if t then t:Destroy() end
    end
end

local function watchPlayer(player)
    player.CharacterAdded:Connect(function(char)
        task.defer(function()
            task.wait(0.25)
            drawTag(player)
            char.ChildAdded:Connect(function(c)
                if c.Name == "Head" then drawTag(player) end
            end)
        end)
    end)
    if player.Character then
        task.spawn(function() task.wait(0.1); drawTag(player) end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(clearTag)

task.spawn(function()
    while true do
        task.wait(3)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then drawTag(p) end
        end
    end
end)

GENV.JenFinderDebug = function()
    for _, p in ipairs(Players:GetPlayers()) do
        local head = p.Character and p.Character:FindFirstChild("Head")
        local tag  = head and head:FindFirstChild("JenFinderNameTag")
        print(string.format("%-22s | Role: %-6s | Tag: %s",
            p.Name, tostring(roleOf(p) or "none"), tostring(tag ~= nil)))
    end
end
