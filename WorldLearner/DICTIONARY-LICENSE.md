# Dictionary attribution and licence

Data/Dictionary*.lua is derived from **CC-CEDICT**, the community-maintained
Chinese-English dictionary published by MDBG, continuing the CEDICT project
started by Paul Denisowski in 1997.

- Source and download: https://www.mdbg.net/chinese/dictionary?page=cc-cedict
- Project: https://cc-cedict.org/
- Source snapshot, retrieval time, SHA-256 and original attribution header:
  `Data/SOURCE.json`
- Source and adapted dictionary licence: **Creative Commons
  Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)**
- Licence: https://creativecommons.org/licenses/by-sa/4.0/
- Full licence terms: https://creativecommons.org/licenses/by-sa/4.0/legalcode

Modifications for ForeverLearner: converted to Lua tables; indexed by both
Simplified and Traditional spelling; converted numbered pinyin to tone marks;
merged alternative readings/senses; selected and shortened inline glosses;
omitted classifier-only senses when other senses exist; flagged entries that
explicitly contain '(idiom)'; capped lookup phrase length at 32 characters;
deduplicated identical records and divided the data into loadable chunks.
These adapted dictionary files are distributed under CC BY-SA 4.0. No endorsement
by MDBG or CC-CEDICT contributors is implied. No Zhongwen or Pleco code or
commercial dictionary content is included.

The original Lua engine/UI code and independently authored starter glossary
are covered by LICENSE.txt. Their licence does not replace the dictionary's
separate CC BY-SA licence.
