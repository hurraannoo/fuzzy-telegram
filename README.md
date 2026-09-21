# WorldLearner

Hold **Shift** over a creature/NPC or an inventory item to read its **Chinese name → pinyin → English name**. Move onto the Chinese words for dictionary definitions. A small circular book button on the minimap opens a Classic-style settings menu.

Version **0.1.0** is a first playable test build for WoW Forever / Classic interface **16001**, matching ForeverLearner's target client. Automated Lua 5.1 checks pass; actual client appearance, API compatibility and performance still need in-game verification.

## Install

Copy the `WorldLearner` folder into your game's `Interface/AddOns` directory. The final path must be `Interface/AddOns/WorldLearner/WorldLearner.toc`. Restart the client or enable the addon at character selection.

WorldLearner works independently. You can keep ForeverLearner installed for quests/chat: this addon has its own settings and does not change the quest reader. It reuses ForeverLearner's dictionary, text segmentation, glossary and Chinese/pinyin font. Both addons currently load their own dictionary copies, so running both costs additional memory.

## Use

- Hold Shift over a creature/NPC or an item tooltip. This includes bag items and other item tooltips exposed through the main game tooltip.
- Keep Shift held as you move onto the new reading panel. Hover a Chinese word for its pinyin and dictionary meanings.
- Release Shift to dismiss; **Pin** keeps the panel open after release. Close with X or Escape.
- The panel stays still while you read. Drag its title bar to set a fixed position.
- Left-click the minimap button for settings; right-click to toggle the addon. Drag it around the minimap's rim.

Native Shift actions, such as equipment comparison, are left intact. Choose Alt or Ctrl in the menu if preferred. Names only are translated in this release, not item stats, effects, full descriptions or NPC dialogue. Player names and world objects such as chests are not covered.

## Settings menu

| Tab | Options |
| --- | --- |
| Hover | Enable addon; NPCs/creatures; items; combat visibility; keep panel open; Shift / Alt / Ctrl / Always activation |
| Languages | Chinese, pinyin and English independently; word hover; show names with missing translations |
| Panel | Separate language sizes; width; opacity; initial-cursor or fixed position; movement lock |
| Minimap | Show/hide button; movement lock; position around minimap |

Preview, Reset settings and Done are available on every tab. Settings persist between sessions. Reset affects only WorldLearner settings. At least one language remains enabled. With Always activation and sticky panels, the last panel stays until replaced or closed; Pin freezes it even when hovering another entity.

Commands: `/wl` (settings), `/wl preview`, `/wl hide`, `/wl minimap` (toggle button). `/worldlearner` is an alias.

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
