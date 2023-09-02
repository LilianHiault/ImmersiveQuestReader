# Immersive Quest Reader


## Architecture of the repository

- `.gitignore`
- `ImmersiveQuestReader.plugin`
- `README.md`
- `ImmersiveQuestReader/`
  - `GenerateQuestDatabase.py`
  - `Main.lua`
  - `Options.lua`
  - `QuestLog.lua`
  - `QuestManager.lua`
  - `QuestWindow.lua`
  - `SettingsManager.lua`
  - `Utils.lua`

## Quest data used

- `bestower`
  - `bestower.text` : accepted quest text
  - `bestower.npcName` : window footer NPC giver name
- `level` : window title
- `name` : search quest and window title
- `objectives` : completed quest text
  - `objective.dialog.text` : completed quest text
- `rewards` : reward window
  - `rewards.XP.quantity`
  - `rewards.money.gold`
  - `rewards.money.silver`
  - `rewards.money.copper`
  - `rewards.object` : reward items
  - `rewards.selectOneOf.object` : choose item

## Planned features

- [x] Show quest text when a new quest is accepted
- [ ] Show quest text when a quest is finished
- [x] Display rewards
- [ ] Show the quest description
- [ ] Show the quest objectives