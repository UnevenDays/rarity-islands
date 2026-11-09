# Rarity Islands

A Roblox collector in the loud, blocky style of Steal a Brainrot. Stand on three islands, buy rarer characters, and use the speed they give you to cross the water. Rarer characters also pay more cash every second.

Only the island path is built. The other two ways to get characters are left for later.

## The ten characters

| Character | Rarity | Island | Cost | Cash per second | Speed |
| --- | --- | --- | --- | --- | --- |
| Tin Teller | Common | Green Dock | 25 | 5 | +4 |
| Bibi Netanjahuuu | Uncommon | Green Dock | 250 | 14 | +7 |
| Josepee Stalin | Rare | Green Dock | 900 | 32 | +9 |
| Parade Drum | Epic | Sand Reach | 2,800 | 70 | +8 |
| Banner Boy | Exotic | Sand Reach | 6,000 | 110 | +9 |
| Kim Jong Uno | Legendary | Sand Reach | 14,000 | 220 | +12 |
| Osama bin Baden | Mythic | Sand Reach | 32,000 | 480 | +14 |
| Vault Monk | Secret | Gold Isle | 150,000 | 1,100 | +10 |
| Jin Pig | Brainrot | Gold Isle | 500,000 | 2,600 | +18 |
| Crown Whale | Godly | Gold Isle | 2,000,000 | 7,000 | +30 |

You start at 16 speed with $50. Green Dock's three characters reach 36 speed, and Sand Reach asks for more than 34. Sand Reach's four characters reach 79, and Gold Isle asks for more than 74. Missing any character on an island leaves you short of the next pad.

Bibi Netanjahuuu is bald, in a blue and white robe with a Star of David, a bat, a stack of cash, dark glasses, and three gold teeth. Josepee Stalin has a red winter hat with a gold emblem, a hammer, a sickle, and heavy leather boots. Kim Jong Uno is the large figure in a red and blue robe with a star, a missile, a small dark green tank, and two smaller people kneeling at his feet. Osama bin Baden has a turban, a toy airplane, and bombs around his waist. Jin Pig is the round yellow figure with a factory in one hand and a red flag in the other.

## Open the place

`RarityIslands.rbxlx` is the file Roblox Studio opens. Rebuild it after a script change:

```bash
python3 tools/build_place.py
```

## Upload it to Roblox

1. Create a free Roblox account at [roblox.com](https://www.roblox.com/) and confirm the email. You need to be at least 13, or have a parent finish the account, before you can publish.
2. Install Roblox Studio from [create.roblox.com](https://create.roblox.com/). Studio is the editor. The Roblox player app only plays games.
3. Open Studio, choose **File → Open from File**, and pick `RarityIslands.rbxlx`.
4. Press **Play** (F5) to test. Buy Tin Teller, then Bibi, then Josepee. Walk onto the yellow pad. You should fly to Sand Reach only after your speed is above 34. Falling in the water sends you back to your island.
5. When it plays the way you want, choose **File → Publish to Roblox**. The first time, Studio asks you to log in and name the experience. Name it **Rarity Islands**.
6. After it uploads, open [create.roblox.com/dashboard/creations](https://create.roblox.com/dashboard/creations). Select the experience, then **Experience Settings**.
7. To let other people play it, set **Playability** to **Public**. Save. The page gives you a link you can share. **Private** keeps it to you. **Friends** limits it to your friends list.
8. Add a thumbnail and description on that same page. The description can say it is a collector with three islands and ten characters.
9. Later script edits: change the files in `src/`, run `python3 tools/build_place.py`, open the new rbxlx in Studio, then **File → Publish to Roblox → Overwrite existing experience** and pick Rarity Islands. That updates the live game without making a second one.

Studio can also publish with **Publish As** if you want a separate copy.

Roblox reviews public experiences. A game with blocky versions of real political figures, a missile, a tank, bombs, and an airplane can be removed or age-restricted under Roblox's community rules even if it is cartoon style. If the upload is rejected, the Creator Dashboard shows the notice, and you can change the characters and publish again.
