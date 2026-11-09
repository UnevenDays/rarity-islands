local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Characters = require(ReplicatedStorage:WaitForChild("Characters"))
local toast = ReplicatedStorage:WaitForChild("Toast")

local BASE_SPEED = Characters.BaseSpeed
local START_CASH = 50
local ISLAND_SIZE = Vector3.new(150, 2, 170)
local GAP = 120

local ISLANDS = {
	{ name = "Green Dock", color = Color3.fromRGB(78, 168, 72), accent = Color3.fromRGB(255, 214, 70) },
	{ name = "Sand Reach", color = Color3.fromRGB(214, 184, 104), accent = Color3.fromRGB(255, 150, 50) },
	{ name = "Gold Isle", color = Color3.fromRGB(92, 70, 168), accent = Color3.fromRGB(255, 210, 70) },
}

local owned = {}
local docks = {}
local spawnPoints = {}
local launchBusy = {}

local function part(props)
	local item = Instance.new(props.className or "Part")
	item.Name = props.name or "Part"
	item.Anchored = true
	item.Size = props.size or Vector3.new(4, 1, 4)
	item.CFrame = props.cframe or CFrame.new()
	item.Color = props.color or Color3.fromRGB(180, 180, 180)
	item.Material = props.material or Enum.Material.SmoothPlastic
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.CanCollide = props.collide ~= false
	item.CanTouch = props.touch == true
	item.Parent = props.parent or workspace
	if props.transparency then
		item.Transparency = props.transparency
	end
	return item
end

local function sign(cframe, text, color)
	local board = part({
		name = "Sign",
		size = Vector3.new(10, 5, 0.4),
		cframe = cframe,
		color = Color3.fromRGB(24, 24, 30),
		parent = workspace,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
	return board
end

local function tree(position)
	part({
		name = "Trunk",
		size = Vector3.new(1.2, 6, 1.2),
		cframe = CFrame.new(position + Vector3.new(0, 3, 0)),
		color = Color3.fromRGB(110, 72, 40),
		material = Enum.Material.Wood,
	})
	part({
		name = "Leaves",
		size = Vector3.new(6, 5, 6),
		cframe = CFrame.new(position + Vector3.new(0, 7.2, 0)),
		color = Color3.fromRGB(46, 150, 70),
		material = Enum.Material.Grass,
	})
end

local function islandCenter(index)
	return Vector3.new((index - 1) * (ISLAND_SIZE.X + GAP), 0, 0)
end

local function buildWorld()
	Lighting.ClockTime = 14.5
	Lighting.Brightness = 2
	Lighting.GlobalShadows = true
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 160, 175)

	part({
		name = "Water",
		size = Vector3.new(1400, 4, 700),
		cframe = CFrame.new(400, -2, 0),
		color = Color3.fromRGB(36, 130, 210),
		transparency = 0.35,
		collide = false,
		touch = true,
	})

	local shops = Instance.new("Folder")
	shops.Name = "Shops"
	shops.Parent = workspace

	for index, info in ipairs(ISLANDS) do
		local center = islandCenter(index)
		part({
			name = info.name,
			size = ISLAND_SIZE,
			cframe = CFrame.new(center + Vector3.new(0, 0, 0)),
			color = info.color,
			material = Enum.Material.Grass,
		})
		part({
			name = "Path",
			size = Vector3.new(ISLAND_SIZE.X - 8, 0.4, 14),
			cframe = CFrame.new(center + Vector3.new(0, 1.2, 8)),
			color = info.accent,
			material = Enum.Material.Concrete,
		})

		local spawn = Instance.new("SpawnLocation")
		spawn.Name = info.name .. " Spawn"
		spawn.Size = Vector3.new(8, 1, 8)
		spawn.CFrame = CFrame.new(center + Vector3.new(-50, 1.5, 40))
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.Enabled = true
		spawn.Color = info.accent
		spawn.Material = Enum.Material.Neon
		spawn.TopSurface = Enum.SurfaceType.Smooth
		spawn.Parent = workspace
		spawnPoints[index] = spawn

		tree(center + Vector3.new(-60, 1, -60))
		tree(center + Vector3.new(62, 1, -50))
		tree(center + Vector3.new(-55, 1, 55))

		if index < #ISLANDS then
			local gate = Characters.Gates[index]
			local pad = part({
				name = "Launch",
				size = Vector3.new(12, 1, 12),
				cframe = CFrame.new(center + Vector3.new(ISLAND_SIZE.X / 2 - 16, 1.6, 8)),
				color = Color3.fromRGB(255, 220, 60),
				material = Enum.Material.Neon,
				touch = true,
			})
			sign(
				CFrame.new(center + Vector3.new(ISLAND_SIZE.X / 2 - 16, 5.5, -4)),
				string.format("%s\nNeed more than %d speed", gate.next, gate.need),
				Color3.fromRGB(255, 220, 80)
			)
			pad.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					launch(player, index)
				end
			end)
		end
	end

	sign(
		CFrame.new(islandCenter(1) + Vector3.new(0, 8, -70)),
		"RARITY ISLANDS\nCollect rarer characters.\nThey pay more and make you faster.",
		Color3.fromRGB(255, 230, 90)
	)
	sign(
		CFrame.new(islandCenter(1) + Vector3.new(-48, 6, -20)),
		"Only the islands are open.\nTwo more ways to collect\nare not built yet.",
		Color3.fromRGB(180, 220, 255)
	)

	local perIsland = {
		{
			Vector3.new(-36, 1.2, -40),
			Vector3.new(0, 1.2, -40),
			Vector3.new(36, 1.2, -40),
		},
		{
			Vector3.new(-48, 1.2, -40),
			Vector3.new(-16, 1.2, -40),
			Vector3.new(16, 1.2, -40),
			Vector3.new(48, 1.2, -40),
		},
		{
			Vector3.new(-32, 1.2, -40),
			Vector3.new(0, 1.2, -40),
			Vector3.new(32, 1.2, -40),
		},
	}
	local placed = { 0, 0, 0 }
	for _, def in ipairs(Characters.List) do
		placed[def.island] += 1
		local center = islandCenter(def.island)
		local offset = perIsland[def.island][placed[def.island]]
		local look = CFrame.lookAt(center + offset + Vector3.new(0, 0, 0), center + offset + Vector3.new(0, 0, 1))
		local model = Characters.Build(def, look, "shop")
		model.Parent = shops
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "Buy"
		prompt.ActionText = "Collect"
		prompt.ObjectText = def.name
		prompt.HoldDuration = 0.35
		prompt.MaxActivationDistance = 14
		prompt.RequiresLineOfSight = false
		prompt.Parent = model.PrimaryPart
		prompt.Triggered:Connect(function(player)
			tryBuy(player, def, model)
		end)
	end
end

local function speedOf(player)
	local stats = player:FindFirstChild("leaderstats")
	local speed = stats and stats:FindFirstChild("Speed")
	return speed and speed.Value or BASE_SPEED
end

local function applySpeed(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = speedOf(player)
	end
end

local function recompute(player)
	local bonus = 0
	local income = 0
	local count = 0
	for _, def in ipairs(Characters.List) do
		if owned[player] and owned[player][def.id] then
			bonus += def.speed
			income += def.income
			count += 1
		end
	end
	player.leaderstats.Speed.Value = BASE_SPEED + bonus
	player.Income.Value = income
	player.OwnedCount.Value = count
	applySpeed(player)
	return player.leaderstats.Speed.Value
end

local function placeCrew(player)
	local folder = docks[player]
	if not folder then
		return
	end
	local old = folder:FindFirstChild("Crew")
	if old then
		old:Destroy()
	end
	local crew = Instance.new("Folder")
	crew.Name = "Crew"
	crew.Parent = folder
	local n = 0
	for _, def in ipairs(Characters.List) do
		if owned[player][def.id] then
			n += 1
			local column = (n - 1) % 5
			local row = math.floor((n - 1) / 5)
			local spot = folder.PrimaryPart.CFrame * CFrame.new(-8 + column * 4, 2, -4 - row * 5)
			local model = Characters.Build(def, spot, "owned")
			model.Parent = crew
		end
	end
end

local nextDock = 0

local function assignDock(player)
	nextDock += 1
	local index = nextDock
	local center = islandCenter(1)
	local origin = center + Vector3.new(-42 + ((index - 1) % 4) * 28, 1.2, 62)
	local dock = Instance.new("Model")
	dock.Name = "Dock_" .. player.UserId
	local pad = part({
		name = "Pad",
		size = Vector3.new(24, 1, 16),
		cframe = CFrame.new(origin),
		color = Color3.fromRGB(255, 244, 210),
		parent = dock,
	})
	dock.PrimaryPart = pad
	local board = part({
		name = "Nameplate",
		size = Vector3.new(10, 3, 0.4),
		cframe = CFrame.new(origin + Vector3.new(0, 4, 7)),
		color = Color3.fromRGB(24, 24, 30),
		parent = dock,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 220, 70)
	label.Text = player.DisplayName .. "'s crew"
	label.Parent = gui
	dock.Parent = workspace
	docks[player] = dock
end

function tryBuy(player, def, model)
	if not owned[player] then
		return
	end
	if player.Checkpoint.Value < def.island then
		toast:FireClient(player, "Reach that island first.")
		return
	end
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp or not model.PrimaryPart then
		return
	end
	if (hrp.Position - model.PrimaryPart.Position).Magnitude > 18 then
		return
	end
	if owned[player][def.id] then
		toast:FireClient(player, "Already in your crew.")
		return
	end
	local cash = player.leaderstats.Cash
	if cash.Value < def.cost then
		toast:FireClient(player, string.format("Need $%d more.", def.cost - cash.Value))
		return
	end
	cash.Value -= def.cost
	owned[player][def.id] = true
	local flag = Instance.new("BoolValue")
	flag.Name = def.id
	flag.Parent = player.Crew
	local speed = recompute(player)
	placeCrew(player)
	toast:FireClient(player, string.format("%s joined. +%d speed, +$%d/s.", def.name, def.speed, def.income))
	local gate = Characters.Gates[player.Checkpoint.Value]
	if gate and speed > gate.need then
		toast:FireClient(player, "You can cross to " .. gate.next .. ".")
	end
end

function launch(player, fromIndex)
	if launchBusy[player] then
		return
	end
	local gate = Characters.Gates[fromIndex]
	if not gate then
		return
	end
	if player.Checkpoint.Value ~= fromIndex then
		toast:FireClient(player, "Use the pad on the island you are on.")
		return
	end
	local speed = speedOf(player)
	if speed <= gate.need then
		toast:FireClient(player, string.format("Need more than %d speed. You have %d.", gate.need, speed))
		return
	end
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid or humanoid.Health <= 0 then
		return
	end

	launchBusy[player] = true
	character:SetAttribute("Launching", true)
	local destination = islandCenter(fromIndex + 1) + Vector3.new(-ISLAND_SIZE.X / 2 + 18, 6, 8)
	local start = hrp.Position
	humanoid.PlatformStand = true
	hrp.Anchored = true
	local began = os.clock()
	local duration = 1.15
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not hrp.Parent then
			connection:Disconnect()
			launchBusy[player] = nil
			return
		end
		local alpha = math.clamp((os.clock() - began) / duration, 0, 1)
		local flat = start:Lerp(destination, alpha)
		local height = math.sin(alpha * math.pi) * 28
		hrp.CFrame = CFrame.new(flat + Vector3.new(0, height, 0))
		if alpha >= 1 then
			connection:Disconnect()
			hrp.CFrame = CFrame.new(destination)
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.Anchored = false
			humanoid.PlatformStand = false
			player.Checkpoint.Value = fromIndex + 1
			player.RespawnLocation = spawnPoints[fromIndex + 1]
			toast:FireClient(player, "Welcome to " .. gate.next .. ".")
			task.delay(0.6, function()
				launchBusy[player] = nil
				if character.Parent then
					character:SetAttribute("Launching", false)
				end
			end)
		end
	end)
end

local function onCharacter(player, character)
	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")
	local island = player.Checkpoint.Value
	character:SetAttribute("Launching", true)
	hrp.CFrame = CFrame.new(islandCenter(island) + Vector3.new(-50, 6, 40))
	humanoid.WalkSpeed = speedOf(player)
	task.delay(0.5, function()
		if character.Parent then
			character:SetAttribute("Launching", false)
		end
	end)
end

local function onPlayer(player)
	if owned[player] then
		return
	end
	owned[player] = {}
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = START_CASH
	cash.Parent = stats
	local speed = Instance.new("IntValue")
	speed.Name = "Speed"
	speed.Value = BASE_SPEED
	speed.Parent = stats
	stats.Parent = player

	local income = Instance.new("IntValue")
	income.Name = "Income"
	income.Value = 0
	income.Parent = player

	local count = Instance.new("IntValue")
	count.Name = "OwnedCount"
	count.Value = 0
	count.Parent = player

	local checkpoint = Instance.new("IntValue")
	checkpoint.Name = "Checkpoint"
	checkpoint.Value = 1
	checkpoint.Parent = player

	local crew = Instance.new("Folder")
	crew.Name = "Crew"
	crew.Parent = player

	player.RespawnLocation = spawnPoints[1]
	assignDock(player)
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		onCharacter(player, player.Character)
	end
end

Players.PlayerRemoving:Connect(function(player)
	owned[player] = nil
	launchBusy[player] = nil
	local dock = docks[player]
	docks[player] = nil
	if dock then
		dock:Destroy()
	end
end)

buildWorld()
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayer(player)
end

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local income = player:FindFirstChild("Income")
			local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
			if income and cash and income.Value > 0 then
				cash.Value += income.Value
			end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if hrp and humanoid and humanoid.Health > 0 and hrp.Position.Y < 0 and not character:GetAttribute("Launching") then
			humanoid.Health = 0
		end
	end
end)
