-- Phantom Hub UI with Premium Loading Screen
-- Press L to toggle (or tap the toggle button on mobile)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Check if we're on mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

-- =============================================
-- PREMIUM LOADING SCREEN IMPLEMENTATION
-- =============================================

-- Color scheme (matching your existing UI)
local COLORS = {
    BACKGROUND = Color3.fromRGB(10, 10, 10),       -- Almost black
    ACCENT = Color3.fromRGB(130, 0, 255),          -- Bright purple
    TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),  -- White
    TEXT_SECONDARY = Color3.fromRGB(200, 180, 255) -- Light purple
}

-- Download and save the image using executor functions
local function downloadImage()
    -- Create folder if it doesn't exist
    if not isfolder or not isfolder("PhantomHubPremium") then
        pcall(function() makefolder("PhantomHubPremium") end)
        print("Created folder: PhantomHubPremium")
    end

    -- GitHub image URL
    local imageUrl = "https://github.com/loading123599/Phantom-Hub-V1.1/blob/main/a_df8ec20590a2fd2c9dfdb24ba8795cdd.jpg?raw=true"
    local imagePath = "PhantomHubPremium/loading_image.jpg"

    -- Check if image already exists
    if isfile and not isfile(imagePath) then
        -- Download the image
        local success, imageData = pcall(function()
            if syn and syn.request then
                return syn.request({Url = imageUrl, Method = "GET"}).Body
            elseif request then
                return request({Url = imageUrl, Method = "GET"}).Body
            elseif http and http.request then
                return http.request({Url = imageUrl, Method = "GET"}).Body
            elseif httpGet then
                return httpGet(imageUrl)
            else
                return game:HttpGet(imageUrl)
            end
        end)

        if success and writefile then
            -- Save the image
            writefile(imagePath, imageData)
            print("Downloaded and saved image to: " .. imagePath)
            return true
        else
            print("Failed to download image: " .. tostring(imageData))
            return false
        end
    elseif isfile and isfile(imagePath) then
        print("Image already exists at: " .. imagePath)
        return true
    else
        return false
    end
end

-- Try to download the image
local imageDownloaded = pcall(downloadImage)

-- Create the loading screen GUI
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "PhantomHubPremiumLoader"
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingScreen.DisplayOrder = 999999 -- Ensure it's on top of everything
LoadingScreen.IgnoreGuiInset = true -- Cover the topbar
LoadingScreen.ResetOnSpawn = false -- Don't reset when character respawns

-- Try to use CoreGui if possible for better performance and security
pcall(function()
    LoadingScreen.Parent = game:GetService("CoreGui")
end)

-- Fallback to PlayerGui if CoreGui fails
if not LoadingScreen.Parent then
    LoadingScreen.Parent = playerGui
end

-- Background frame that covers the entire screen
local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.fromScale(1, 1)
Background.Position = UDim2.fromScale(0, 0)
Background.BackgroundColor3 = COLORS.BACKGROUND
Background.BorderSizePixel = 0
Background.BackgroundTransparency = 1 -- Start fully transparent for fade-in
Background.Parent = LoadingScreen

-- Create a container for the loading content
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
-- Adjust size based on device type
ContentContainer.Size = isMobile and UDim2.fromScale(0.9, 0.8) or UDim2.fromScale(0.8, 0.8)
ContentContainer.Position = UDim2.fromScale(0.5, 0.5)
ContentContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Background

-- Create an aspect ratio constraint for the image to maintain proper proportions
local ImageContainer = Instance.new("Frame")
ImageContainer.Name = "ImageContainer"
ImageContainer.Size = UDim2.fromScale(0.7, 0.5) -- Larger container for the image
ImageContainer.Position = UDim2.fromScale(0.5, 0.4)
ImageContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ImageContainer.BackgroundTransparency = 1
ImageContainer.Parent = ContentContainer

-- Add aspect ratio constraint to maintain image proportions
local AspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
AspectRatioConstraint.AspectRatio = 16/9 -- Standard aspect ratio
AspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
AspectRatioConstraint.Parent = ImageContainer

-- Create the image that will move up and down
local PhantomImage = Instance.new("ImageLabel")
PhantomImage.Name = "PhantomImage"
PhantomImage.Size = UDim2.fromScale(1, 1) -- Fill the container
PhantomImage.Position = UDim2.fromScale(0.5, 0.5)
PhantomImage.AnchorPoint = Vector2.new(0.5, 0.5)
PhantomImage.BackgroundTransparency = 1
PhantomImage.ImageTransparency = 1 -- Start fully transparent for fade-in
-- Set proper scale type to prevent stretching
PhantomImage.ScaleType = Enum.ScaleType.Fit
PhantomImage.ResampleMode = Enum.ResamplerMode.Default

-- Try to use the downloaded image if available
if imageDownloaded and isfile and isfile("PhantomHubPremium/loading_image.jpg") and getcustomasset then
    -- Use the executor's function to load the image from file
    pcall(function()
        PhantomImage.Image = getcustomasset("PhantomHubPremium/loading_image.jpg") or "rbxassetid://7733658504"
    end)
else
    -- Fallback to a Roblox asset
    PhantomImage.Image = "rbxassetid://7733658504"
end

PhantomImage.Parent = ImageContainer

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Name = "LoadingText"
LoadingText.Size = UDim2.new(0.9, 0, 0.1, 0)
LoadingText.Position = UDim2.new(0.5, 0, 0.7, 0)
LoadingText.AnchorPoint = Vector2.new(0.5, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.TextTransparency = 1 -- Start fully transparent for fade-in
LoadingText.Font = Enum.Font.GothamBold
-- Adjust text size based on device
LoadingText.TextSize = isMobile and 18 or 24
LoadingText.TextColor3 = COLORS.TEXT_PRIMARY
LoadingText.Text = "LOADING PHANTOM HUB PREMIUM"
LoadingText.TextWrapped = true -- Enable text wrapping for mobile
LoadingText.Parent = ContentContainer

-- Status text (shows loading progress or status)
local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Size = UDim2.new(0.9, 0, 0.05, 0)
StatusText.Position = UDim2.new(0.5, 0, 0.8, 0)
StatusText.AnchorPoint = Vector2.new(0.5, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextTransparency = 1 -- Start fully transparent for fade-in
StatusText.Font = Enum.Font.Gotham
-- Adjust text size based on device
StatusText.TextSize = isMobile and 14 or 18
StatusText.TextColor3 = COLORS.TEXT_SECONDARY
StatusText.Text = "Initializing..."
StatusText.TextWrapped = true -- Enable text wrapping for mobile
StatusText.Parent = ContentContainer

-- Loading bar background
local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Name = "LoadingBarBg"
-- Adjust size based on device
LoadingBarBg.Size = UDim2.new(isMobile and 0.8 or 0.6, 0, 0.02, 0)
LoadingBarBg.Position = UDim2.new(0.5, 0, 0.85, 0)
LoadingBarBg.AnchorPoint = Vector2.new(0.5, 0)
LoadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LoadingBarBg.BackgroundTransparency = 1 -- Start fully transparent for fade-in
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.Parent = ContentContainer

-- Add rounded corners to loading bar background
local LoadingBarBgCorner = Instance.new("UICorner")
LoadingBarBgCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
LoadingBarBgCorner.Parent = LoadingBarBg

-- Loading bar fill
local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Name = "LoadingBarFill"
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0) -- Start at 0% width
LoadingBarFill.Position = UDim2.new(0, 0, 0, 0)
LoadingBarFill.BackgroundColor3 = COLORS.ACCENT
LoadingBarFill.BackgroundTransparency = 1 -- Start fully transparent for fade-in
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Parent = LoadingBarBg

-- Add rounded corners to loading bar fill
local LoadingBarFillCorner = Instance.new("UICorner")
LoadingBarFillCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
LoadingBarFillCorner.Parent = LoadingBarFill

-- Phantom Hub logo/branding
local BrandingText = Instance.new("TextLabel")
BrandingText.Name = "BrandingText"
BrandingText.Size = UDim2.new(0.9, 0, 0.05, 0)
BrandingText.Position = UDim2.new(0.5, 0, 0.95, 0)
BrandingText.AnchorPoint = Vector2.new(0.5, 0)
BrandingText.BackgroundTransparency = 1
BrandingText.TextTransparency = 1 -- Start fully transparent for fade-in
BrandingText.Font = Enum.Font.GothamBold
-- Adjust text size based on device
BrandingText.TextSize = isMobile and 12 or 16
BrandingText.TextColor3 = COLORS.ACCENT
BrandingText.Text = "PHANTOM HUB PREMIUM"
BrandingText.Parent = ContentContainer

-- Function to create the fade-in effect
local function fadeInLoadingScreen()
    -- Create a list of all elements that need to fade in
    local elementsToFade = {
        {object = Background, property = "BackgroundTransparency"},
        {object = PhantomImage, property = "ImageTransparency"},
        {object = LoadingText, property = "TextTransparency"},
        {object = StatusText, property = "TextTransparency"},
        {object = LoadingBarBg, property = "BackgroundTransparency"},
        {object = LoadingBarFill, property = "BackgroundTransparency"},
        {object = BrandingText, property = "TextTransparency"}
    }

    -- Create a smooth fade-in animation
    local fadeInTime = 1.2 -- 1.2 seconds for fade-in

    -- Stagger the fade-ins for a more dynamic effect
    for i, element in ipairs(elementsToFade) do
        local delay = (i - 1) * 0.1 -- Stagger each element by 0.1 seconds

        task.delay(delay, function()
            local tweenInfo = TweenInfo.new(
                fadeInTime - delay, -- Adjust time so all finish together
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.Out
            )

            local tweenGoal = {}
            tweenGoal[element.property] = 0 -- Fade to fully visible

            local tween = TweenService:Create(element.object, tweenInfo, tweenGoal)
            tween:Play()
        end)
    end
end

-- Function to create smooth up and down animation for the image
local function animateImageUpDown()
    -- Create a smooth up and down animation
    local tweenInfo = TweenInfo.new(
        2, -- Duration (2 seconds)
        Enum.EasingStyle.Sine, -- Sine easing for smooth movement
        Enum.EasingDirection.InOut, -- InOut for smooth transitions
        -1, -- Repeat infinitely
        true -- Yoyo (reverse) for up and down motion
    )

    -- Starting position
    local startPos = ImageContainer.Position

    -- Create up position (move up by 5% of screen height)
    local upPos = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset, 
        startPos.Y.Scale - 0.03, -- Reduced movement for better appearance
        startPos.Y.Offset
    )

    -- Create the tween
    local tween = TweenService:Create(ImageContainer, tweenInfo, {Position = upPos})

    -- Start the animation
    tween:Play()
end

-- Add a pulsing effect to the branding text
local function createPulseEffect()
    local tweenInfo = TweenInfo.new(
        1.5, -- Duration
        Enum.EasingStyle.Sine, -- Easing style
        Enum.EasingDirection.InOut, -- Easing direction
        -1, -- Repeat count (-1 means loop forever)
        true -- Reverses
    )

    local tween = TweenService:Create(
        BrandingText,
        tweenInfo,
        {TextTransparency = 0.5} -- Target transparency
    )

    -- Wait a moment before starting the pulse (after fade-in)
    task.delay(1.5, function()
        tween:Play()
    end)
end

-- Function to update loading progress
local function updateLoadingProgress(progress, status)
    -- Update loading bar
    local tween = TweenService:Create(
        LoadingBarFill,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(progress, 0, 1, 0)}
    )
    tween:Play()

    -- Update status text if provided
    if status then
        StatusText.Text = status
    end
end

-- Block input while loading
local function blockInput()
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Allow Alt+F4 and Windows key to work
            if input.KeyCode == Enum.KeyCode.F4 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
                return
            elseif input.KeyCode == Enum.KeyCode.LeftMeta or input.KeyCode == Enum.KeyCode.RightMeta then
                return
            end

            -- Block all other inputs
            input.Changed:Connect(function()
                if input.UserInputState ~= Enum.UserInputState.Cancel then
                    input.UserInputState = Enum.UserInputState.Cancel
                end
            end)
        end
    end)

    -- Return the connection so it can be disconnected later
    return inputConnection
end

-- Function to create a custom notification
local function createThankYouNotification()
    -- Create notification GUI
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "PhantomHubNotification"
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.ResetOnSpawn = false

    -- Try to use CoreGui if possible
    pcall(function()
        NotificationGui.Parent = game:GetService("CoreGui")
    end)

    -- Fallback to PlayerGui if CoreGui fails
    if not NotificationGui.Parent then
        NotificationGui.Parent = playerGui
    end

    -- Create notification frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    -- Adjust size based on device
    NotificationFrame.Size = UDim2.new(0, isMobile and 250 or 300, 0, isMobile and 90 or 100)
    NotificationFrame.Position = UDim2.new(1, 20, 0.1, 0) -- Start off-screen to the right
    NotificationFrame.BackgroundColor3 = COLORS.BACKGROUND
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui

    -- Add rounded corners
    local NotificationCorner = Instance.new("UICorner")
    NotificationCorner.CornerRadius = UDim.new(0, 8)
    NotificationCorner.Parent = NotificationFrame

    -- Add accent bar on the left
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 5, 1, 0)
    AccentBar.Position = UDim2.new(0, 0, 0, 0)
    AccentBar.BackgroundColor3 = COLORS.ACCENT
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = NotificationFrame

    -- Add rounded corners to accent bar (only left side)
    local AccentBarCorner = Instance.new("UICorner")
    AccentBarCorner.CornerRadius = UDim.new(0, 8)
    AccentBarCorner.Parent = AccentBar

    -- Create a container for the user avatar
    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.Name = "AvatarContainer"
    -- Adjust size based on device
    AvatarContainer.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 50 or 60)
    AvatarContainer.Position = UDim2.new(0, isMobile and 15 or 20, 0.5, 0)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Parent = NotificationFrame

    -- Create user avatar image
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, 0, 1, 0)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
    AvatarImage.Parent = AvatarContainer

    -- Add rounded corners to avatar
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0) -- Make it circular
    AvatarCorner.Parent = AvatarImage

    -- Create thank you text
    local ThankYouText = Instance.new("TextLabel")
    ThankYouText.Name = "ThankYouText"
    ThankYouText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 25 or 30)
    ThankYouText.Position = UDim2.new(1, -10, 0, isMobile and 10 or 15)
    ThankYouText.AnchorPoint = Vector2.new(1, 0)
    ThankYouText.BackgroundTransparency = 1
    ThankYouText.Font = Enum.Font.GothamBold
    ThankYouText.TextSize = isMobile and 14 or 18
    ThankYouText.TextColor3 = COLORS.TEXT_PRIMARY
    ThankYouText.Text = "Thank You Premium User"
    ThankYouText.TextXAlignment = Enum.TextXAlignment.Right
    ThankYouText.Parent = NotificationFrame

    -- Create username text
    local UsernameText = Instance.new("TextLabel")
    UsernameText.Name = "UsernameText"
    UsernameText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 18 or 20)
    UsernameText.Position = UDim2.new(1, -10, 0, isMobile and 35 or 45)
    UsernameText.AnchorPoint = Vector2.new(1, 0)
    UsernameText.BackgroundTransparency = 1
    UsernameText.Font = Enum.Font.Gotham
    UsernameText.TextSize = isMobile and 12 or 14
    UsernameText.TextColor3 = COLORS.TEXT_SECONDARY
    UsernameText.Text = "@" .. player.Name
    UsernameText.TextXAlignment = Enum.TextXAlignment.Right
    UsernameText.Parent = NotificationFrame

    -- Create premium text
    local PremiumText = Instance.new("TextLabel")
    PremiumText.Name = "PremiumText"
    PremiumText.Size = UDim2.new(0, isMobile and 170 or 200, 0, isMobile and 18 or 20)
    PremiumText.Position = UDim2.new(1, -10, 0, isMobile and 55 or 65)
    PremiumText.AnchorPoint = Vector2.new(1, 0)
    PremiumText.BackgroundTransparency = 1
    PremiumText.Font = Enum.Font.Gotham
    PremiumText.TextSize = isMobile and 10 or 12
    PremiumText.TextColor3 = COLORS.ACCENT
    PremiumText.Text = "Phantom Hub Premium Activated"
    PremiumText.TextXAlignment = Enum.TextXAlignment.Right
    PremiumText.Parent = NotificationFrame

    -- Add shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = NotificationFrame

    -- Calculate the final position based on screen size and device type
    local screenSize = workspace.CurrentCamera.ViewportSize
    local notifWidth = isMobile and 250 or 300
    local finalPosX = math.min(screenSize.X - notifWidth - 20, screenSize.X * 0.98 - notifWidth)

    -- Animate the notification sliding in
    local slideInTween = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, finalPosX, 0.1, 0)} -- Slide in from right, position based on screen size
    )

    slideInTween:Play()

    -- Wait and then slide out
    task.delay(5, function()
        local slideOutTween = TweenService:Create(
            NotificationFrame,
            TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 20, 0.1, 0)} -- Slide out to right
        )

        slideOutTween.Completed:Connect(function()
            NotificationGui:Destroy()
        end)

        slideOutTween:Play()
    end)

    return NotificationGui
end

-- Function to handle screen orientation changes for mobile
local function setupOrientationHandling()
    if isMobile then
        -- Connect to orientation changed event
        local orientationConnection
        orientationConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            -- Get new viewport size
            local viewportSize = workspace.CurrentCamera.ViewportSize

            -- Adjust UI elements based on orientation
            local isPortrait = viewportSize.Y > viewportSize.X

            if isPortrait then
                -- Portrait adjustments
                ImageContainer.Size = UDim2.fromScale(0.8, 0.4)
                LoadingText.TextSize = 16
                StatusText.TextSize = 12
                BrandingText.TextSize = 10
            else
                -- Landscape adjustments
                ImageContainer.Size = UDim2.fromScale(0.7, 0.5)
                LoadingText.TextSize = 18
                StatusText.TextSize = 14
                BrandingText.TextSize = 12
            end
        end)

        -- Return the connection so it can be disconnected later
        return orientationConnection
    end

    return nil
end

-- =============================================
-- MAIN PHANTOM HUB UI IMPLEMENTATION
-- =============================================

-- Function to create the main Phantom Hub UI
local function createPhantomHubUI()
    -- Remove existing GUI if it exists
    if playerGui:FindFirstChild("PhantomHub") then
        playerGui:FindFirstChild("PhantomHub"):Destroy()
    end

    -- Create main ScreenGui
    local phantomHub = Instance.new("ScreenGui")
    phantomHub.Name = "PhantomHub"
    phantomHub.ResetOnSpawn = false
    phantomHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    phantomHub.Parent = playerGui

    -- Function to download and save the color wheel image
    local function downloadColorWheel()
        -- Image URL for the color wheel
        local imageUrl = "https://github.com/Justanewplayer19/rizzyv2/blob/main/iGLGQ-removebg-preview.png?raw=true"
        local imagePath = "phantom_hub_color_wheel.png"

        -- Check if the file already exists
        local fileExists = pcall(function()
            return readfile and readfile(imagePath)
        end)

        if not fileExists and writefile then
            -- Try different HTTP request methods based on the exploit
            local success, response = false, nil

            -- Try Synapse X request
            if syn and syn.request then
                success = pcall(function()
                    response = syn.request({
                        Url = imageUrl,
                        Method = "GET"
                    })
                end)
            -- Try KRNL request
            elseif request then
                success = pcall(function()
                    response = request({
                        Url = imageUrl,
                        Method = "GET"
                    })
                end)
            -- Try HttpGet (some exploits support this)
            elseif game.HttpGet then
                success = pcall(function()
                    response = {Body = game:HttpGet(imageUrl)}
                end)
            end

            -- Save the image if download was successful
            if success and response and response.Body then
                pcall(function()
                    writefile(imagePath, response.Body)
                    print("Color wheel image downloaded successfully")
                end)
            else
                warn("Failed to download color wheel image")
            end
        else
            print("Color wheel image already exists")
        end

        return imagePath
    end

    -- Try to download the color wheel image
    local colorWheelPath = downloadColorWheel()

    -- Default colors (can be customized)
    local colors = {
        background = Color3.fromRGB(0, 0, 0),
        text = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
        border = Color3.fromRGB(40, 40, 40),
        button = Color3.fromRGB(0, 0, 0),
        buttonHover = Color3.fromRGB(20, 20, 20),
        buttonBorder = Color3.fromRGB(40, 40, 40),
        buttonBorderHover = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
        tabActive = Color3.fromRGB(20, 20, 20),
        tabInactive = Color3.fromRGB(0, 0, 0)
    }

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 310, 0, 310)
    mainFrame.Position = UDim2.new(0.5, -155, 0.5, -155)
    mainFrame.BackgroundColor3 = colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Parent = phantomHub

    -- Add corner radius
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 8)
    cornerRadius.Parent = mainFrame

    -- Add border
    local border = Instance.new("UIStroke")
    border.Color = colors.border
    border.Thickness = 1
    border.Parent = mainFrame

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = colors.background
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    -- Header shadow
    local headerShadow = Instance.new("Frame")
    headerShadow.Name = "HeaderShadow"
    headerShadow.Size = UDim2.new(1, 0, 0, 1)
    headerShadow.Position = UDim2.new(0, 0, 1, 0)
    headerShadow.BackgroundColor3 = colors.border
    headerShadow.BorderSizePixel = 0
    headerShadow.ZIndex = 2
    headerShadow.Parent = header

    -- Title icon
    local titleIcon = Instance.new("Frame")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 10, 0, 10)
    titleIcon.Position = UDim2.new(0, 10, 0.5, -5)
    titleIcon.BackgroundColor3 = colors.accent
    titleIcon.BorderSizePixel = 0
    titleIcon.Parent = header

    -- Make icon round
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = titleIcon

    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0, 200, 1, 0)
    titleText.Position = UDim2.new(0, 30, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.SourceSansBold
    titleText.TextSize = 14
    titleText.TextColor3 = colors.text
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = "Phantom Hub Premium"
    titleText.Parent = header

    -- Close button (using a custom X instead of text)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = ""
    closeButton.Parent = header

    -- Create a custom X using frames
    local xPart1 = Instance.new("Frame")
    xPart1.Name = "XPart1"
    xPart1.Size = UDim2.new(0, 12, 0, 2)
    xPart1.Position = UDim2.new(0.5, -6, 0.5, -1)
    xPart1.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    xPart1.BorderSizePixel = 0
    xPart1.Rotation = 45
    xPart1.Parent = closeButton

    local xPart2 = Instance.new("Frame")
    xPart2.Name = "XPart2"
    xPart2.Size = UDim2.new(0, 12, 0, 2)
    xPart2.Position = UDim2.new(0.5, -6, 0.5, -1)
    xPart2.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    xPart2.BorderSizePixel = 0
    xPart2.Rotation = -45
    xPart2.Parent = closeButton

    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -65, 0.5, -15)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = ""
    minimizeButton.Parent = header

    -- Create a custom minimize icon
    local minIcon = Instance.new("Frame")
    minIcon.Name = "MinIcon"
    minIcon.Size = UDim2.new(0, 12, 0, 2)
    minIcon.Position = UDim2.new(0.5, -6, 0.5, -1)
    minIcon.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    minIcon.BorderSizePixel = 0
    minIcon.Parent = minimizeButton

    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, 0, 1, -40)
    contentContainer.Position = UDim2.new(0, 0, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame

    -- Tab sidebar
    local tabSidebar = Instance.new("Frame")
    tabSidebar.Name = "TabSidebar"
    tabSidebar.Size = UDim2.new(0, 100, 1, 0)
    tabSidebar.BackgroundColor3 = colors.background
    tabSidebar.BorderSizePixel = 0
    tabSidebar.Parent = contentContainer

    -- Tab sidebar shadow
    local sidebarShadow = Instance.new("Frame")
    sidebarShadow.Name = "SidebarShadow"
    sidebarShadow.Size = UDim2.new(0, 1, 1, 0)
    sidebarShadow.Position = UDim2.new(1, 0, 0, 0)
    sidebarShadow.BackgroundColor3 = colors.border
    sidebarShadow.BorderSizePixel = 0
    sidebarShadow.Parent = tabSidebar

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -100, 1, 0)
    contentArea.Position = UDim2.new(0, 100, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = contentContainer

    -- Create color picker container (outside of mainFrame to avoid clipping)
    local colorPickerContainer = Instance.new("Frame")
    colorPickerContainer.Name = "ColorPickerContainer"
    colorPickerContainer.Size = UDim2.new(0, 200, 0, 230)
    colorPickerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    colorPickerContainer.BorderColor3 = Color3.fromRGB(60, 60, 60)
    colorPickerContainer.BorderSizePixel = 1
    colorPickerContainer.Visible = false
    colorPickerContainer.ZIndex = 100
    colorPickerContainer.Parent = phantomHub

    -- Add corner radius to color picker
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = colorPickerContainer

    -- Create a programmatically generated color wheel if we couldn't download the image
    local function createProgrammaticColorWheel()
        local colorWheel = Instance.new("Frame")
        colorWheel.Name = "ColorWheel"
        colorWheel.Size = UDim2.new(0, 150, 0, 150)
        colorWheel.Position = UDim2.new(0.5, -75, 0, 15)
        colorWheel.BackgroundTransparency = 1
        colorWheel.ZIndex = 101
        colorWheel.Parent = colorPickerContainer

        -- Create the base circle
        local wheelBase = Instance.new("Frame")
        wheelBase.Name = "WheelBase"
        wheelBase.Size = UDim2.new(1, 0, 1, 0)
        wheelBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        wheelBase.BorderSizePixel = 0
        wheelBase.ZIndex = 101
        wheelBase.Parent = colorWheel

        -- Make it circular
        local baseCorner = Instance.new("UICorner")
        baseCorner.CornerRadius = UDim.new(1, 0)
        baseCorner.Parent = wheelBase

        -- Create a rainbow gradient
        local rainbowGradient = Instance.new("UIGradient")
        rainbowGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        rainbowGradient.Rotation = 90
        rainbowGradient.Parent = wheelBase

        -- Create a saturation overlay (white to transparent radial gradient)
        local satOverlay = Instance.new("Frame")
        satOverlay.Name = "SaturationOverlay"
        satOverlay.Size = UDim2.new(1, 0, 1, 0)
        satOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        satOverlay.BackgroundTransparency = 0.5
        satOverlay.BorderSizePixel = 0
        satOverlay.ZIndex = 102
        satOverlay.Parent = colorWheel

        -- Make it circular
        local satCorner = Instance.new("UICorner")
        satCorner.CornerRadius = UDim.new(1, 0)
        satCorner.Parent = satOverlay

        -- Create a radial gradient for saturation
        local satGradient = Instance.new("UIGradient")
        satGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),  -- Center (transparent)
            NumberSequenceKeypoint.new(1, 0)   -- Edge (white)
        })
        satGradient.Parent = satOverlay

        return colorWheel
    end

    -- Color wheel - Try to load from file or create programmatically
    local colorWheel
    local success = pcall(function()
        if colorWheelPath and isfile and isfile(colorWheelPath) and getcustomasset then
            -- Create an ImageLabel and load the image from file
            colorWheel = Instance.new("ImageLabel")
            colorWheel.Name = "ColorWheel"
            colorWheel.Size = UDim2.new(0, 150, 0, 150)
            colorWheel.Position = UDim2.new(0.5, -75, 0, 15)
            colorWheel.BackgroundTransparency = 1
            colorWheel.ZIndex = 101

            -- Load image from file
            colorWheel.Image = getcustomasset(colorWheelPath)

            colorWheel.Parent = colorPickerContainer
        else
            -- If file loading fails, create a programmatic wheel
            colorWheel = createProgrammaticColorWheel()
        end
    end)

    if not success then
        -- Fallback if there was an error
        colorWheel = createProgrammaticColorWheel()
    end

    -- Color wheel selector
    local wheelSelector = Instance.new("Frame")
    wheelSelector.Name = "WheelSelector"
    wheelSelector.Size = UDim2.new(0, 10, 0, 10)
    wheelSelector.AnchorPoint = Vector2.new(0.5, 0.5)
    wheelSelector.Position = UDim2.new(0.5, 0, 0.5, 0)
    wheelSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    wheelSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    wheelSelector.BorderSizePixel = 1
    wheelSelector.ZIndex = 103
    wheelSelector.Parent = colorWheel

    -- Make wheel selector round
    local selectorCorner = Instance.new("UICorner")
    selectorCorner.CornerRadius = UDim.new(1, 0)
    selectorCorner.Parent = wheelSelector

    -- Brightness slider
    local brightnessSlider = Instance.new("Frame")
    brightnessSlider.Name = "BrightnessSlider"
    brightnessSlider.Size = UDim2.new(0, 150, 0, 20)
    brightnessSlider.Position = UDim2.new(0.5, -75, 0, 175)
    brightnessSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    brightnessSlider.ZIndex = 101
    brightnessSlider.Parent = colorPickerContainer

    -- Brightness gradient
    local brightnessGradient = Instance.new("UIGradient")
    brightnessGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    brightnessGradient.Parent = brightnessSlider

    -- Brightness slider corner
    local brightnessCorner = Instance.new("UICorner")
    brightnessCorner.CornerRadius = UDim.new(0, 4)
    brightnessCorner.Parent = brightnessSlider

    -- Brightness selector
    local brightnessSelector = Instance.new("Frame")
    brightnessSelector.Name = "BrightnessSelector"
    brightnessSelector.Size = UDim2.new(0, 5, 1, 4)
    brightnessSelector.Position = UDim2.new(1, -2.5, 0, -2)
    brightnessSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    brightnessSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    brightnessSelector.BorderSizePixel = 1
    brightnessSelector.ZIndex = 102
    brightnessSelector.Parent = brightnessSlider

    -- Color preview
    local colorPreview = Instance.new("Frame")
    colorPreview.Name = "ColorPreview"
    colorPreview.Size = UDim2.new(0, 30, 0, 30)
    colorPreview.Position = UDim2.new(0, 10, 0, 175)
    colorPreview.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    colorPreview.BorderColor3 = Color3.fromRGB(60, 60, 60)
    colorPreview.BorderSizePixel = 1
    colorPreview.ZIndex = 101
    colorPreview.Parent = colorPickerContainer

    -- Color preview corner
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = colorPreview

    -- Apply button
    local applyButton = Instance.new("TextButton")
    applyButton.Name = "ApplyButton"
    applyButton.Size = UDim2.new(0, 80, 0, 25)
    applyButton.Position = UDim2.new(0.5, -40, 1, -35)
    applyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    applyButton.BorderColor3 = Color3.fromRGB(60, 60, 60)
    applyButton.Font = Enum.Font.SourceSans
    applyButton.TextSize = 14
    applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyButton.Text = "Apply"
    applyButton.ZIndex = 101
    applyButton.Parent = colorPickerContainer

    -- Apply button corner
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 4)
    applyCorner.Parent = applyButton

    -- Variables for color picker
    local currentColorOption = nil
    local currentColor = Color3.fromRGB(255, 0, 0)
    local hue, saturation, value = 0, 1, 1
    local wheelDragging = false
    local brightnessDragging = false
    local currentCallback = nil

    -- IMPROVED HSV to RGB conversion function
    local function HSVToRGB(h, s, v)
        if s <= 0 then
            return Color3.fromRGB(v * 255, v * 255, v * 255)
        end

        h = h * 6
        local c = v * s
        local x = c * (1 - math.abs((h % 2) - 1))
        local m = v - c
        local r, g, b

        if h < 1 then
            r, g, b = c, x, 0
        elseif h < 2 then
            r, g, b = x, c, 0
        elseif h < 3 then
            r, g, b = 0, c, x
        elseif h < 4 then
            r, g, b = 0, x, c
        elseif h < 5 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end

        return Color3.fromRGB((r + m) * 255, (g + m) * 255, (b + m) * 255)
    end

    -- IMPROVED RGB to HSV conversion function
    local function RGBToHSV(color)
        local r, g, b = color.R, color.G, color.B
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, v

        v = max

        local delta = max - min
        if max == 0 then
            s = 0
        else
            s = delta / max
        end

        if delta == 0 then
            h = 0
        else
            if max == r then
                h = (g - b) / delta
                if g < b then h = h + 6 end
            elseif max == g then
                h = (b - r) / delta + 2
            else
                h = (r - g) / delta + 4
            end
            h = h / 6
        end

        return h, s, v
    end

    -- Function to update color from wheel position
    local function updateColorFromWheel(x, y)
        local centerX, centerY = colorWheel.AbsoluteSize.X/2, colorWheel.AbsoluteSize.Y/2
        local dx, dy = x - centerX, y - centerY
        local distance = math.sqrt(dx*dx + dy*dy)

        -- Clamp distance to wheel radius
        local radius = colorWheel.AbsoluteSize.X/2
        local clampedDistance = math.min(distance, radius)

        -- Calculate saturation based on distance from center
        saturation = clampedDistance / radius

        -- Calculate hue based on angle
        local angle = math.atan2(dy, dx)
        hue = ((angle / (2 * math.pi)) + 0.5) % 1

        -- Update selector position
        local posX = centerX + math.cos(angle) * (saturation * radius)
        local posY = centerY + math.sin(angle) * (saturation * radius)

        wheelSelector.Position = UDim2.new(0, posX, 0, posY)

        -- Update color
        currentColor = HSVToRGB(hue, saturation, value)
        colorPreview.BackgroundColor3 = currentColor

        -- Update brightness gradient
        brightnessGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, HSVToRGB(hue, saturation, 1))
        })
    end

    -- Function to update color from brightness slider
    local function updateColorFromBrightness(x)
        local width = brightnessSlider.AbsoluteSize.X
        local position = math.clamp(x, 0, width)

        -- Calculate value based on position
        value = position / width

        -- Update selector position
        brightnessSelector.Position = UDim2.new(0, position - 2.5, 0, -2)

        -- Update color
        currentColor = HSVToRGB(hue, saturation, value)
        colorPreview.BackgroundColor3 = currentColor
    end

    -- Function to show color picker
    local function showColorPicker(option, initialColor, callback)
        currentColorOption = option
        currentCallback = callback

        -- Set initial color
        hue, saturation, value = RGBToHSV(initialColor)
        currentColor = initialColor
        colorPreview.BackgroundColor3 = currentColor

        -- Update brightness gradient
        brightnessGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, HSVToRGB(hue, saturation, 1))
        })

        -- Update wheel selector position
        local radius = colorWheel.AbsoluteSize.X/2
        local angle = hue * 2 * math.pi
        local posX = math.cos(angle) * saturation * radius + radius
        local posY = math.sin(angle) * saturation * radius + radius
        wheelSelector.Position = UDim2.new(0, posX, 0, posY)

        -- Update brightness selector position
        brightnessSelector.Position = UDim2.new(0, value * brightnessSlider.AbsoluteSize.X - 2.5, 0, -2)

        -- Position color picker near the option
        local optionPos = option.AbsolutePosition
        local optionSize = option.AbsoluteSize

        colorPickerContainer.Position = UDim2.new(0, optionPos.X + optionSize.X + 10, 0, optionPos.Y - 50)

        -- Make sure the picker is fully visible on screen
        local screenSize = phantomHub.AbsoluteSize
        local pickerSize = colorPickerContainer.AbsoluteSize

        if optionPos.X + optionSize.X + pickerSize.X + 20 > screenSize.X then
            colorPickerContainer.Position = UDim2.new(0, optionPos.X - pickerSize.X - 10, 0, optionPos.Y - 50)
        end

        if optionPos.Y + pickerSize.Y > screenSize.Y then
            colorPickerContainer.Position = UDim2.new(colorPickerContainer.Position.X.Scale, colorPickerContainer.Position.X.Offset, 0, screenSize.Y - pickerSize.Y - 10)
        end

        -- Show the picker
        colorPickerContainer.Visible = true
    end

    -- Color wheel input handlers
    colorWheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wheelDragging = true
            local position = input.Position
            local wheelPosition = colorWheel.AbsolutePosition
            updateColorFromWheel(position.X - wheelPosition.X, position.Y - wheelPosition.Y)
        end
    end)

    colorWheel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wheelDragging = false
        end
    end)

    colorWheel.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and wheelDragging then
            local position = input.Position
            local wheelPosition = colorWheel.AbsolutePosition
            updateColorFromWheel(position.X - wheelPosition.X, position.Y - wheelPosition.Y)
        end
    end)

    -- Brightness slider input handlers
    brightnessSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            brightnessDragging = true
            local position = input.Position
            local sliderPosition = brightnessSlider.AbsolutePosition
            updateColorFromBrightness(position.X - sliderPosition.X)
        end
    end)

    brightnessSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            brightnessDragging = false
        end
    end)

    brightnessSlider.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and brightnessDragging then
            local position = input.Position
            local sliderPosition = brightnessSlider.AbsolutePosition
            updateColorFromBrightness(position.X - sliderPosition.X)
        end
    end)

    -- Apply button handler
    applyButton.MouseButton1Click:Connect(function()
        if currentCallback then
            currentCallback(currentColor)
        end
        colorPickerContainer.Visible = false
    end)

    -- Function to update UI with new colors
    local function updateUIColors()
        -- Update main elements
        mainFrame.BackgroundColor3 = colors.background
        border.Color = colors.border
        header.BackgroundColor3 = colors.background
        headerShadow.BackgroundColor3 = colors.border
        titleIcon.BackgroundColor3 = colors.accent
        titleText.TextColor3 = colors.text
        tabSidebar.BackgroundColor3 = colors.background
        sidebarShadow.BackgroundColor3 = colors.border

        -- Update all tab buttons
        for _, tabData in pairs(tabButtons) do
            if tabData.button.TextColor3 == Color3.fromRGB(255, 255, 255) then
                tabData.button.TextColor3 = colors.text
                tabData.button.BackgroundColor3 = colors.tabActive
            end
            tabData.indicator.BackgroundColor3 = colors.accent
        end

        -- Update all example buttons
        for _, content in pairs(tabContents) do
            if content:IsA("ScrollingFrame") then
                for _, child in pairs(content:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundColor3 = colors.button
                        child.BorderColor3 = colors.buttonBorder
                        child.TextColor3 = colors.text
                    end
                end
            end
        end

        -- Update mobile toggle button if it exists
        if toggleButton then
            toggleButton.BackgroundColor3 = colors.background
            toggleButton.TextColor3 = colors.text
            toggleShadow.Color = colors.border
        end
    end

    -- Create tab buttons and content
    local tabs = {"Main", "Universal", "Reanimation", "Dancing", "Settings"}
    local tabButtons = {}
    local tabContents = {}

    -- Create example buttons for each tab
    local exampleCounts = {
        Main = 4,
        Universal = 7,
        Reanimation = 1, -- We'll create a toggler for this instead of buttons
        Dancing = 7,
        Settings = 0, -- We'll create custom settings content
    }

    -- Function to create tab content
    local function createTabContent(tabName, count)
        local contentFrame = Instance.new("ScrollingFrame")
        contentFrame.Name = tabName .. "Content"
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.BorderSizePixel = 0
        contentFrame.ScrollBarThickness = 4
        contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        contentFrame.Visible = false

        -- IMPORTANT: Enable scrolling for mobile
        contentFrame.ScrollingEnabled = true
        contentFrame.ElasticBehavior = Enum.ElasticBehavior.Always
        contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y

        contentFrame.Parent = contentArea

        -- Create list layout instead of grid layout for vertical buttons
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = contentFrame

        -- Add padding
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = contentFrame

        -- Create Tab object
        local Tab = {}

        -- Add CreateButton function to Tab
        Tab.CreateButton = function(properties)
            local button = Instance.new("TextButton")
            button.Name = properties.Name or "Button"
            button.Size = UDim2.new(1, -20, 0, 40)
            button.BackgroundColor3 = colors.button
            button.BorderColor3 = colors.buttonBorder
            button.Font = Enum.Font.SourceSans
            button.TextSize = 14
            button.TextColor3 = colors.text
            button.Text = properties.Name or "Button"
            button.LayoutOrder = properties.LayoutOrder or #contentFrame:GetChildren()

            -- Add corner radius
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = button

            -- Button hover effect
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = colors.buttonHover
                button.BorderColor3 = colors.buttonBorderHover
            end)

            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = colors.button
                button.BorderColor3 = colors.buttonBorder
            end)

            -- Button click effect with callback
            button.MouseButton1Click:Connect(properties.Callback or function() end)

            button.Parent = contentFrame
            return button
        end

        -- Add CreateToggler function to Tab
        Tab.CreateToggler = function(properties)
            local container = Instance.new("Frame")
            container.Name = properties.Name .. "Container" or "TogglerContainer"
            container.Size = UDim2.new(1, -20, 0, 40)
            container.BackgroundColor3 = colors.button
            container.BorderColor3 = colors.buttonBorder
            container.LayoutOrder = properties.LayoutOrder or #contentFrame:GetChildren()
            
            -- Add corner radius
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 4)
            containerCorner.Parent = container
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextColor3 = colors.text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = properties.Name or "Toggler"
            label.Parent = container
            
            -- Toggle background
            local toggleBg = Instance.new("Frame")
            toggleBg.Name = "ToggleBg"
            toggleBg.Size = UDim2.new(0, 40, 0, 20)
            toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
            toggleBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = container
            
            -- Toggle background corner
            local toggleBgCorner = Instance.new("UICorner")
            toggleBgCorner.CornerRadius = UDim.new(1, 0)
            toggleBgCorner.Parent = toggleBg
            
            -- Toggle knob
            local toggleKnob = Instance.new("Frame")
            toggleKnob.Name = "ToggleKnob"
            toggleKnob.Size = UDim2.new(0, 16, 0, 16)
            toggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            toggleKnob.BorderSizePixel = 0
            toggleKnob.Parent = toggleBg
            
            -- Toggle knob corner
            local toggleKnobCorner = Instance.new("UICorner")
            toggleKnobCorner.CornerRadius = UDim.new(1, 0)
            toggleKnobCorner.Parent = toggleKnob
            
            -- Toggle state
            local enabled = false
            
            -- Toggle function
            local function updateToggle()
                enabled = not enabled
                
                -- Animate the toggle
                local targetPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local targetColor = enabled and colors.accent or Color3.fromRGB(200, 200, 200)
                local bgColor = enabled and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
                
                -- Create tweens
                local knobTween = TweenService:Create(
                    toggleKnob,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = targetPos, BackgroundColor3 = targetColor}
                )
                
                local bgTween = TweenService:Create(
                    toggleBg,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundColor3 = bgColor}
                )
                
                knobTween:Play()
                bgTween:Play()
                
                -- Call the callback
                if properties.Callback then
                    properties.Callback(enabled)
                end
            end
            
            -- Make the entire container clickable
            container.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    updateToggle()
                end
            end)
            
            -- Container hover effect
            container.MouseEnter:Connect(function()
                container.BackgroundColor3 = colors.buttonHover
                container.BorderColor3 = colors.buttonBorderHover
            end)
            
            container.MouseLeave:Connect(function()
                container.BackgroundColor3 = colors.button
                container.BorderColor3 = colors.buttonBorder
            end)
            
            container.Parent = contentFrame
            
            -- Return the container and functions to control it
            return {
                Container = container,
                SetState = function(state)
                    if state ~= enabled then
                        updateToggle()
                    end
                end,
                GetState = function()
                    return enabled
                end
            }
        end
        
        -- Add CreateSlider function to Tab
        Tab.CreateSlider = function(properties)
            local container = Instance.new("Frame")
            container.Name = properties.Name .. "Container" or "SliderContainer"
            container.Size = UDim2.new(1, -20, 0, 60)
            container.BackgroundColor3 = colors.button
            container.BorderColor3 = colors.buttonBorder
            container.LayoutOrder = properties.LayoutOrder or #contentFrame:GetChildren()
            
            -- Add corner radius
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 4)
            containerCorner.Parent = container
            
            -- Label
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextColor3 = colors.text
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = properties.Name or "Slider"
            label.Parent = container
            
            -- Value display
            local valueDisplay = Instance.new("TextLabel")
            valueDisplay.Name = "ValueDisplay"
            valueDisplay.Size = UDim2.new(0, 40, 0, 20)
            valueDisplay.Position = UDim2.new(1, -50, 0, 5)
            valueDisplay.BackgroundTransparency = 1
            valueDisplay.Font = Enum.Font.SourceSans
            valueDisplay.TextSize = 14
            valueDisplay.TextColor3 = colors.text
            valueDisplay.Text = tostring(properties.Min or 0)
            valueDisplay.Parent = container
            
            -- Slider background
            local sliderBg = Instance.new("Frame")
            sliderBg.Name = "SliderBg"
            sliderBg.Size = UDim2.new(1, -20, 0, 6)
            sliderBg.Position = UDim2.new(0, 10, 0, 35)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = container
            
            -- Slider background corner
            local sliderBgCorner = Instance.new("UICorner")
            sliderBgCorner.CornerRadius = UDim.new(1, 0)
            sliderBgCorner.Parent = sliderBg
            
            -- Slider fill
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "SliderFill"
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.BackgroundColor3 = colors.accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            
            -- Slider fill corner
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(1, 0)
            sliderFillCorner.Parent = sliderFill
            
            -- Slider knob
            local sliderKnob = Instance.new("Frame")
            sliderKnob.Name = "SliderKnob"
            sliderKnob.Size = UDim2.new(0, 16, 0, 16)
            sliderKnob.Position = UDim2.new(0, -8, 0.5, -8)
            sliderKnob.BackgroundColor3 = colors.accent
            sliderKnob.BorderSizePixel = 0
            sliderKnob.ZIndex = 2
            sliderKnob.Parent = sliderFill
            
            -- Slider knob corner
            local sliderKnobCorner = Instance.new("UICorner")
            sliderKnobCorner.CornerRadius = UDim.new(1, 0)
            sliderKnobCorner.Parent = sliderKnob
            
            -- Slider properties
            local min = properties.Min or 0
            local max = properties.Max or 100
            local currentValue = properties.Default or min
            local dragging = false
            
            -- Update slider function
            local function updateSlider(value)
                -- Clamp value between min and max
                value = math.clamp(value, min, max)
                currentValue = value
                
                -- Calculate percentage
                local percent = (value - min) / (max - min)
                
                -- Update slider fill
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                
                -- Update value display
                valueDisplay.Text = tostring(math.floor(value * 100) / 100)
                
                -- Call callback
                if properties.Callback then
                    properties.Callback(value)
                end
            end
            
            -- Set initial value
            updateSlider(currentValue)
            
            -- Handle slider input
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    
                    -- Calculate value based on input position
                    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * percent
                    
                    updateSlider(value)
                end
            end)
            
            sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            sliderBg.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Calculate value based on input position
                    local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * percent
                    
                    updateSlider(value)
                end
            end)
            
            -- Container hover effect
            container.MouseEnter:Connect(function()
                container.BackgroundColor3 = colors.buttonHover
                container.BorderColor3 = colors.buttonBorderHover
            end)
            
            container.MouseLeave:Connect(function()
                container.BackgroundColor3 = colors.button
                container.BorderColor3 = colors.buttonBorder
            end)
            
            container.Parent = contentFrame
            
            -- Return the container and functions to control it
            return {
                Container = container,
                SetValue = function(value)
                    updateSlider(value)
                end,
                GetValue = function()
                    return currentValue
                end
            }
        end

        -- Create example buttons for each tab
        if tabName ~= "Reanimation" then
            for i = 1, count do
                Tab:CreateButton({
                    Name = tabName .. " Button " .. i,
                    Callback = function()
                        print("Clicked: " .. tabName .. " - Button " .. i)
                        -- Here you would add your loadstring execution
                        -- Example:
                        -- loadstring(game:HttpGet("https://your-script-url.com"))()
                    end,
                })
            end
        else
            -- For Reanimation tab, create a toggler instead of buttons
            Tab:CreateToggler({
                Name = "Enable Reanimation",
                Callback = function(enabled)
                    print("Reanimation toggled: " .. (enabled and "ON" or "OFF"))
                    -- Here you would add your reanimation loadstring
                    if enabled then
                        -- Example:
                        -- loadstring(game:HttpGet("https://your-reanimation-script.com"))()
                    else
                        -- Disable reanimation code here
                    end
                end
            })
            
            -- Add some sliders for reanimation settings
            Tab:CreateSlider({
                Name = "Animation Speed",
                Min = 0.1,
                Max = 2,
                Default = 1,
                Callback = function(value)
                    print("Animation Speed set to: " .. value)
                    -- Here you would adjust your reanimation speed
                end
            })
            
            Tab:CreateSlider({
                Name = "Height Offset",
                Min = -5,
                Max = 5,
                Default = 0,
                Callback = function(value)
                    print("Height Offset set to: " .. value)
                    -- Here you would adjust your reanimation height
                end
            })
        end

        -- Update canvas size
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, (count * 50) + 20)

        return contentFrame, Tab
    end

    -- Create tab buttons and content
    for i, tabName in ipairs(tabs) do
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.Position = UDim2.new(0, 0, 0, (i-1) * 40)
        tabButton.BackgroundTransparency = 1
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextSize = 14
        tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabButton.Text = tabName
        tabButton.Parent = tabSidebar

        -- Create selection indicator
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "SelectionIndicator"
        selectionIndicator.Size = UDim2.new(0, 2, 1, 0)
        selectionIndicator.BackgroundColor3 = colors.accent
        selectionIndicator.BorderSizePixel = 0
        selectionIndicator.Visible = false
        selectionIndicator.Parent = tabButton

        -- Create tab content
        local content, tab
        if tabName ~= "Settings" then
            content, tab = createTabContent(tabName, exampleCounts[tabName])
        else
            -- Create custom settings content
            content = Instance.new("ScrollingFrame")
            content.Name = "SettingsContent"
            content.Size = UDim2.new(1, 0, 1, 0)
            content.BackgroundTransparency = 1
            content.BorderSizePixel = 0
            content.ScrollBarThickness = 4
            content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

            -- IMPORTANT: Enable scrolling for mobile
            content.ScrollingEnabled = true
            content.ElasticBehavior = Enum.ElasticBehavior.Always
            content.ScrollingDirection = Enum.ScrollingDirection.Y

            content.Visible = false
            content.Parent = contentArea

            -- Add padding
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.PaddingRight = UDim.new(0, 10)
            padding.PaddingTop = UDim.new(0, 10)
            padding.PaddingBottom = UDim.new(0, 10)
            padding.Parent = content

            -- Add list layout
            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 10)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = content

            -- Create settings sections
            local function createSettingSection(title, layoutOrder)
                local section = Instance.new("Frame")
                section.Name = title .. "Section"
                section.Size = UDim2.new(1, 0, 0, 30)
                section.BackgroundTransparency = 1
                section.LayoutOrder = layoutOrder
                section.AutomaticSize = Enum.AutomaticSize.Y
                section.Parent = content

                local sectionTitle = Instance.new("TextLabel")
                sectionTitle.Name = "Title"
                sectionTitle.Size = UDim2.new(1, 0, 0, 30)
                sectionTitle.BackgroundTransparency = 1
                sectionTitle.Font = Enum.Font.SourceSansBold
                sectionTitle.TextSize = 16
                sectionTitle.TextColor3 = colors.text
                sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                sectionTitle.Text = title
                sectionTitle.Parent = section

                local sectionContent = Instance.new("Frame")
                sectionContent.Name = "Content"
                sectionContent.Size = UDim2.new(1, 0, 0, 0)
                sectionContent.Position = UDim2.new(0, 0, 0, 30)
                sectionContent.BackgroundTransparency = 1
                sectionContent.AutomaticSize = Enum.AutomaticSize.Y
                sectionContent.Parent = section

                local contentLayout = Instance.new("UIListLayout")
                contentLayout.Padding = UDim.new(0, 8)
                contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                contentLayout.Parent = sectionContent

                return section, sectionContent
            end

            -- Create UI Colors section
            local colorSection, colorContent = createSettingSection("UI Colors", 1)

            -- Function to create a color option
            local function createColorOption(name, defaultColor, layoutOrder, callback)
                local colorOption = Instance.new("Frame")
                colorOption.Name = name .. "Option"
                colorOption.Size = UDim2.new(1, 0, 0, 30)
                colorOption.BackgroundTransparency = 1
                colorOption.LayoutOrder = layoutOrder
                colorOption.Parent = colorContent

                local colorLabel = Instance.new("TextLabel")
                colorLabel.Name = "Label"
                colorLabel.Size = UDim2.new(0.5, -10, 1, 0)
                colorLabel.BackgroundTransparency = 1
                colorLabel.Font = Enum.Font.SourceSans
                colorLabel.TextSize = 14
                colorLabel.TextColor3 = colors.text
                colorLabel.TextXAlignment = Enum.TextXAlignment.Left
                colorLabel.Text = name
                colorLabel.Parent = colorOption

                local colorPreview = Instance.new("Frame")
                colorPreview.Name = "Preview"
                colorPreview.Size = UDim2.new(0, 30, 0, 20)
                colorPreview.Position = UDim2.new(0.5, 0, 0.5, -10)
                colorPreview.BackgroundColor3 = defaultColor
                colorPreview.BorderColor3 = Color3.fromRGB(60, 60, 60)
                colorPreview.BorderSizePixel = 1
                colorPreview.Parent = colorOption

                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, 4)
                previewCorner.Parent = colorPreview

                -- Create color picker button
                local pickerButton = Instance.new("TextButton")
                pickerButton.Name = "PickerButton"
                pickerButton.Size = UDim2.new(0.5, -40, 1, 0)
                pickerButton.Position = UDim2.new(0.5, 40, 0, 0)
                pickerButton.BackgroundColor3 = colors.button
                pickerButton.BorderColor3 = colors.buttonBorder
                pickerButton.Font = Enum.Font.SourceSans
                pickerButton.TextSize = 14
                pickerButton.TextColor3 = colors.text
                pickerButton.Text = "Change"
                pickerButton.Parent = colorOption

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = pickerButton

                -- Button hover effect
                pickerButton.MouseEnter:Connect(function()
                    pickerButton.BackgroundColor3 = colors.buttonHover
                    pickerButton.BorderColor3 = colors.buttonBorderHover
                end)

                pickerButton.MouseLeave:Connect(function()
                    pickerButton.BackgroundColor3 = colors.button
                    pickerButton.BorderColor3 = colors.buttonBorder
                end)

                -- Show color picker on button click
                pickerButton.MouseButton1Click:Connect(function()
                    showColorPicker(colorOption, colorPreview.BackgroundColor3, function(newColor)
                        colorPreview.BackgroundColor3 = newColor
                        if callback then
                            callback(newColor)
                        end
                    end)
                end)

                return colorPreview
            end

            -- Create color options
            createColorOption("Background", colors.background, 1, function(color)
                colors.background = color
                updateUIColors()
            end)

            createColorOption("Text", colors.text, 2, function(color)
                colors.text = color
                updateUIColors()
            end)

            createColorOption("Accent", colors.accent, 3, function(color)
                colors.accent = color
                updateUIColors()
            end)

            createColorOption("Border", colors.border, 4, function(color)
                colors.border = color
                updateUIColors()
            end)

            createColorOption("Button", colors.button, 5, function(color)
                colors.button = color
                updateUIColors()
            end)

            createColorOption("Button Hover", colors.buttonHover, 6, function(color)
                colors.buttonHover = color
            end)

            createColorOption("Button Border", colors.buttonBorder, 7, function(color)
                colors.buttonBorder = color
                updateUIColors()
            end)

            -- Create preset themes section
            local themeSection, themeContent = createSettingSection("Preset Themes", 2)

            -- Function to create theme buttons
            local function createThemeButton(name, themeColors, layoutOrder)
                local themeButton = Instance.new("TextButton")
                themeButton.Name = name .. "Theme"
                themeButton.Size = UDim2.new(1, 0, 0, 30)
                themeButton.BackgroundColor3 = themeColors.background
                themeButton.BorderColor3 = themeColors.border
                themeButton.Font = Enum.Font.SourceSans
                themeButton.TextSize = 14
                themeButton.TextColor3 = themeColors.text
                themeButton.Text = name
                themeButton.LayoutOrder = layoutOrder
                themeButton.Parent = themeContent

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = themeButton

                -- Theme preview (small colored squares)
                local previewSize = 8
                local previewGap = 2
                local totalWidth = (previewSize * 3) + (previewGap * 2)

                local bgPreview = Instance.new("Frame")
                bgPreview.Size = UDim2.new(0, previewSize, 0, previewSize)
                bgPreview.Position = UDim2.new(1, -totalWidth - 10, 0.5, -previewSize/2)
                bgPreview.BackgroundColor3 = themeColors.background
                bgPreview.BorderSizePixel = 0
                bgPreview.Parent = themeButton

                local accentPreview = Instance.new("Frame")
                accentPreview.Size = UDim2.new(0, previewSize, 0, previewSize)
                accentPreview.Position = UDim2.new(1, -totalWidth + previewSize + previewGap - 10, 0.5, -previewSize/2)
                accentPreview.BackgroundColor3 = themeColors.accent
                accentPreview.BorderSizePixel = 0
                accentPreview.Parent = themeButton

                local textPreview = Instance.new("Frame")
                textPreview.Size = UDim2.new(0, previewSize, 0, previewSize)
                textPreview.Position = UDim2.new(1, -totalWidth + (previewSize + previewGap) * 2 - 10, 0.5, -previewSize/2)
                textPreview.BackgroundColor3 = themeColors.text
                textPreview.BorderSizePixel = 0
                textPreview.Parent = themeButton

                -- Click handler
                themeButton.MouseButton1Click:Connect(function()
                    -- Apply theme colors
                    for key, value in pairs(themeColors) do
                        colors[key] = value
                    end
                    updateUIColors()
                end)
            end

            -- Define preset themes
            local themes = {
                ["Dark"] = {
                    background = Color3.fromRGB(0, 0, 0),
                    text = Color3.fromRGB(255, 255, 255),
                    accent = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    border = Color3.fromRGB(40, 40, 40),
                    button = Color3.fromRGB(0, 0, 0),
                    buttonHover = Color3.fromRGB(20, 20, 20),
                    buttonBorder = Color3.fromRGB(40, 40, 40),
                    buttonBorderHover = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    tabActive = Color3.fromRGB(20, 20, 20),
                    tabInactive = Color3.fromRGB(0, 0, 0)
                },
                ["Light"] = {
                    background = Color3.fromRGB(240, 240, 240),
                    text = Color3.fromRGB(0, 0, 0),
                    accent = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    border = Color3.fromRGB(200, 200, 200),
                    button = Color3.fromRGB(230, 230, 230),
                    buttonHover = Color3.fromRGB(220, 220, 220),
                    buttonBorder = Color3.fromRGB(180, 180, 180),
                    buttonBorderHover = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    tabActive = Color3.fromRGB(220, 220, 220),
                    tabInactive = Color3.fromRGB(240, 240, 240)
                },
                ["Purple"] = {
                    background = Color3.fromRGB(30, 10, 40),
                    text = Color3.fromRGB(255, 255, 255),
                    accent = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    border = Color3.fromRGB(60, 30, 80),
                    button = Color3.fromRGB(40, 20, 60),
                    buttonHover = Color3.fromRGB(50, 30, 70),
                    buttonBorder = Color3.fromRGB(70, 40, 100),
                    buttonBorderHover = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    tabActive = Color3.fromRGB(50, 30, 70),
                    tabInactive = Color3.fromRGB(30, 10, 40)
                }
            }

            -- Create theme buttons
            local themeOrder = 1
            for name, themeColors in pairs(themes) do
                createThemeButton(name, themeColors, themeOrder)
                themeOrder = themeOrder + 1
            end

            -- Create other settings section
            local otherSection, otherContent = createSettingSection("Other Settings", 3)

            -- Reset button
            local resetButton = Instance.new("TextButton")
            resetButton.Name = "ResetButton"
            resetButton.Size = UDim2.new(1, 0, 0, 30)
            resetButton.BackgroundColor3 = colors.button
            resetButton.BorderColor3 = colors.buttonBorder
            resetButton.Font = Enum.Font.SourceSans
            resetButton.TextSize = 14
            resetButton.TextColor3 = colors.text
            resetButton.Text = "Reset All Settings"
            resetButton.LayoutOrder = 1
            resetButton.Parent = otherContent

            local resetCorner = Instance.new("UICorner")
            resetCorner.CornerRadius = UDim.new(0, 4)
            resetCorner.Parent = resetButton

            -- Reset button click handler
            resetButton.MouseButton1Click:Connect(function()
                -- Reset to default colors
                colors = {
                    background = Color3.fromRGB(0, 0, 0),
                    text = Color3.fromRGB(255, 255, 255),
                    accent = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    border = Color3.fromRGB(40, 40, 40),
                    button = Color3.fromRGB(0, 0, 0),
                    buttonHover = Color3.fromRGB(20, 20, 20),
                    buttonBorder = Color3.fromRGB(40, 40, 40),
                    buttonBorderHover = Color3.fromRGB(130, 0, 255), -- Changed to match loading screen purple
                    tabActive = Color3.fromRGB(20, 20, 20),
                    tabInactive = Color3.fromRGB(0, 0, 0)
                }
                updateUIColors()
            end)

            -- Update canvas size based on content
            -- IMPORTANT: Make sure the canvas size is large enough for mobile scrolling
            content.CanvasSize = UDim2.new(0, 0, 0, colorSection.Size.Y.Offset + themeSection.Size.Y.Offset + otherSection.Size.Y.Offset + 50)

            -- Force update canvas size after a short delay to ensure all content is measured
            spawn(function()
                wait(0.1)
                local totalHeight = 0
                for _, child in pairs(content:GetChildren()) do
                    if child:IsA("Frame") and child.Visible then
                        totalHeight = totalHeight + child.AbsoluteSize.Y + 10
                    end
                end
                content.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
            end)
        end

        tabButtons[tabName] = {
            button = tabButton,
            indicator = selectionIndicator,
            tab = tab
        }

        tabContents[tabName] = content

        -- Tab button click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all content frames and indicators
            for _, tab in pairs(tabButtons) do
                tab.indicator.Visible = false
                tab.button.TextColor3 = Color3.fromRGB(150, 150, 150)
                tab.button.BackgroundTransparency = 1
            end

            for _, content in pairs(tabContents) do
                content.Visible = false
            end

            -- Show selected tab
            selectionIndicator.Visible = true
            tabButton.TextColor3 = colors.text
            tabButton.BackgroundColor3 = colors.tabActive
            tabButton.BackgroundTransparency = 0
            content.Visible = true

            -- Hide color picker when switching tabs
            colorPickerContainer.Visible = false
        end)
    end

    -- Set default tab
    tabButtons["Main"].indicator.Visible = true
    tabButtons["Main"].button.TextColor3 = colors.text
    tabButtons["Main"].button.BackgroundColor3 = colors.tabActive
    tabButtons["Main"].button.BackgroundTransparency = 0
    tabContents["Main"].Visible = true

    -- Resize handle
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 15, 0, 15)
    resizeHandle.Position = UDim2.new(1, -15, 1, -15)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.Parent = mainFrame

    -- Add a visual indicator for the resize handle
    local resizeIndicator = Instance.new("Frame")
    resizeIndicator.Name = "ResizeIndicator"
    resizeIndicator.Size = UDim2.new(0, 6, 0, 6)
    resizeIndicator.Position = UDim2.new(0.5, -3, 0.5, -3)
    resizeIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    resizeIndicator.BorderSizePixel = 0
    resizeIndicator.Parent = resizeHandle

    -- Add toggle button for mobile
    local toggleButton
    if isMobile then
        toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 40, 0, 40)
        toggleButton.Position = UDim2.new(0, 10, 0, 10)
        toggleButton.BackgroundColor3 = colors.background
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = "P"
        toggleButton.TextColor3 = colors.text
        toggleButton.Font = Enum.Font.SourceSansBold
        toggleButton.TextSize = 18
        toggleButton.Parent = phantomHub

        -- Add corner radius
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleButton

        -- Add shadow
        local toggleShadow = Instance.new("UIStroke")
        toggleShadow.Color = colors.border
        toggleShadow.Thickness = 1
        toggleShadow.Parent = toggleButton
    end

    -- Variables for dragging
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    -- Variables for resizing
    local resizing = false
    local resizeStart
    local startSize

    -- Variables for UI state
    local isMinimized = false
    local isOpen = true

    -- Make UI draggable (works for both mouse and touch)
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    -- Handle both mouse and touch input for dragging
    local function beginDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        -- Connect to the appropriate event based on input type
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- Make UI resizable (works for both mouse and touch)
    local function updateResize(input)
        local delta = input.Position - resizeStart
        local newSize = UDim2.new(startSize.X.Scale, startSize.X.Offset + delta.X, startSize.Y.Scale, startSize.Y.Offset + delta.Y)

        -- Minimum size constraints
        newSize = UDim2.new(
            newSize.X.Scale, 
            math.max(newSize.X.Offset, 300), 
            newSize.Y.Scale, 
            math.max(newSize.Y.Offset, 200)
        )

        mainFrame.Size = newSize
    end

    -- Handle both mouse and touch input for resizing
    local function beginResize(input)
        resizing = true
        resizeStart = input.Position
        startSize = mainFrame.Size

        -- Connect to the appropriate event based on input type
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    connection:Disconnect()
                end
            end)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    connection:Disconnect()
                end
            end)
        end
    end

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginResize(input)
        end
    end)

    resizeHandle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and resizing then
            updateResize(input)
        end
    end)

    -- Universal input handling for both mouse and touch
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateDrag(input)
            end
        end
    end)

    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        -- Closing animation
        local closeTween = TweenService:Create(
            mainFrame, 
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
            {
                Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 0),
                Position = UDim2.new(
                    mainFrame.Position.X.Scale, 
                    mainFrame.Position.X.Offset, 
                    mainFrame.Position.Y.Scale, 
                    mainFrame.Position.Y.Offset + mainFrame.Size.Y.Offset/2
                ),
                Rotation = 5,
                BackgroundTransparency = 1
            }
        )

        closeTween:Play()

        closeTween.Completed:Connect(function()
            isOpen = false
            mainFrame.Visible = false
            colorPickerContainer.Visible = false -- Hide color picker when UI is closed
        end)
    end)

    -- Minimize button functionality
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized

        if isMinimized then
            -- Minimize animation
            local minimizeTween = TweenService:Create(
                mainFrame, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 40)}
            )
            minimizeTween:Play()
            contentContainer.Visible = false
            colorPickerContainer.Visible = false -- Hide color picker when minimized
        else
            -- Restore animation
            local restoreTween = TweenService:Create(
                mainFrame, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 310)}
            )
            restoreTween:Play()
            contentContainer.Visible = true
        end
    end)

    -- Toggle with L key or toggle button
    local function toggleUI()
        if not isOpen then
            -- Open animation
            mainFrame.Size = UDim2.new(0, 310, 0, 310)
            mainFrame.Position = UDim2.new(0.5, -155, 0.5, -155)
            mainFrame.Rotation = 0
            mainFrame.BackgroundTransparency = 0
            mainFrame.Visible = true
            contentContainer.Visible = not isMinimized

            local openTween = TweenService:Create(
                mainFrame, 
                TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
                {
                    Size = UDim2.new(0, 310, 0, isMinimized and 40 or 310),
                    BackgroundTransparency = 0,
                    Rotation = 0
                }
            )

            openTween:Play()
            isOpen = true
        else
            -- Close animation
            local closeTween = TweenService:Create(
                mainFrame, 
                TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
                {
                    Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 0),
                    Position = UDim2.new(
                        mainFrame.Position.X.Scale, 
                        mainFrame.Position.X.Offset, 
                        mainFrame.Position.Y.Scale, 
                        mainFrame.Position.Y.Offset + mainFrame.Size.Y.Offset/2
                    ),
                    Rotation = 5,
                    BackgroundTransparency = 1
                }
            )

            closeTween:Play()
            colorPickerContainer.Visible = false -- Hide color picker when UI is closed

            closeTween.Completed:Connect(function()
                isOpen = false
                mainFrame.Visible = false
            end)
        end
    end

    -- Keyboard toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.L then
            toggleUI()
        end
    end)

    -- Mobile toggle button
    if isMobile and toggleButton then
        toggleButton.MouseButton1Click:Connect(toggleUI)
    end

    -- Initially hide the UI (it will be shown after loading)
    mainFrame.Visible = false

    return phantomHub
end

-- Function to hide the loading screen and show the main UI
local function hideLoadingScreen(inputConnection)
    -- Disconnect the input blocking
    if inputConnection then
        inputConnection:Disconnect()
    end

    -- Create a slow fade-out effect (2 seconds)
    local fadeOutTween = TweenService:Create(
        Background,
        TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )

    -- Also fade out all children
    for _, child in pairs(ContentContainer:GetDescendants()) do
        if child:IsA("GuiObject") and child.BackgroundTransparency < 1 then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            ):Play()
        end

        if child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {TextTransparency = 1}
            ):Play()
        end

        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            TweenService:Create(
                child,
                TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {ImageTransparency = 1}
            ):Play()
        end
    end

    fadeOutTween.Completed:Connect(function()
        -- Remove the loading screen after fade-out
        LoadingScreen:Destroy()

        -- Show the thank you notification
        createThankYouNotification()

        -- Create and show the main UI
        local phantomHubUI = createPhantomHubUI()

        -- Show the main UI with a fade-in effect
        local mainFrame = phantomHubUI.MainFrame
        mainFrame.BackgroundTransparency = 1
        mainFrame.Visible = true

        -- Fade in the main UI
        local fadeInTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0}
        )
        fadeInTween:Play()
    end)

    fadeOutTween:Play()
end

-- Simulate loading process with guaranteed completion
local function simulateLoading(callback)
    local stages = {
        {progress = 0.1, status = "Checking premium status...", time = 0.5},
        {progress = 0.2, status = "Verifying user...", time = 0.5},
        {progress = 0.3, status = "Loading modules...", time = 0.5},
        {progress = 0.5, status = "Initializing features...", time = 0.5},
        {progress = 0.7, status = "Preparing UI...", time = 0.5},
        {progress = 0.9, status = "Almost ready...", time = 0.5},
        {progress = 1.0, status = "Welcome to Phantom Hub Premium!", time = 0.5}
    }

    -- Process each stage sequentially with coroutine to ensure completion
    coroutine.wrap(function()
        for i, stage in ipairs(stages) do
            updateLoadingProgress(stage.progress, stage.status)
            task.wait(stage.time) -- Wait for the specified time
        end

        -- Wait a moment on 100% before calling the callback
        task.wait(1) -- Wait 1 second at 100%

        -- Call the callback when done
        if callback then
            callback()
        end
    end)()
end

-- Main function to start the loading screen
local function startPremiumLoading(loadingTime)
    loadingTime = loadingTime or 5 -- Default loading time in seconds

    -- Start with fade-in effect
    fadeInLoadingScreen()

    -- Setup orientation handling for mobile
    local orientationConnection = setupOrientationHandling()

    -- Start animations after a short delay (after fade-in starts)
    task.delay(0.5, function()
        createPulseEffect()
        animateImageUpDown()
    end)

    -- Block input and get the connection
    local inputConnection = blockInput()

    -- Start the loading simulation with guaranteed completion after fade-in
    task.delay(1.2, function() -- Wait for fade-in to complete
        simulateLoading(function()
            -- Hide the loading screen when done - with SLOW fade-out
            hideLoadingScreen(inputConnection)

            -- Disconnect orientation handling if it exists
            if orientationConnection then
                orientationConnection:Disconnect()
            end
        end)
    end)

    -- Failsafe: Force close after a maximum time to prevent getting stuck
    task.delay(loadingTime + 7, function() -- Extended to account for fade-in and fade-out time
        if LoadingScreen.Parent then
            print("Loading screen failsafe triggered - forcing close")
            hideLoadingScreen(inputConnection)

            -- Disconnect orientation handling if it exists
            if orientationConnection then
                orientationConnection:Disconnect()
            end
        end
    end)
end

-- Start the loading screen
startPremiumLoading(5) -- 5 seconds loading time

-- Return the script for external control
return {
    UpdateProgress = updateLoadingProgress,
    Hide = function() hideLoadingScreen() end
}
