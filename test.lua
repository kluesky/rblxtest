--RELOAD GUI
if game.CoreGui:FindFirstChild("LyoraHub") then
	game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Lyora Official",Text = "GUI Already loaded, rejoin to re-execute",Duration = 5;})
	return
end
local version = 2
--VARIABLES
_G.AntiFlingToggled = false
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Light = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local mouse = plr:GetMouse()
local ScriptWhitelist = {}
local ForceWhitelist = {}
local TargetedPlayer = nil
local FlySpeed = 50
local PotionTool = nil
local SavedCheckpoint = nil
local MinesFolder = nil
local FreeEmotesEnabled = false
local CannonsFolders = {}

-- FLOATING LOGO FUNCTION
local function createFloatingLogo()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LyoraFloatingLogo"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Name = "FloatingLogo"
    ImageLabel.Parent = ScreenGui
    ImageLabel.Size = UDim2.new(0, 80, 0, 80)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = "rbxassetid://10818605405" -- Ganti dengan ID logo Lyora Anda
    ImageLabel.ImageColor3 = Color3.fromRGB(0, 255, 255)
    
    -- Smooth floating animation
    coroutine.wrap(function()
        local time = 0
        while true do
            time = time + 0.03
            local x = math.sin(time) * 150 + 200
            local y = math.cos(time * 0.7) * 80 + 150
            ImageLabel.Position = UDim2.new(0, x, 0, y)
            wait(0.03)
        end
    end)()
end

-- Jalankan floating logo
spawn(createFloatingLogo)

pcall(function()
	MinesFolder = game:GetService("Workspace").Landmines
	for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
		if v.Name == "Cannons" then
			table.insert(CannonsFolders, v)
		end
	end
end)

-- FUNCTIONS (tetap sama seperti sebelumnya)
_G.shield = function(id)
	if not table.find(ForceWhitelist,id) then
		table.insert(ForceWhitelist, id)
	end
end

local function RandomChar()
	local length = math.random(1,5)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function ChangeToggleColor(Button)
	led = Button.Ticket_Asset
	if led.ImageColor3 == Color3.fromRGB(255, 0, 0) then
		led.ImageColor3 = Color3.fromRGB(0, 255, 0)
	else
		led.ImageColor3 = Color3.fromRGB(255, 0, 0)
	end
end

local function GetPing()
	return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())/1000
end

local function GetPlayer(UserDisplay)
	if UserDisplay ~= "" then
        for i,v in pairs(Players:GetPlayers()) do
            if v.Name:lower():match(UserDisplay) or v.DisplayName:lower():match(UserDisplay) then
                return v
            end
        end
		return nil
	else
		return nil
    end
end

local function GetCharacter(Player)
	if Player.Character then
		return Player.Character
	end
end

local function GetRoot(Player)
	if GetCharacter(Player):FindFirstChild("HumanoidRootPart") then
		return GetCharacter(Player).HumanoidRootPart
	end
end

local function TeleportTO(posX,posY,posZ,player,method)
	pcall(function()
		if method == "safe" then
			task.spawn(function()
				for i = 1,30 do
					task.wait()
					GetRoot(plr).Velocity = Vector3.new(0,0,0)
					if player == "pos" then
						GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
					else
						GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
					end
				end
			end)
		else
			GetRoot(plr).Velocity = Vector3.new(0,0,0)
			if player == "pos" then
				GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
			else
				GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
			end
		end
	end)
end

local function PredictionTP(player,method)
	local root = GetRoot(player)
	local pos = root.Position
	local vel = root.Velocity
	GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
	if method == "safe" then
		task.wait()
		GetRoot(plr).CFrame = CFrame.new(pos)
		task.wait()
		GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
	end
end

local function Touch(x,root)
	pcall(function()
		x = x:FindFirstAncestorWhichIsA("Part")
		if x then
			if firetouchinterest then
				task.spawn(function()
					firetouchinterest(x, root, 1)
					task.wait()
					firetouchinterest(x, root, 0)
				end)
			end
		end
	end)
end

local function GetPush()
	local TempPush = nil
	pcall(function()
		if plr.Backpack:FindFirstChild("Push") then
			PushTool = plr.Backpack.Push
			PushTool.Parent = plr.Character
			TempPush = PushTool
		end
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character:FindFirstChild("Push") then
				TempPush = v.Character.Push
			end
		end
	end)
	return TempPush
end

local function CheckPotion()
	if plr.Backpack:FindFirstChild("potion") then
		PotionTool = plr.Backpack:FindFirstChild("potion")
		return true
	elseif plr.Character:FindFirstChild("potion") then
		PotionTool = plr.Character:FindFirstChild("potion")
		return true
	else
		return false
	end
end

local function Push(Target)
	local Push = GetPush()
	local FixTool = nil
	if Push ~= nil then
		local args = {[1] = Target.Character}
		GetPush().PushTool:FireServer(unpack(args))
	end
	if plr.Character:FindFirstChild("Push") then
		plr.Character.Push.Parent = plr.Backpack
	end
	if plr.Character:FindFirstChild("ModdedPush") then
		FixTool = plr.Character:FindFirstChild("ModdedPush")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
	if plr.Character:FindFirstChild("ClickTarget") then
		FixTool = plr.Character:FindFirstChild("ClickTarget")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
	if plr.Character:FindFirstChild("potion") then
		FixTool = plr.Character:FindFirstChild("potion")
		FixTool.Parent = plr.Backpack
		FixTool.Parent = plr.Character
	end
end

local function ToggleRagdoll(bool)
	pcall(function()
		plr.Character["Falling down"].Disabled = bool
		plr.Character["Swimming"].Disabled = bool
		plr.Character["StartRagdoll"].Disabled = bool
		plr.Character["Pushed"].Disabled = bool
		plr.Character["RagdollMe"].Disabled = bool
	end)
end

local function ToggleVoidProtection(bool)
	if bool then
		game.Workspace.FallenPartsDestroyHeight = 0/0
	else
		game.Workspace.FallenPartsDestroyHeight = -500
	end
end

local function PlayAnim(id,time,speed)
	pcall(function()
		plr.Character.Animate.Disabled = false
		local hum = plr.Character.Humanoid
		local animtrack = hum:GetPlayingAnimationTracks()
		for i,track in pairs(animtrack) do
			track:Stop()
		end
		plr.Character.Animate.Disabled = true
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..id
		local loadanim = hum:LoadAnimation(Anim)
		loadanim:Play()
		loadanim.TimePosition = time
		loadanim:AdjustSpeed(speed)
		loadanim.Stopped:Connect(function()
			plr.Character.Animate.Disabled = false
			for i, track in pairs (animtrack) do
        		track:Stop()
    		end
		end)
	end)
end

local function StopAnim()
	plr.Character.Animate.Disabled = false
    local animtrack = plr.Character.Humanoid:GetPlayingAnimationTracks()
    for i, track in pairs (animtrack) do
        track:Stop()
    end
end

local function SendNotify(title, message, duration)
	game:GetService("StarterGui"):SetCore("SendNotification", {Title = title,Text = message,Duration = duration;})
end

--LOAD GUI MODERN
task.wait(0.1)
local LyoraHub = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local SideBar = Instance.new("Frame")
local HomeBtn = Instance.new("TextButton")
local GameBtn = Instance.new("TextButton")
local CharacterBtn = Instance.new("TextButton")
local TargetBtn = Instance.new("TextButton")
local AnimationsBtn = Instance.new("TextButton")
local MiscBtn = Instance.new("TextButton")
local CreditsBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")
local HomePage = Instance.new("ScrollingFrame")
local ProfileFrame = Instance.new("Frame")
local ProfileImage = Instance.new("ImageLabel")
local WelcomeLabel = Instance.new("TextLabel")
local AnnounceFrame = Instance.new("Frame")
local AnnounceLabel = Instance.new("TextLabel")

-- Modern UI Colors
local Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(35, 35, 45)
}

-- Create Modern GUI
LyoraHub.Name = "LyoraHub"
LyoraHub.Parent = game.CoreGui
LyoraHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = LyoraHub
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Add modern corner radius
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Top Bar
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Theme.Secondary
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Lyora VIP - Premium Hub"
TitleLabel.TextColor3 = Theme.Accent
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Side Bar
SideBar.Name = "SideBar"
SideBar.Parent = MainFrame
SideBar.BackgroundColor3 = Theme.Secondary
SideBar.BorderSizePixel = 0
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.Size = UDim2.new(0, 150, 0, 360)

-- Navigation Buttons
local buttonNames = {"Home", "Game", "Character", "Target", "Animations", "Misc", "Credits"}
local buttons = {}

for i, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Parent = SideBar
    btn.BackgroundColor3 = Theme.Button
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, 10, 0, 10 + (i-1)*45)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Theme.Text
    btn.TextSize = 14
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    buttons[name] = btn
end

-- Content Area
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Theme.Background
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 150, 0, 40)
ContentFrame.Size = UDim2.new(1, -150, 1, -40)

-- Home Page (Example)
HomePage.Name = "HomePage"
HomePage.Parent = ContentFrame
HomePage.Active = true
HomePage.BackgroundColor3 = Theme.Background
HomePage.BorderSizePixel = 0
HomePage.Size = UDim2.new(1, 0, 1, 0)
HomePage.CanvasSize = UDim2.new(0, 0, 1.5, 0)
HomePage.ScrollBarThickness = 5

ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Parent = HomePage
ProfileFrame.BackgroundColor3 = Theme.Secondary
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Position = UDim2.new(0, 20, 0, 20)
ProfileFrame.Size = UDim2.new(1, -40, 0, 100)

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 8)
ProfileCorner.Parent = ProfileFrame

ProfileImage.Name = "ProfileImage"
ProfileImage.Parent = ProfileFrame
ProfileImage.BackgroundColor3 = Theme.Button
ProfileImage.BorderSizePixel = 0
ProfileImage.Position = UDim2.new(0, 15, 0, 15)
ProfileImage.Size = UDim2.new(0, 70, 0, 70)
ProfileImage.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(1, 0)
ImageCorner.Parent = ProfileImage

WelcomeLabel.Name = "WelcomeLabel"
WelcomeLabel.Parent = ProfileFrame
WelcomeLabel.BackgroundTransparency = 1
WelcomeLabel.Position = UDim2.new(0, 100, 0, 15)
WelcomeLabel.Size = UDim2.new(1, -115, 0, 70)
WelcomeLabel.Font = Enum.Font.Gotham
WelcomeLabel.Text = "Welcome, " .. plr.Name .. "!\n\nPress [B] to toggle GUI"
WelcomeLabel.TextColor3 = Theme.Text
WelcomeLabel.TextSize = 14
WelcomeLabel.TextWrapped = true
WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left

AnnounceFrame.Name = "AnnounceFrame"
AnnounceFrame.Parent = HomePage
AnnounceFrame.BackgroundColor3 = Theme.Secondary
AnnounceFrame.BorderSizePixel = 0
AnnounceFrame.Position = UDim2.new(0, 20, 0, 140)
AnnounceFrame.Size = UDim2.new(1, -40, 0, 200)

local AnnounceCorner = Instance.new("UICorner")
AnnounceCorner.CornerRadius = UDim.new(0, 8)
AnnounceCorner.Parent = AnnounceFrame

AnnounceLabel.Name = "AnnounceLabel"
AnnounceLabel.Parent = AnnounceFrame
AnnounceLabel.BackgroundTransparency = 1
AnnounceLabel.Position = UDim2.new(0, 15, 0, 15)
AnnounceLabel.Size = UDim2.new(1, -30, 1, -30)
AnnounceLabel.Font = Enum.Font.Gotham
AnnounceLabel.Text = loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/announce"))()
AnnounceLabel.TextColor3 = Theme.Text
AnnounceLabel.TextSize = 12
AnnounceLabel.TextWrapped = true
AnnounceLabel.TextXAlignment = Enum.TextXAlignment.Left
AnnounceLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Tambahkan halaman lainnya (Game, Character, Target, dll) dengan style yang sama...

-- Close Button Function
CloseButton.MouseButton1Click:Connect(function()
    LyoraHub:Destroy()
end)

-- Navigation Function
local function ShowPage(pageName)
    for _, page in pairs(ContentFrame:GetChildren()) do
        if page:IsA("Frame") or page:IsA("ScrollingFrame") then
            page.Visible = false
        end
    end
    
    for name, btn in pairs(buttons) do
        if name:lower() == pageName:lower() then
            btn.BackgroundColor3 = Theme.Accent
        else
            btn.BackgroundColor3 = Theme.Button
        end
    end
    
    if ContentFrame:FindFirstChild(pageName .. "Page") then
        ContentFrame[pageName .. "Page"].Visible = true
    end
end

-- Navigation Events
for name, btn in pairs(buttons) do
    btn.MouseButton1Click:Connect(function()
        ShowPage(name)
    end)
end

-- Show Home page by default
ShowPage("Home")

-- Toggle GUI with B key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.B then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Assets dan fungsi toggle (tetap sama seperti script asli)
local Assets = Instance.new("Folder")
Assets.Parent = LyoraHub

local Ticket_Asset = Instance.new("ImageButton")
Ticket_Asset.Name = "Ticket_Asset"
Ticket_Asset.Parent = Assets
Ticket_Asset.AnchorPoint = Vector2.new(0, 0.5)
Ticket_Asset.BackgroundTransparency = 1.000
Ticket_Asset.BorderSizePixel = 0
Ticket_Asset.LayoutOrder = 5
Ticket_Asset.Position = UDim2.new(1, 5, 0.5, 0)
Ticket_Asset.Size = UDim2.new(0, 25, 0, 25)
Ticket_Asset.ZIndex = 2
Ticket_Asset.Image = "rbxassetid://3926305904"
Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
Ticket_Asset.ImageRectOffset = Vector2.new(424, 4)
Ticket_Asset.ImageRectSize = Vector2.new(36, 36)

local Click_Asset = Instance.new("ImageButton")
Click_Asset.Name = "Click_Asset"
Click_Asset.Parent = Assets
Click_Asset.AnchorPoint = Vector2.new(0, 0.5)
Click_Asset.BackgroundTransparency = 1.000
Click_Asset.BorderSizePixel = 0
Click_Asset.Position = UDim2.new(1, 5, 0.5, 0)
Click_Asset.Size = UDim2.new(0, 25, 0, 25)
Click_Asset.ZIndex = 2
Click_Asset.Image = "rbxassetid://3926305904"
Click_Asset.ImageColor3 = Color3.fromRGB(100, 100, 100)
Click_Asset.ImageRectOffset = Vector2.new(204, 964)
Click_Asset.ImageRectSize = Vector2.new(36, 36)

local function CreateToggle(Button)
	local NewToggle = Ticket_Asset:Clone()
	NewToggle.Parent = Button
end

local function CreateClicker(Button)
	local NewClicker = Click_Asset:Clone()
	NewClicker.Parent = Button
end

-- ... (sisa fungsi dan logika dari script asli tetap sama)

SendNotify("Lyora Official", "Modern GUI Loaded Successfully!", 5)