-- Rarity Islands catalog.
-- Way 1 is the three speed-gated islands. Ways 2 and 3 are not in this version.

local Characters = {}

Characters.BaseSpeed = 16

-- Leave an island only when Speed is greater than `need`.
Characters.Gates = {
	{ from = 1, need = 34, next = "Sand Reach" },
	{ from = 2, need = 74, next = "Gold Isle" },
}

Characters.RarityColor = {
	Common = Color3.fromRGB(190, 190, 198),
	Uncommon = Color3.fromRGB(70, 210, 95),
	Rare = Color3.fromRGB(70, 150, 255),
	Epic = Color3.fromRGB(186, 80, 255),
	Exotic = Color3.fromRGB(255, 120, 40),
	Legendary = Color3.fromRGB(255, 186, 40),
	Mythic = Color3.fromRGB(255, 64, 90),
	Secret = Color3.fromRGB(255, 90, 190),
	Brainrot = Color3.fromRGB(255, 210, 40),
	Godly = Color3.fromRGB(80, 255, 220),
}

local function add(model, name, size, cf, color, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = false
	if shape then
		part.Shape = shape
	end
	part.Parent = model
	return part
end

local function mark(part, text, color, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.LightInfluence = 0
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Parent = gui
	return part
end

local function cf(pos, rx, ry, rz)
	return CFrame.new(pos) * CFrame.Angles(rx or 0, ry or 0, rz or 0)
end

local function buildBody(model, def)
	local s = def.scale or 1
	local function sz(v)
		return v * s
	end
	local function p(v)
		return v * s
	end
	local sleeve = def.sleeve or def.shirt
	add(model, "Torso", sz(Vector3.new(2, 2, 1)), cf(p(Vector3.new(0, 3, 0))), def.shirt)
	add(model, "Head", sz(Vector3.new(1.35, 1.35, 1.35)), cf(p(Vector3.new(0, 4.75, 0))), def.skin, Enum.PartType.Ball)
	add(model, "LeftArm", sz(Vector3.new(0.9, 2, 0.9)), cf(p(Vector3.new(-1.5, 3, 0))), sleeve)
	add(model, "RightArm", sz(Vector3.new(0.9, 2, 0.9)), cf(p(Vector3.new(1.5, 3, 0))), sleeve)
	add(model, "LeftLeg", sz(Vector3.new(0.9, 2, 0.9)), cf(p(Vector3.new(-0.5, 1, 0))), def.pants)
	add(model, "RightLeg", sz(Vector3.new(0.9, 2, 0.9)), cf(p(Vector3.new(0.5, 1, 0))), def.pants)
	if def.hair then
		add(model, "Hair", sz(Vector3.new(1.45, 0.7, 1.45)), cf(p(Vector3.new(0, 5.35, 0))), def.hair, Enum.PartType.Ball)
	end
	if not def.customFace then
		add(model, "EyeL", sz(Vector3.new(0.16, 0.2, 0.12)), cf(p(Vector3.new(-0.28, 4.82, -0.62))), Color3.fromRGB(20, 20, 24))
		add(model, "EyeR", sz(Vector3.new(0.16, 0.2, 0.12)), cf(p(Vector3.new(0.28, 4.82, -0.62))), Color3.fromRGB(20, 20, 24))
	end
end

local function decorateTin(model, s)
	local coin = add(model, "Coin", Vector3.new(0.16, 1.05, 1.05) * s, cf(Vector3.new(0, 6.15, 0) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
	mark(coin, "$", Color3.fromRGB(120, 70, 10), Enum.NormalId.Right)
end

local function decorateBibi(model, s)
	local shade = add(model, "Glasses", Vector3.new(1.25, 0.32, 0.16) * s, cf(Vector3.new(0, 4.82, -0.68) * s), Color3.fromRGB(12, 12, 16))
	shade.Material = Enum.Material.Glass
	add(model, "GlassGlint", Vector3.new(0.35, 0.08, 0.08) * s, cf(Vector3.new(0.28, 4.9, -0.76) * s), Color3.fromRGB(180, 230, 255), nil, Enum.Material.Neon)
	for i = -1, 1 do
		add(model, "Tooth", Vector3.new(0.12, 0.12, 0.1) * s, cf(Vector3.new(i * 0.16, 4.28, -0.66) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
	end
	local plate = add(model, "RobePlate", Vector3.new(1.15, 1.15, 0.12) * s, cf(Vector3.new(0, 3.05, -0.56) * s), Color3.fromRGB(248, 251, 255))
	mark(plate, "✡", Color3.fromRGB(20, 70, 190))
	add(model, "BlueHem", Vector3.new(2.05, 0.28, 1.05) * s, cf(Vector3.new(0, 2.1, 0) * s), Color3.fromRGB(28, 78, 216))
	local bat = add(model, "Bat", Vector3.new(0.28, 0.28, 2.1) * s, cf(Vector3.new(1.7, 2.3, -0.7) * s, math.rad(70), 0, math.rad(20)), Color3.fromRGB(150, 96, 42))
	bat.Material = Enum.Material.Wood
	add(model, "MoneyA", Vector3.new(0.7, 0.12, 0.4) * s, cf(Vector3.new(-1.7, 2.35, -0.45) * s), Color3.fromRGB(70, 170, 80))
	add(model, "MoneyB", Vector3.new(0.62, 0.12, 0.36) * s, cf(Vector3.new(-1.7, 2.5, -0.45) * s), Color3.fromRGB(90, 190, 100))
	add(model, "MoneyC", Vector3.new(0.5, 0.1, 0.3) * s, cf(Vector3.new(-1.7, 2.62, -0.45) * s), Color3.fromRGB(230, 230, 230))
end

local function decorateStalin(model, s)
	add(model, "Hat", Vector3.new(1.7, 0.7, 1.7) * s, cf(Vector3.new(0, 5.45, 0) * s), Color3.fromRGB(170, 28, 36))
	add(model, "HatFlapL", Vector3.new(0.28, 0.7, 1.2) * s, cf(Vector3.new(-0.78, 4.9, 0) * s), Color3.fromRGB(150, 24, 32))
	add(model, "HatFlapR", Vector3.new(0.28, 0.7, 1.2) * s, cf(Vector3.new(0.78, 4.9, 0) * s), Color3.fromRGB(150, 24, 32))
	local emblem = add(model, "Emblem", Vector3.new(0.55, 0.55, 0.1) * s, cf(Vector3.new(0, 5.35, -0.82) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
	mark(emblem, "☭", Color3.fromRGB(120, 70, 10))
	add(model, "Mustache", Vector3.new(0.7, 0.16, 0.18) * s, cf(Vector3.new(0, 4.45, -0.66) * s), Color3.fromRGB(40, 32, 28))
	local handle = add(model, "HammerHandle", Vector3.new(0.16, 1.3, 0.16) * s, cf(Vector3.new(-1.75, 2.5, -0.55) * s), Color3.fromRGB(110, 72, 40), nil, Enum.Material.Wood)
	handle.Name = "HammerHandle"
	add(model, "HammerHead", Vector3.new(0.7, 0.28, 0.28) * s, cf(Vector3.new(-1.75, 3.15, -0.55) * s), Color3.fromRGB(150, 154, 160), nil, Enum.Material.Metal)
	add(model, "SickleHandle", Vector3.new(0.14, 1.15, 0.14) * s, cf(Vector3.new(1.8, 2.55, -0.4) * s), Color3.fromRGB(110, 72, 40), nil, Enum.Material.Wood)
	add(model, "SickleBlade", Vector3.new(0.55, 0.12, 0.45) * s, cf(Vector3.new(2.05, 3.05, -0.55) * s, 0, 0, math.rad(40)), Color3.fromRGB(190, 40, 40), nil, Enum.Material.Metal)
	add(model, "BootL", Vector3.new(1.05, 0.55, 1.35) * s, cf(Vector3.new(-0.5, 0.35, -0.15) * s), Color3.fromRGB(58, 36, 24), nil, Enum.Material.Leather)
	add(model, "BootR", Vector3.new(1.05, 0.55, 1.35) * s, cf(Vector3.new(0.5, 0.35, -0.15) * s), Color3.fromRGB(58, 36, 24), nil, Enum.Material.Leather)
end

local function decorateParade(model, s)
	add(model, "Drum", Vector3.new(1.25, 0.85, 1.25) * s, cf(Vector3.new(0, 2.4, -0.95) * s), Color3.fromRGB(200, 40, 50))
	add(model, "DrumSkin", Vector3.new(1.05, 0.16, 1.05) * s, cf(Vector3.new(0, 2.85, -0.95) * s), Color3.fromRGB(245, 230, 190))
	add(model, "GoldButton", Vector3.new(0.22, 0.22, 0.12) * s, cf(Vector3.new(0, 3.4, -0.56) * s), Color3.fromRGB(255, 196, 40), Enum.PartType.Ball, Enum.Material.Neon)
end

local function decorateBanner(model, s)
	add(model, "Pole", Vector3.new(0.16, 3.2, 0.16) * s, cf(Vector3.new(1.85, 3.3, -0.3) * s), Color3.fromRGB(90, 60, 30), nil, Enum.Material.Wood)
	local flag = add(model, "Flag", Vector3.new(1.4, 0.9, 0.08) * s, cf(Vector3.new(2.6, 4.3, -0.3) * s), Color3.fromRGB(255, 214, 60))
	mark(flag, "★", Color3.fromRGB(150, 70, 10))
end

local function kneelingFan(model, s, side)
	local x = side * 1.7 * s
	local z = -2.15 * s
	local skin = Color3.fromRGB(232, 186, 146)
	local cloth = Color3.fromRGB(180, 30, 40)
	add(model, "FanBody", Vector3.new(0.7, 0.55, 0.55) * s, cf(Vector3.new(x, 0.55 * s, z)), cloth)
	add(model, "FanHead", Vector3.new(0.55, 0.55, 0.55) * s, cf(Vector3.new(x, 1.05 * s, z - 0.1 * s)), skin, Enum.PartType.Ball)
	add(model, "FanArm", Vector3.new(0.18, 0.55, 0.18) * s, cf(Vector3.new(x, 0.95 * s, z - 0.35 * s), math.rad(-40), 0, 0), skin)
	add(model, "Tear", Vector3.new(0.12, 0.18, 0.08) * s, cf(Vector3.new(x + 0.12 * s, 0.95 * s, z - 0.32 * s)), Color3.fromRGB(80, 170, 255), nil, Enum.Material.Glass)
end

local function decorateKim(model, s)
	local torso = model:FindFirstChild("Torso")
	if torso then
		torso.Size = Vector3.new(2.9, 2.3, 1.7) * s
		torso.CFrame = cf(Vector3.new(0, 3.05, 0) * s)
	end
	local head = model:FindFirstChild("Head")
	if head then
		head.Size = Vector3.new(1.7, 1.55, 1.6) * s
	end
	add(model, "EyeL", Vector3.new(0.34, 0.08, 0.1) * s, cf(Vector3.new(-0.32, 4.85, -0.75) * s, 0, 0, math.rad(12)), Color3.fromRGB(15, 15, 18))
	add(model, "EyeR", Vector3.new(0.34, 0.08, 0.1) * s, cf(Vector3.new(0.32, 4.85, -0.75) * s, 0, 0, math.rad(-12)), Color3.fromRGB(15, 15, 18))
	local badge = add(model, "Badge", Vector3.new(0.7, 0.7, 0.1) * s, cf(Vector3.new(0, 3.2, -0.9) * s), Color3.fromRGB(248, 248, 252))
	mark(badge, "★", Color3.fromRGB(190, 20, 30))
	add(model, "StarBand", Vector3.new(2.2, 0.28, 1.2) * s, cf(Vector3.new(0, 2.15, 0) * s), Color3.fromRGB(20, 50, 160))
	local missile = add(model, "Missile", Vector3.new(0.38, 0.38, 2.4) * s, cf(Vector3.new(1.9, 2.7, -0.9) * s, math.rad(80), 0, 0), Color3.fromRGB(70, 78, 70), nil, Enum.Material.Metal)
	missile.Name = "Missile"
	add(model, "MissileTip", Vector3.new(0.4, 0.5, 0.4) * s, cf(Vector3.new(2.15, 3.7, -1.15) * s), Color3.fromRGB(190, 30, 30), Enum.PartType.Ball)
	add(model, "TankHull", Vector3.new(1.5, 0.45, 2.1) * s, cf(Vector3.new(-2.3, 0.4, -0.2) * s), Color3.fromRGB(28, 58, 32), nil, Enum.Material.Metal)
	add(model, "TankTop", Vector3.new(0.7, 0.4, 0.8) * s, cf(Vector3.new(-2.3, 0.8, -0.15) * s), Color3.fromRGB(24, 48, 28), nil, Enum.Material.Metal)
	add(model, "TankGun", Vector3.new(0.16, 0.16, 1.1) * s, cf(Vector3.new(-2.3, 0.85, -0.9) * s), Color3.fromRGB(20, 36, 22), nil, Enum.Material.Metal)
	kneelingFan(model, s, -1)
	kneelingFan(model, s, 1)
end

local function decorateOsama(model, s)
	add(model, "Turban", Vector3.new(1.55, 0.55, 1.55) * s, cf(Vector3.new(0, 5.35, 0) * s), Color3.fromRGB(245, 245, 240))
	add(model, "TurbanWrap", Vector3.new(1.2, 0.35, 1.7) * s, cf(Vector3.new(0, 5.15, -0.05) * s), Color3.fromRGB(230, 230, 224))
	add(model, "TurbanTail", Vector3.new(0.35, 1.1, 0.2) * s, cf(Vector3.new(0.2, 4.5, 0.7) * s), Color3.fromRGB(245, 245, 240))
	add(model, "Beard", Vector3.new(0.7, 0.85, 0.4) * s, cf(Vector3.new(0, 4.15, -0.55) * s), Color3.fromRGB(30, 26, 22))
	for i = -1, 2 do
		local angle = i * 0.8
		add(model, "Bomb", Vector3.new(0.42, 0.42, 0.42) * s, cf(Vector3.new(math.sin(angle) * 0.95, 2.35, -math.cos(angle) * 0.7) * s), Color3.fromRGB(25, 25, 28), Enum.PartType.Ball, Enum.Material.Metal)
	end
	add(model, "Fuse", Vector3.new(0.08, 0.35, 0.08) * s, cf(Vector3.new(0.15, 2.7, -0.85) * s), Color3.fromRGB(180, 180, 180))
	add(model, "PlaneBody", Vector3.new(0.35, 0.28, 1.7) * s, cf(Vector3.new(1.9, 3.1, -0.6) * s), Color3.fromRGB(235, 240, 245))
	add(model, "PlaneWing", Vector3.new(1.5, 0.08, 0.4) * s, cf(Vector3.new(1.9, 3.15, -0.45) * s), Color3.fromRGB(40, 120, 200))
	add(model, "PlaneTail", Vector3.new(0.08, 0.4, 0.35) * s, cf(Vector3.new(1.9, 3.35, 0.1) * s), Color3.fromRGB(40, 120, 200))
end

local function decorateVault(model, s)
	add(model, "Hood", Vector3.new(1.5, 0.8, 1.5) * s, cf(Vector3.new(0, 5.3, 0) * s), Color3.fromRGB(90, 40, 150))
	local door = add(model, "VaultDoor", Vector3.new(1.1, 1.3, 0.2) * s, cf(Vector3.new(0, 3.1, 0.6) * s), Color3.fromRGB(70, 74, 82), nil, Enum.Material.Metal)
	mark(door, "VAULT", Color3.fromRGB(255, 196, 40), Enum.NormalId.Back)
	add(model, "GoldBelt", Vector3.new(2.1, 0.22, 1.1) * s, cf(Vector3.new(0, 2.2, 0) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
end

local function decorateJin(model, s)
	local torso = model:FindFirstChild("Torso")
	if torso then
		torso.Size = Vector3.new(2.7, 2.15, 1.6) * s
	end
	local head = model:FindFirstChild("Head")
	if head then
		head.Size = Vector3.new(1.85, 1.6, 1.7) * s
		head.Color = Color3.fromRGB(255, 196, 60)
	end
	add(model, "EarL", Vector3.new(0.4, 0.45, 0.25) * s, cf(Vector3.new(-0.95, 4.9, 0) * s), Color3.fromRGB(255, 186, 50), Enum.PartType.Ball)
	add(model, "EarR", Vector3.new(0.4, 0.45, 0.25) * s, cf(Vector3.new(0.95, 4.9, 0) * s), Color3.fromRGB(255, 186, 50), Enum.PartType.Ball)
	add(model, "EyeL", Vector3.new(0.16, 0.16, 0.1) * s, cf(Vector3.new(-0.4, 4.95, -0.75) * s), Color3.fromRGB(20, 16, 12), Enum.PartType.Ball)
	add(model, "EyeR", Vector3.new(0.16, 0.16, 0.1) * s, cf(Vector3.new(0.4, 4.95, -0.75) * s), Color3.fromRGB(20, 16, 12), Enum.PartType.Ball)
	add(model, "Snout", Vector3.new(0.45, 0.35, 0.35) * s, cf(Vector3.new(0, 4.55, -0.75) * s), Color3.fromRGB(255, 176, 50), Enum.PartType.Ball)
	add(model, "Nose", Vector3.new(0.18, 0.16, 0.12) * s, cf(Vector3.new(0, 4.58, -0.95) * s), Color3.fromRGB(30, 24, 20), Enum.PartType.Ball)
	local star = add(model, "FlagStar", Vector3.new(0.7, 0.7, 0.08) * s, cf(Vector3.new(-0.35, 3.35, -0.85) * s), Color3.fromRGB(190, 20, 30))
	mark(star, "★", Color3.fromRGB(255, 210, 40))
	add(model, "FactoryA", Vector3.new(0.7, 1.1, 0.7) * s, cf(Vector3.new(-1.9, 2.7, -0.4) * s), Color3.fromRGB(130, 136, 144), nil, Enum.Material.Concrete)
	add(model, "FactoryB", Vector3.new(0.55, 0.8, 0.55) * s, cf(Vector3.new(-2.45, 2.5, -0.35) * s), Color3.fromRGB(110, 116, 124), nil, Enum.Material.Concrete)
	add(model, "Chimney", Vector3.new(0.22, 0.7, 0.22) * s, cf(Vector3.new(-1.9, 3.5, -0.4) * s), Color3.fromRGB(70, 74, 80), nil, Enum.Material.Metal)
	local flag = add(model, "ChinaFlag", Vector3.new(0.9, 0.6, 0.08) * s, cf(Vector3.new(1.9, 3.3, -0.5) * s), Color3.fromRGB(190, 24, 32))
	mark(flag, "★★", Color3.fromRGB(255, 210, 40))
	add(model, "FlagPole", Vector3.new(0.1, 1.4, 0.1) * s, cf(Vector3.new(1.45, 2.8, -0.4) * s), Color3.fromRGB(230, 190, 60), nil, Enum.Material.Metal)
end

local function decorateWhale(model, s)
	add(model, "Body", Vector3.new(3.4, 1.8, 4.2) * s, cf(Vector3.new(0, 2.2, 0) * s), Color3.fromRGB(55, 130, 210), nil, Enum.Material.SmoothPlastic)
	add(model, "Belly", Vector3.new(2.4, 0.7, 3.2) * s, cf(Vector3.new(0, 1.5, -0.1) * s), Color3.fromRGB(235, 242, 250))
	add(model, "Head", Vector3.new(2.2, 1.6, 1.8) * s, cf(Vector3.new(0, 2.5, -2.2) * s), Color3.fromRGB(55, 130, 210), Enum.PartType.Ball)
	add(model, "EyeL", Vector3.new(0.28, 0.28, 0.12) * s, cf(Vector3.new(-0.55, 2.65, -3) * s), Color3.fromRGB(20, 20, 24), Enum.PartType.Ball)
	add(model, "EyeR", Vector3.new(0.28, 0.28, 0.12) * s, cf(Vector3.new(0.55, 2.65, -3) * s), Color3.fromRGB(20, 20, 24), Enum.PartType.Ball)
	add(model, "Tail", Vector3.new(0.4, 1.3, 1.5) * s, cf(Vector3.new(0, 2.4, 2.5) * s, math.rad(20), 0, 0), Color3.fromRGB(40, 110, 190))
	add(model, "Crown", Vector3.new(1.5, 0.4, 1.5) * s, cf(Vector3.new(0, 3.7, -2.1) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
	add(model, "CrownPoint", Vector3.new(0.25, 0.45, 0.25) * s, cf(Vector3.new(0, 4.1, -2.1) * s), Color3.fromRGB(255, 196, 40), nil, Enum.Material.Neon)
	add(model, "Spout", Vector3.new(0.35, 0.9, 0.35) * s, cf(Vector3.new(0, 3.5, -0.4) * s), Color3.fromRGB(180, 230, 255), nil, Enum.Material.Glass)
end

local SKIN = Color3.fromRGB(242, 196, 154)
local PALE = Color3.fromRGB(255, 214, 176)

Characters.List = {
	{
		id = "tin",
		name = "Tin Teller",
		rarity = "Common",
		island = 1,
		cost = 25,
		income = 5,
		speed = 4,
		scale = 1,
		skin = PALE,
		shirt = Color3.fromRGB(74, 78, 88),
		pants = Color3.fromRGB(48, 50, 58),
		hair = Color3.fromRGB(70, 48, 32),
		decorate = decorateTin,
	},
	{
		id = "bibi",
		name = "Bibi Netanjahuuu",
		rarity = "Uncommon",
		island = 1,
		cost = 250,
		income = 14,
		speed = 7,
		scale = 1,
		skin = PALE,
		shirt = Color3.fromRGB(248, 251, 255),
		pants = Color3.fromRGB(28, 78, 216),
		sleeve = Color3.fromRGB(28, 78, 216),
		decorate = decorateBibi,
	},
	{
		id = "stalin",
		name = "Josepee Stalin",
		rarity = "Rare",
		island = 1,
		cost = 900,
		income = 32,
		speed = 9,
		scale = 1.02,
		skin = SKIN,
		shirt = Color3.fromRGB(92, 62, 40),
		pants = Color3.fromRGB(62, 48, 36),
		sleeve = Color3.fromRGB(92, 62, 40),
		hair = Color3.fromRGB(80, 80, 84),
		decorate = decorateStalin,
	},
	{
		id = "parade",
		name = "Parade Drum",
		rarity = "Epic",
		island = 2,
		cost = 2800,
		income = 70,
		speed = 8,
		scale = 1,
		skin = SKIN,
		shirt = Color3.fromRGB(190, 30, 48),
		pants = Color3.fromRGB(30, 30, 36),
		sleeve = Color3.fromRGB(190, 30, 48),
		hair = Color3.fromRGB(20, 20, 24),
		decorate = decorateParade,
	},
	{
		id = "banner",
		name = "Banner Boy",
		rarity = "Exotic",
		island = 2,
		cost = 6000,
		income = 110,
		speed = 9,
		scale = 1,
		skin = PALE,
		shirt = Color3.fromRGB(36, 78, 170),
		pants = Color3.fromRGB(24, 36, 80),
		sleeve = Color3.fromRGB(36, 78, 170),
		hair = Color3.fromRGB(40, 28, 18),
		decorate = decorateBanner,
	},
	{
		id = "kim",
		name = "Kim Jong Uno",
		rarity = "Legendary",
		island = 2,
		cost = 14000,
		income = 220,
		speed = 12,
		scale = 1.15,
		skin = Color3.fromRGB(236, 186, 140),
		shirt = Color3.fromRGB(186, 22, 32),
		pants = Color3.fromRGB(22, 48, 150),
		sleeve = Color3.fromRGB(186, 22, 32),
		hair = Color3.fromRGB(18, 18, 20),
		customFace = true,
		decorate = decorateKim,
	},
	{
		id = "osama",
		name = "Osama bin Baden",
		rarity = "Mythic",
		island = 2,
		cost = 32000,
		income = 480,
		speed = 14,
		scale = 1.05,
		skin = Color3.fromRGB(214, 170, 130),
		shirt = Color3.fromRGB(236, 236, 228),
		pants = Color3.fromRGB(226, 226, 216),
		sleeve = Color3.fromRGB(236, 236, 228),
		decorate = decorateOsama,
	},
	{
		id = "vault",
		name = "Vault Monk",
		rarity = "Secret",
		island = 3,
		cost = 150000,
		income = 1100,
		speed = 10,
		scale = 1.05,
		skin = SKIN,
		shirt = Color3.fromRGB(86, 36, 140),
		pants = Color3.fromRGB(48, 20, 80),
		sleeve = Color3.fromRGB(86, 36, 140),
		decorate = decorateVault,
	},
	{
		id = "jin",
		name = "Jin Pig",
		rarity = "Brainrot",
		island = 3,
		cost = 500000,
		income = 2600,
		speed = 18,
		scale = 1.18,
		skin = Color3.fromRGB(255, 196, 60),
		shirt = Color3.fromRGB(186, 22, 32),
		pants = Color3.fromRGB(186, 22, 32),
		sleeve = Color3.fromRGB(255, 196, 60),
		customFace = true,
		decorate = decorateJin,
	},
	{
		id = "whale",
		name = "Crown Whale",
		rarity = "Godly",
		island = 3,
		cost = 2000000,
		income = 7000,
		speed = 30,
		scale = 1.1,
		custom = true,
		decorate = decorateWhale,
	},
}

Characters.ById = {}
for _, def in ipairs(Characters.List) do
	Characters.ById[def.id] = def
end

function Characters.Build(def, worldCf, mode)
	local model = Instance.new("Model")
	model.Name = def.name
	local root = add(model, "Root", Vector3.new(0.4, 0.4, 0.4), cf(Vector3.new(0, 0.2, 0)), Color3.new(1, 1, 1))
	root.Transparency = 1
	root.CanQuery = true
	if not def.custom then
		buildBody(model, def)
	end
	if def.decorate then
		def.decorate(model, def.scale or 1)
	end
	model.PrimaryPart = root
	model:SetAttribute("Id", def.id)
	model:SetAttribute("Mode", mode)

	local color = Characters.RarityColor[def.rarity] or Color3.new(1, 1, 1)
	local scale = def.scale or 1
	local stand = add(model, "Stand", Vector3.new(3.4, 0.4, 3.4) * scale, cf(Vector3.new(0, 0.12, 0)), color, nil, Enum.Material.Neon)
	stand.Transparency = 0.4
	add(model, "StandRim", Vector3.new(4.1, 0.18, 4.1) * scale, cf(Vector3.new(0, 0.02, 0)), Color3.fromRGB(18, 18, 24))

	local glow = Instance.new("Highlight")
	glow.Name = "RarityGlow"
	glow.FillTransparency = 0.82
	glow.OutlineTransparency = 0.2
	glow.FillColor = color
	glow.OutlineColor = color
	glow.Parent = model

	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 12
	light.Brightness = 1.1
	light.Parent = root

	local bill = Instance.new("BillboardGui")
	bill.Name = "Label"
	bill.Size = UDim2.fromOffset(220, 92)
	bill.StudsOffset = Vector3.new(0, 6.8 * scale, 0)
	bill.AlwaysOnTop = true
	bill.MaxDistance = 110
	bill.Parent = root

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	frame.BackgroundTransparency = 0.18
	frame.Parent = bill
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = frame

	local function line(y, height, text, textColor)
		local item = Instance.new("TextLabel")
		item.BackgroundTransparency = 1
		item.Position = UDim2.fromScale(0.04, y)
		item.Size = UDim2.fromScale(0.92, height)
		item.Font = Enum.Font.GothamBold
		item.Text = text
		item.TextColor3 = textColor
		item.TextScaled = true
		item.Parent = frame
		return item
	end
	line(0.04, 0.34, def.name, Color3.new(1, 1, 1))
	line(0.36, 0.24, def.rarity, color)
	if mode == "shop" then
		line(0.64, 0.28, string.format("$%d   +%d speed   $%d/s", def.cost, def.speed, def.income), Color3.fromRGB(255, 226, 120))
	else
		line(0.64, 0.28, string.format("+$%d/s", def.income), Color3.fromRGB(255, 226, 120))
	end

	model:PivotTo(worldCf)
	model:SetAttribute("Base", model:GetPivot())
	model:SetAttribute("Phase", math.random() * math.pi * 2)
	model:SetAttribute("Bob", mode == "shop")
	return model
end

return Characters
