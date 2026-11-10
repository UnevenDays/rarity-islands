import { CHARACTERS, createGame, draw, gateRatio, hint, incomeOf, nearestAffordable, nextGoal, speedOf, update } from "./game"

const canvas = document.querySelector<HTMLCanvasElement>("#view")!
const ctx = canvas.getContext("2d")!
const cashEl = document.querySelector<HTMLElement>("#cash")!
const infoEl = document.querySelector<HTMLElement>("#info")!
const hintEl = document.querySelector<HTMLElement>("#hint")!
const nextEl = document.querySelector<HTMLElement>("#next")!
const barEl = document.querySelector<HTMLElement>("#bar-fill")!
const crewEl = document.querySelector<HTMLElement>("#crew")!
const collectBtn = document.querySelector<HTMLButtonElement>("#collect")!
const title = document.querySelector<HTMLElement>("#title")!
const playBtn = document.querySelector<HTMLButtonElement>("#play")!
const joy = document.querySelector<HTMLElement>("#joy")!
const knob = document.querySelector<HTMLElement>("#knob")!
const game = createGame()
const keys = new Set<string>()
let joyX = 0
let joyY = 0
let collectQueued = false
let pointerId: number | null = null
let playing = false
function resize() {
  const dpr = Math.min(2, window.devicePixelRatio || 1)
  canvas.width = Math.floor(window.innerWidth * dpr)
  canvas.height = Math.floor(window.innerHeight * dpr)
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
}

function money(value: number) {
  return `$${Math.floor(value).toLocaleString("en-US")}`
}

function paintHud() {
  cashEl.textContent = money(game.cash)
  infoEl.textContent = `Speed ${speedOf(game)}    ${money(incomeOf(game))}/s    ${game.owned.size}/10`
  hintEl.textContent = hint(game)
  nextEl.textContent = nextGoal(game)
  const ratio = gateRatio(game)
  barEl.style.width = `${ratio * 100}%`
  barEl.style.background = ratio >= 1 ? "#5dffa0" : "#ffc42e"
  const ready = nearestAffordable(game)
  collectBtn.disabled = !ready
  collectBtn.textContent = ready ? `Collect ${ready.name}` : "Collect"
  crewEl.innerHTML = ""
  const owned = CHARACTERS.filter((def) => game.owned.has(def.id))
  if (owned.length === 0) {
    const item = document.createElement("li")
    item.textContent = "Nobody yet."
    crewEl.append(item)
  }
  for (const def of owned) {
    const item = document.createElement("li")
    item.textContent = def.name
    item.style.color = def.accent
    crewEl.append(item)
  }
}

let lastFrame = 0
function frame(now: number) {
  const dt = lastFrame ? (now - lastFrame) / 1000 : 0
  lastFrame = now
  if (playing) {
    let mx = joyX
    let my = joyY
    if (keys.has("arrowleft") || keys.has("a")) mx -= 1
    if (keys.has("arrowright") || keys.has("d")) mx += 1
    if (keys.has("arrowup") || keys.has("w")) my -= 1
    if (keys.has("arrowdown") || keys.has("s")) my += 1
    const collect = collectQueued || keys.has("e") || keys.has(" ")
    collectQueued = false
    update(game, dt, mx, my, collect)
    paintHud()
  }
  draw(ctx, game, window.innerWidth, window.innerHeight)
  requestAnimationFrame(frame)
}
playBtn.addEventListener("click", () => {
  playing = true
  title.hidden = true
  title.style.display = "none"
})
collectBtn.addEventListener("click", () => {
  collectQueued = true
})
window.addEventListener("keydown", (event) => {
  keys.add(event.key.toLowerCase())
  if ([" ", "arrowup", "arrowdown", "arrowleft", "arrowright"].includes(event.key.toLowerCase())) event.preventDefault()
})
window.addEventListener("keyup", (event) => keys.delete(event.key.toLowerCase()))
window.addEventListener("resize", resize)

function setKnob(x: number, y: number) {
  knob.style.left = `${30 + x * 28}px`
  knob.style.top = `${30 + y * 28}px`
}
joy.addEventListener("pointerdown", (event) => {
  pointerId = event.pointerId
  joy.setPointerCapture(event.pointerId)
})
joy.addEventListener("pointermove", (event) => {
  if (pointerId !== event.pointerId) return
  const rect = joy.getBoundingClientRect()
  const dx = event.clientX - (rect.left + rect.width / 2)
  const dy = event.clientY - (rect.top + rect.height / 2)
  const mag = Math.hypot(dx, dy) || 1
  const scale = Math.min(1, mag / 42)
  joyX = (dx / mag) * scale
  joyY = (dy / mag) * scale
  setKnob(joyX, joyY)
})
function releaseJoy(event: PointerEvent) {
  if (pointerId !== event.pointerId) return
  pointerId = null
  joyX = 0
  joyY = 0
  setKnob(0, 0)
}
joy.addEventListener("pointerup", releaseJoy)
joy.addEventListener("pointercancel", releaseJoy)

resize()
paintHud()
requestAnimationFrame(frame)
