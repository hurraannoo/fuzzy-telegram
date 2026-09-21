# Data sources and licences

- **Reused reader code, glossary, dictionary and font:** [ForeverLearner](https://github.com/hurraannoo/psychic-rotary-phone), version 0.4.0. `Reader.lua` and `Glossary.lua` are reused under the MIT licence in `LICENSE.txt`. The core, hover panel, minimap button and settings are new WorldLearner code under the same licence. The dictionary and font retain their original separate licences below.
- **NPC and item names:** [CMaNGOS Classic DB](https://github.com/cmangos/classic-db/tree/22b51464f1625f6ef6275771de1f5466c6f5d19e), pinned at `22b51464f1625f6ef6275771de1f5466c6f5d19e`. English from `Full_DB/ClassicDB_1_12_1_z2815.sql.gz`; Simplified Chinese from `locales/Chinese/locales_creature.sql` and `locales/Chinese/locales_item.sql`. Name fields only; subsequent update SQL is not applied. Conversion is reproducible with `tools/build_entities.py` and `tools/source-blobs.json`. `Data/ENTITY-SOURCE.json` records coverage and source hashes. The original GPLv3 and copyright notices remain in `Data/Quest-Licenses`. Blizzard's separate retained game-content rights still apply.
- **Word dictionary:** CC-CEDICT, CC BY-SA 4.0. See `DICTIONARY-LICENSE.md` and `Data/SOURCE.json`. The converted dictionary chunks are copied unchanged from ForeverLearner.
- **Font:** Noto Sans SC, instantiated and renamed ForeverLearner Sans by ForeverLearner. The font is copied unchanged; see `Fonts/OFL.txt` and `Fonts/SOURCE.json`.
- **Artwork:** references to the client's built-in Classic dialog/minimap/book textures; no Blizzard artwork files are redistributed.

No external translation services, proprietary dictionary databases or network access are used in game. No private messages, game cache files or account data are bundled.
