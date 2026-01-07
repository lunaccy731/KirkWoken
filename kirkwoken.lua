
local RunService = game:GetService("RunService") 
local Players = game:GetService("Players") 
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace") 
local NPCFolder = Workspace:WaitForChild("NPCs") 
local Light = game:GetService("Lighting")



local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local Camera = Workspace.CurrentCamera

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()





local Settings = {
    HealthESP = false,
    BoxEsp = false,
    HealthText = false,
    SkeletonESP = false,
    NameESP = false,
    NpcNameEsp = false,
    MobNameEsp = false,
    EnableChams = false,
    MobChams = false,
    MobHealthESP = false,
    GuildEspEnabled = false,
    PlayerDinstace = false,
    MaxESPDistance = 1000,
    SpeedActive = false,
    SpeedEnabled = false,
    noclipActive = false,
    noclip = false,
    WalkSpeed = 15,
    InfJumpEnabled = false,
    InfJumpActive = false,
    NoFallDamage = false,
    NoFog = false,
    SkyColor = false,
    WorldColor = false,
    ChestEspEnabled = false,
    TrialTP = false,
    LuminantTpEaster = false,
    LuminantTpEtrea = false,
    ClickToSpectateEnabled = false,
    GuildTP = false,
    DepthsTP = false,
    JumpPower = 55,
    SpeedKeybind = Enum.KeyCode.F,
    NoclipKeyBind = Enum.KeyCode.G,
}

local Colors = {
    NameColor =  Color3.fromRGB(240, 52, 52), 
    BoxesColor =  Color3.fromRGB(255, 0, 255), 
    ChamsColor =  Color3.fromRGB(127, 0, 255),
    SkyColorValue = Color3.fromRGB(255, 0, 255),
    WorldColorValue = Color3.fromRGB(127, 0, 255)


}

--Tables Drawing
local NameTexts = {}
local Distances = {}
local Boxes = {}
local Skeletons = {}
local HealthTexts = {}
local NPCNameTexts = {}
local MobNameTexts = {}
local HealthTextsMobs = {}
local MobChams = {}
local Chams = {}
local ChestTexts = {}
local GuildTexts = {}

--Tables 
local PlayerList = {}
local NPCList = {}
local ChestList = {}
local MobList = {}
local GuildList = {}

local function worldToScreen(worldPos)
    local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(pos.X, pos.Y), onScreen
end


local function UpdatePlayers()
    table.clear(PlayerList)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayerList, player)
        end
    end
end

Players.PlayerAdded:Connect(UpdatePlayers)
Players.PlayerRemoving:Connect(UpdatePlayers)
UpdatePlayers()

local function UpdateNPCs()
    NPCList = Workspace.NPCs:GetChildren()
end

Workspace.NPCs.ChildAdded:Connect(UpdateNPCs)
Workspace.NPCs.ChildRemoved:Connect(UpdateNPCs)
UpdateNPCs()

local function UpdateChests()
    ChestList = Workspace.Thrown:GetChildren()
end

Workspace.Thrown.ChildAdded:Connect(UpdateChests)
Workspace.Thrown.ChildRemoved:Connect(UpdateChests)
UpdateChests()

local function UpdateMobs()
    MobList = Workspace.Live:GetChildren()
end

Workspace.Live.ChildAdded:Connect(UpdateMobs)
Workspace.Live.ChildRemoved:Connect(UpdateMobs)
UpdateMobs()


local function RemoveDrawing(d)
    if d then
        pcall(function()
            d:Remove()
        end)
    end
end

local function ClearAllESP()
    --Player 
    for _, d in pairs(NameTexts) do RemoveDrawing(d) end
    for _, d in pairs(Boxes) do RemoveDrawing(d) end
    for _, d in pairs(Distances) do RemoveDrawing(d) end
    for _, d in pairs(HealthTexts) do RemoveDrawing(d) end

    for _, lines in pairs(Skeletons) do
        for _, line in pairs(lines) do
            RemoveDrawing(line)
        end
    end
    --NPC n Mobs
    for _, d in pairs(NPCNameTexts) do RemoveDrawing(d) end
    for _, d in pairs(MobNameTexts) do RemoveDrawing(d) end
    for _, d in pairs(HealthTextsMobs) do RemoveDrawing(d) end

    --Chams 
    for _, h in pairs(Chams) do if h then h:Destroy() end end
    for _, h in pairs(MobChams) do if h then h:Destroy() end end

    --Chests
    for _,h in pairs(ChestTexts)do if h then h:Destroy()end end
    -- Guilds
    for _,h in pairs(GuildTexts)do if h then h:Destroy()end end

end

local function GetDistance(EnemyPosition)
   
    local character = LocalPlayer.Character
    if not character then return math.huge end  

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end  

    local distance = (EnemyPosition - rootPart.Position).Magnitude
    return distance
end


--NameESP
local function NameESP(player)
    if not Settings.NameESP or Library.Unloaded then
        local text = NameTexts[player]
        if text then
            text.Visible = false
            NameTexts[player] = nil
        end
        return
    end

    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")
    if not head or not humanoid then return end

    if GetDistance(head.Position) > Settings.MaxESPDistance then
        local text = NameTexts[player]
        if text then
            text.Visible = false
            NameTexts[player] = nil
        end
        return
    end

    local text = NameTexts[player]
    if not text then
        text = Drawing.new("Text")
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Color = Colors.NameColor
        NameTexts[player] = text
    end
    NameTexts[player].Color = Colors.NameColor

    local screenPos, onScreen = worldToScreen(head.Position + Vector3.new(0, 5.5, 0))
    if not onScreen then
        text.Visible = false
        return
    end

    text.Text = player.DisplayName ~= "" and player.DisplayName or player.Name
    text.Position = screenPos
    text.Visible = true
end

local function PlayerDistanceESP(player)
    if not Settings.PlayerDinstace or Library.Unloaded then
        local text = Distances[player]
        if text then
            text.Visible = false
            Distances[player] = nil
        end
        return
    end

    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if  not humanoid or not hrp then return end

    if GetDistance(hrp.Position) > Settings.MaxESPDistance then
        local text = Distances[player]
        if text then
            text.Visible = false
            Distances[player] = nil     
        end
        return
    end

    t
    local text = Distances[player]
    if not text then
        text = Drawing.new("Text")
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Color = Color3.fromRGB(255, 255, 255)
        Distances[player] = text
    end

   
    local screenPos, onScreen = worldToScreen(hrp.Position + Vector3.new(3, -5.5, 0))
    if not onScreen then
        text.Visible = false
        return
    end
    local Distance = GetDistance(hrp.Position)

    text.Text =  math.floor(Distance) .. " Studs"
    text.Position = screenPos + Vector2.new(-25, 50)
    text.Visible = true
end

local function BoxESP(player) 
   local box = Boxes[player]
 if not Settings.BoxEsp or Library.Unloaded then
    if box then
        box.Visible = false
        Boxes[player] = nil
    end
    return
 end 
   local char = player.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
      if GetDistance(hrp.Position) > Settings.MaxESPDistance then
        if box then
          box.Visible = false 
          Boxes[player] = nil
        end
        return
    end

     local headPos, headOn = worldToScreen(head.Position + Vector3.new(0, 2, 0))
    local footPos, footOn = worldToScreen(hrp.Position - Vector3.new(0, 4.5, 0))
    if not headOn or not footOn then
        if box then box.Visible = false end
        return
    end
     local height = footPos.Y - headPos.Y
    local width = height / 2

       if not box then
        box = Drawing.new("Square")
        box.Filled = false
        box.Thickness = 1
        box.Color = Colors.BoxesColor
        Boxes[player] = box
    end
      Boxes[player].Color = Colors.BoxesColor

    box.Size = Vector2.new(width, height)
    box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
    box.Visible = true



end

local function SkeletonESP(player)
    local lines = Skeletons[player]

    if not Settings.SkeletonESP or Library.Unloaded then
        if lines then
            for _, l in pairs(lines) do
                l.Visible = false
                Skeletons[player] = nil
            end
        end
        return
    end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not hrp or not head or not torso then return end

      
    local dist = GetDistance(hrp.Position)
    if dist > Settings.MaxESPDistance then
        if lines then
            for _, l in pairs(lines) do
                l.Visible = false
                 l:Remove() 
            end
                Skeletons[player] = nil

        end
        return
    end

    --parts
    local parts = {
        head,
        torso,
        hrp,
        char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
        char:FindFirstChild("LeftLowerArm"),
        char:FindFirstChild("LeftHand"),
        char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
        char:FindFirstChild("RightLowerArm"),
        char:FindFirstChild("RightHand"),
        char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
        char:FindFirstChild("LeftLowerLeg"),
        char:FindFirstChild("LeftFoot"),
        char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
        char:FindFirstChild("RightLowerLeg"),
        char:FindFirstChild("RightFoot"),
    }

    local bones = {
        {parts[1], parts[2]}, {parts[2], parts[3]},
        {parts[2], parts[4]}, {parts[4], parts[5]}, {parts[5], parts[6]},
        {parts[2], parts[7]}, {parts[7], parts[8]}, {parts[8], parts[9]},
        {parts[2], parts[10]}, {parts[10], parts[11]}, {parts[11], parts[12]},
        {parts[2], parts[13]}, {parts[13], parts[14]}, {parts[14], parts[15]},
    }

    -- Create lines if missing
    if not Skeletons[player] then
        Skeletons[player] = {}
        for i = 1, #bones do
            local l = Drawing.new("Line")
            l.Color = Color3.fromRGB(255, 255, 255)
            l.Thickness = 2
            l.Visible = false
            Skeletons[player][i] = l
        end
    end

    -- Update lines
    for i, bone in ipairs(bones) do
        local a, b = bone[1], bone[2]
        local line = Skeletons[player][i]

        if a and b then
            local p1, on1 = worldToScreen(a.Position)
            local p2, on2 = worldToScreen(b.Position)

            if on1 and on2 then
                line.From = p1
                line.To = p2
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

local function HealthTextESP(player)
    local text = HealthTexts[player]

    if not Settings.HealthESP or Library.Unloaded then
        if text then 
        text.Visible = false 
        HealthTexts[player] = nil
        end
        return
    end

    local char = player.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")

       if GetDistance(head.Position) > Settings.MaxESPDistance then
        if text then
             text.Visible = false
             HealthTexts[player] = nil
              end
        return
    end

    if not head or not humanoid or humanoid.Health <= 0 then
        if text then text.Visible = false end
        return
    end

   

    local pos, onScreen = worldToScreen(head.Position + Vector3.new(3, 2.5, 0))
    if not onScreen then
        if text then text.Visible = false end
        return
    end

    if not text then
        text = Drawing.new("Text")
        text.Size = 14
        text.Color = Color3.fromRGB(0, 255, 0)
        text.Outline = true
        HealthTexts[player] = text
    end

    text.Text = tostring(math.floor(humanoid.Health))
    text.Position = pos --+ Vector2.new(-35, -150)
    text.Visible = true
end

local function NPCNameESP(npc)

        if not Settings.NpcNameEsp or Library.Unloaded then
        if NPCNameTexts[npc] then
         NPCNameTexts[npc].Visible = false
          NPCNameTexts[npc] = nil
        end
        return
    end

    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    
    -- Distance check
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lhrp then return end

    local dist = (lhrp.Position - hrp.Position).Magnitude
    if dist > Settings.MaxESPDistance then
        if NPCNameTexts[npc] then
            NPCNameTexts[npc].Visible = false
             NPCNameTexts[npc] = nil
        end
        return
    end


    if not NPCNameTexts[npc] then
        local text = Drawing.new("Text")
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Color = Color3.fromRGB(255, 170, 255) -- purple NPC color
        NPCNameTexts[npc] = text
    end



    local screenPos, onScreen = worldToScreen(hrp.Position + Vector3.new(0, 3, 0))
    if not onScreen then
        NPCNameTexts[npc].Visible = false
        return
    end

    local txt = NPCNameTexts[npc]
    txt.Text = npc.Name -- 
    txt.Position = screenPos
    txt.Visible = true
end


local function MobNameESP(mob)

        if not Settings.MobNameEsp or Library.Unloaded then
        if MobNameTexts[mob] then
            MobNameTexts[mob].Visible = false
             MobNameTexts[mob] = nil
        end
        return
    end


    local humanoid = mob:FindFirstChild("Humanoid")
    if not humanoid then return end

    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    
   
    local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lhrp then return end

    if mob:FindFirstChild("ControllerManager") then
    return -- skip this its a player
end

    local dist = (lhrp.Position - hrp.Position).Magnitude
    if dist > Settings.MaxESPDistance then
        if MobNameTexts[mob] then
            MobNameTexts[mob].Visible = false
            MobNameTexts[mob] = nil
        end
        return
    end


    if not MobNameTexts[mob] then
        local text = Drawing.new("Text")
        text.Size = 14
        text.Center = true
        text.Outline = true
        text.Color = Color3.fromRGB(255, 170, 255)
        MobNameTexts[mob] = text
    end

    local screenPos, onScreen = worldToScreen(hrp.Position + Vector3.new(0, 3, 0))
    if not onScreen then
        MobNameTexts[mob].Visible = false
        return
    end

    local txt = MobNameTexts[mob]
    txt.Text = mob.Name -- 
    txt.Position = screenPos
    txt.Visible = true
end

local function ChamsESP(player)
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp or humanoid.Health <= 0 then
        if Chams[player] then
            Chams[player]:Destroy()
            Chams[player] = nil
        end
        return
    end

    if not Settings.EnableChams or Library.Unloaded then
        if Chams[player] then
            Chams[player]:Destroy()
            Chams[player] = nil
        end
        return
    end

    if GetDistance(hrp.Position) > Settings.MaxESPDistance then
        if Chams[player] then
            Chams[player]:Destroy()
            Chams[player] = nil
        end
        return
    end

    if not Chams[player] then
        local h = Instance.new("Highlight")
        h.Name = "Chams"
        h.Adornee = char
        h.FillColor = Colors.ChamsColor
        h.FillTransparency = 0.5
        h.OutlineColor = Color3.fromRGB(127, 0, 255)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char

        Chams[player] = h
    end
    Chams[player].FillColor = Colors.ChamsColor--for color picker

end

local function MobChamsESP(mob)
    if not Settings.MobChams or Library.Unloaded then
        if MobChams[mob] then
            MobChams[mob]:Destroy()
            MobChams[mob] = nil
        end
        return
    end

    if not mob:IsA("Model") then return end

    local humanoid = mob:FindFirstChild("Humanoid")
    local hrp = mob:FindFirstChild("HumanoidRootPart")

    if not humanoid or not hrp or humanoid.Health <= 0 then
        if MobChams[mob] then
            MobChams[mob]:Destroy()
            MobChams[mob] = nil
        end
        return
    end

    if mob:FindFirstChild("ControllerManager") then
        return
    end


    if GetDistance(hrp.Position) > Settings.MaxESPDistance then
        if MobChams[mob] then
            MobChams[mob]:Destroy()
            MobChams[mob] = nil
        end
        return
    end

    -- Create highlight
    if not MobChams[mob] then
        local h = Instance.new("Highlight") -- create a highlight instance
        h.Name = "MobCham"
        h.Adornee = mob
        h.FillColor = Color3.fromRGB(176, 224, 230)
        h.FillTransparency = 0.5
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = mob

        MobChams[mob] = h
    end
end





local function HealthTextESPMobs(mob)
    local text = HealthTextsMobs[mob]

    if not Settings.MobHealthESP or Library.Unloaded then
        if text then 
        text.Visible = false 
        HealthTextsMobs[mob] = nil
      
        end
        return
    end
      if not mob:IsA("Model") then return end

local humanoid = mob:FindFirstChild("Humanoid")

    local hrp = mob:FindFirstChild("HumanoidRootPart")

       if GetDistance(hrp.Position) > Settings.MaxESPDistance then
        if text then
             text.Visible = false
             HealthTextsMobs[mob] = nil
              end
        return
    end

    if not hrp or not humanoid or humanoid.Health <= 0 then
        if text then text.Visible = false end
        return
    end
  if mob:FindFirstChild("ControllerManager") then
    return
  end
   

    local pos, onScreen = worldToScreen(hrp.Position + Vector3.new(3, 1.0, 0))
    if not onScreen then
        if text then text.Visible = false end
        return
    end

    if not text then
        text = Drawing.new("Text")
        text.Size = 18
        text.Color = Color3.fromRGB(0, 255, 0)
        text.Outline = true
        HealthTextsMobs[mob] = text
    end

    text.Text = tostring(math.floor(humanoid.Health))
    text.Position = pos --+ Vector2.new(-35, -150)
    text.Visible = true
end

local function ChestESP(chest)
    local text = ChestTexts[chest]

    if not Settings.ChestEspEnabled or Library.Unloaded then
        if text then
            text.Visible = false
            ChestTexts[chest] = nil
        end
        return
    end

    local root = chest:FindFirstChild("RootPart")
    if not root then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = (root.Position - hrp.Position).Magnitude
    if dist > Settings.MaxESPDistance then
        if text then
            text.Visible = false
            ChestTexts[chest] = nil
        end
        return
    end

    if not text then
        text = Drawing.new("Text")
        text.Size = 15
        text.Center = true
        text.Outline = true
        text.Color = Color3.fromRGB(255, 255, 255)
        ChestTexts[chest] = text
    end

    local screenPos, onScreen = worldToScreen(root.Position + Vector3.new(0, 3, 0))
    if not onScreen then
        text.Visible = false
        return
    end

    text.Text = "Chest"
    text.Position = screenPos
    text.Visible = true
end




local function GuildBaseEsp(door)
    local text = GuildTexts[door]
    if not Settings.GuildEspEnabled or Library.Unloaded then
        if text then
        GuildTexts[door].Visible = false
          GuildTexts[door] = nil
        end
        return
    end
    local pos = door.CFrame.Position
    local distance = GetDistance(pos)
    if distance > Settings.MaxESPDistance then
        if text then
            text.Visible = false
            GuildTexts[door] = nil
        end
        return 
    end
        if not text then
        text = Drawing.new("Text")
        text.Size = 15
        text.Center = true
        text.Outline = true
        text.Color = Color3.fromRGB(33, 192, 227)--blue?
        GuildTexts[door] = text
    end
     local screenPos, onScreen = worldToScreen(pos + Vector3.new(0, 3, 0))
    if not onScreen then
        text.Visible = false
        return
    end

    text.Text = door.Name
    text.Position = screenPos
    text.Visible = true

end

local function UpdateGuildESP()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name:match("GuildDoor") then
            table.insert(GuildList,child)
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    if child.Name:match("GuildDoor") then
        UpdateGuildESP()
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child.Name:match("GuildDoor") then
        UpdateGuildESP()
    end
end)



local movementDirection = Vector3.new(0, 0, 0)

-- Function to update the movement direction based on key inputs
local function updateMovementDirection()
    movementDirection = Vector3.new(0, 0, 0)
    
    -- Get the camera's look vector
    local cameraLookVector = Camera.CFrame.LookVector
    
    -- Break down the look vector into the XZ plane
    local cameraDirection = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

    -- Right direction relative to the camera
    local cameraRight = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z).Unit

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        movementDirection = movementDirection + cameraDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        movementDirection = movementDirection - cameraDirection
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        movementDirection = movementDirection - cameraRight
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        movementDirection = movementDirection + cameraRight
    end
    

    -- Normalize direction to ensure consistent speed
    if movementDirection.Magnitude > 0 then
        movementDirection = movementDirection.Unit
    end
end

-- Function to move the character using CFrame with increased speed
local function moveCharacter(deltaTime)
    if movementDirection.Magnitude > 0 then
        -- Calculate the new position using CFrame
        local displacement = movementDirection * Settings.WalkSpeed * deltaTime
        local newCFrame = humanoidRootPart.CFrame + displacement
        humanoidRootPart.CFrame = newCFrame
    end
end





-- Input listeners to update the movement direction
UserInputService.InputBegan:Connect(updateMovementDirection)
UserInputService.InputEnded:Connect(updateMovementDirection)
RunService.RenderStepped:Connect(function(deltaTime)
    if(Settings.SpeedEnabled and Settings.SpeedActive)then
        updateMovementDirection()
        moveCharacter(deltaTime)
    end
end)
--Noclip loop
local NoClipCache = {}--stores the values of all parts
RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    if not Settings.noclip or not Settings.noclipActive then return end

    local character = LocalPlayer.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then

            if Settings.noclip and Settings.noclipActive then
                if NoClipCache[part] == nil then
                    NoClipCache[part] = part.CanCollide
                end
                part.CanCollide = false

            else
                if NoClipCache[part] ~= nil then
                    part.CanCollide = NoClipCache[part]
                    NoClipCache[part] = nil
                end
            end

        end
    end
end)

local function UpdateInfJump(rootPart)
    if not Settings.InfJumpEnabled or not Settings.InfJumpActive then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    --cancel the downward velocity 
     rootPart.AssemblyLinearVelocity =
        Vector3.new(
            rootPart.AssemblyLinearVelocity.X,
            0,--here
            rootPart.AssemblyLinearVelocity.Z
        )
         --Apply upward boost
    rootPart.AssemblyLinearVelocity =
    rootPart.AssemblyLinearVelocity + Vector3.new(0, Settings.JumpPower, 0)-- should use a variable here


end


RunService.RenderStepped:Connect(function()
    if not Settings.InfJumpEnabled or not Settings.InfJumpActive then return end
    if not LocalPlayer.Character then return end

    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    UpdateInfJump(hrp)
end)

--NoFog 
local originalDensity

local function NoFog()
    if not Settings.NoFog then return end
    local atmosphere = Light:FindFirstChild("Atmosphere")
    if not atmosphere then return end

    --Store original  
    if originalDensity == nil then
        originalDensity = atmosphere.Density
    end

    atmosphere.Density = 0
end
local function ResetFog()
    local atmosphere = Light:FindFirstChild("Atmosphere")
    if not atmosphere or originalDensity == nil then return end

    atmosphere.Density = originalDensity
end

local function SkyColor()
    if not Settings.SkyColor then return end
    local atmosphere = Light:FindFirstChild("Atmosphere")
    if not atmosphere then return end
    atmosphere.Color = Colors.SkyColorValue

  
end

local function WorldColor()
    if not Settings.WorldColor then return end
    local worldcolor = Light:FindFirstChild("WorldColor")
    if not worldcolor then return end
    worldcolor.TintColor = Colors.WorldColorValue

  
end

--Misc and removals
RunService.RenderStepped:Connect(function()
    if Settings.NoFog then
        NoFog()
    else
        ResetFog()
    end
    if Settings.SkyColor then
        SkyColor()
    end
    if Settings.WorldColor then
        WorldColor()
    end
end)





local function TeleportTo(position)
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    char:PivotTo(CFrame.new(position))
end

local PlayerNames = {}
local SelectedPlayerName = nil
local function ClickToSpectate(player)
    if not Settings.ClickToSpectateEnabled then return end
    if not Camera or not player then return end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Camera.CameraType = Enum.CameraType.Scriptable 

    local targetPos = hrp.Position
    local cameraOffset = Vector3.new(0, 10, 20)
    local cameraPos = targetPos + cameraOffset

    Camera.CFrame = CFrame.new(cameraPos, targetPos)
end

local GuildNames = {}
local SelectedGuildName = nil

local function TeleportToSelectedGuild()
    if not Settings.GuildTP then return end
    if not SelectedGuildName then return end

    local door = GuildDoors[SelectedGuildName]
    if not door or not door:IsA("BasePart") then return end

    TeleportTo(door.Position + Vector3.new(0, 0, 0))
end


--Teleports
RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end

    if Settings.LuminantTpEaster then
        TeleportTo(Vector3.new(-2632.86084, 628.632935, -6707.99805))

    elseif Settings.LuminantTpEtrea then
        TeleportTo(Vector3.new(-514.263, 665.174316, -4772.3208))

    elseif Settings.TrialTP then
        TeleportTo(Vector3.new(-959.787659, 146.996887, -6659.63037))

    elseif Settings.DepthsTP then
        TeleportTo(Vector3.new(39911.3672, 39980.9375, 39708.320))    
    end


end)

task.spawn(function()
    while true do
        if Settings.GuildTP then
         TeleportToSelectedGuild() 

         end
        task.wait(0.4)
    end
end)



 
local Window = Library:CreateWindow({
    

    Title = 'KirkWoken Beta',
    Center = true,
    AutoShow = true,
    TabPadding = 6
})

local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
    ['Combat & Exploits'] = Window:AddTab('Combat & Exploits'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('             Visual')
LeftGroupBox:AddLabel("Players", true) 
--Toggles for ESP
LeftGroupBox:AddToggle('NameEsp', {
    Text = 'Name Esp',
    Default = false,
  --Tooltip = 'This is a tooltip', 

})

LeftGroupBox:AddToggle('BoxEsp', {
    Text = 'Box Esp',
    Default = false
})

LeftGroupBox:AddToggle('HealthEsp', {
    Text = 'Health Esp',
    Default = false
})

LeftGroupBox:AddToggle('Chams', {
    Text = 'Chams',
    Default = false
})


LeftGroupBox:AddToggle('SkeletonEsp', {
    Text = 'Skeleton Esp',
    Default = false
})

LeftGroupBox:AddToggle('ShowDistance', {
    Text = 'Distance ',
    Default = false
})

LeftGroupBox:AddLabel("Mobs", true) 

LeftGroupBox:AddToggle('MobNameEsp', {
    Text = 'Mob Name Esp',
    Default = false,

})

LeftGroupBox:AddToggle('MobChams', {
    Text = 'Mob Chams',
    Default = false,

})

LeftGroupBox:AddToggle('MobHealths', {
    Text = 'Mob Health Esp',
    Default = false,

})


LeftGroupBox:AddLabel("NPCs", true) 
LeftGroupBox:AddToggle('NpcNameEsp', {
    Text = 'Npc Name Esp',
    Default = false,

})

LeftGroupBox:AddLabel("Chests", true) 
LeftGroupBox:AddToggle('ChestEsp', {
    Text = 'Chest Esp',
    Default = false,

})


LeftGroupBox:AddLabel("Guilds", true) 
LeftGroupBox:AddToggle('GuildEsp', {
    Text = 'Guilds Esp',
    Default = false,
 

})





Settings.NameEsp = Toggles.NameEsp.Value
Toggles.NameEsp:OnChanged(function(v)
    Settings.NameESP = v
end)
Toggles.NameEsp:SetValue(false) 


Settings.BoxEsp = Toggles.BoxEsp.Value
Toggles.BoxEsp:OnChanged(function(v)
    Settings.BoxEsp = v
end)
Toggles.BoxEsp:SetValue(false) 


Settings.HealthEsp = Toggles.HealthEsp.Value
Toggles.HealthEsp:OnChanged(function(v)
    Settings.HealthESP = v
end)
Toggles.HealthEsp:SetValue(false)


Settings.EnableChams = Toggles.Chams.Value
Toggles.Chams:OnChanged(function(v)
    Settings.EnableChams = v
end)
Toggles.Chams:SetValue(false)

Settings.SkeletonEsp = Toggles.SkeletonEsp.Value
Toggles.SkeletonEsp:OnChanged(function(v)
    Settings.SkeletonESP = v
end)
Toggles.SkeletonEsp:SetValue(false)


Settings.MobNameEsp = Toggles.MobNameEsp.Value
Toggles.MobNameEsp:OnChanged(function(v)
    Settings.MobNameEsp = v
end)
Toggles.MobNameEsp:SetValue(false)


Settings.MobChams = Toggles.MobChams.Value
Toggles.MobChams:OnChanged(function(v)
    Settings.MobChams = v
end)
Toggles.MobChams:SetValue(false)


Settings.MobHealths = Toggles.MobHealths.Value
Toggles.MobHealths:OnChanged(function(v)
    Settings.MobHealthESP = v
end)
Toggles.MobHealths:SetValue(false)


Settings.NpcNameEsp = Toggles.NpcNameEsp.Value
Toggles.NpcNameEsp:OnChanged(function(v)
    Settings.NpcNameEsp = v
end)
Toggles.NpcNameEsp:SetValue(false)


Settings.ChestEspEnabled = Toggles.ChestEsp.Value
Toggles.ChestEsp:OnChanged(function(v)
    Settings.ChestEspEnabled = v
end)
Toggles.ChestEsp:SetValue(false)


Settings.GuildEspEnabled = Toggles.GuildEsp.Value
Toggles.GuildEsp:OnChanged(function(v)
    Settings.GuildEspEnabled = v
end)
Toggles.GuildEsp:SetValue(false)




Settings.ShowDistance = Toggles.ShowDistance.Value
Toggles.ShowDistance:OnChanged(function(v)
    Settings.PlayerDinstace = v
end)
Toggles.ShowDistance:SetValue(false)



LeftGroupBox:AddDivider()

local MySlider = LeftGroupBox:AddSlider('ESP Distance', {
    Text = 'Max distance',
    Default = 1000,
    Min = 100,
    Max = 3000,
    Rounding = 1,
    Compact = false,
})


Settings.MaxESPDistance = MySlider.Value
MySlider:OnChanged(function(value)
    Settings.MaxESPDistance = value
end)


LeftGroupBox:AddLabel('Chams Color'):AddColorPicker('ChamsColorPicker', {
    Default = Colors.ChamsColor,
    Callback = function(Value)
        Colors.ChamsColor = Value
    end
})

LeftGroupBox:AddLabel('Names Color'):AddColorPicker('NameColorPicker', {
    Default = Colors.NameColor,
    Callback = function(Value)
        Colors.NameColor = Value
    end
})

LeftGroupBox:AddLabel('Box Color'):AddColorPicker('BoxColorPicker', {
    Default = Colors.BoxesColor,
    Callback = function(Value)
        Colors.BoxesColor = Value
    end
})




local LeftGroupBox2 = Tabs.Main:AddLeftGroupbox('Misc ');


LeftGroupBox2:AddToggle('NoFog', {
    Text = 'Enable NoFog',
    Default = false,

})
Settings.NoFog = Toggles.NoFog.Value
Toggles.NoFog:OnChanged(function(v)
    Settings.NoFog = v
end)
Toggles.NoFog:SetValue(false)


LeftGroupBox2:AddToggle('SkyColor', {
    Text = 'Change Sky Color',
    Default = false,

})
Settings.SkyColor = Toggles.SkyColor.Value
Toggles.SkyColor:OnChanged(function(v)
    Settings.SkyColor = v
end)
Toggles.SkyColor:SetValue(false)


LeftGroupBox2:AddLabel('Sky Color'):AddColorPicker('Color Picker', {
    Default = Colors.SkyColorValue,
    Callback = function(Value)
        Colors.SkyColorValue = Value
    end
})

LeftGroupBox2:AddToggle('WorldColor', {
    Text = 'Change World Color ',
    Default = false,

})
Settings.WorldColor = Toggles.WorldColor.Value
Toggles.WorldColor:OnChanged(function(v)
    Settings.WorldColor = v
end)
Toggles.WorldColor:SetValue(false)


LeftGroupBox2:AddLabel('World Color'):AddColorPicker('Color Picker', {
    Default = Colors.WorldColorValue,
    Callback = function(Value)
        Colors.WorldColorValue = Value
    end
})


LeftGroupBox2:AddToggle('ClickToSpectate', {
    Text = 'ClickToSpectate',
    Default = false,


})

Settings.ClickToSpectateEnabled = Toggles.ClickToSpectate.Value
Toggles.ClickToSpectate:OnChanged(function(v)
    Settings.ClickToSpectateEnabled = v
end)
Toggles.ClickToSpectate:SetValue(false)


local function UpdatePlayerDropdown()
    PlayerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayerNames, player.Name)
        end
    end
   if Options.PlayerDropdown then
        Options.PlayerDropdown:SetValues(PlayerNames)
    end 

end


-- Dropdown
LeftGroupBox2:AddDropdown("PlayerDropdown", {
    Values = PlayerNames,  -- must be a table
    Default = 1,
    Multi = false,
    Text = "Select a Player",
    Tooltip = "Choose a player to spectate",
    Callback = function(value)
        SelectedPlayerName = value
    end,
})
Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(UpdatePlayerDropdown)


UpdatePlayerDropdown()



local RightGroupbox = Tabs.Main:AddRightGroupbox('             Movement       ');
RightGroupbox:AddLabel('            SpeedHack')

RightGroupbox:AddToggle('SpeedHack', {
    Text = 'Enable',
    Default = false,


})



-- Calls the passed function when the toggle is updated
Settings.SpeedHack = Toggles.SpeedHack.Value
Toggles.SpeedHack:OnChanged(function(v)
    Settings.SpeedActive = v
end)
Toggles.SpeedHack:SetValue(false)





RightGroupbox:AddLabel('Keybind'):AddKeyPicker('SpeedKeybind', {
    Default = 'T',
    Mode = 'Toggle',
    Text = 'Toggle SpeedHack',

    Callback = function()
        Settings.SpeedEnabled = not Settings.SpeedEnabled
        print("Speed toggled:", Settings.SpeedEnabled)
    end,

  
})


local WalkSpeedSlider = RightGroupbox:AddSlider('WalkSpeedValue', {
    Text = 'Speed',
    Default = Settings.WalkSpeed,
    Min = 16,
    Max = 200,
    Rounding = 1,
})
Settings.WalkSpeed = WalkSpeedSlider.Value
WalkSpeedSlider:OnChanged(function(value)
    Settings.WalkSpeed = value
end)

RightGroupbox:AddLabel('             Noclip')
RightGroupbox:AddToggle('Noclip', {
    Text = 'Enable Noclip',
    Default = false,


})

Settings.noclipActive = Toggles.Noclip.Value
Toggles.Noclip:OnChanged(function(v)
    Settings.noclipActive = v
end)
Toggles.Noclip:SetValue(false)


RightGroupbox:AddLabel('Keybind'):AddKeyPicker('NoclipKeyBind', {
    Default = 'Y',
    SyncToggleState = false,
     Mode =  'Toggle';
    Text = 'Toggle NoClip',
    NoUI = false,

        Callback = function()
        Settings.noclip = not Settings.noclip
        print("Speed toggled:", Settings.noclip)
    end,




})
RightGroupbox:AddLabel('             InfJump')
RightGroupbox:AddToggle('InfiniteJump', {
    Text = 'Enable InfJump',
    Default = false,

})



Settings.InfJumpActive = Toggles.InfiniteJump.Value
Toggles.InfiniteJump:OnChanged(function(v)
    Settings.InfJumpActive = v
end)
Toggles.InfiniteJump:SetValue(false)


RightGroupbox:AddLabel('Keybind'):AddKeyPicker('InfJumpKeyBind', {
    Default = 'J',
    SyncToggleState = false,
     Mode =  'Toggle';
    Text = 'Toggle InfJump',
    NoUI = false,

        Callback = function()
        Settings.InfJumpEnabled = not Settings.InfJumpEnabled
    end,


})

local JumpSlider = RightGroupbox:AddSlider('JumpPower', {
    Text = 'Jump Power',
    Default = Settings.JumpPower,
    Min = 10,
    Max = 80,
    Rounding = 1,
    Compact = false,
})


Settings.JumpPower = JumpSlider.Value
JumpSlider:OnChanged(function(value)
    Settings.JumpPower = value
end)


RightGroupbox:AddLabel('            NoFallDamage')
RightGroupbox:AddToggle('NoFallDamage', {
    Text = 'Enable NoFallDamage',
    Default = false,
  Tooltip = 'Gotta make this', 

})

Settings.NoFallDamage = Toggles.NoFallDamage.Value
Toggles.NoFallDamage:OnChanged(function(v)
    Settings.NoFallDamage = v
end)
Toggles.NoFallDamage:SetValue(false)


RightGroupbox:AddLabel('            Teleports')



local EeasterLuminantTpButton = RightGroupbox:AddButton({
   Text = 'Easter Luminant TP',
   Func = function()
       Settings.LuminantTpEaster = true
        Settings.LuminantTpEtrea = false
        Settings.TrialTP = false
   end,
   DoubleClick = Settings.LuminantTpEaster,
   
})


local EtreaLuminantTpButton = RightGroupbox:AddButton({
   Text = 'Etrea Luminant TP',
   Func = function()
        Settings.LuminantTpEaster = false
        Settings.LuminantTpEtrea = true
        Settings.TrialTP = false
   end,
   DoubleClick = Settings.LuminantTpEtrea,
   
})



local TrialTpButton = RightGroupbox:AddButton({
   Text = 'Trial Of One TP',
   Func = function()
        Settings.LuminantTpEaster = false
        Settings.LuminantTpEtrea = false
        Settings.TrialTP = true
   end,
   DoubleClick = Settings.TrialTP,
   
})

local DepthsTpButton = RightGroupbox:AddButton({
   Text = 'Depths TP',
   Func = function()
        Settings.LuminantTpEaster = false
        Settings.LuminantTpEtrea = false
        Settings.TrialTP = false
        Settings.DepthsTP = true
   end,
   DoubleClick = Settings.TrialTP,
   
})


RightGroupbox:AddToggle('GuildTP', {
    Text = 'Enable GuildTP',
    Default = false,
  Tooltip = 'Telepots you to target guild door press e to go in', 

})


Settings.GuildTP = Toggles.GuildTP.Value
Toggles.GuildTP:OnChanged(function(v)
    Settings.GuildTP = v
end)
Toggles.GuildTP:SetValue(false)


local function UpdateGuildDropdown()
    GuildNames = {}
    GuildDoors = {}

    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("BasePart") and child.Name:match("GuildDoor") then
            GuildDoors[child.Name] = child
            table.insert(GuildNames, child.Name)
        end
    end

    table.sort(GuildNames)

    if Options.GuildDropdown then
        Options.GuildDropdown:SetValues(GuildNames)
    end
end


RightGroupbox:AddDropdown("GuildDropdown", {
    Values = GuildNames, 
    Default = 1,
    Multi = false,
    Text = "Select a Guild",
    Tooltip = "Choose a guild to TP",
    Callback = function(value)
        SelectedGuildName = value
    end,
})
UpdateGuildDropdown()



Library.KeybindFrame.Visible = true; 


local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })



Library.ToggleKeybind =  Options.MenuKeybind 


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
ThemeManager.DefaultTheme = 'BBot'
SaveManager:BuildConfigSection(Tabs['UI Settings'])


ThemeManager:ApplyToTab(Tabs['UI Settings'])


SaveManager:LoadAutoloadConfig()




--main stuff
local ESPConnection  

ESPConnection = RunService.RenderStepped:Connect(function(dt)
    if Library.Unloaded then return end

    --PLAYER 
    for _, player in ipairs(PlayerList) do
        if player and player ~= LocalPlayer then
            NameESP(player)
            BoxESP(player)
            SkeletonESP(player)
            HealthTextESP(player)
            PlayerDistanceESP(player)
            ChamsESP(player)
        end
    end


    if SelectedPlayerName then
        local target = Players:FindFirstChild(SelectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            ClickToSpectate(target)
        end
    end

    for _, npc in ipairs(NPCList) do
        if npc and npc:IsA("Model") then
            NPCNameESP(npc)
        end
    end


    for _, chest in ipairs(ChestList) do
        if chest and chest:IsA("Model") then
            ChestESP(chest)
        end
    end


    for _, mob in ipairs(MobList) do
        if mob and mob:IsA("Model") then
            MobNameESP(mob)
            MobChamsESP(mob)
            HealthTextESPMobs(mob)
        end
    end

    --Guilds
       for _, guild in ipairs(GuildList) do
             if  Settings.GuildEspEnabled then
                 GuildBaseEsp(guild)
             end
           
        end

end)


Library:OnUnload(function()
    print("Unloading script...")

   
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end

  
    ClearAllESP()

 
    Library.KeybindFrame.Visible = false
    Library.Unloaded = true
end)

