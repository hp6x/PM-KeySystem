------------------------------------------------------------------------
-- SETTINGS & SERVICES
------------------------------------------------------------------------
local SAVE_LOGINS = true
local SEND_TO_WEBHOOK = true

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local URL = "https://raw.githubusercontent.com/hp6x/PM-Script/refs/heads/main/Pirate%20Mayhem%20Script%20(encrypted).lua"
local DISCLINK = "https://discord.gg/DRrTwTvHzW"
local KEY_URL = "https://raw.githubusercontent.com/hp6x/hp6xtempkeys/refs/heads/main/keys.txt"
local WEBHOOK = "https://discord.com/api/webhooks/1428202195668566086/f-vJipUhw6i3FooKUJgkvx0iD7KLR6tnXn7QakihG8gWjQGPzwmBPVPdrlvZF9Q4d9a_"
local WEBSITE = "cia.gov" 

local KEY_FILE = "hp6xkeysavepm.txt"


------------------------------------------------------------------------
-- DISCORD WEBHOOK FUNCTION
------------------------------------------------------------------------
local function sendDiscordWebhook(success, key, reason)
    if not SEND_TO_WEBHOOK then return end
    
    pcall(function()
        local username = player.Name
        local userId = player.UserId
        local color = success and 65280 or 16711680
        local status = success and "" or ""
    
        pcall(function()
            local data = HttpService:JSONDecode(response)
        end)
        
        local embed = {
            ["embeds"] = {{
                ["title"] = status,
                ["color"] = color,
                ["fields"] = {
                    {
                        ["name"] = "Username",
                        ["value"] = username,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "User ID",
                        ["value"] = tostring(userId),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Key",
                        ["value"] = "||" .. key .. "||",
                        ["inline"] = false
                    }
                }
            }}
        }
        
        local jsonData = HttpService:JSONEncode(embed)
        
        request({
            Url = WEBHOOK,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
end


------------------------------------------------------------------------
-- VALIDATE KEY
------------------------------------------------------------------------
local function validateKeyWithServer(k)
    if not k or k == "" then return false, "Empty key" end
    local ok, res = pcall(function() return game:HttpGet(KEY_URL) end)
    if not ok or not res then return false, "Server error" end
    for line in res:gmatch("[^\r\n]+") do
        if line == k then return true end
    end
    return false, "Invalid key"
end


------------------------------------------------------------------------
-- HANDLE KEY (SIMPLIFIED - NO USER TRACKING)
------------------------------------------------------------------------
local function handleKey(inputKey)
    -- Simply validate the key - no user restriction
    local valid, msg = validateKeyWithServer(inputKey)
    if not valid then
        sendDiscordWebhook(false, inputKey, msg)
        return false, msg
    end

    -- Key is valid, grant access
    sendDiscordWebhook(true, inputKey, nil)
    if SAVE_LOGINS then pcall(function() writefile(KEY_FILE, inputKey) end) end
    pcall(function() loadstring(game:HttpGet(URL))() end)
    return true
end


------------------------------------------------------------------------
-- AUTO-LOGIN
------------------------------------------------------------------------
if SAVE_LOGINS and isfile and isfile(KEY_FILE) then
    local saved = readfile(KEY_FILE)
    if saved and saved ~= "" then
        local ok = validateKeyWithServer(saved)
        if ok then
            pcall(function() loadstring(game:HttpGet(URL))() end)
            return
        end
    end
end


------------------------------------------------------------------------
-- MODERN PROFESSIONAL GUI
------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyAuthUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 165)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -82)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

-- Subtle gradient overlay
local gradient = Instance.new("Frame")
gradient.Size = UDim2.new(1, 0, 1, 0)
gradient.BackgroundTransparency = 0.97
gradient.BorderSizePixel = 0
gradient.Parent = mainFrame
Instance.new("UICorner", gradient).CornerRadius = UDim.new(0, 14)
local gradientUI = Instance.new("UIGradient", gradient)
gradientUI.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 100, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 220))
}
gradientUI.Rotation = 135

-- Frame border
local frameBorder = Instance.new("UIStroke", mainFrame)
frameBorder.Color = Color3.fromRGB(45, 45, 55)
frameBorder.Thickness = 1
frameBorder.Transparency = 0.5

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 26)
title.Position = UDim2.new(0, 18, 0, 14)
title.BackgroundTransparency = 1
title.Text = "  hp6x Key System | Pirate Mayhem"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local xButton = Instance.new("TextButton")
xButton.Size = UDim2.new(0, 26, 0, 26)
xButton.Position = UDim2.new(1, -36, 0, 14)
xButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
xButton.Text = "×"
xButton.TextColor3 = Color3.fromRGB(160, 160, 175)
xButton.Font = Enum.Font.GothamBold
xButton.TextSize = 18
xButton.Parent = mainFrame
Instance.new("UICorner", xButton).CornerRadius = UDim.new(0, 8)

local xBorder = Instance.new("UIStroke", xButton)
xBorder.Color = Color3.fromRGB(45, 45, 55)
xBorder.Thickness = 1
xBorder.Transparency = 0.6

xButton.MouseEnter:Connect(function()
    TweenService:Create(xButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(38, 38, 45)
    }):Play()
    TweenService:Create(xButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(220, 220, 230)
    }):Play()
    TweenService:Create(xBorder, TweenInfo.new(0.2), {
        Transparency = 0.3
    }):Play()
end)
xButton.MouseLeave:Connect(function()
    TweenService:Create(xButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    }):Play()
    TweenService:Create(xButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(160, 160, 175)
    }):Play()
    TweenService:Create(xBorder, TweenInfo.new(0.2), {
        Transparency = 0.6
    }):Play()
end)
xButton.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.3)
    screenGui:Destroy()
end)

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.6, 0, 0, 34)
keyInput.Position = UDim2.new(0, 18, 0, 58)
keyInput.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
keyInput.TextColor3 = Color3.fromRGB(200, 200, 215)
keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
keyInput.PlaceholderText = "Get Key From Discord!"
keyInput.Text = ""
keyInput.Font = Enum.Font.GothamMedium
keyInput.TextSize = 13
keyInput.ClearTextOnFocus = false
keyInput.Parent = mainFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new("UIStroke", keyInput)
inputStroke.Color = Color3.fromRGB(45, 45, 55)
inputStroke.Thickness = 1
inputStroke.Transparency = 0.6

keyInput.Focused:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.25), {
        Color = Color3.fromRGB(100, 100, 150),
        Transparency = 0.2
    }):Play()
    TweenService:Create(keyInput, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    }):Play()
end)

keyInput.FocusLost:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.25), {
        Color = Color3.fromRGB(45, 45, 55),
        Transparency = 0.6
    }):Play()
    TweenService:Create(keyInput, TweenInfo.new(0.25), {
        BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    }):Play()
end)

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0.3, 0, 0, 34)
submitButton.Position = UDim2.new(0.65, 0, 0, 58)
submitButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
submitButton.Text = "→"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 13
submitButton.TextColor3 = Color3.fromRGB(180, 180, 200)
submitButton.Parent = mainFrame
Instance.new("UICorner", submitButton).CornerRadius = UDim.new(0, 8)

local submitStroke = Instance.new("UIStroke", submitButton)
submitStroke.Color = Color3.fromRGB(45, 45, 55)
submitStroke.Thickness = 1
submitStroke.Transparency = 0.6

submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(38, 38, 45),
        Size = UDim2.new(0.3, 0, 0, 36)
    }):Play()
    TweenService:Create(submitStroke, TweenInfo.new(0.2), {
        Transparency = 0.3
    }):Play()
end)

submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 35),
        Size = UDim2.new(0.3, 0, 0, 34)
    }):Play()
    TweenService:Create(submitStroke, TweenInfo.new(0.2), {
        Transparency = 0.6
    }):Play()
end)

-- Discord Button
local discordButton = Instance.new("TextButton")
discordButton.Size = UDim2.new(0.43, 0, 0, 30)
discordButton.Position = UDim2.new(0.056, 0, 0, 108)
discordButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
discordButton.Text = "Discord"
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 12
discordButton.TextColor3 = Color3.fromRGB(140, 140, 160)
discordButton.Parent = mainFrame
Instance.new("UICorner", discordButton).CornerRadius = UDim.new(0, 8)

local discordStroke = Instance.new("UIStroke", discordButton)
discordStroke.Color = Color3.fromRGB(45, 45, 55)
discordStroke.Thickness = 1
discordStroke.Transparency = 0.6

discordButton.MouseEnter:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(38, 38, 45),
        Size = UDim2.new(0.43, 0, 0, 32)
    }):Play()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(180, 180, 200)
    }):Play()
    TweenService:Create(discordStroke, TweenInfo.new(0.2), {
        Transparency = 0.3
    }):Play()
end)

discordButton.MouseLeave:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 35),
        Size = UDim2.new(0.43, 0, 0, 30)
    }):Play()
    TweenService:Create(discordButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(140, 140, 160)
    }):Play()
    TweenService:Create(discordStroke, TweenInfo.new(0.2), {
        Transparency = 0.6
    }):Play()
end)

-- Website Button
local urlKeyButton = Instance.new("TextButton")
urlKeyButton.Size = UDim2.new(0.43, 0, 0, 30)
urlKeyButton.Position = UDim2.new(0.514, 0, 0, 108)
urlKeyButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
urlKeyButton.Text = "Website (down)"
urlKeyButton.Font = Enum.Font.GothamBold
urlKeyButton.TextSize = 12
urlKeyButton.TextColor3 = Color3.fromRGB(140, 140, 160)
urlKeyButton.Parent = mainFrame
Instance.new("UICorner", urlKeyButton).CornerRadius = UDim.new(0, 8)

local urlStroke = Instance.new("UIStroke", urlKeyButton)
urlStroke.Color = Color3.fromRGB(45, 45, 55)
urlStroke.Thickness = 1
urlStroke.Transparency = 0.6

urlKeyButton.MouseEnter:Connect(function()
    TweenService:Create(urlKeyButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(38, 38, 45),
        Size = UDim2.new(0.43, 0, 0, 32)
    }):Play()
    TweenService:Create(urlKeyButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(180, 180, 200)
    }):Play()
    TweenService:Create(urlStroke, TweenInfo.new(0.2), {
        Transparency = 0.3
    }):Play()
end)

urlKeyButton.MouseLeave:Connect(function()
    TweenService:Create(urlKeyButton, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 35),
        Size = UDim2.new(0.43, 0, 0, 30)
    }):Play()
    TweenService:Create(urlKeyButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(140, 140, 160)
    }):Play()
    TweenService:Create(urlStroke, TweenInfo.new(0.2), {
        Transparency = 0.6
    }):Play()
end)

local feedback = Instance.new("TextLabel")
feedback.Size = UDim2.new(1, 0, 0, 20)
feedback.Position = UDim2.new(0, 0, 1, -26)
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.Font = Enum.Font.GothamMedium
feedback.TextSize = 11
feedback.TextColor3 = Color3.fromRGB(140, 140, 160)
feedback.TextTransparency = 1
feedback.Parent = mainFrame

local function showFeedback(text, color)
    feedback.Text = text
    feedback.TextColor3 = color
    TweenService:Create(feedback, TweenInfo.new(0.3), {
        TextTransparency = 0
    }):Play()
    task.delay(2.5, function()
        TweenService:Create(feedback, TweenInfo.new(0.4), {
            TextTransparency = 1
        }):Play()
    end)
end

------------------------------------------------------------------------
-- BUTTON LOGIC
------------------------------------------------------------------------
discordButton.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(DISCLINK) end)
    showFeedback("Discord link copied to clipboard", Color3.fromRGB(140, 180, 220))
end)

urlKeyButton.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(WEBSITE) end)
    showFeedback("Website link copied to clipboard", Color3.fromRGB(140, 180, 220))
end)

submitButton.MouseButton1Click:Connect(function()
    local inputKey = tostring(keyInput.Text or ""):gsub("%s+", "")
    if inputKey == "" then
        showFeedback("join discord server to get key!", Color3.fromRGB(220, 120, 120))
        return
    end

    local ok, msg = handleKey(inputKey)
    if ok then
        showFeedback("Access Granted! (saving login. .)", Color3.fromRGB(120, 200, 140))
        task.wait(0.6)
        TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.4)
        screenGui:Destroy()
    else
        showFeedback(msg or "Invalid key", Color3.fromRGB(220, 120, 120))
    end
end)

------------------------------------------------------------------------
-- DRAGGING
------------------------------------------------------------------------
local dragging, dragStart, startPos = false, nil, nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)