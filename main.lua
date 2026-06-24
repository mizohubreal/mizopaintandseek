-- LocalScript inside StarterPlayerScripts or StarterGui
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------------
-- [CẤU HÌNH TÍNH NĂNG]
------------------------------------------------------------------
-- 1. Cấu hình ESP
local ESP_COLOR = Color3.fromRGB(255, 215, 0) -- Màu vàng (Gold)
local FILL_TRANSPARENCY = 0.5                 -- Độ trong suốt của thân
local OUTLINE_TRANSPARENCY = 0                -- Độ trong suốt của viền phát sáng

-- 2. Cấu hình Chỉ số Bản thân
local TARGET_SPEED = 50                       -- Tốc độ chạy (Mặc định: 16)
local TARGET_JUMP = 100                       -- Độ nhảy cao (Mặc định: 50)


------------------------------------------------------------------
-- [CHỨC NĂNG TẠO INTRO UI (ĐEN VIỀN HỒNG)]
------------------------------------------------------------------
local function playIntro()
	-- Chờ PlayerGui sẵn sàng
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not playerGui then return end

	-- Tạo ScreenGui độc lập để tránh xung đột trùng tên
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MizoIntroGui_" .. math.random(1000, 9999)
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true -- Tràn màn hình hoàn toàn
	screenGui.Parent = playerGui

	-- Tạo Khung Main Frame (Màu đen)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 320, 0, 100)
	mainFrame.Position = UDim2.new(0.5, -160, 0.4, -50) -- Giữa màn hình
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Màu đen tối
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 1 -- Ẩn để fade in
	mainFrame.Parent = screenGui

	-- Bo góc cho mượt
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainFrame

	-- Viền màu hồng
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 20, 147) -- Màu hồng đậm (Deep Pink)
	uiStroke.Thickness = 2.5
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Transparency = 1 -- Ẩn lúc đầu
	uiStroke.Parent = mainFrame

	-- Nhãn chữ (TextLabel)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "WelcomeText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.fromRGB(255, 105, 180) -- Màu hồng Neon (Hot Pink)
	textLabel.TextSize = 24
	textLabel.Text = "" -- Rỗng để gõ chữ
	textLabel.Parent = mainFrame

	-- Hiệu ứng hiện UI dần dần (Fade In)
	TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
	TweenService:Create(uiStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
	task.wait(0.4)

	-- Hiệu ứng gõ chữ an toàn bằng vòng lặp đếm ký tự
	local fullText = "Thank For Using Mizo"
	for i = 1, #fullText do
		local currentText = string.sub(fullText, 1, i)
		textLabel.Text = currentText
		task.wait(0.05) -- Tốc độ xuất hiện từng chữ (0.05 giây mỗi ký tự)
	end

	task.wait(1.2) -- Giữ chữ lại trên màn hình

	-- Hiệu ứng ẩn UI dần dần (Fade Out)
	local fadeMain = TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
	local fadeStroke = TweenService:Create(uiStroke, TweenInfo.new(0.4), {Transparency = 1})
	local fadeText = TweenService:Create(textLabel, TweenInfo.new(0.4), {TextTransparency = 1})
	
	fadeMain:Play()
	fadeStroke:Play()
	fadeText:Play()
	
	-- Đợi hiệu ứng mờ hoàn thành rồi xóa hẳn (Dùng Completed để đảm bảo biến mất hoàn toàn)
	fadeMain.Completed:Connect(function()
		screenGui:Destroy()
	end)
end


------------------------------------------------------------------
-- [CHỨC NĂNG ESP MÀU VÀNG]
------------------------------------------------------------------
local function applyESP(player, character)
	if player == LocalPlayer then return end 

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
	if not humanoidRootPart then return end

	local existingHighlight = character:FindFirstChild("MizoHub_ESP")
	if existingHighlight then
		existingHighlight:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "MizoHub_ESP"
	highlight.FillColor = ESP_COLOR
	highlight.FillTransparency = FILL_TRANSPARENCY
	highlight.OutlineColor = ESP_COLOR
	highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character
end

local function onPlayerAdded(player)
	if player == LocalPlayer then return end

	if player.Character then
		task.spawn(applyESP, player, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		task.spawn(applyESP, player, character)
	end)
end


------------------------------------------------------------------
-- [CHỨC NĂNG ĐIỀU CHỈNH CHỈ SỐ BẢN THÂN]
------------------------------------------------------------------
local function applyMyStats(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	humanoid.UseJumpPower = true
	humanoid.WalkSpeed = TARGET_SPEED
	humanoid.JumpPower = TARGET_JUMP

	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if humanoid.WalkSpeed ~= TARGET_SPEED then
			humanoid.WalkSpeed = TARGET_SPEED
		end
	end)

	humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
		if humanoid.JumpPower ~= TARGET_JUMP then
			humanoid.JumpPower = TARGET_JUMP
		end
	end)
end


------------------------------------------------------------------
-- [KÍCH HOẠT TOÀN BỘ HỆ THỐNG]
------------------------------------------------------------------
-- 1. Chạy hiệu ứng Intro trước bằng luồng riêng biệt
task.spawn(playIntro)

-- 2. Khởi chạy ESP cho người chơi khác
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- 3. Khởi chạy tăng chỉ số cho bản thân
if LocalPlayer.Character then
	task.spawn(applyMyStats, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(character)
	task.spawn(applyMyStats, character)
end)
