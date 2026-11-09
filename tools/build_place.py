#!/usr/bin/env python3
"""Pack the Luau sources into a Roblox place file and check the speed gates."""

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "RarityIslands.rbxlx"


def cdata(text: str) -> str:
    return text.replace("]]>", "]] >")


def script(class_name: str, name: str, source: str, referent: str) -> str:
    return f"""<Item class="{class_name}" referent="{referent}">
      <Properties>
        <string name="Name">{name}</string>
        <ProtectedString name="Source"><![CDATA[{cdata(source)}]]></ProtectedString>
        <bool name="Disabled">false</bool>
      </Properties>
    </Item>"""


def check_gates() -> None:
    text = (SRC / "ReplicatedStorage" / "Characters.lua").read_text()
    entries = re.findall(
        r'id = "([^"]+)".*?island = (\d+).*?speed = (\d+)',
        text,
        flags=re.S,
    )
    if len(entries) != 10:
        raise SystemExit(f"expected 10 characters, found {len(entries)}: {entries}")
    ids = [item[0] for item in entries]
    if len(set(ids)) != 10:
        raise SystemExit(f"duplicate character ids: {ids}")
    by_island: dict[int, int] = {}
    for _id, island, speed in entries:
        by_island[int(island)] = by_island.get(int(island), 0) + int(speed)
    gates = [int(item) for item in re.findall(r"need = (\d+)", text)]
    if gates != [34, 74]:
        raise SystemExit(f"unexpected gates: {gates}")
    base = 16
    island1 = base + by_island[1]
    island2 = island1 + by_island[2]
    if not (island1 > gates[0] and island1 - min(
        int(speed) for _id, island, speed in entries if int(island) == 1
    ) <= gates[0]):
        raise SystemExit(f"island 1 speed {island1} does not need every character to pass {gates[0]}")
    smallest_island2 = min(int(speed) for _id, island, speed in entries if int(island) == 2)
    if not (island2 > gates[1] and island2 - smallest_island2 <= gates[1]):
        raise SystemExit(f"island 2 speed {island2} does not need every character to pass {gates[1]}")
    print(f"gates ok: island1={island1} need>{gates[0]} island2={island2} need>{gates[1]}")


def balance(path: Path) -> None:
    text = path.read_text()
    # Strip strings and comments roughly enough to catch a dropped end.
    stripped = re.sub(r"--\[\[.*?\]\]", "", text, flags=re.S)
    stripped = re.sub(r"--.*?$", "", stripped, flags=re.M)
    stripped = re.sub(r"\[\[.*?\]\]", "", stripped, flags=re.S)
    stripped = re.sub(r"\"(?:\\.|[^\"])*\"", "\"\"", stripped)
    stripped = re.sub(r"'(?:\\.|[^'])*'", "''", stripped)
    tokens = re.findall(r"\b(function|if|elseif|for|while|end|repeat|until)\b", stripped)
    depth = 0
    for token in tokens:
        if token in {"function", "if", "for", "while", "repeat"}:
            depth += 1
        elif token in {"end", "until"}:
            depth -= 1
        if depth < 0:
            raise SystemExit(f"{path.name} has an extra end")
    if depth != 0:
        raise SystemExit(f"{path.name} block depth is {depth}, expected 0")


def build() -> None:
    check_gates()
    sources = [
        SRC / "ReplicatedStorage" / "Characters.lua",
        SRC / "ServerScriptService" / "GameServer.lua",
        SRC / "StarterPlayerScripts" / "GameClient.lua",
    ]
    for path in sources:
        balance(path)

    characters = (SRC / "ReplicatedStorage" / "Characters.lua").read_text()
    server = (SRC / "ServerScriptService" / "GameServer.lua").read_text()
    client = (SRC / "StarterPlayerScripts" / "GameClient.lua").read_text()

    place = f"""<?xml version="1.0" encoding="utf-8"?>
<roblox version="4">
  <Item class="Lighting" referent="1">
    <Properties>
      <string name="Name">Lighting</string>
      <float name="Brightness">2</float>
      <Color3 name="OutdoorAmbient">
        <R>0.58</R><G>0.62</G><B>0.68</B>
      </Color3>
    </Properties>
  </Item>
  <Item class="ReplicatedStorage" referent="2">
    <Properties>
      <string name="Name">ReplicatedStorage</string>
    </Properties>
    {script("ModuleScript", "Characters", characters, "3")}
    <Item class="RemoteEvent" referent="4">
      <Properties>
        <string name="Name">Toast</string>
      </Properties>
    </Item>
  </Item>
  <Item class="ServerScriptService" referent="5">
    <Properties>
      <string name="Name">ServerScriptService</string>
    </Properties>
    {script("Script", "GameServer", server, "6")}
  </Item>
  <Item class="StarterPlayer" referent="7">
    <Properties>
      <string name="Name">StarterPlayer</string>
    </Properties>
    <Item class="StarterPlayerScripts" referent="8">
      <Properties>
        <string name="Name">StarterPlayerScripts</string>
      </Properties>
      {script("LocalScript", "GameClient", client, "9")}
    </Item>
  </Item>
  <Item class="Workspace" referent="10">
    <Properties>
      <string name="Name">Workspace</string>
      <float name="Gravity">196.2</float>
    </Properties>
    <Item class="Camera" referent="11">
      <Properties>
        <string name="Name">Camera</string>
      </Properties>
    </Item>
  </Item>
</roblox>
"""
    OUT.write_text(place)
    ET.parse(OUT)
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    try:
        build()
    except ET.ParseError as error:
        sys.exit(f"rbxlx is not valid XML: {error}")
