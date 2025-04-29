-- Modern Tabbed UI Script
-- Phantom Hub Premium with sleek, minimalist design

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Create global table for connections if it doesn't exist
if not _G.PhantomHubConnections then
    _G.PhantomHubConnections = {}
end

-- Color scheme (dark theme with blue accents)
local COLORS = {
    BACKGROUND = Color3.fromRGB(13, 13, 13),        -- Very dark gray (almost black)
    BACKGROUND_SECONDARY = Color3.fromRGB(20, 20, 30), -- Slightly lighter dark blue-gray
    HEADER = Color3.fromRGB(10, 10, 15),            -- Very dark header
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),   -- White
    TEXT_SECONDARY = Color3.fromRGB(180, 180, 180), -- Light gray
    ACCENT = Color3.fromRGB(65, 105, 225),          -- Royal blue
    ACCENT_DARK = Color3.fromRGB(45, 75, 180),      -- Darker blue
    TOGGLE_ON = Color3.fromRGB(65, 105, 225),       -- Royal blue
    TOGGLE_OFF = Color3.fromRGB(60, 60, 70),        -- Dark gray
    TAB_ACTIVE = Color3.fromRGB(25, 25, 35),        -- Active tab background
    TAB_INACTIVE = Color3.fromRGB(15, 15, 25)       -- Inactive tab background
}

-- Animation settings
local ANIMATION = {
    DURATION = 0.15,                                -- Duration of animations in seconds (faster)
    EASING_STYLE = Enum.EasingStyle.Quint,         -- Smooth easing style
    EASING_DIRECTION = Enum.EasingDirection.Out    -- Easing direction
}

-- Check if the device is mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

-- Function to create a custom notification
local function createNotification(title, message, duration)
    duration = duration or 3
   
    -- Create notification GUI
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "PhantomNotification"
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.ResetOnSpawn = false
   
    -- Try to use CoreGui if possible
    pcall(function()
        notificationGui.Parent = game:GetService("CoreGui")
    end)
   
    -- Fallback to PlayerGui if CoreGui fails
    if not notificationGui.Parent then
        notificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
   
    -- Create notification frame
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.Size = UDim2.new(0, 250, 0, 60)
    notificationFrame.Position = UDim2.new(0.5, -125, 0, -70)
    notificationFrame.BackgroundColor3 = COLORS.BACKGROUND
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = notificationGui
   
    -- Add rounded corners
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 4)
    notificationCorner.Parent = notificationFrame
   
    -- Add a thin border
    local border = Instance.new("UIStroke")
    border.Color = COLORS.ACCENT
    border.Thickness = 1
    border.Parent = notificationFrame
   
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notificationFrame
   
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 25)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 12
    messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
    messageLabel.Text = message
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = notificationFrame
   
    -- Animate the notification sliding in
    local slideInTween = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -125, 0, 20)}
    )
   
    slideInTween:Play()
   
    -- Wait and then slide out
    task.delay(duration, function()
        local slideOutTween = TweenService:Create(
            notificationFrame,
            TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -125, 0, -70)}
        )
       
        slideOutTween.Completed:Connect(function()
            notificationGui:Destroy()
        end)
       
        slideOutTween:Play()
    end)
   
    return notificationGui
end

-- Create a toggle switch
-- Parameters:
--   parent: The parent frame to put the toggle in
--   text: The label text for the toggle
--   default: Boolean for default state (true = on, false = off)
--   callback: Function that runs when toggle changes state, receives boolean parameter
local function createToggle(parent, text, default, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = text .. "Container"
    toggleContainer.Size = UDim2.new(1, 0, 0, 40)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = parent
   
    -- Toggle text
    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "Text"
    toggleText.Size = UDim2.new(1, -60, 1, 0)
    toggleText.Position = UDim2.new(0, 10, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Font = Enum.Font.Gotham
    toggleText.TextSize = 14
    toggleText.TextColor3 = COLORS.TEXT_PRIMARY
    toggleText.Text = text
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleContainer
   
    -- Toggle background
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "Background"
    toggleBackground.Size = UDim2.new(0, 40, 0, 20)
    toggleBackground.Position = UDim2.new(1, -50, 0.5, 0)
    toggleBackground.AnchorPoint = Vector2.new(0, 0.5)
    toggleBackground.BackgroundColor3 = default and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
   
    -- Add rounded corners to toggle background
    local toggleBackgroundCorner = Instance.new("UICorner")
    toggleBackgroundCorner.CornerRadius = UDim.new(1, 0)
    toggleBackgroundCorner.Parent = toggleBackground
   
    -- Toggle knob
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BackgroundColor3 = COLORS.TEXT_PRIMARY
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBackground
   
    -- Add rounded corners to toggle knob
    local toggleKnobCorner = Instance.new("UICorner")
    toggleKnobCorner.CornerRadius = UDim.new(1, 0)
    toggleKnobCorner.Parent = toggleKnob
   
    -- Toggle state
    local enabled = default or false
   
    -- Make the entire container clickable
    toggleContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
           
            -- Animate the toggle
            local knobPosition = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            local backgroundColor = enabled and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF
           
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = knobPosition
            }):Play()
           
            TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
                BackgroundColor3 = backgroundColor
            }):Play()
           
            if callback then
                callback(enabled)
            end
        end
    end)
   
    -- Return the container and a function to get the current state
    return toggleContainer, function() return enabled end
end

-- Create a dropdown selector
-- Parameters:
--   parent: The parent frame to put the dropdown in
--   text: The label text for the dropdown
--   options: Table of strings for dropdown options
--   default: Default selected option
--   callback: Function that runs when selection changes, receives string parameter
local function createDropdown(parent, text, options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = text .. "Container"
    dropdownContainer.Size = UDim2.new(1, 0, 0, 40)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = parent
   
    -- Dropdown text
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "Text"
    dropdownText.Size = UDim2.new(0.5, -10, 1, 0)
    dropdownText.Position = UDim2.new(0, 10, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Font = Enum.Font.Gotham
    dropdownText.TextSize = 14
    dropdownText.TextColor3 = COLORS.TEXT_PRIMARY
    dropdownText.Text = text
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdownContainer
   
    -- Dropdown button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "Button"
    dropdownButton.Size = UDim2.new(0.5, -10, 0, 30)
    dropdownButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    dropdownButton.AnchorPoint = Vector2.new(0, 0.5)
    dropdownButton.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 12
    dropdownButton.TextColor3 = COLORS.TEXT_PRIMARY
    dropdownButton.Text = default or options[1] or "Select"
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdownContainer
   
    -- Add padding to the text
    local textPadding = Instance.new("UIPadding")
    textPadding.PaddingLeft = UDim.new(0, 10)
    textPadding.Parent = dropdownButton
   
    -- Add rounded corners to dropdown button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = dropdownButton
   
    -- Dropdown arrow
    local dropdownArrow = Instance.new("TextLabel")
    dropdownArrow.Name = "Arrow"
    dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
    dropdownArrow.Position = UDim2.new(1, -25, 0.5, 0)
    dropdownArrow.AnchorPoint = Vector2.new(0, 0.5)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Font = Enum.Font.GothamBold
    dropdownArrow.TextSize = 14
    dropdownArrow.TextColor3 = COLORS.TEXT_SECONDARY
    dropdownArrow.Text = "▼"
    dropdownArrow.Parent = dropdownButton
   
    -- Dropdown menu
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Name = "Menu"
    dropdownMenu.Size = UDim2.new(0.5, -10, 0, #options * 30)
    dropdownMenu.Position = UDim2.new(0.5, 0, 1, 5)
    dropdownMenu.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 10
    dropdownMenu.Parent = dropdownContainer
   
    -- Add rounded corners to dropdown menu
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 4)
    menuCorner.Parent = dropdownMenu
   
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option .. "Option"
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        optionButton.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
        optionButton.BackgroundTransparency = 0.5
        optionButton.BorderSizePixel = 0
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 12
        optionButton.TextColor3 = COLORS.TEXT_PRIMARY
        optionButton.Text = option
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.ZIndex = 11
        optionButton.AutoButtonColor = false
        optionButton.Parent = dropdownMenu
       
        -- Add padding to the text
        local optionPadding = Instance.new("UIPadding")
        optionPadding.PaddingLeft = UDim.new(0, 10)
        optionPadding.Parent = optionButton
       
        -- Option hover effect
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0
            }):Play()
        end)
       
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
       
        -- Option click
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option
            dropdownMenu.Visible = false
           
            if callback then
                callback(option)
            end
        end)
    end
   
    -- Toggle dropdown menu visibility
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownMenu.Visible = not dropdownMenu.Visible
        dropdownArrow.Text = dropdownMenu.Visible and "▲" or "▼"
    end)
   
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local guiObjects = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            local coreGuiObjects = {}
           
            pcall(function()
                coreGuiObjects = game:GetService("CoreGui"):GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            end)
           
            local clickedOnDropdown = false
           
            for _, object in ipairs(guiObjects) do
                if object:IsDescendantOf(dropdownContainer) then
                    clickedOnDropdown = true
                    break
                end
            end
           
            for _, object in ipairs(coreGuiObjects) do
                if object:IsDescendantOf(dropdownContainer) then
                    clickedOnDropdown = true
                    break
                end
            end
           
            if not clickedOnDropdown and dropdownMenu.Visible then
                dropdownMenu.Visible = false
                dropdownArrow.Text = "▼"
            end
        end
    end)
   
    -- Button hover effect
    dropdownButton.MouseEnter:Connect(function()
        TweenService:Create(dropdownButton, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        }):Play()
    end)
   
    dropdownButton.MouseLeave:Connect(function()
        TweenService:Create(dropdownButton, TweenInfo.new(0.1), {
            BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
        }):Play()
    end)
   
    return dropdownContainer
end

-- Create a slider
-- Parameters:
--   parent: The parent frame to put the slider in
--   text: The label text for the slider
--   min: Minimum value
--   max: Maximum value
--   default: Default value
--   callback: Function that runs when slider value changes, receives number parameter
local function createSlider(parent, text, min, max, default, callback)
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = text .. "Container"
    sliderContainer.Size = UDim2.new(1, 0, 0, 40)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = parent
   
    -- Slider text and value
    local sliderText = Instance.new("TextLabel")
    sliderText.Name = "Text"
    sliderText.Size = UDim2.new(0.5, -10, 1, 0)
    sliderText.Position = UDim2.new(0, 10, 0, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Font = Enum.Font.Gotham
    sliderText.TextSize = 14
    sliderText.TextColor3 = COLORS.TEXT_PRIMARY
    sliderText.Text = text
    sliderText.TextXAlignment = Enum.TextXAlignment.Left
    sliderText.Parent = sliderContainer
   
    -- Value display
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Name = "Value"
    valueDisplay.Size = UDim2.new(0, 30, 1, 0)
    valueDisplay.Position = UDim2.new(0.5, -40, 0, 0)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Font = Enum.Font.GothamBold
    valueDisplay.TextSize = 14
    valueDisplay.TextColor3 = COLORS.TEXT_PRIMARY
    valueDisplay.Text = tostring(default or min)
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Parent = sliderContainer
   
    -- Slider background
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "Background"
    sliderBackground.Size = UDim2.new(0.5, -50, 0, 6)
    sliderBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
    sliderBackground.AnchorPoint = Vector2.new(0, 0.5)
    sliderBackground.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderContainer
   
    -- Add rounded corners to slider background
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(1, 0)
    backgroundCorner.Parent = sliderBackground
   
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    local defaultValue = default or min
    local fillPercent = (defaultValue - min) / (max - min)
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
   
    -- Add rounded corners to slider fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
   
    -- Slider knob
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Name = "Knob"
    sliderKnob.Size = UDim2.new(0, 14, 0, 14)
    sliderKnob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundColor3 = COLORS.TEXT_PRIMARY
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBackground
   
    -- Add rounded corners to slider knob
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
   
    -- Slider functionality
    local dragging = false
    local value = defaultValue or min
   
    local function updateSlider(input)
        local sliderPos = sliderBackground.AbsolutePosition.X
        local sliderWidth = sliderBackground.AbsoluteSize.X
        local mousePos = input.Position.X
       
        -- Calculate the percentage based on mouse position
        local percent = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
       
        -- Calculate the value based on percentage
        value = math.floor(min + (max - min) * percent)
        value = math.clamp(value, min, max)
       
        -- Update the UI
        valueDisplay.Text = tostring(value)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
       
        -- Call the callback
        if callback then
            callback(value)
        end
    end
   
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
   
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
   
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
   
    return sliderContainer, function() return value end
end

-- Create a button
-- Parameters:
--   parent: The parent frame to put the button in
--   text: The button text
--   callback: Function that runs when button is clicked
local function createButton(parent, text, callback)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = text .. "Container"
    buttonContainer.Size = UDim2.new(1, 0, 0, 40)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = parent
   
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = COLORS.TEXT_PRIMARY
    button.Text = text
    button.AutoButtonColor = false
    button.Parent = buttonContainer
   
    -- Add rounded corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
   
    -- Button hover and click effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        }):Play()
    end)
   
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
        }):Play()
    end)
   
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = COLORS.ACCENT_DARK
        }):Play()
    end)
   
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        }):Play()
    end)
   
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
   
    return buttonContainer
end

-- Create a script execution button
-- Parameters:
--   parent: The parent frame to put the button in
--   text: The button text
--   scriptCode: The Lua code to execute when clicked (empty by default)
--   visible: Whether the button is initially visible
local function createScriptButton(parent, text, scriptCode, visible)
    local scriptCode = scriptCode or ""
    local visible = visible ~= nil and visible or true
   
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = text .. "Container"
    buttonContainer.Size = UDim2.new(1, 0, 0, 40)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Visible = visible
    buttonContainer.Parent = parent
   
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = COLORS.TEXT_PRIMARY
    button.Text = text
    button.AutoButtonColor = false
    button.Parent = buttonContainer
   
    -- Add rounded corners
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
   
    -- Button hover and click effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        }):Play()
    end)
   
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
        }):Play()
    end)
   
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = COLORS.ACCENT_DARK
        }):Play()
    end)
   
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        }):Play()
    end)
   
    button.MouseButton1Click:Connect(function()
        -- Execute the script
        if scriptCode and scriptCode ~= "" then
            local success, err = pcall(function()
                loadstring(scriptCode)()
            end)
           
            if success then
                createNotification("Script Executed", text .. " executed successfully", 2)
            else
                createNotification("Execution Error", "Error: " .. tostring(err), 3)
            end
        else
            createNotification("Script Empty", "No script code provided for " .. text, 2)
        end
    end)
   
    -- Return the container and a function to set the script code
    return buttonContainer, function(newScriptCode)
        scriptCode = newScriptCode or ""
        return scriptCode
    end, function(isVisible)
        buttonContainer.Visible = isVisible
    end
end

-- Create a section header
-- Parameters:
--   parent: The parent frame to put the section in
--   text: The section title text
local function createSection(parent, text)
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = text .. "Section"
    sectionContainer.Size = UDim2.new(1, 0, 0, 30)
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.Parent = parent
   
    local sectionText = Instance.new("TextLabel")
    sectionText.Name = "Text"
    sectionText.Size = UDim2.new(1, 0, 1, 0)
    sectionText.BackgroundTransparency = 1
    sectionText.Font = Enum.Font.GothamBold
    sectionText.TextSize = 16
    sectionText.TextColor3 = COLORS.TEXT_PRIMARY
    sectionText.Text = text
    sectionText.TextXAlignment = Enum.TextXAlignment.Left
    sectionText.Parent = sectionContainer
   
    return sectionContainer
end

-- Create a tab button
-- Parameters:
--   parent: The parent frame to put the tab button in
--   text: The tab button text
--   isActive: Boolean for if this tab is active by default
--   callback: Function that runs when tab is clicked
local function createTabButton(parent, text, isActive, callback)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = text .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = isActive and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE
    tabButton.BorderSizePixel = 0
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 14
    tabButton.TextColor3 = isActive and COLORS.TEXT_PRIMARY or COLORS.TEXT_SECONDARY
    tabButton.Text = text
    tabButton.AutoButtonColor = false
    tabButton.Parent = parent
   
    -- Tab indicator (blue line on the left when active)
    local tabIndicator = Instance.new("Frame")
    tabIndicator.Name = "Indicator"
    tabIndicator.Size = UDim2.new(0, 3, 1, 0)
    tabIndicator.Position = UDim2.new(0, 0, 0, 0)
    tabIndicator.BackgroundColor3 = COLORS.ACCENT
    tabIndicator.BorderSizePixel = 0
    tabIndicator.Visible = isActive
    tabIndicator.Parent = tabButton
   
    -- Tab click
    tabButton.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
   
    -- Tab hover effect
    tabButton.MouseEnter:Connect(function()
        if not isActive then
            TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                TextColor3 = COLORS.TEXT_PRIMARY
            }):Play()
        end
    end)
   
    tabButton.MouseLeave:Connect(function()
        if not isActive then
            TweenService:Create(tabButton, TweenInfo.new(0.1), {
                BackgroundColor3 = COLORS.TAB_INACTIVE,
                TextColor3 = COLORS.TEXT_SECONDARY
            }):Play()
        end
    end)
   
    -- Function to set active state
    local function setActive(active)
        isActive = active
       
        TweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = active and COLORS.TAB_ACTIVE or COLORS.TAB_INACTIVE,
            TextColor3 = active and COLORS.TEXT_PRIMARY or COLORS.TEXT_SECONDARY
        }):Play()
       
        tabIndicator.Visible = active
    end
   
    return tabButton, setActive
end

-- Create the main UI
local function createMainUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PhantomHubPremium"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
   
    -- Try to use CoreGui if possible
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
   
    -- Fallback to PlayerGui if CoreGui fails
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
   
    -- Create the header bar
    local headerBar = Instance.new("Frame")
    headerBar.Name = "HeaderBar"
    headerBar.Size = UDim2.new(0, 400, 0, 30)
    headerBar.Position = UDim2.new(0.5, -200, 0.1, 0)
    headerBar.BackgroundColor3 = COLORS.HEADER
    headerBar.BorderSizePixel = 0
    headerBar.Parent = gui
   
    -- Add rounded corners to header (top corners only)
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 4)
    headerCorner.Parent = headerBar
   
    -- Version text
    local versionText = Instance.new("TextLabel")
    versionText.Name = "Version"
    versionText.Size = UDim2.new(0, 100, 1, 0)
    versionText.Position = UDim2.new(0, 10, 0, 0)
    versionText.BackgroundTransparency = 1
    versionText.Font = Enum.Font.Gotham
    versionText.TextSize = 12
    versionText.TextColor3 = COLORS.TEXT_SECONDARY
    versionText.Text = "v1.0.0"
    versionText.TextXAlignment = Enum.TextXAlignment.Left
    versionText.Parent = headerBar
   
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -200, 1, 0)
    titleText.Position = UDim2.new(0, 100, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextColor3 = COLORS.TEXT_PRIMARY
    titleText.Text = "phantom.hub premium"
    titleText.Parent = headerBar
   
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "-"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.TextColor3 = COLORS.TEXT_SECONDARY
    minimizeButton.Parent = headerBar
   
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.TextColor3 = COLORS.TEXT_SECONDARY
    closeButton.Parent = headerBar
   
    -- Main content frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -200, 0.1, 30)
    mainFrame.BackgroundColor3 = COLORS.BACKGROUND
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
   
    -- Add rounded corners to main frame (bottom corners only)
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 4)
    mainCorner.Parent = mainFrame
   
    -- Create tab container (left side)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, 0)
    tabContainer.Position = UDim2.new(0, 0, 0, 0)
    tabContainer.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
   
    -- Add rounded corners to tab container (bottom left only)
    local tabContainerCorner = Instance.new("UICorner")
    tabContainerCorner.CornerRadius = UDim.new(0, 4)
    tabContainerCorner.Parent = tabContainer
   
    -- Create tab content container (right side)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, 0)
    contentContainer.Position = UDim2.new(0, 120, 0, 0)
    contentContainer.BackgroundColor3 = COLORS.BACKGROUND
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
   
    -- Add layout for tabs
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 0)
    tabLayout.Parent = tabContainer
   
    -- Create tab content frames
    local tabContents = {}
   
    -- Function to create a new tab and its content
    local function createTab(name, layoutOrder)
        -- Create tab content frame
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = name .. "Content"
        contentFrame.Size = UDim2.new(1, -20, 1, -20)
        contentFrame.Position = UDim2.new(0, 10, 0, 10)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollBarImageColor3 = COLORS.ACCENT
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
        contentFrame.Visible = layoutOrder == 0 -- Only first tab visible by default
        contentFrame.Parent = contentContainer
       
        -- Add padding to content
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.Parent = contentFrame
       
        -- Add layout for content
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = contentFrame
       
        -- Update canvas size when content changes
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
       
        -- Store content frame
        tabContents[name] = contentFrame
       
        return contentFrame
    end
   
    -- Create tabs
    local tabs = {
        "Home",
        "Movement",
        "Teleport",
        "Visuals",
        "Scripts"
    }
   
    local tabButtons = {}
    local activeTab = tabs[1]
   
    -- Create tab buttons and content frames
    for i, tabName in ipairs(tabs) do
        local isActive = i == 1
        local layoutOrder = i - 1
       
        -- Create tab content
        local contentFrame = createTab(tabName, layoutOrder)
       
        -- Create tab button
        local tabButton, setActive = createTabButton(tabContainer, tabName, isActive, function()
            -- Hide all tab contents
            for _, content in pairs(tabContents) do
                content.Visible = false
            end
           
            -- Show selected tab content
            tabContents[tabName].Visible = true
           
            -- Update active states
            for name, setTabActive in pairs(tabButtons) do
                setTabActive(name == tabName)
            end
           
            activeTab = tabName
        end)
       
        tabButton.LayoutOrder = layoutOrder
        tabButtons[tabName] = setActive
    end
   
    -- Fill tab contents with elements - ALL TABS ARE BLANK NOW
   
    -- HOME TAB
    local homeContent = tabContents["Home"]
   
    -- Add a welcome section
    createSection(homeContent, "Welcome")
 
  createButton(homeContent, "Reanimation", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/loading123599/Phantom-Hub-V1.1/refs/heads/main/Reanimation.lua"))()
end)
   
    -- SCRIPTS TAB
    local scriptsContent = tabContents["Scripts"]
   
    -- Scripts section
    createSection(scriptsContent, "Script Visibility")
   
    -- Toggle to show/hide scripts
    local scriptsVisible = true
    local scriptButtons = {}
   
    createToggle(scriptsContent, "Show Scripts", true, function(enabled)
        scriptsVisible = enabled
       
        -- Show/hide all script buttons
        for _, buttonInfo in pairs(scriptButtons) do
            buttonInfo.setVisible(enabled)
        end
    end)
   
    -- Custom scripts section
    createSection(scriptsContent, "Custom Scripts")
   
    -- Create blank script buttons
    local function addScriptButton(name, index)
        local button, setScript, setVisible = createScriptButton(scriptsContent, name, "", scriptsVisible)
       
        -- Store the button and its functions
        scriptButtons[index] = {
            button = button,
            setScript = setScript,
            setVisible = setVisible
        }
       
        return button
    end
   
    -- Add 10 blank script buttons
    for i = 1, 10 do
        addScriptButton("Script " .. i, i)
    end
   
    -- Add script section
    createSection(scriptsContent, "Add Your Own Script")
   
    -- Script input
    local scriptInputContainer = Instance.new("Frame")
    scriptInputContainer.Name = "ScriptInputContainer"
    scriptInputContainer.Size = UDim2.new(1, 0, 0, 100)
    scriptInputContainer.BackgroundTransparency = 1
    scriptInputContainer.Parent = scriptsContent
   
    local scriptInput = Instance.new("TextBox")
    scriptInput.Name = "ScriptInput"
    scriptInput.Size = UDim2.new(1, 0, 1, 0)
    scriptInput.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    scriptInput.BorderSizePixel = 0
    scriptInput.Font = Enum.Font.Code
    scriptInput.TextSize = 14
    scriptInput.TextColor3 = COLORS.TEXT_PRIMARY
    scriptInput.Text = "-- Enter your script here"
    scriptInput.TextXAlignment = Enum.TextXAlignment.Left
    scriptInput.TextYAlignment = Enum.TextYAlignment.Top
    scriptInput.ClearTextOnFocus = false
    scriptInput.MultiLine = true
    scriptInput.Parent = scriptInputContainer
   
    -- Add rounded corners to script input
    local scriptInputCorner = Instance.new("UICorner")
    scriptInputCorner.CornerRadius = UDim.new(0, 4)
    scriptInputCorner.Parent = scriptInput
   
    -- Add padding to script input
    local scriptInputPadding = Instance.new("UIPadding")
    scriptInputPadding.PaddingTop = UDim.new(0, 5)
    scriptInputPadding.PaddingBottom = UDim.new(0, 5)
    scriptInputPadding.PaddingLeft = UDim.new(0, 5)
    scriptInputPadding.PaddingRight = UDim.new(0, 5)
    scriptInputPadding.Parent = scriptInput
   
    -- Script name input
    local scriptNameContainer = Instance.new("Frame")
    scriptNameContainer.Name = "ScriptNameContainer"
    scriptNameContainer.Size = UDim2.new(1, 0, 0, 30)
    scriptNameContainer.BackgroundTransparency = 1
    scriptNameContainer.Parent = scriptsContent
   
    local scriptNameInput = Instance.new("TextBox")
    scriptNameInput.Name = "ScriptNameInput"
    scriptNameInput.Size = UDim2.new(1, 0, 1, 0)
    scriptNameInput.BackgroundColor3 = COLORS.BACKGROUND_SECONDARY
    scriptNameInput.BorderSizePixel = 0
    scriptNameInput.Font = Enum.Font.Gotham
    scriptNameInput.TextSize = 14
    scriptNameInput.TextColor3 = COLORS.TEXT_PRIMARY
    scriptNameInput.PlaceholderText = "Enter script name"
    scriptNameInput.Text = ""
    scriptNameInput.Parent = scriptNameContainer
   
    -- Add rounded corners to script name input
    local scriptNameCorner = Instance.new("UICorner")
    scriptNameCorner.CornerRadius = UDim.new(0, 4)
    scriptNameCorner.Parent = scriptNameInput
   
    -- Add padding to script name input
    local scriptNamePadding = Instance.new("UIPadding")
    scriptNamePadding.PaddingLeft = UDim.new(0, 10)
    scriptNamePadding.Parent = scriptNameInput
   
    -- Execute button
    createButton(scriptsContent, "Execute Script", function()
        local scriptToExecute = scriptInput.Text
       
        if scriptToExecute and scriptToExecute ~= "-- Enter your script here" and scriptToExecute ~= "" then
            local success, err = pcall(function()
                loadstring(scriptToExecute)()
            end)
           
            if success then
                createNotification("Script Executed", "Custom script executed successfully", 2)
            else
                createNotification("Execution Error", "Error: " .. tostring(err), 3)
            end
        else
            createNotification("Execution Error", "Please enter a script first", 2)
        end
    end)
   
    -- Save script button
    createButton(scriptsContent, "Save Script", function()
        local scriptName = scriptNameInput.Text
        local scriptCode = scriptInput.Text
       
        if scriptName == "" then
            createNotification("Save Error", "Please enter a script name", 2)
            return
        end
       
        if scriptCode == "" or scriptCode == "-- Enter your script here" then
            createNotification("Save Error", "Please enter script code", 2)
            return
        end
       
        -- Find an empty slot or create a new one
        local slotFound = false
        for i = 1, #scriptButtons do
            local buttonInfo = scriptButtons[i]
            local buttonText = buttonInfo.button:FindFirstChild("Button").Text
           
            if buttonText == "Script " .. i then
                -- This is an unused slot
                buttonInfo.button:FindFirstChild("Button").Text = scriptName
                buttonInfo.setScript(scriptCode)
                slotFound = true
                createNotification("Script Saved", "Script saved to slot " .. i, 2)
                break
            end
        end
       
        if not slotFound and #scriptButtons < 10 then
            -- Create a new slot
            local newIndex = #scriptButtons + 1
            local button, setScript, setVisible = createScriptButton(scriptsContent, scriptName, scriptCode, scriptsVisible)
           
            scriptButtons[newIndex] = {
                button = button,
                setScript = setScript,
                setVisible = setVisible
            }
           
            createNotification("Script Saved", "Script saved to new slot", 2)
        elseif not slotFound then
            createNotification("Save Error", "All slots are full. Clear a slot first.", 3)
        end
    end)
   
    -- Clear button
    createButton(scriptsContent, "Clear Script", function()
        scriptInput.Text = "-- Enter your script here"
        scriptNameInput.Text = ""
    end)
   
    -- Make UI draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
   
    local function updateDrag(input)
        local delta = input.Position - dragStart
        headerBar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        mainFrame.Position = UDim2.new(headerBar.Position.X.Scale, headerBar.Position.X.Offset, headerBar.Position.Y.Scale, headerBar.Position.Y.Offset + 30)
    end
   
    headerBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = headerBar.Position
           
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
   
    headerBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
   
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
   
    -- Minimize button functionality with animation
    local minimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
       
        if minimized then
            -- Animate minimizing
            local minimizeTween = TweenService:Create(
                mainFrame,
                TweenInfo.new(ANIMATION.DURATION, ANIMATION.EASING_STYLE, ANIMATION.EASING_DIRECTION),
                {Size = UDim2.new(0, 400, 0, 0)}
            )
           
            minimizeTween.Completed:Connect(function()
                mainFrame.Visible = false
            end)
           
            minimizeTween:Play()
            minimizeButton.Text = "+"
        else
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 400, 0, 0)
           
            -- Animate expanding
            local expandTween = TweenService:Create(
                mainFrame,
                TweenInfo.new(ANIMATION.DURATION, ANIMATION.EASING_STYLE, ANIMATION.EASING_DIRECTION),
                {Size = UDim2.new(0, 400, 0, 350)}
            )
           
            expandTween:Play()
            minimizeButton.Text = "-"
        end
    end)
   
    -- Close button functionality with animation
    closeButton.MouseButton1Click:Connect(function()
        -- Animate closing
        local headerFadeTween = TweenService:Create(
            headerBar,
            TweenInfo.new(ANIMATION.DURATION, ANIMATION.EASING_STYLE, ANIMATION.EASING_DIRECTION),
            {BackgroundTransparency = 1}
        )
       
        local mainFadeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION.DURATION, ANIMATION.EASING_STYLE, ANIMATION.EASING_DIRECTION),
            {BackgroundTransparency = 1}
        )
       
        headerFadeTween:Play()
        mainFadeTween:Play()
       
        -- Shrink the UI
        local shrinkTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(ANIMATION.DURATION, ANIMATION.EASING_STYLE, ANIMATION.EASING_DIRECTION),
            {Size = UDim2.new(0, 400, 0, 0)}
        )
       
        shrinkTween:Play()
       
        -- Wait for animation to complete then destroy
        task.delay(ANIMATION.DURATION, function()
            gui:Destroy()
           
            -- Clean up connections
            for _, connection in pairs(_G.PhantomHubConnections) do
                if connection.Connected then
                    connection:Disconnect()
                end
            end
            _G.PhantomHubConnections = {}
        end)
    end)
   
    -- Button hover effects
    for _, button in pairs({minimizeButton, closeButton}) do
        button.MouseEnter:Connect(function()
            button.TextColor3 = COLORS.TEXT_PRIMARY
        end)
       
        button.MouseLeave:Connect(function()
            button.TextColor3 = COLORS.TEXT_SECONDARY
        end)
    end
   
    -- Set up keybind to toggle UI
    local toggleKey = Enum.KeyCode.RightControl
    local connectionId = HttpService:GenerateGUID(false)
   
    local function setupToggleKeybind()
        -- Disconnect previous connection if it exists
        if _G.PhantomHubConnections[connectionId] then
            _G.PhantomHubConnections[connectionId]:Disconnect()
        end
       
        -- Create new connection
        local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == toggleKey then
                gui.Enabled = not gui.Enabled
            end
        end)
       
        -- Store the connection
        _G.PhantomHubConnections[connectionId] = connection
    end
   
    -- Initial setup
    setupToggleKeybind()
   
    -- Show welcome notification
    createNotification("Phantom Hub Premium", "Successfully loaded!", 3)
   
    return gui
end

-- Start the UI
createMainUI()

-- SIMPLE INSTRUCTIONS FOR CUSTOMIZATION:
--
-- HOW TO ADD YOUR OWN SCRIPTS:
-- 1. Go to the Scripts tab
-- 2. Type your script name in the "Enter script name" box
-- 3. Type or paste your script code in the big text box
-- 4. Click "Save Script" to save it to a button
-- 5. Click the button anytime to run your script
-- 6. Use the "Show Scripts" toggle to hide/show all script buttons
--
-- HOW TO ADD A NEW TAB:
-- 1. Find this line: local tabs = {"Home", "Movement", "Teleport", "Visuals", "Scripts"}
-- 2. Add your new tab name to the list, e.g.: {"Home", "Movement", "Teleport", "Visuals", "Scripts", "MyNewTab"}
--
-- HOW TO ADD A NEW TOGGLE:
-- createToggle(parentFrame, "Toggle Name", false, function(enabled)
--     if enabled then
--         -- Code when toggle is ON
--     else
--         -- Code when toggle is OFF
--     end
-- end)
--
-- HOW TO ADD A NEW BUTTON:
-- createButton(parentFrame, "Button Name", function()
--     -- Code when button is clicked
-- end)
--
-- HOW TO ADD A NEW SECTION HEADER:
-- createSection(parentFrame, "Section Title")
--
-- HOW TO ADD A NEW SLIDER:
-- createSlider(parentFrame, "Slider Name", 0, 100, 50, function(value)
--     -- Code when slider changes, value = current slider value
-- end)
--
-- HOW TO ADD A NEW DROPDOWN:
-- createDropdown(parentFrame, "Dropdown Name", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
--     -- Code when selection changes, selected = current selected option
-- end)

