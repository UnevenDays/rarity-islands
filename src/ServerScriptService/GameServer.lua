local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Characters = require(ReplicatedStorage:WaitForChild("Characters"))
local toast = ReplicatedStorage:WaitForChild("Toast")
local float = Instance.new("RemoteEvent")
float.Name = "Float"
float.Parent = ReplicatedStorage

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

local function palm(position)
	part({
		name = "PalmTrunk",
		size = Vector3.new(1.1, 7, 1.1),
		cframe = CFrame.new(position + Vector3.new(0, 4.2, 0)) * CFrame.Angles(0, 0, math.rad(7)),
		color = Color3.fromRGB(122, 78, 42),
		material = Enum.Material.Wood,
	})
	for i = 0, 4 do
		local angle = i * math.pi * 2 / 5
		part({
			name = "Frond",
			size = Vector3.new(3.6, 0.22, 0.85),
			cframe = CFrame.new(position + Vector3.new(math.cos(angle) * 1.7, 7.6, math.sin(angle) * 1.7)) * CFrame.Angles(math.rad(22), angle, 0),
			color = Color3.fromRGB(36, 148, 64),
			material = Enum.Material.Grass,
		})
	end
end

local function rock(position, scale)
	part({
		name = "Rock",
		size = Vector3.new(3.4, 2.1, 2.6) * scale,
		cframe = CFrame.new(position) * CFrame.Angles(0, math.rad(20 * scale), 0),
		color = Color3.fromRGB(120, 124, 132),
		material = Enum.Material.Slate,
	})
end

local function styleLighting()
	Lighting.ClockTime = 15
	Lighting.Brightness = 2.2
	Lighting.GlobalShadows = true
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 168, 190)
	Lighting.Ambient = Color3.fromRGB(70, 80, 100)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.7
	Lighting.FogColor = Color3.fromRGB(176, 214, 245)
	Lighting.FogStart = 280
	Lighting.FogEnd = 900

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.28
	atmosphere.Offset = 0.2
	atmosphere.Color = Color3.fromRGB(190, 220, 255)
	atmosphere.Decay = Color3.fromRGB(110, 150, 210)
	atmosphere.Glare = 0.25
	atmosphere.Haze = 1.1
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.35
	bloom.Size = 22
	bloom.Threshold = 0.95
	bloom.Parent = Lighting

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Saturation = 0.22
	grade.Contrast = 0.08
	grade.Brightness = 0.03
	grade.Parent = Lighting
end

local function burst(position, color)
	for i = 1, 8 do
		local angle = i / 8 * math.pi * 2
		local goal = position + Vector3.new(math.cos(angle) * 4, 2.5 + (i % 3), math.sin(angle) * 4)
		local bit = part({
			name = "Spark",
			size = Vector3.new(0.4, 0.4, 0.4),
			cframe = CFrame.new(position),
			color = color,
			material = Enum.Material.Neon,
			collide = false,
		})
		bit.Shape = Enum.PartType.Ball
		task.spawn(function()
			local began = os.clock()
			while bit.Parent and os.clock() - began < 0.4 do
				local alpha = (os.clock() - began) / 0.4
				bit.CFrame = CFrame.new(position:Lerp(goal, alpha))
				bit.Transparency = alpha
				task.wait()
			end
			if bit.Parent then
				bit:Destroy()
			end
		end)
	end
end

local function ping(parent)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	sound.Volume = 0.45
	sound.Parent = parent
	sound:Play()
	task.delay(2, function()
		sound:Destroy()
	end)
end

local function islandCenter(index)
	return Vector3.new((index - 1) * (ISLAND_SIZE.X + GAP), 0, 0)
end

local function buildWorld()
	styleLighting()

	part({
		name = "DeepWater",
		size = Vector3.new(1600, 16, 800),
		cframe = CFrame.new(400, -10, 0),
		color = Color3.fromRGB(16, 70, 140),
		material = Enum.Material.Glass,
		transparency = 0.2,
		collide = false,
	})
	part({
		name = "Water",
		size = Vector3.new(1600, 2, 800),
		cframe = CFrame.new(400, -1.2, 0),
		color = Color3.fromRGB(64, 176, 230),
		material = Enum.Material.Glass,
		transparency = 0.35,
		collide = false,
		touch = true,
	})
	local foam = Instance.new("Folder")
	foam.Name = "Foam"
	foam.Parent = workspace
	for i = 1, 8 do
		local crest = part({
			name = "Crest",
			size = Vector3.new(18, 0.3, 4),
			cframe = CFrame.new(80 + i * 70, -0.2, -30 + (i % 3) * 24),
			color = Color3.fromRGB(235, 248, 255),
			transparency = 0.35,
			collide = false,
			parent = foam,
		})
		crest:SetAttribute("Origin", crest.Position)
		crest:SetAttribute("Phase", i)
	end

	local shops = Instance.new("Folder")
	shops.Name = "Shops"
	shops.Parent = workspace

	for index, info in ipairs(ISLANDS) do
		local center = islandCenter(index)
		part({
			name = info.name .. " Cliff",
			size = Vector3.new(ISLAND_SIZE.X + 8, 12, ISLAND_SIZE.Z + 8),
			cframe = CFrame.new(center + Vector3.new(0, -6, 0)),
			color = Color3.fromRGB(92, 78, 64),
			material = Enum.Material.Rock,
		})
		part({
			name = info.name .. " Beach",
			size = Vector3.new(ISLAND_SIZE.X + 14, 1.4, ISLAND_SIZE.Z + 14),
			cframe = CFrame.new(center + Vector3.new(0, -0.2, 0)),
			color = Color3.fromRGB(232, 214, 164),
			material = Enum.Material.Sand,
		})
		part({
			name = info.name,
			size = ISLAND_SIZE,
			cframe = CFrame.new(center),
			color = info.color,
			material = Enum.Material.Grass,
		})
		part({
			name = "Path",
			size = Vector3.new(ISLAND_SIZE.X - 10, 0.35, 16),
			cframe = CFrame.new(center + Vector3.new(0, 1.15, 8)),
			color = Color3.fromRGB(236, 228, 206),
			material = Enum.Material.Concrete,
		})
		part({
			name = "PathEdge",
			size = Vector3.new(ISLAND_SIZE.X - 10, 0.2, 18),
			cframe = CFrame.new(center + Vector3.new(0, 1.05, 8)),
			color = info.accent,
			material = Enum.Material.Neon,
			collide = false,
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

		palm(center + Vector3.new(-62, 1, -62))
		palm(center + Vector3.new(64, 1, -48))
		palm(center + Vector3.new(-58, 1, 58))
		rock(center + Vector3.new(58, 1.4, 52), 1.1)
		rock(center + Vector3.new(-40, 1.3, 64), 0.7)

		if index < #ISLANDS then
			local gate = Characters.Gates[index]
			local padPosition = center + Vector3.new(ISLAND_SIZE.X / 2 - 16, 1.6, 8)
			local pad = part({
				name = "Launch",
				size = Vector3.new(14, 1, 14),
				cframe = CFrame.new(padPosition),
				color = Color3.fromRGB(255, 220, 60),
				material = Enum.Material.Neon,
				touch = true,
			})
			part({
				name = "LaunchRing",
				size = Vector3.new(16, 0.4, 16),
				cframe = CFrame.new(padPosition + Vector3.new(0, 0.4, 0)),
				color = Color3.fromRGB(255, 255, 255),
				material = Enum.Material.Neon,
				collide = false,
			})
			for step = 1, 3 do
				part({
					name = "Arrow",
					size = Vector3.new(1.2, 0.3, 2.2),
					cframe = CFrame.new(padPosition + Vector3.new(2 + step * 1.6, 0.7, 0)),
					color = Color3.fromRGB(255, 250, 220),
					material = Enum.Material.Neon,
					collide = false,
				})
			end
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
	burst(model.PrimaryPart.Position + Vector3.new(0, 3, 0), Characters.RarityColor[def.rarity] or Color3.new(1, 1, 1))
	ping(hrp)
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
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local center = islandCenter(fromIndex)
			local back = Vector3.new(center.X - hrp.Position.X, 0, center.Z - hrp.Position.Z)
			if back.Magnitude < 0.2 then
				back = Vector3.new(-1, 0, 0)
			end
			hrp.AssemblyLinearVelocity = back.Unit * 58 + Vector3.new(0, 42, 0)
		end
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
			burst(destination, Color3.fromRGB(255, 220, 80))
			ping(hrp)
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
	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, 1.1, 0)
	top.Parent = hrp
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -1.2, 0)
	bottom.Parent = hrp
	local trail = Instance.new("Trail")
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Lifetime = 0.35
	trail.MinLength = 0.05
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 230, 90), Color3.fromRGB(90, 210, 255))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.Parent = hrp
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

local ORB_VALUE = { 15, 70, 350 }
local orbs = Instance.new("Folder")
orbs.Name = "Orbs"
orbs.Parent = workspace

local function spawnOrb(islandIndex)
	local center = islandCenter(islandIndex)
	local spot = center + Vector3.new(math.random(-46, 46), 3.4, math.random(-8, 46))
	local orb = part({
		name = "CashOrb",
		size = Vector3.new(1.6, 1.6, 1.6),
		cframe = CFrame.new(spot),
		color = Color3.fromRGB(255, 210, 50),
		material = Enum.Material.Neon,
		collide = false,
		touch = true,
		parent = orbs,
	})
	orb.Shape = Enum.PartType.Ball
	orb:SetAttribute("Island", islandIndex)
	orb:SetAttribute("Value", ORB_VALUE[islandIndex])
	orb:SetAttribute("BaseY", spot.Y)
	orb:SetAttribute("Phase", math.random() * 6)
	local taken = false
	orb.Touched:Connect(function(hit)
		if taken then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or player.Checkpoint.Value ~= islandIndex then
			return
		end
		local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
		if not cash then
			return
		end
		taken = true
		local amount = orb:GetAttribute("Value")
		cash.Value += amount
		float:FireClient(player, amount)
		burst(orb.Position, Color3.fromRGB(255, 210, 50))
		orb:Destroy()
	end)
	task.delay(22, function()
		if orb.Parent then
			orb:Destroy()
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(3.2)
		for islandIndex = 1, 3 do
			local count = 0
			local watchers = 0
			for _, player in ipairs(Players:GetPlayers()) do
				local checkpoint = player:FindFirstChild("Checkpoint")
				if checkpoint and checkpoint.Value == islandIndex then
					watchers += 1
				end
			end
			if watchers > 0 then
				for _, orb in ipairs(orbs:GetChildren()) do
					if orb:GetAttribute("Island") == islandIndex then
						count += 1
					end
				end
				if count < 5 then
					spawnOrb(islandIndex)
				end
			end
		end
	end
end)

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
	local now = os.clock()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if hrp and humanoid and humanoid.Health > 0 and hrp.Position.Y < 0 and not character:GetAttribute("Launching") then
			humanoid.Health = 0
		end
	end
	local shops = workspace:FindFirstChild("Shops")
	if shops then
		for _, model in ipairs(shops:GetChildren()) do
			if model:GetAttribute("Bob") then
				local base = model:GetAttribute("Base")
				local phase = model:GetAttribute("Phase") or 0
				if typeof(base) == "CFrame" then
					model:PivotTo(base + Vector3.new(0, math.sin(now * 2 + phase) * 0.35, 0))
				end
			end
		end
	end
	for _, orb in ipairs(orbs:GetChildren()) do
		local baseY = orb:GetAttribute("BaseY")
		local phase = orb:GetAttribute("Phase") or 0
		if baseY then
			local pos = orb.Position
			orb.CFrame = CFrame.new(pos.X, baseY + math.sin(now * 3 + phase) * 0.45, pos.Z)
		end
	end
	local foam = workspace:FindFirstChild("Foam")
	if foam then
		for _, crest in ipairs(foam:GetChildren()) do
			local origin = crest:GetAttribute("Origin")
			local phase = crest:GetAttribute("Phase") or 0
			if typeof(origin) == "Vector3" then
				crest.CFrame = CFrame.new(origin + Vector3.new(math.sin(now * 0.6 + phase) * 6, 0, 0))
				crest.Transparency = 0.25 + (math.sin(now * 2 + phase) + 1) * 0.2
			end
		end
	end
end)
