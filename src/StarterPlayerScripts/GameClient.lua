local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Characters = require(ReplicatedStorage:WaitForChild("Characters"))
local toast = ReplicatedStorage:WaitForChild("Toast")
local float = ReplicatedStorage:WaitForChild("Float")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "RarityIslands"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius or 12)
	item.Parent = parent
	return item
end

local function panel(position, size, color, transparency)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = color or Color3.fromRGB(14, 14, 20)
	frame.BackgroundTransparency = transparency or 0.18
	frame.Position = position
	frame.Size = size
	frame.Parent = gui
	corner(frame, 14)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 214, 70)
	stroke.Thickness = 2
	stroke.Parent = frame
	return frame
end

local function text(parent, position, size, value, color, scaled)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = Enum.Font.GothamBold
	label.Text = value
	label.TextColor3 = color
	label.TextScaled = scaled ~= false
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Parent = parent
	return label
end

local top = panel(UDim2.fromScale(0.3, 0.02), UDim2.fromScale(0.4, 0.13), Color3.fromRGB(12, 12, 18), 0.12)
local cashLabel = text(top, UDim2.fromScale(0.04, 0.06), UDim2.fromScale(0.92, 0.42), "$0", Color3.fromRGB(255, 220, 60))
local infoLabel = text(top, UDim2.fromScale(0.04, 0.5), UDim2.fromScale(0.92, 0.22), "Speed 16", Color3.fromRGB(190, 240, 255))
local barBack = Instance.new("Frame")
barBack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
barBack.Position = UDim2.fromScale(0.08, 0.78)
barBack.Size = UDim2.fromScale(0.84, 0.14)
barBack.Parent = top
corner(barBack, 8)
local barFill = Instance.new("Frame")
barFill.BackgroundColor3 = Color3.fromRGB(255, 196, 40)
barFill.Size = UDim2.fromScale(0, 1)
barFill.Parent = barBack
corner(barFill, 8)

local hint = panel(UDim2.fromScale(0.18, 0.88), UDim2.fromScale(0.64, 0.08), Color3.fromRGB(12, 12, 18), 0.15)
local hintLabel = text(hint, UDim2.fromScale(0.03, 0.12), UDim2.fromScale(0.94, 0.4), "", Color3.new(1, 1, 1))
local nextLabel = text(hint, UDim2.fromScale(0.03, 0.52), UDim2.fromScale(0.94, 0.36), "", Color3.fromRGB(180, 255, 190))

local crewFrame = panel(UDim2.fromScale(0.78, 0.18), UDim2.fromScale(0.2, 0.52))
text(crewFrame, UDim2.fromScale(0.06, 0.02), UDim2.fromScale(0.88, 0.1), "CREW", Color3.fromRGB(255, 220, 70))
local crewList = text(crewFrame, UDim2.fromScale(0.06, 0.14), UDim2.fromScale(0.88, 0.82), "Nobody yet.", Color3.new(1, 1, 1), false)
crewList.TextSize = 15
crewList.TextXAlignment = Enum.TextXAlignment.Left
crewList.TextYAlignment = Enum.TextYAlignment.Top
crewList.TextWrapped = true
crewList.RichText = true

local toastFrame = panel(UDim2.fromScale(0.25, 0.4), UDim2.fromScale(0.5, 0.08))
toastFrame.Visible = false
local toastLabel = text(toastFrame, UDim2.fromScale(0.04, 0.15), UDim2.fromScale(0.92, 0.7), "", Color3.fromRGB(255, 244, 160))
local toastToken = 0

local function showToast(message)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastFrame.Visible = true
	task.delay(2.4, function()
		if toastToken == token then
			toastFrame.Visible = false
		end
	end)
end

toast.OnClientEvent:Connect(showToast)

float.OnClientEvent:Connect(function(amount)
	local popup = text(gui, UDim2.fromScale(0.42, 0.2), UDim2.fromScale(0.16, 0.05), "+$" .. tostring(amount), Color3.fromRGB(255, 230, 80))
	task.spawn(function()
		for step = 1, 18 do
			popup.Position = popup.Position - UDim2.fromScale(0, 0.003)
			popup.TextTransparency = step / 18
			popup.TextStrokeTransparency = step / 18
			task.wait(0.03)
		end
		popup:Destroy()
	end)
end)

local function rgb(color)
	return math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
end

local function refreshCrew(crew)
	local lines = {}
	if crew then
		for _, def in ipairs(Characters.List) do
			if crew:FindFirstChild(def.id) then
				local color = Characters.RarityColor[def.rarity] or Color3.new(1, 1, 1)
				local r, g, b = rgb(color)
				table.insert(lines, string.format('<font color="rgb(%d,%d,%d)">%s</font>  %s', r, g, b, def.rarity, def.name))
			end
		end
	end
	crewList.Text = #lines > 0 and table.concat(lines, "\n") or "Nobody yet."
end

local function nextLine(cash, crew, checkpoint)
	for _, def in ipairs(Characters.List) do
		local have = crew and crew:FindFirstChild(def.id)
		if not have then
			if checkpoint < def.island then
				return string.format("Cross before you can collect %s.", def.name)
			end
			if cash < def.cost then
				return string.format("Next: %s. $%d to go.", def.name, def.cost - cash)
			end
			return string.format("%s is ready. Walk up and collect.", def.name)
		end
	end
	return "Full crew. Every character is yours."
end

local function paintShops(cash, crew, checkpoint)
	local shops = workspace:FindFirstChild("Shops")
	if not shops then
		return
	end
	for _, model in ipairs(shops:GetChildren()) do
		local def = Characters.ById[model:GetAttribute("Id")]
		local ready = false
		if def then
			local have = crew and crew:FindFirstChild(def.id)
			ready = checkpoint >= def.island and cash >= def.cost and not have
		end
		local mark = model:FindFirstChild("Ready")
		if ready and not mark then
			mark = Instance.new("Highlight")
			mark.Name = "Ready"
			mark.FillColor = Color3.fromRGB(130, 255, 150)
			mark.OutlineColor = Color3.fromRGB(210, 255, 220)
			mark.FillTransparency = 0.65
			mark.OutlineTransparency = 0
			mark.Parent = model
		elseif mark and not ready then
			mark:Destroy()
		end
	end
end

local function refreshHud()
	local stats = player:FindFirstChild("leaderstats")
	local cash = stats and stats:FindFirstChild("Cash")
	local speed = stats and stats:FindFirstChild("Speed")
	local income = player:FindFirstChild("Income")
	local ownedCount = player:FindFirstChild("OwnedCount")
	local checkpoint = player:FindFirstChild("Checkpoint")
	local crew = player:FindFirstChild("Crew")
	if not (cash and speed and income and ownedCount and checkpoint) then
		return
	end
	cashLabel.Text = string.format("$%d", cash.Value)
	infoLabel.Text = string.format("Speed %d     +$%d/s     %d/10", speed.Value, income.Value, ownedCount.Value)
	local gate = Characters.Gates[checkpoint.Value]
	if gate then
		local ratio = math.clamp(speed.Value / (gate.need + 1), 0, 1)
		barFill.Size = UDim2.fromScale(ratio, 1)
		barFill.BackgroundColor3 = ratio >= 1 and Color3.fromRGB(90, 220, 120) or Color3.fromRGB(255, 196, 40)
		if speed.Value > gate.need then
			hintLabel.Text = string.format("The pad is open. Launch to %s.", gate.next)
		else
			hintLabel.Text = string.format("%s needs more than %d speed. You have %d.", gate.next, gate.need, speed.Value)
		end
	else
		barFill.Size = UDim2.fromScale(1, 1)
		barFill.BackgroundColor3 = Color3.fromRGB(90, 220, 120)
		hintLabel.Text = "Gold Isle. Grab the coins and finish the crew."
	end
	nextLabel.Text = nextLine(cash.Value, crew, checkpoint.Value)
	refreshCrew(crew)
	paintShops(cash.Value, crew, checkpoint.Value)
end

local function watch(instance)
	if not instance then
		return
	end
	instance.Changed:Connect(refreshHud)
	if instance:IsA("Folder") then
		instance.ChildAdded:Connect(refreshHud)
	end
end

task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	watch(stats:WaitForChild("Cash"))
	watch(stats:WaitForChild("Speed"))
	watch(player:WaitForChild("Income"))
	watch(player:WaitForChild("OwnedCount"))
	watch(player:WaitForChild("Checkpoint"))
	watch(player:WaitForChild("Crew"))
	refreshHud()
end)
