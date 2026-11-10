export type CharacterDef = {
  id: string
  name: string
  rarity: string
  island: number
  cost: number
  income: number
  speed: number
  color: string
  accent: string
}

export const CHARACTERS: CharacterDef[] = [
  { id: "tin", name: "Tin Teller", rarity: "Common", island: 0, cost: 25, income: 5, speed: 4, color: "#4a4e58", accent: "#ffc428" },
  { id: "bibi", name: "Bibi Netanjahuuu", rarity: "Uncommon", island: 0, cost: 250, income: 14, speed: 7, color: "#f8fbff", accent: "#1d4ed8" },
  { id: "stalin", name: "Josepee Stalin", rarity: "Rare", island: 0, cost: 900, income: 32, speed: 9, color: "#5c3e28", accent: "#aa1c24" },
  { id: "parade", name: "Parade Drum", rarity: "Epic", island: 1, cost: 2800, income: 70, speed: 8, color: "#be1e30", accent: "#f5e6be" },
  { id: "banner", name: "Banner Boy", rarity: "Exotic", island: 1, cost: 6000, income: 110, speed: 9, color: "#244eaa", accent: "#ffd63c" },
  { id: "kim", name: "Kim Jong Uno", rarity: "Legendary", island: 1, cost: 14000, income: 220, speed: 12, color: "#ba1620", accent: "#163096" },
  { id: "osama", name: "Osama bin Baden", rarity: "Mythic", island: 1, cost: 32000, income: 480, speed: 14, color: "#ecece4", accent: "#222" },
  { id: "vault", name: "Vault Monk", rarity: "Secret", island: 2, cost: 150000, income: 1100, speed: 10, color: "#56248c", accent: "#ffc428" },
  { id: "jin", name: "Jin Pig", rarity: "Brainrot", island: 2, cost: 500000, income: 2600, speed: 18, color: "#ffc43c", accent: "#be1620" },
  { id: "whale", name: "Crown Whale", rarity: "Godly", island: 2, cost: 2000000, income: 7000, speed: 30, color: "#3782d2", accent: "#ffc428" },
]

export const ISLANDS = [
  { name: "Green Dock", x: 0, y: 0, w: 980, h: 700, grass: "#4ea848", sand: "#e6d3a0", cliff: "#6b5848" },
  { name: "Sand Reach", x: 1460, y: 0, w: 980, h: 700, grass: "#d6b868", sand: "#f0e2b8", cliff: "#6b5848" },
  { name: "Gold Isle", x: 2920, y: 0, w: 980, h: 700, grass: "#5c46a8", sand: "#e6d3a0", cliff: "#4a4038" },
]

export const GATES = [
  { from: 0, need: 34, next: "Sand Reach" },
  { from: 1, need: 74, next: "Gold Isle" },
]

const BASE_SPEED = 16
const ORB_VALUE = [15, 70, 350]

export type Coin = { x: number; y: number; island: number; value: number; phase: number }
export type Floater = { x: number; y: number; text: string; life: number }

export type Game = {
  x: number
  y: number
  vx: number
  vy: number
  cash: number
  checkpoint: number
  owned: Set<string>
  coins: Coin[]
  floaters: Floater[]
  coinTimer: number
  incomeTimer: number
  launch: number
  launchFromX: number
  launchFromY: number
  launchToX: number
  launchToY: number
  message: string
  messageT: number
  time: number
  bounce: number
}

export function createGame(): Game {
  const spawn = spawnPoint(0)
  return {
    x: spawn.x,
    y: spawn.y,
    vx: 0,
    vy: 0,
    cash: 50,
    checkpoint: 0,
    owned: new Set(),
    coins: [],
    floaters: [],
    coinTimer: 1,
    incomeTimer: 0,
    launch: 0,
    launchFromX: 0,
    launchFromY: 0,
    launchToX: 0,
    launchToY: 0,
    message: "Collect Tin Teller to start earning.",
    messageT: 4,
    time: 0,
    bounce: 0,
  }
}

export function incomeOf(game: Game) {
  let total = 0
  for (const def of CHARACTERS) if (game.owned.has(def.id)) total += def.income
  return total
}

export function speedOf(game: Game) {
  let bonus = 0
  for (const def of CHARACTERS) if (game.owned.has(def.id)) bonus += def.speed
  return BASE_SPEED + bonus
}

export function characterSpot(def: CharacterDef) {
  const island = ISLANDS[def.island]
  const group = CHARACTERS.filter((item) => item.island === def.island)
  const index = group.findIndex((item) => item.id === def.id)
  const span = Math.min(island.w - 180, group.length * 180)
  const start = -span / 2 + span / group.length / 2
  return { x: island.x + start + index * (span / group.length), y: island.y - 50 }
}

function spawnPoint(index: number) {
  const first = CHARACTERS.find((item) => item.island === index) ?? CHARACTERS[0]
  const spot = characterSpot(first)
  return { x: spot.x, y: spot.y + 230 }
}

function padRect(index: number) {
  const island = ISLANDS[index]
  return { x: island.x + island.w * 0.36, y: island.y + 40, w: 110, h: 90 }
}

function onIsland(x: number, y: number, index: number) {
  const island = ISLANDS[index]
  return Math.abs(x - island.x) < island.w / 2 - 8 && Math.abs(y - island.y) < island.h / 2 - 8
}

function anyIsland(x: number, y: number) {
  return ISLANDS.some((_, index) => onIsland(x, y, index))
}

export function nearestAffordable(game: Game) {
  let best: CharacterDef | null = null
  let bestD = 130
  for (const def of CHARACTERS) {
    if (game.owned.has(def.id) || def.island > game.checkpoint || game.cash < def.cost) continue
    const spot = characterSpot(def)
    const d = Math.hypot(game.x - spot.x, game.y - spot.y)
    if (d < bestD) {
      best = def
      bestD = d
    }
  }
  return best
}

export function tryCollect(game: Game) {
  const def = nearestAffordable(game)
  if (!def || game.launch > 0) return false
  game.cash -= def.cost
  game.owned.add(def.id)
  const spot = characterSpot(def)
  game.floaters.push({ x: spot.x, y: spot.y - 70, text: def.name, life: 1.4 })
  game.message = `${def.name} joined. +${def.speed} speed, +$${def.income}/s.`
  game.messageT = 3.2
  const gate = GATES[game.checkpoint]
  if (gate && speedOf(game) > gate.need) {
    game.message = `You can launch to ${gate.next}.`
  }
  return true
}

function launch(game: Game, from: number) {
  const gate = GATES[from]
  if (!gate || game.launch > 0 || game.checkpoint !== from) return
  if (speedOf(game) <= gate.need) {
    game.bounce = 0.55
    game.message = `${gate.next} needs more than ${gate.need} speed. You have ${speedOf(game)}.`
    game.messageT = 2.4
    return
  }
  const dest = spawnPoint(from + 1)
  game.launch = 1
  game.launchFromX = game.x
  game.launchFromY = game.y
  game.launchToX = dest.x
  game.launchToY = dest.y
}

export function update(game: Game, dt: number, mx: number, my: number, collect: boolean) {
  dt = Math.min(dt, 0.05)
  game.time += dt
  if (game.messageT > 0) game.messageT -= dt
  game.incomeTimer += dt
  if (game.incomeTimer >= 1) {
    game.incomeTimer = 0
    const gain = incomeOf(game)
    if (gain > 0) {
      game.cash += gain
      game.floaters.push({ x: game.x, y: game.y - 40, text: `+$${gain}`, life: 0.8 })
    }
  }

  if (game.launch > 0) {
    game.launch -= dt / 1.15
    const t = 1 - Math.max(game.launch, 0)
    const arc = Math.sin(t * Math.PI) * 180
    game.x = game.launchFromX + (game.launchToX - game.launchFromX) * t
    game.y = game.launchFromY + (game.launchToY - game.launchFromY) * t - arc
    if (game.launch <= 0) {
      game.launch = 0
      game.checkpoint += 1
      const spot = spawnPoint(game.checkpoint)
      game.x = spot.x
      game.y = spot.y
      game.vx = 0
      game.vy = 0
      game.message = `Welcome to ${ISLANDS[game.checkpoint].name}.`
      game.messageT = 2.6
    }
    return
  }

  const speed = 210 + speedOf(game) * 1.4
  const mag = Math.hypot(mx, my)
  if (game.bounce > 0) {
    game.bounce -= dt
    game.vx = -340
    game.vy = -60
  } else if (mag > 0.12) {
    game.vx = (mx / mag) * speed
    game.vy = (my / mag) * speed
  } else {
    game.vx *= Math.exp(-8 * dt)
    game.vy *= Math.exp(-8 * dt)
  }
  game.x += game.vx * dt
  game.y += game.vy * dt

  if (collect) tryCollect(game)

  for (let i = game.coins.length - 1; i >= 0; i--) {
    const coin = game.coins[i]
    if (coin.island === game.checkpoint && Math.hypot(game.x - coin.x, game.y - coin.y) < 36) {
      game.cash += coin.value
      game.floaters.push({ x: coin.x, y: coin.y, text: `+$${coin.value}`, life: 0.9 })
      game.coins.splice(i, 1)
    }
  }

  const pad = GATES[game.checkpoint] ? padRect(game.checkpoint) : null
  if (game.bounce <= 0 && pad && Math.abs(game.x - (pad.x + pad.w / 2)) < pad.w / 2 && Math.abs(game.y - (pad.y + pad.h / 2)) < pad.h / 2) {
    launch(game, game.checkpoint)
  }

  if (game.launch === 0 && !anyIsland(game.x, game.y)) {
    const spot = spawnPoint(game.checkpoint)
    game.x = spot.x
    game.y = spot.y
    game.vx = 0
    game.vy = 0
    game.message = "The water sent you back."
    game.messageT = 1.6
  }

  game.coinTimer -= dt
  const here = game.coins.filter((coin) => coin.island === game.checkpoint).length
  if (game.coinTimer <= 0 && here < 5) {
    game.coinTimer = 3.2
    const island = ISLANDS[game.checkpoint]
    game.coins.push({
      x: island.x + (Math.random() - 0.5) * (island.w - 160),
      y: island.y + (Math.random() - 0.15) * (island.h - 180),
      island: game.checkpoint,
      value: ORB_VALUE[game.checkpoint],
      phase: Math.random() * Math.PI * 2,
    })
  }
  for (const floater of game.floaters) {
    floater.y -= 30 * dt
    floater.life -= dt
  }
  game.floaters = game.floaters.filter((floater) => floater.life > 0)
}

export function nextGoal(game: Game) {
  for (const def of CHARACTERS) {
    if (game.owned.has(def.id)) continue
    if (def.island > game.checkpoint) return `Cross before you can collect ${def.name}.`
    if (game.cash < def.cost) return `Next: ${def.name}. $${def.cost - game.cash} to go.`
    return `${def.name} is ready. Walk up and collect.`
  }
  return "Full crew. Every character is yours."
}

export function hint(game: Game) {
  if (game.messageT > 0) return game.message
  const gate = GATES[game.checkpoint]
  if (!gate) return "Gold Isle. Grab the coins and finish the crew."
  if (speedOf(game) > gate.need) return `The pad is open. Launch to ${gate.next}.`
  return `${gate.next} needs more than ${gate.need} speed. You have ${speedOf(game)}.`
}

export function gateRatio(game: Game) {
  const gate = GATES[game.checkpoint]
  if (!gate) return 1
  return Math.max(0, Math.min(1, speedOf(game) / (gate.need + 1)))
}

function roundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
  ctx.beginPath()
  ctx.roundRect(x, y, w, h, r)
}

function drawIsland(ctx: CanvasRenderingContext2D, index: number, time: number) {
  const island = ISLANDS[index]
  const x = island.x - island.w / 2
  const y = island.y - island.h / 2
  ctx.fillStyle = island.cliff
  roundRect(ctx, x - 18, y + 18, island.w + 36, island.h + 28, 36)
  ctx.fill()
  ctx.fillStyle = island.sand
  roundRect(ctx, x - 16, y - 8, island.w + 32, island.h + 20, 32)
  ctx.fill()
  ctx.fillStyle = island.grass
  roundRect(ctx, x, y, island.w, island.h, 26)
  ctx.fill()
  ctx.fillStyle = "rgba(255,255,255,0.14)"
  roundRect(ctx, x + 28, island.y + 8, island.w - 56, 54, 16)
  ctx.fill()
  for (const spot of [[-0.38, -0.32], [0.4, -0.22], [-0.34, 0.34]]) {
    const px = island.x + spot[0] * island.w
    const py = island.y + spot[1] * island.h
    ctx.fillStyle = "#7a5230"
    ctx.fillRect(px - 4, py, 8, 34)
    ctx.fillStyle = index === 2 ? "#b7a0ff" : "#2f9a45"
    for (let i = 0; i < 5; i++) {
      const a = i / 5 * Math.PI * 2 + time * 0.2
      ctx.beginPath()
      ctx.ellipse(px + Math.cos(a) * 16, py - 6 + Math.sin(a) * 8, 16, 6, a, 0, Math.PI * 2)
      ctx.fill()
    }
  }
}

function drawStar(ctx: CanvasRenderingContext2D, x: number, y: number, r: number, color: string) {
  ctx.fillStyle = color
  for (const rot of [-Math.PI / 2, Math.PI / 2]) {
    ctx.beginPath()
    for (let i = 0; i < 3; i++) {
      const a = rot + (i * 2 * Math.PI) / 3
      const px = x + Math.cos(a) * r
      const py = y + Math.sin(a) * r
      if (i === 0) ctx.moveTo(px, py)
      else ctx.lineTo(px, py)
    }
    ctx.closePath()
    ctx.fill()
  }
}

function drawPerson(ctx: CanvasRenderingContext2D, x: number, y: number, shirt: string, pants: string, scale = 1) {
  ctx.save()
  ctx.translate(x, y)
  ctx.scale(scale, scale)
  ctx.fillStyle = "rgba(0,0,0,0.25)"
  ctx.beginPath()
  ctx.ellipse(0, 28, 16, 6, 0, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = pants
  ctx.fillRect(-10, 8, 8, 18)
  ctx.fillRect(2, 8, 8, 18)
  ctx.fillStyle = shirt
  ctx.fillRect(-14, -10, 28, 22)
  ctx.fillStyle = "#f3c7a1"
  ctx.beginPath()
  ctx.arc(0, -22, 12, 0, Math.PI * 2)
  ctx.fill()
  ctx.restore()
}

function drawCharacter(ctx: CanvasRenderingContext2D, def: CharacterDef, owned: boolean, ready: boolean, time: number) {
  const spot = characterSpot(def)
  const bob = Math.sin(time * 2 + def.island) * 4
  const y = spot.y + bob
  ctx.fillStyle = owned ? "rgba(80,220,120,0.35)" : ready ? "rgba(120,255,160,0.9)" : def.accent
  ctx.beginPath()
  ctx.ellipse(spot.x, spot.y + 34, 28, 10, 0, 0, Math.PI * 2)
  ctx.fill()
  if (def.id === "whale") {
    ctx.fillStyle = def.color
    ctx.beginPath()
    ctx.ellipse(spot.x, y + 6, 34, 20, 0, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = def.accent
    ctx.fillRect(spot.x - 10, y - 28, 20, 10)
  } else if (def.id === "jin") {
    drawPerson(ctx, spot.x, y, def.accent, def.accent, 1.15)
    ctx.fillStyle = def.color
    ctx.beginPath()
    ctx.arc(spot.x, y - 24, 16, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = "#222"
    ctx.beginPath()
    ctx.arc(spot.x, y - 22, 4, 0, Math.PI * 2)
    ctx.fill()
  } else {
    drawPerson(ctx, spot.x, y, def.color, def.id === "bibi" ? def.accent : "#2a241c", def.id === "kim" ? 1.18 : 1)
  }
  if (def.id === "bibi") {
    ctx.fillStyle = "#111"
    ctx.fillRect(spot.x - 10, y - 26, 20, 5)
    drawStar(ctx, spot.x, y - 2, 7, def.accent)
  } else if (def.id === "stalin") {
    ctx.fillStyle = def.accent
    ctx.fillRect(spot.x - 14, y - 40, 28, 8)
  } else if (def.id === "kim") {
    drawStar(ctx, spot.x, y - 2, 6, "#f8f8ff")
  } else if (def.id === "osama") {
    ctx.fillStyle = "#f4f4ee"
    ctx.fillRect(spot.x - 12, y - 38, 24, 8)
  }
  ctx.fillStyle = "#101218"
  ctx.font = "700 13px Nunito, Trebuchet MS, sans-serif"
  ctx.textAlign = "center"
  ctx.fillText(def.name, spot.x, y - 58)
  ctx.fillStyle = def.accent
  ctx.fillText(owned ? "Owned" : `$${def.cost}`, spot.x, y - 44)
}

export function draw(ctx: CanvasRenderingContext2D, game: Game, width: number, height: number) {
  const camX = game.x - width / 2
  const camY = game.y - height / 2
  const sky = ctx.createLinearGradient(0, 0, 0, height)
  sky.addColorStop(0, "#8fd0ff")
  sky.addColorStop(0.45, "#2f86d8")
  sky.addColorStop(1, "#0c4e96")
  ctx.fillStyle = sky
  ctx.fillRect(0, 0, width, height)

  ctx.save()
  ctx.translate(-camX, -camY)
  const left = camX - 40
  const top = camY - 40
  for (let i = 0; i < 18; i++) {
    ctx.strokeStyle = `rgba(255,255,255,${0.08 + (i % 3) * 0.03})`
    ctx.lineWidth = 2
    ctx.beginPath()
    const y = top + ((i * 80 + game.time * 24) % (height + 160)) - 40
    ctx.moveTo(left, y)
    ctx.bezierCurveTo(left + 180, y - 12, left + 320, y + 14, left + width + 80, y)
    ctx.stroke()
  }
  for (const index of ISLANDS.keys()) drawIsland(ctx, index, game.time)
  GATES.forEach((gate, index) => {
    const pad = padRect(index)
    const open = game.checkpoint === index && speedOf(game) > gate.need
    ctx.fillStyle = open ? "#5dffa0" : "#ffd84a"
    roundRect(ctx, pad.x, pad.y, pad.w, pad.h, 12)
    ctx.fill()
    ctx.fillStyle = "#1a1404"
    ctx.font = "900 14px Nunito, Trebuchet MS, sans-serif"
    ctx.textAlign = "center"
    ctx.fillText(open ? "LAUNCH" : `>${gate.need}`, pad.x + pad.w / 2, pad.y + 50)
  })
  for (const coin of game.coins) {
    const bob = Math.sin(game.time * 3 + coin.phase) * 6
    ctx.fillStyle = "#ffd24a"
    ctx.beginPath()
    ctx.arc(coin.x, coin.y + bob, 12, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = "#7a4e08"
    ctx.font = "900 12px Nunito, sans-serif"
    ctx.textAlign = "center"
    ctx.fillText("$", coin.x, coin.y + bob + 4)
  }
  for (const def of CHARACTERS) {
    const ready = !game.owned.has(def.id) && def.island <= game.checkpoint && game.cash >= def.cost
    drawCharacter(ctx, def, game.owned.has(def.id), ready, game.time)
  }
  drawPerson(ctx, game.x, game.y, "#f8fbff", "#1d4ed8")
  ctx.strokeStyle = "rgba(255,255,255,0.7)"
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.moveTo(game.x - game.vx * 0.05, game.y)
  ctx.lineTo(game.x - game.vx * 0.12, game.y - 10)
  ctx.stroke()
  for (const floater of game.floaters) {
    ctx.globalAlpha = Math.max(0, floater.life)
    ctx.fillStyle = "#fff4a8"
    ctx.font = "900 18px Nunito, sans-serif"
    ctx.textAlign = "center"
    ctx.fillText(floater.text, floater.x, floater.y)
    ctx.globalAlpha = 1
  }
  ctx.restore()
}
