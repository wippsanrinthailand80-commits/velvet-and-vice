# Velvet & Vice — 3D Hentai Sandbox (Godot 3.6)

> **"In Vice City Apartments, every door hides a desire."**

A full-length 3D action/sandbox hentai game. Build relationships, explore corruption, unlock the Pleasure Club, and reach one of 5 endings.

## 🎮 Game Name
**Velvet & Vice**

## 📖 Story
You're the new resident of **Vice City Apartments** — a luxury building with a secret underground **Pleasure Club** run by the enigmatic **Aoi**. Build relationships with the residents, uncover the club, complete trials, and explore your desires. Your choices shape your **corruption level** (0-100) and unlock progressively darker content. 5 distinct endings based on your path.

## 👥 Characters (7 total)
| Character | Role | Personality | Corruption Gate |
|---|---|---|---|
| **Maya** | Neighbor | Warm, sweet, shy | Low |
| **Riko** | Aoi's assistant | Dominant seductress | Medium |
| **Kenji** | Resident | Quiet psychologist, BDSM mentor | Medium |
| **Aoi** | Building owner | Mysterious club master | High |
| **Yuki** | Resident | Shy medical student, virgin | Low-Medium |
| **Yui (Sister)** | Family | Clingy younger sister | High |
| **Reiko (Mother)** | Family | Lonely, mature, dominant | High |

## 🗺️ Locations (6)
Bedroom ↔ Hallway ↔ Riko's Apt / Aoi's Office / Yuki's Study / Family Home

## ⚙️ Systems
- **Dialogue**: JSON branching with affinity/corruption/flag/item/quest gates
- **Relationship**: 0-100 affinity per NPC
- **Corruption**: 0-100 scale, 5 tiers (innocent → depraved), gates darker content
- **Quests**: tracked objectives with rewards
- **Time**: day/night cycle with UI
- **Sex Scenes**: 8 poses, arousal tracking, climax, interaction actions
- **Inventory**: item DB + UI
- **Audio**: procedural music & SFX (no file imports needed)
- **Animations**: idle + walk cycles on characters
- **Save/Load**: F5/F9
- **Endings**: 5 endings based on corruption level

## 🎮 Controls
- **WASD**: move | **Mouse**: look | **Space**: jump
- **E**: interact (pickup/talk/doors) | **I**: inventory
- **F5**: save | **F9**: load | **ESC**: release mouse

## 📁 Project Structure
```
hentai_game/
├── project.godot
├── default_env.tres / default_theme.tres
├── export_presets.cfg (Linux/Windows/HTML5/Android)
├── scenes/ (main_menu, main, player, ending, world/*)
├── scripts/ (26 scripts)
├── dialogues/ (7 character JSONs)
├── quests/ (trial_surrender.json)
├── assets/models/ (glb from Blender)
├── assets/audio/ (procedural, generated at runtime)
└── blender/build_kit.py
```

## 🚀 Running
1. Open `project.godot` in Godot 3.6 → Play
2. Or: `godot3 --path /root/hentai_game`
3. Rebuild assets: `blender --background --python blender/build_kit.py`

## 🔧 Adding Content
- **Dialogue**: add JSON to `dialogues/` (npc_id must match NPC)
- **Quest**: add JSON to `quests/`
- **Character**: add glb + NPC node + dialogue JSON
- **Room**: duplicate scene + add doors
- **Ending**: modify `ending_manager.gd`

## 📝 Notes
- Assets are primitive placeholders — refine in Blender
- Animations (idle/walk) exported with glb
- Audio is procedural (AudioStreamSample generated in code) — no import needed
- Corruption/affinity gates defined in dialogue JSON

---
*Built with Godot 3.6 + Blender 4.3. No AI slop. Full effort.*