# Immersive Quest Reader

An immersive quest reader plugin for LOTRO.

Whennever the player accepts a quest, displays the quest text one phrase at a time to make it easier to read.
It also shws additional information like the quest giver, the gold, experience and item rewards.
To advance to the next line of dialogue, simply clic on the window.
If multiple quests are accepted or completed at once, all texts will be queued so you can keep up running to your quests while reading.

This plugin was heavily inspired by the addon *Immersion* in World of Warcraft.

## Overview

![Screenshot of LOTRO. A window displays a new quest text and rewards.](ImmersiveQuestReader/res/iqr_new_quests.gif)

## Planned features

- [x] Show quest text when a new quest is accepted
- [x] Show quest text when a quest is completed
- [x] Display rewards
- [ ] Show the quest description
- [ ] Show the quest objectives

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
  - `rewards.object` : item rewards
  - `rewards.selectOneOf.object` : item reward choice

## Thanks

A huge thank you to the [Lotro Companion datas](https://github.com/LotroCompanion/lotro-data) which are necessary for this plugin.
I would also like to thank some plugin authors whose source code helped me during development : Galhulad to display items like ItemTreasury does.
