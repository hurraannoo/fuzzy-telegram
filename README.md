# WorldLearner

Hold **Shift** over a creature/NPC or an inventory item to read its **Chinese name → pinyin → English name**. Move onto the Chinese words for dictionary definitions. A small circular book button on the minimap opens a Classic-style settings menu.

Version **0.2.0** is a test build for WoW Forever / Classic interface **16001**, matching ForeverLearner's target client. Automated Lua 5.1 checks pass; actual client appearance, API compatibility and performance still need in-game verification.

## Install

Copy the `WorldLearner` folder into your game's `Interface/AddOns` directory. The final path must be `Interface/AddOns/WorldLearner/WorldLearner.toc`. Restart the client or enable the addon at character selection.

WorldLearner works independently. You can keep ForeverLearner installed for quests/chat: this addon has its own settings and does not change the quest reader. It reuses ForeverLearner's dictionary, text segmentation, glossary and Chinese/pinyin font. Both addons currently load their own dictionary copies, so running both costs additional memory.

## Use

- Hold Shift over a creature/NPC or an item tooltip. This includes bag items and other item tooltips exposed through the main game tooltip.
- Keep Shift held as you move onto the new reading panel. Hover a Chinese word for its pinyin and dictionary meanings.
- Release Shift to dismiss; **Pin** keeps the panel open after release. Close with X or Escape.
- The panel stays still while you read. Drag its blank top edge to set a fixed position.
- Left-click the minimap button for settings; right-click to toggle the addon. Drag it around the minimap's rim.

Native Shift actions, such as equipment comparison, are left intact. Choose Alt or Ctrl in the menu if preferred. Names only are translated in this release, not item stats, effects, full descriptions or NPC dialogue. Player names and world objects such as chests are not covered.

## Settings menu

| Tab | Options |
| --- | --- |
| Hover | Enable addon; NPCs/creatures; items; combat visibility; keep panel open; Shift / Alt / Ctrl / Always activation; Always-mode fade after 5 or 10 seconds (or Never) |
| Languages | Chinese, pinyin and English independently; word hover; show names with missing translations |
| Panel | Separate language sizes; width; opacity; Classic / Modern style; initial-cursor, fixed or above-creature position; movement lock |
| Minimap | Show/hide button; movement lock; position around minimap |

Preview, Reset settings and Done are available on every tab. Settings persist between sessions. Reset affects only WorldLearner settings. At least one language remains enabled. With Always activation, choose Never, 5 seconds or 10 seconds before a short fade. Hovering the panel pauses the timer; Pin prevents fading. Once faded, the same hovered entity stays dismissed until you move away and back. With fading off and sticky panels enabled, the last panel stays until replaced or closed.

Commands: `/wl` (settings), `/wl preview`, `/wl hide`, `/wl minimap` (toggle button). `/worldlearner` is an alias.

## Cleaner hover panel and tracking

The reading box has no addon title, instructional footer or routine database-source label. Missing-data warnings remain. The Modern style uses ForeverLearner's dark blue-grey background, a fine grey border and minimal controls; the minimap settings menu keeps its Classic styling.

Panel → Position → **Above creature** follows the hovered creature's visible nameplate. It pauses movement while the mouse is over the reading box, and Pin freezes it. It checks the creature GUID so a recycled nameplate cannot intentionally attach the text to another boar. Items and creatures without a usable nameplate start near the cursor; if a tracked plate disappears, the box stops at its last available position. Enable the relevant friendly/enemy nameplates in WoW for tracking. The addon does not change those game settings.

This follows a nameplate, not the 3D model or its selection outline. It requires the client to expose the nameplate API, and needs testing in Forever. See the [Blizzard nameplate implementation](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.lua) for the API used.

## Coverage and limitations

The bundled CMaNGOS Classic database contains **10,384 creature/NPC records** (10,359 bilingual) and **17,718 item records** (14,834 bilingual). The snapshot is the same revision used for ForeverLearner's quest data. These are database counts, not counts of validated Forever entities.

Names are matched by ID and checked against the displayed name. A custom or renamed entity shows the available native text with a missing/mismatched-data label instead of an unrelated translation. The addon does not query the internet. New Forever content is not automatically covered. Unknown Chinese names still get dictionary word help where available. Non-Chinese unknown native names are displayed as-is; an English-client name is not a verified translation of custom content.

Pinyin is dictionary-based and can be ambiguous for proper names or polyphonic characters. English entity names come from the database, not assembled word definitions. Simplified Chinese is the bundled entity-name locale; Traditional-client names may fall back to native text.

See [data sources](WorldLearner/DATA-SOURCES.md) and [validation](WorldLearner/VALIDATION.md).

## Tests and data rebuild

With Python installed:

```sh
python -m pip install -r tests/requirements.txt
python tests/test_worldlearner.py
python tools/fetch_sources.py --output source-data
python tools/build_entities.py --sources source-data
```

The data tools verify Git blob hashes, parse SQL as text without executing it, and emit Lua tables. Do not commit the downloaded source-data directory. The addon code is MIT; dictionary, database and font assets have separate licences retained in the addon. See [attribution](WorldLearner/DATA-SOURCES.md).
