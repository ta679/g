--!nolint BuiltinGlobalWrite
--!optimize 2
--!native

if getconnections then
    if cloneref then
        for _,v in pairs(getconnections(cloneref(game:GetService("LogService")).MessageOut)) do v:Disable() end
        for _,v in pairs(getconnections(cloneref(game:GetService("ScriptContext")).Error)) do v:Disable() end
    else
        for _,v in pairs(getconnections(game:GetService("LogService")).MessageOut) do v:Disable() end
        for _,v in pairs(getconnections(game:GetService("ScriptContext")).Error)) do v:Disable() end
    end
    warn("[Phantom Hub] -> DISCONNECTED ALL CONSOLE CONNECTIONS")
end

local function randomHex(len)
    local str = ""
    for i = 1, len do
        str = str .. string.format("%x", math.random(0, 15))
    end
    return str
end

local function randstr()
    local uuid = table.concat({
        randomHex(8),
        randomHex(4),
        randomHex(4),
        randomHex(4),
        randomHex(12)
    }, "-")
    return "phantom_" .. uuid
end

local ANIMATION_UI_ID = randstr()
local NOTIFICATIONS_ID = randstr()

sep = string.rep("\n", 200)
print("                             v LATEST LOGS OF PHANTOM HUB ANIM ARE BELOW v"..sep.."            > Starting Phantom Hub")
warn("[Phantom Hub] -> Starting...")

local logging = true
local function log(...)
    if logging then
        warn("[Phantom Hub] -> " .. ...)
    end
end
local function seperate(job)
    if logging then
        print("> "..job)
    end
end

log("Logging is enabled.")
seperate("Protection")

if hookfunction and newcclosure then
    local originalHttpGet = game.HttpGet
    hookfunction(game.HttpGet, newcclosure(function(self, ...)
        if self == game then
            local url = select(1, ...)
            if url == originalHttpGet then
                log("HttpGet protection triggered")
                while true do end
                return nil
            end
        end
        return originalHttpGet(self, ...)
    end))
    log("Hooked HttpGet.")
end

local rawgs = clonefunction and clonefunction(game.GetService) or game.GetService
function gs(service)
    local ok, result = pcall(function()
        return rawgs(game, service)
    end)
    if ok and result then
        log("Got service '" .. service .. "' successfully")
        return result
    else
        log("Failed to get service '" .. service .. "'")
        return nil
    end
end

function define(instance)
    if cloneref then
        local ok, protected = pcall(cloneref, instance)
        if ok and protected then
            log("Protected instance '" .. tostring(instance) .. "' with cloneref")
            return protected
        else
            log("cloneref failed for '" .. tostring(instance) .. "'")
        end
    else
        log("cloneref not available, returning raw instance '" .. tostring(instance) .. "'")
    end
    return instance
end

local HttpService = define(gs("HttpService"))
local TweenService = define(gs("TweenService"))
local RunService = define(gs("RunService"))
local UserInputService = define(gs("UserInputService"))
local Players = define(gs("Players"))
local Player = define(Players.LocalPlayer)
local GuiService = define(gs("GuiService"))
local ReplicatedStorage = define(gs("ReplicatedStorage"))
local workspace = define(gs("Workspace"))
local CoreGui = define(gs("CoreGui"))

workspace.FallenPartsDestroyHeight = 0/0

seperate("Loading UI")

-- Changed to black and white color scheme
local UI_CONFIG = {
    MainColor = Color3.fromRGB(10, 10, 10), -- Black
    SecondaryColor = Color3.fromRGB(25, 25, 25), -- Dark gray
    AccentColor = Color3.fromRGB(200, 200, 200), -- Light gray
    AccentColorDark = Color3.fromRGB(150, 150, 150), -- Medium gray
    TextColor = Color3.fromRGB(255, 255, 255), -- White
    SubTextColor = Color3.fromRGB(180, 180, 180), -- Light gray
    BorderColor = Color3.fromRGB(50, 50, 50), -- Medium gray
    HoverColor = Color3.fromRGB(40, 40, 40), -- Dark gray hover
    ToggleOnColor = Color3.fromRGB(200, 200, 200), -- Light gray
    ToggleOffColor = Color3.fromRGB(80, 80, 80), -- Medium gray
    ErrorColor = Color3.fromRGB(220, 60, 60), -- Keeping red for errors
    SuccessColor = Color3.fromRGB(180, 180, 180), -- Light gray for success
    WarningColor = Color3.fromRGB(200, 200, 200), -- Light gray for warnings
    
    CornerRadius = UDim.new(0, 4),
    ButtonCornerRadius = UDim.new(0, 4),
    WindowCornerRadius = UDim.new(0, 6),
    SliderHeight = 4,
    Padding = 10,
    BorderSize = 1,
    
    Font = Enum.Font.Gotham,
    HeaderFont = Enum.Font.GothamBold,
    TitleSize = 16,
    TextSize = 14,
    SubTextSize = 12,
    
    TweenTime = 0.2,
    TweenStyle = Enum.EasingStyle.Quad,
    TweenDirection = Enum.EasingDirection.Out,
}

local CONFIG = {
    FOLDER_NAME = "phantom/animations",
    SETTINGS_FILE = "settings.json",
    DEFAULT_SPEED = 1,
    KEYBINDS = {
        TOGGLE_UI = Enum.KeyCode.RightControl,
        PLAY_STOP = Enum.KeyCode.X,
        SPEED_UP = Enum.KeyCode.E,
        SPEED_DOWN = Enum.KeyCode.Q
    }
}

local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UI_CONFIG.CornerRadius
    corner.Parent = instance
    return corner
end

local function createStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or UI_CONFIG.BorderColor
    stroke.Transparency = 0
    stroke.Thickness = thickness or UI_CONFIG.BorderSize
    stroke.Parent = instance
    return stroke
end

local FileSystem = {}

function FileSystem:ensureFolder()
    if not isfolder(CONFIG.FOLDER_NAME) then
        makefolder(CONFIG.FOLDER_NAME)
    end
end

function FileSystem:saveJSON(filename, data)
    self:ensureFolder()
    writefile(CONFIG.FOLDER_NAME .. "/" .. filename, HttpService:JSONEncode(data))
end

function FileSystem:loadJSON(filename)
    if isfile(CONFIG.FOLDER_NAME .. "/" .. filename) then
        return HttpService:JSONDecode(readfile(CONFIG.FOLDER_NAME .. "/" .. filename))
    end
    return nil
end

function FileSystem:saveAnimation(id, keyframeData)
    self:ensureFolder()
    writefile(CONFIG.FOLDER_NAME .. "/" .. id .. ".txt", HttpService:JSONEncode(keyframeData))
end

function FileSystem:loadAnimation(id)
    if isfile(CONFIG.FOLDER_NAME .. "/" .. id .. ".txt") then
        return HttpService:JSONDecode(readfile(CONFIG.FOLDER_NAME .. "/" .. id .. ".txt"))
    end
    return nil
end

local NotificationSystem = {
    queue = {},
    current = nil
}

function NotificationSystem:createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = NOTIFICATIONS_ID
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = gethui()
    
    self.gui = gui
    return gui
end

function NotificationSystem:push(title, message, type, duration)
    table.insert(self.queue, {
        title = title,
        message = message,
        type = type or "info",
        duration = duration or 3
    })
    
    if not self.current then
        self:showNext()
    end
end

function NotificationSystem:showNext()
    if #self.queue == 0 then
        self.current = nil
        return
    end
    
    local notif = table.remove(self.queue, 1)
    self.current = notif
    
    if not self.gui then
        self:createUI()
    end
    
    local colors = {
        success = UI_CONFIG.SuccessColor,
        error = UI_CONFIG.ErrorColor,
        warning = UI_CONFIG.WarningColor,
        info = UI_CONFIG.AccentColor
    }
    
    local color = colors[notif.type] or UI_CONFIG.AccentColor
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 70)
    frame.Position = UDim2.new(1, 20, 0.8, 0)
    frame.BackgroundColor3 = UI_CONFIG.MainColor
    frame.Parent = self.gui
    createCorner(frame, UI_CONFIG.WindowCornerRadius)
    createStroke(frame, color, 1.5)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = color
    indicator.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = notif.title
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 14, 0, 5)
    title.Font = UI_CONFIG.HeaderFont
    title.TextColor3 = UI_CONFIG.TextColor
    title.TextSize = UI_CONFIG.TitleSize
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local message = Instance.new("TextLabel")
    message.Text = notif.message
    message.Size = UDim2.new(1, -20, 0, 30)
    message.Position = UDim2.new(0, 14, 0, 30)
    message.Font = UI_CONFIG.Font
    message.TextColor3 = UI_CONFIG.SubTextColor
    message.TextSize = UI_CONFIG.TextSize
    message.BackgroundTransparency = 1
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextWrapped = true
    message.Parent = frame
    
    frame:TweenPosition(
        UDim2.new(1, -300, 0.8, 0),
        UI_CONFIG.TweenDirection,
        UI_CONFIG.TweenStyle,
        UI_CONFIG.TweenTime,
        true
    )
    
    task.delay(notif.duration, function()
        frame:TweenPosition(
            UDim2.new(1, 20, 0.8, 0),
            Enum.EasingDirection.In,
            UI_CONFIG.TweenStyle,
            UI_CONFIG.TweenTime,
            true,
            function()
                frame:Destroy()
                self:showNext()
            end
        )
    end)
end

local AnimationComponent = {}
AnimationComponent.__index = AnimationComponent

function AnimationComponent.new(keyframeData)
    local self = setmetatable({}, AnimationComponent)
    self.speed = 1
    self.stopped = true
    self.connection = nil
    self.lastUpdateTime = 0
    self.animationTime = 0
    self.totalDuration = keyframeData[#keyframeData].Time
    self.keyframeData = keyframeData
    self.joints = {}
    return self
end

function AnimationComponent:play(character, joints)
    if self.connection then
        self.connection:Disconnect()
    end
    
    self.stopped = false
    self.lastUpdateTime = tick()
    self.animationTime = 0
    self.joints = joints
    
    self.connection = RunService.Heartbeat:Connect(function()
        if self.stopped then
            self.connection:Disconnect()
            self.connection = nil
            return
        end
        
        local currentTime = tick()
        local deltaTime = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        self.animationTime = self.animationTime + (deltaTime * self.speed)
        if self.animationTime >= self.totalDuration then
            self.animationTime = self.animationTime % self.totalDuration
        end
        
        local currentFrame = 1
        local nextFrame = 2
        
        for i = 1, #self.keyframeData do
            if self.animationTime >= self.keyframeData[i].Time then
                currentFrame = i
                nextFrame = (i % #self.keyframeData) + 1
            end
        end
        
        local currentKeyframe = self.keyframeData[currentFrame]
        local nextKeyframe = self.keyframeData[nextFrame]
        
        local frameDuration = nextKeyframe.Time - currentKeyframe.Time
        if frameDuration < 0 then
            frameDuration = frameDuration + self.totalDuration
        end
        
        local timeIntoFrame = self.animationTime - currentKeyframe.Time
        if timeIntoFrame < 0 then
            timeIntoFrame = timeIntoFrame + self.totalDuration
        end
        
        local alpha = timeIntoFrame / frameDuration
        alpha = math.clamp(alpha, 0, 1)
        
        for partName, joint in pairs(self.joints) do
            local currentPose = currentKeyframe.Poses[partName]
            local nextPose = nextKeyframe.Poses[partName]
            
            if currentPose and nextPose and joint.Joint then
                local currentCF = CFrame.new(unpack(currentPose.CFrame.Position)) * 
                                CFrame.Angles(unpack(currentPose.CFrame.Orientation))
                local nextCF = CFrame.new(unpack(nextPose.CFrame.Position)) * 
                             CFrame.Angles(unpack(nextPose.CFrame.Orientation))
                
                joint.Joint.C0 = joint.C0 * currentCF:Lerp(nextCF, alpha)
            end
        end
    end)
end

function AnimationComponent:stop()
    self.stopped = true
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
    
    if self.joints then
        for _, joint in pairs(self.joints) do
            if joint.Joint then
                joint.Joint.C0 = joint.C0
                joint.Joint.C1 = joint.C1
            end
        end
    end
end

function AnimationComponent:setSpeed(speed)
    self.speed = speed
end

local AnimationManager = {
    ui = nil,
    currentAnim = nil,
    settings = {},
    cache = {},
    connections = {},
    joints = nil,
    character = nil,
    isRunning = false,
    buttons = {}
}

function AnimationManager:processKeyframes(keyframeSequence)
    local keyframeData = {}
    for _, keyframe in ipairs(keyframeSequence:GetKeyframes()) do
        local frameData = {
            Time = keyframe.Time,
            Poses = {}
        }
        
        for _, pose in ipairs(keyframe:GetDescendants()) do
            if pose:IsA("Pose") then
                frameData.Poses[pose.Name] = {
                    CFrame = {
                        Position = {pose.CFrame.Position.X, pose.CFrame.Position.Y, pose.CFrame.Position.Z},
                        Orientation = {pose.CFrame:ToEulerAnglesXYZ()}
                    }
                }
            end
        end
        
        table.insert(keyframeData, frameData)
    end
    return keyframeData
end

function AnimationManager:loadAnimation(id)
    if self.cache[id] then
        return self.cache[id]
    end
    
    local cachedData = FileSystem:loadAnimation(id)
    if cachedData then
        local anim = AnimationComponent.new(cachedData)
        self.cache[id] = anim
        return anim
    end
    
    local success, animation = pcall(function()
        return game:GetObjects("rbxassetid://" .. id)[1]
    end)
    
    if not success or not animation or not animation:IsA('KeyframeSequence') then
        NotificationSystem:push("Error", "Failed to load animation: " .. id, "error", 3)
        return nil
    end
    
    local keyframeData = self:processKeyframes(animation)
    FileSystem:saveAnimation(id, keyframeData)
    
    local anim = AnimationComponent.new(keyframeData)
    self.cache[id] = anim
    
    return anim
end

function AnimationManager:cleanupCharacter()
    for _, conn in pairs(self.connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    self.connections = {}
    
    if self.currentAnim then
        self.currentAnim:stop()
        self.currentAnim = nil
    end
    
    self.isRunning = false
end

function AnimationManager:toggleAnimation(id)
    if not self.character or not self.joints then
        NotificationSystem:push("Error", "Character not loaded", "error", 2)
        return
    end
    
    if self.currentAnim and self.currentAnim.id == id then
        self.currentAnim:stop()
        self.currentAnim = nil
        
        if self.buttons[id] then
            self.buttons[id].SetSelected(false)
        end
        return
    end
    
    local anim = self:loadAnimation(id)
    if not anim then return end
    
    if self.currentAnim then
        if self.buttons[self.currentAnim.id] then
            self.buttons[self.currentAnim.id].SetSelected(false)
        end
        self.currentAnim:stop()
    end
    
    anim.id = id
    anim:setSpeed(self.settings.defaultSpeed)
    anim:play(self.character, self.joints)
    self.currentAnim = anim
    
    if self.buttons[id] then
        self.buttons[id].SetSelected(true)
    end
end

function AnimationManager:updateSpeed(speed)
    if not speed or speed < 0.1 or speed > 4 then return end
    
    self.settings.defaultSpeed = speed
    
    if self.currentAnim then
        self.currentAnim:setSpeed(speed)
    end
    
    FileSystem:saveJSON(CONFIG.SETTINGS_FILE, self.settings)
end

function AnimationManager:setupCharacter()
    local function createJoints(char)
        local joints = {}
        local jointData = {
            Head = {Joint = "Neck"},
            UpperTorso = {Joint = "Waist"},
            LowerTorso = {Joint = "Root"},
            RightUpperArm = {Joint = "RightShoulder"},
            RightLowerArm = {Joint = "RightElbow"},
            RightHand = {Joint = "RightWrist"},
            LeftUpperArm = {Joint = "LeftShoulder"},
            LeftLowerArm = {Joint = "LeftElbow"},
            LeftHand = {Joint = "LeftWrist"},
            RightUpperLeg = {Joint = "RightHip"},
            RightLowerLeg = {Joint = "RightKnee"},
            RightFoot = {Joint = "RightAnkle"},
            LeftUpperLeg = {Joint = "LeftHip"},
            LeftLowerLeg = {Joint = "LeftKnee"},
            LeftFoot = {Joint = "LeftAnkle"}
        }
        
        for partName, data in pairs(jointData) do
            local part = char:FindFirstChild(partName)
            if part then
                local joint = part:FindFirstChild(data.Joint)
                if joint then
                    joints[partName] = {
                        Joint = joint,
                        C0 = joint.C0,
                        C1 = joint.C1
                    }
                end
            end
        end
        
        return joints
    end

    local function onCharacterAdded(char)
        local player = Players.LocalPlayer
        local expectedCloneName = "Phantom"
        
        if char.Name ~= expectedCloneName then
            self:cleanupCharacter()
            NotificationSystem:push("Warning", "Please reanimate first before using animations", "warning", 3)
            return
        end
        
        if self.currentAnim then
            self.currentAnim:stop()
            self.currentAnim = nil
        end
        
        self.character = char
        self.joints = createJoints(char)
        
        for _, conn in pairs(self.connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        self.connections = {}

        self.connections.ancestryChanged = char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                self:cleanupCharacter()
            end
        end)
        
        self.connections.nameChanged = char:GetPropertyChangedSignal("Name"):Connect(function()
            if char.Name ~= expectedCloneName then
                self:cleanupCharacter()
                NotificationSystem:push("Warning", "Reanimation status lost", "warning", 3)
            end
        end)
        
        NotificationSystem:push("Success", "Animations ready", "success", 2)
    end
    
    local player = Players.LocalPlayer
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

function AnimationManager:loadSettings()
    local saved = FileSystem:loadJSON(CONFIG.SETTINGS_FILE)
    self.settings = {
        animations = {},
        defaultSpeed = CONFIG.DEFAULT_SPEED,
        keybinds = {},
    }
    
    if saved then
        for key, value in pairs(saved) do
            self.settings[key] = value
        end
    end
    
    local savedAnims = FileSystem:loadJSON("animations.json")
    if savedAnims then
        self.settings.animations = savedAnims
    end
    
    local savedKeybinds = FileSystem:loadJSON("keybinds.json")
    if savedKeybinds then
        for id, keyCode in pairs(savedKeybinds) do
            self.settings.keybinds[id] = Enum.KeyCode[keyCode]
        end
    end
end

function AnimationManager:setupKeybinds()
    local function handleInput(input, processed)
        if processed then return end
        
        if input.KeyCode == CONFIG.KEYBINDS.TOGGLE_UI then
            self.ui.main.Visible = not self.ui.main.Visible
            return
        end
        
        for id, keyCode in pairs(self.settings.keybinds) do
            if input.KeyCode == keyCode then
                self:toggleAnimation(id)
                return
            end
        end
    end
    
    UserInputService.InputBegan:Connect(handleInput)
end

function AnimationManager:refreshAnimationList(searchQuery)
    for _, child in pairs(self.ui.content:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    
    self.buttons = {}
    
    local filteredAnimations = self.settings.animations
    if searchQuery and searchQuery ~= "" then
        filteredAnimations = {}
        searchQuery = string.lower(searchQuery)
        for _, animData in pairs(self.settings.animations) do
            if string.find(string.lower(animData.name), searchQuery) then
                table.insert(filteredAnimations, animData)
            end
        end
    end
    
    for _, animData in pairs(filteredAnimations) do
        local button = self.ui.createAnimButton({
            name = animData.name,
            id = animData.id,
            keybind = self.settings.keybinds[animData.id]
        })
        button.Main.Parent = self.ui.content
        
        self.buttons[animData.id] = button
        
        button.ClickArea.MouseButton1Click:Connect(function()
            self:toggleAnimation(animData.id)
        end)
        
        button.DeleteButton.MouseButton1Click:Connect(function()
            if self.currentAnim and self.currentAnim.id == animData.id then
                self:toggleAnimation(animData.id)
            end
            
            for i, anim in pairs(self.settings.animations) do
                if anim.id == animData.id then
                    if self.settings.keybinds[animData.id] then
                        self.settings.keybinds[animData.id] = nil
                        FileSystem:saveJSON("keybinds.json", self.settings.keybinds)
                    end
                    table.remove(self.settings.animations, i)
                    break
                end
            end
            
            FileSystem:saveJSON("animations.json", self.settings.animations)
            self:refreshAnimationList(self.ui.searchBox.Text)
            NotificationSystem:push("Success", "Animation removed", "success", 2)
        end)
        
        button.KeybindButton.MouseButton1Click:Connect(function()
            button.KeybindButton.Text = "..."
            
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    conn:Disconnect()
                    
                    if input.KeyCode == Enum.KeyCode.Escape then
                        button.KeybindButton.Text = "..."
                        self.settings.keybinds[animData.id] = nil
                    else
                        button.KeybindButton.Text = input.KeyCode.Name
                        self.settings.keybinds[animData.id] = input.KeyCode
                    end
                    
                    FileSystem:saveJSON("keybinds.json", self.settings.keybinds)
                end
            end)
        end)
    end
    
    local listLayout = self.ui.content:FindFirstChild("UIListLayout")
    if listLayout then
        self.ui.content.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + UI_CONFIG.Padding * 2)
    end
end

local function createModernUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = ANIMATION_UI_ID
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = UI_CONFIG.MainColor
    main.Parent = gui
    createCorner(main, UI_CONFIG.WindowCornerRadius)
    createStroke(main)
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = UI_CONFIG.SecondaryColor
    topBar.Parent = main
    createCorner(topBar, UI_CONFIG.WindowCornerRadius)
    
    local bottomCover = Instance.new("Frame")
    bottomCover.Size = UDim2.new(1, 0, 0, 20)
    bottomCover.Position = UDim2.new(0, 0, 1, -20)
    bottomCover.BackgroundColor3 = UI_CONFIG.SecondaryColor
    bottomCover.BorderSizePixel = 0
    bottomCover.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Phantom Hub Premium"
    title.TextColor3 = UI_CONFIG.TextColor
    title.Font = UI_CONFIG.HeaderFont
    title.TextSize = UI_CONFIG.TitleSize
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://6031094678"
    closeBtn.ImageColor3 = UI_CONFIG.TextColor
    closeBtn.Parent = topBar
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {ImageColor3 = UI_CONFIG.ErrorColor}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {ImageColor3 = UI_CONFIG.TextColor}):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, -UI_CONFIG.Padding*2, 0, 30)
    searchContainer.Position = UDim2.new(0, UI_CONFIG.Padding, 0, 50)
    searchContainer.BackgroundColor3 = UI_CONFIG.SecondaryColor
    searchContainer.Parent = main
    createCorner(searchContainer)
    createStroke(searchContainer)

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(0, 10, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://6031154871"
    searchIcon.ImageColor3 = UI_CONFIG.SubTextColor
    searchIcon.Parent = searchContainer

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -86, 1, 0)
    searchBox.Position = UDim2.new(0, 36, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search animations..."
    searchBox.TextColor3 = UI_CONFIG.TextColor
    searchBox.PlaceholderColor3 = UI_CONFIG.SubTextColor
    searchBox.Font = UI_CONFIG.Font
    searchBox.TextSize = UI_CONFIG.TextSize
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.Parent = searchContainer

    local addButtonGroup = Instance.new("Frame")
    addButtonGroup.Size = UDim2.new(0, 56, 0, 30)
    addButtonGroup.Position = UDim2.new(1, -56, 0, 0)
    addButtonGroup.BackgroundColor3 = UI_CONFIG.AccentColor
    addButtonGroup.Parent = searchContainer
    createCorner(addButtonGroup)

    local addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0, 56, 0, 30)
    addButton.Position = UDim2.new(0, 0, 0, 0)
    addButton.BackgroundTransparency = 1
    addButton.Text = "Add"
    addButton.TextColor3 = UI_CONFIG.TextColor
    addButton.Font = UI_CONFIG.HeaderFont
    addButton.TextSize = 15
    addButton.Parent = addButtonGroup

    addButtonGroup.MouseEnter:Connect(function()
        TweenService:Create(addButtonGroup, TweenInfo.new(0.2), {BackgroundColor3 = UI_CONFIG.AccentColorDark}):Play()
    end)

    addButtonGroup.MouseLeave:Connect(function()
        TweenService:Create(addButtonGroup, TweenInfo.new(0.2), {BackgroundColor3 = UI_CONFIG.AccentColor}):Play()
    end)
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -UI_CONFIG.Padding*2, 1, -155)
    contentFrame.Position = UDim2.new(0, UI_CONFIG.Padding, 0, 93)
    contentFrame.BackgroundColor3 = UI_CONFIG.SecondaryColor
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = main
    createCorner(contentFrame)
    createStroke(contentFrame)
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = UI_CONFIG.AccentColor
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = contentFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, UI_CONFIG.Padding)
    padding.PaddingBottom = UDim.new(0, UI_CONFIG.Padding)
    padding.Parent = content
    
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, -UI_CONFIG.Padding*2, 0, 40)
    controlsFrame.Position = UDim2.new(0, UI_CONFIG.Padding, 1, -50)
    controlsFrame.BackgroundColor3 = UI_CONFIG.SecondaryColor
    controlsFrame.Parent = main
    createCorner(controlsFrame)
    createStroke(controlsFrame)
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 60, 1, 0)
    speedLabel.Position = UDim2.new(0, 10, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed:"
    speedLabel.TextColor3 = UI_CONFIG.TextColor
    speedLabel.Font = UI_CONFIG.Font
    speedLabel.TextSize = UI_CONFIG.TextSize
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = controlsFrame
    
    local speedValue = Instance.new("TextLabel")
    speedValue.Size = UDim2.new(0, 40, 1, 0)
    speedValue.Position = UDim2.new(1, -50, 0, 0)
    speedValue.BackgroundTransparency = 1
    speedValue.Text = "1.00"
    speedValue.TextColor3 = UI_CONFIG.TextColor
    speedValue.Font = UI_CONFIG.Font
    speedValue.TextSize = UI_CONFIG.TextSize
    speedValue.Parent = controlsFrame
    
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -170, 0, UI_CONFIG.SliderHeight)
    sliderContainer.Position = UDim2.new(0, 75, 0.5, -UI_CONFIG.SliderHeight/2)
    sliderContainer.BackgroundColor3 = UI_CONFIG.MainColor
    sliderContainer.Parent = controlsFrame
    createCorner(sliderContainer, UDim.new(0, UI_CONFIG.SliderHeight/2))
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = UI_CONFIG.AccentColor
    sliderFill.Parent = sliderContainer
    createCorner(sliderFill, UDim.new(0, UI_CONFIG.SliderHeight/2))
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new(1, -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = UI_CONFIG.TextColor
    sliderKnob.Parent = sliderFill
    createCorner(sliderKnob, UDim.new(0, 8))
    createStroke(sliderKnob, UI_CONFIG.AccentColor)
    
    local dragging = false
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local isDragging = false
    local lastValidValue = 1.00
    
    local function updateSliderVisual(pos)
        pos = math.clamp(pos, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        local value = 0.1 + (pos * 3.9)
        value = math.floor(value * 100) / 100
        speedValue.Text = string.format("%.2f", value)
        lastValidValue = value
        return value
    end
    
    local function handleSliderInput(input)
        local mousePos = input.Position
        local sliderPos = (mousePos.X - sliderContainer.AbsolutePosition.X) / sliderContainer.AbsoluteSize.X
        return updateSliderVisual(sliderPos)
    end
    
    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            local newSpeed = handleSliderInput(input)
            AnimationManager:updateSpeed(newSpeed)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newSpeed = handleSliderInput(input)
            AnimationManager:updateSpeed(newSpeed)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    local function createAnimButton(data)
        local button = Instance.new("Frame")
        button.Size = UDim2.new(1, -UI_CONFIG.Padding*2, 0, 40)
        button.BackgroundColor3 = UI_CONFIG.MainColor
        button.Parent = content
        createCorner(button)
        createStroke(button)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -100, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = data.name
        nameLabel.TextColor3 = UI_CONFIG.TextColor
        nameLabel.Font = UI_CONFIG.Font
        nameLabel.TextSize = UI_CONFIG.TextSize
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = button
        
        local clickArea = Instance.new("TextButton")
        clickArea.Size = UDim2.new(1, 0, 1, 0)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = button
        clickArea.ZIndex = 1
        
        local idLabel = Instance.new("TextLabel")
        idLabel.Size = UDim2.new(0, 60, 0, 16)
        idLabel.Position = UDim2.new(0, 10, 0.75, -8)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = data.id
        idLabel.TextColor3 = UI_CONFIG.SubTextColor
        idLabel.Font = UI_CONFIG.Font
        idLabel.TextSize = UI_CONFIG.SubTextSize
        idLabel.TextXAlignment = Enum.TextXAlignment.Left
        idLabel.Parent = button
        
        local keybindBtn = Instance.new("TextButton")
        keybindBtn.Size = UDim2.new(0, 36, 0, 24)
        keybindBtn.Position = UDim2.new(1, -80, 0.5, -12)
        keybindBtn.BackgroundColor3 = UI_CONFIG.SecondaryColor
        keybindBtn.Text = data.keybind and data.keybind.Name or "..."
        keybindBtn.TextColor3 = UI_CONFIG.TextColor
        keybindBtn.Font = UI_CONFIG.Font
        keybindBtn.TextSize = UI_CONFIG.SubTextSize
        keybindBtn.ZIndex = 2
        keybindBtn.Parent = button
        createCorner(keybindBtn)
        createStroke(keybindBtn)
        
        local deleteBtn = Instance.new("ImageButton")
        deleteBtn.Size = UDim2.new(0, 24, 0, 24)
        deleteBtn.Position = UDim2.new(1, -30, 0.5, -12)
        deleteBtn.BackgroundTransparency = 1
        deleteBtn.Image = "rbxassetid://6031094678"
        deleteBtn.ImageColor3 = UI_CONFIG.SubTextColor
        deleteBtn.ZIndex = 2
        deleteBtn.Parent = button
        
        deleteBtn.MouseEnter:Connect(function()
            TweenService:Create(deleteBtn, TweenInfo.new(0.2), {ImageColor3 = UI_CONFIG.ErrorColor}):Play()
        end)
        
        deleteBtn.MouseLeave:Connect(function()
            TweenService:Create(deleteBtn, TweenInfo.new(0.2), {ImageColor3 = UI_CONFIG.SubTextColor}):Play()
        end)
        
        local isSelected = false
        
        local function updateVisuals()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = isSelected and UI_CONFIG.AccentColorDark or UI_CONFIG.MainColor
            }):Play()
        end
        
        clickArea.MouseEnter:Connect(function()
            if not isSelected then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = UI_CONFIG.HoverColor
                }):Play()
            end
        end)
        
        clickArea.MouseLeave:Connect(function()
            if not isSelected then
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = UI_CONFIG.MainColor
                }):Play()
            end
        end)
        
        return {
            Main = button,
            ClickArea = clickArea,
            KeybindButton = keybindBtn,
            DeleteButton = deleteBtn,
            SetSelected = function(selected)
                isSelected = selected
                updateVisuals()
            end
        }
    end
    
    local function createAddAnimPrompt()
        local promptBg = Instance.new("Frame")
        promptBg.Size = UDim2.new(1, 0, 1, 0)
        promptBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        promptBg.BackgroundTransparency = 0.5
        promptBg.ZIndex = 10
        promptBg.Parent = main
        createCorner(promptBg, UI_CONFIG.WindowCornerRadius)
        
        local prompt = Instance.new("Frame")
        prompt.Size = UDim2.new(0.9, 0, 0, 180)
        prompt.Position = UDim2.new(0.05, 0, 0.5, -90)
        prompt.BackgroundColor3 = UI_CONFIG.MainColor
        prompt.ZIndex = 11
        prompt.Parent = promptBg
        createCorner(prompt, UI_CONFIG.WindowCornerRadius)
        createStroke(prompt, UI_CONFIG.AccentColor)
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 40)
        title.Text = "Add Animation"
        title.TextColor3 = UI_CONFIG.TextColor
        title.Font = UI_CONFIG.HeaderFont
        title.TextSize = UI_CONFIG.TitleSize
        title.BackgroundTransparency = 1
        title.ZIndex = 11
        title.Parent = prompt
        
        local function createInputField(text, yPos)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 40)
            container.Position = UDim2.new(0, 10, 0, yPos)
            container.BackgroundColor3 = UI_CONFIG.SecondaryColor
            container.ZIndex = 11
            container.Parent = prompt
            createCorner(container)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.25, 0, 1, 0)
            label.Text = text
            label.TextColor3 = UI_CONFIG.TextColor
            label.Font = UI_CONFIG.Font
            label.TextSize = UI_CONFIG.TextSize
            label.BackgroundTransparency = 1
            label.ZIndex = 11
            label.Parent = container
            
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(0.75, -10, 1, -10)
            input.Position = UDim2.new(0.25, 5, 0, 5)
            input.Text = ""
            input.PlaceholderText = "Enter " .. string.lower(text) .. "..."
            input.TextColor3 = UI_CONFIG.TextColor
            input.PlaceholderColor3 = UI_CONFIG.SubTextColor
            input.BackgroundColor3 = UI_CONFIG.MainColor
            input.Font = UI_CONFIG.Font
            input.TextSize = UI_CONFIG.TextSize
            input.ZIndex = 11
            input.Parent = container
            createCorner(input)
            
            return input
        end
        
        local nameInput = createInputField("Name", 40)
        local idInput = createInputField("ID", 90)
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -20, 0, 30)
        buttonContainer.Position = UDim2.new(0, 10, 1, -40)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.ZIndex = 11
        buttonContainer.Parent = prompt
        
        local cancelBtn = Instance.new("TextButton")
        cancelBtn.Size = UDim2.new(0.5, -5, 1, 0)
        cancelBtn.BackgroundColor3 = UI_CONFIG.SecondaryColor
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = UI_CONFIG.TextColor
        cancelBtn.Font = UI_CONFIG.Font
        cancelBtn.TextSize = UI_CONFIG.TextSize
        cancelBtn.ZIndex = 11
        cancelBtn.Parent = buttonContainer
        createCorner(cancelBtn)
        
        local addBtn = Instance.new("TextButton")
        addBtn.Size = UDim2.new(0.5, -5, 1, 0)
        addBtn.Position = UDim2.new(0.5, 5, 0, 0)
        addBtn.BackgroundColor3 = UI_CONFIG.AccentColor
        addBtn.Text = "Add"
        addBtn.TextColor3 = UI_CONFIG.TextColor
        addBtn.Font = UI_CONFIG.Font
        addBtn.TextSize = UI_CONFIG.TextSize
        addBtn.ZIndex = 11
        addBtn.Parent = buttonContainer
        createCorner(addBtn)
        
        return {
            promptBg = promptBg,
            nameInput = nameInput,
            idInput = idInput,
            cancelBtn = cancelBtn,
            addBtn = addBtn
        }
    end
    
    return {
        gui = gui,
        main = main,
        content = content,
        searchBox = searchBox,
        addButton = addButton,
        speedValue = speedValue,
        sliderFill = sliderFill,
        createAnimButton = createAnimButton,
        createAddAnimPrompt = createAddAnimPrompt,
        updateSliderVisual = updateSliderVisual
    }
end

function AnimationManager:init()
    self.ui = createModernUI()
    self:loadSettings()
    
    local debounce = false
    self.ui.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if debounce then return end
        debounce = true
        
        task.delay(0.1, function()
            self:refreshAnimationList(self.ui.searchBox.Text)
            debounce = false
        end)
    end)
    
    if self.settings.defaultSpeed then
        local pos = (self.settings.defaultSpeed - 0.1) / 3.9
        self.ui.sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        self.ui.speedValue.Text = string.format("%.2f", self.settings.defaultSpeed)
    end
    
    self:setupCharacter()
    self:setupKeybinds()
    self:refreshAnimationList()
    
    self.ui.addButton.MouseButton1Click:Connect(function()
        local addPrompt = self.ui.createAddAnimPrompt()
        
        addPrompt.cancelBtn.MouseButton1Click:Connect(function()
            addPrompt.promptBg:Destroy()
        end)
        
        addPrompt.addBtn.MouseButton1Click:Connect(function()
            local name = addPrompt.nameInput.Text
            local id = tonumber(addPrompt.idInput.Text)
            
            if name ~= "" and id then
                local anim = self:loadAnimation(id)
                if anim then
                    table.insert(self.settings.animations, {
                        name = name,
                        id = id
                    })
                    FileSystem:saveJSON("animations.json", self.settings.animations)
                    self:refreshAnimationList()
                    addPrompt.promptBg:Destroy()
                    NotificationSystem:push("Success", "Animation added", "success", 2)
                else
                    NotificationSystem:push("Error", "Invalid animation ID", "error", 2)
                end
            else
                NotificationSystem:push("Error", "Please fill all fields", "error", 2)
            end
        end)
    end)
    
    self.ui.gui.Parent = gethui()
    
    NotificationSystem:push("Phantom Hub", "Animation system loaded", "info", 3)
    log("UI Initialized")
    
    return self
end

local manager = AnimationManager:init()

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == CONFIG.KEYBINDS.TOGGLE_UI then
        manager.ui.main.Visible = not manager.ui.main.Visible
    end
    
    if input.KeyCode == CONFIG.KEYBINDS.SPEED_UP then
        local currentSpeed = manager.settings.defaultSpeed or CONFIG.DEFAULT_SPEED
        local newSpeed = math.min(currentSpeed + 0.25, 4)
        manager:updateSpeed(newSpeed)
    end
    
    if input.KeyCode == CONFIG.KEYBINDS.SPEED_DOWN then
        local currentSpeed = manager.settings.defaultSpeed or CONFIG.DEFAULT_SPEED
        local newSpeed = math.max(currentSpeed - 0.25, 0.1)
        manager:updateSpeed(newSpeed)
    end
end)

log("Script loaded and running")
