local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Characters = require(ReplicatedStorage:WaitForChild("Characters"))
local toast = ReplicatedStorage:WaitForChild("Toast")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "RarityIslands"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function stroke(label)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	return label
end

local function label(parent, position, size, text, color, z)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Position = position
	item.Size = size
	item.Font = Enum.Font.GothamBold
	item.Text = text
	item.TextColor3 = color
	item.TextScaled = true
	item.ZIndex = z or 2
	stroke(item)
	item.Parent = parent
	return item
end

local cashLabel = label(gui, UDim2.fromScale(0.28, 0.02), UDim2.fromScale(0.44, 0.07), "$0", Color3.fromRGB(255, 220, 60), 3)
local infoLabel = label(gui, UDim2.fromScale(0.2, 0.09), UDim2.fromScale(0.6, 0.04), "Speed 16", Color3.fromRGB(180, 240, 255), 3)
local hintLabel = label(gui, UDim2.fromScale(0.15, 0.9), UDim2.fromScale(0.7, 0.06), "", Color3.fromRGB(255, 255, 255), 3)

local crewFrame = Instance.new("Frame")
crewFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
crewFrame.BackgroundTransparency = 0.25
crewFrame.Position = UDim2.fromScale(0.78, 0.16)
crewFrame.Size = UDim2.fromScale(0.2, 0.55)
crewFrame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = crewFrame
local crewTitle = label(crewFrame, UDim2.fromScale(0.05, 0.02), UDim2.fromScale(0.9, 0.1), "CREW", Color3.fromRGB(255, 220, 70), 4)
crewTitle.Parent = crewFrame
local crewList = Instance.new("TextLabel")
crewList.BackgroundTransparency = 1
crewList.Position = UDim2.fromScale(0.06, 0.14)
crewList.Size = UDim2.fromScale(0.88, 0.82)
crewList.Font = Enum.Font.GothamBold
crewList.TextXAlignment = Enum.TextXAlignment.Left
crewList.TextYAlignment = Enum.TextYAlignment.Top
crewList.TextWrapped = true
crewList.TextScaled = false
crewList.TextSize = 16
crewList.TextColor3 = Color3.new(1, 1, 1)
crewList.Text = "Nobody yet."
stroke(crewList)
crewList.Parent = crewFrame

local toastLabel = label(gui, UDim2.fromScale(0.2, 0.42), UDim2.fromScale(0.6, 0.08), "", Color3.fromRGB(255, 244, 160), 5)
toastLabel.Visible = false
local toastToken = 0

local function showToast(text)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = text
	toastLabel.Visible = true
	task.delay(2.4, function()
		if toastToken == token then
			toastLabel.Visible = false
		end
	end)
end

toast.OnClientEvent:Connect(showToast)

local function refreshCrew()
	local crew = player:FindFirstChild("Crew")
	local lines = {}
	if crew then
		for _, def in ipairs(Characters.List) do
			if crew:FindFirstChild(def.id) then
				table.insert(lines, string.format("%s  %s  $%d/s", def.rarity, def.name, def.income))
			end
		end
	end
	crewList.Text = #lines > 0 and table.concat(lines, "\n") or "Nobody yet."
end

local function refreshHud()
	local stats = player:FindFirstChild("leaderstats")
	local cash = stats and stats:FindFirstChild("Cash")
	local speed = stats and stats:FindFirstChild("Speed")
	local income = player:FindFirstChild("Income")
	local ownedCount = player:FindFirstChild("OwnedCount")
	local checkpoint = player:FindFirstChild("Checkpoint")
	if not (cash and speed and income and ownedCount and checkpoint) then
		return
	end
	cashLabel.Text = string.format("$%d", cash.Value)
	infoLabel.Text = string.format("Speed %d    +$%d/s    %d/10", speed.Value, income.Value, ownedCount.Value)
	local gate = Characters.Gates[checkpoint.Value]
	if gate then
		if speed.Value > gate.need then
			hintLabel.Text = string.format("Step on the yellow pad. %s is open.", gate.next)
		else
			hintLabel.Text = string.format("%s needs more than %d speed. You have %d.", gate.next, gate.need, speed.Value)
		end
	else
		hintLabel.Text = "Gold Isle. Collect the last characters."
	end
	refreshCrew()
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
