# Validation — 0.2.0

Automated suite: Python unittest with Lupa 2.8 / Lua 5.1 and explicit WoW API doubles. All addon Lua and all dictionary/data chunks load in manifest order. **15 tests pass.**

Checks cover bilingual records and segmentation, modern creature/vehicle GUID and item-link parsing, Shift activation after a tooltip already exists, moving to the sticky panel, release dismissal, item/NPC category controls, player exclusion, reused/missing IDs, setting validation and persistence, alternative modifiers, combat suppression, pin/unpin, nonsticky dismissal, word hover, minimap/menu actions, and text-size extremes with estimated font metrics.

Data sources are checked against pinned Git blob hashes before extraction. Both TOCs use interface 16001, matching the existing ForeverLearner target. Native game tooltips are read, not rewritten; no protected targeting/inventory actions are performed.

Additional checks cover both fade delays, no repeated reopening after expiry, rearming after leaving, pausing while reading, modifier-mode exemption, clean panel text, theme switching, nameplate tracking, recycled plate GUID checks, pinning, and fallback when no nameplate is available.

## Still needs testing in the actual client

This build has not been loaded in WoW. The UI doubles do not validate real rendering, texture availability, tooltip getters, combat behaviour, font metrics or memory use.

1. Enable alongside ForeverLearner. Check the circular book button, all four menu tabs, Preview, and no Lua errors.
2. Hold Shift over Stormwind City Guard, a boar, and a bag item. Also press Shift after the native tooltip is open.
3. Move onto the Chinese words while holding Shift. Confirm dictionary text and tone marks display correctly; release to dismiss.
4. Pin, release Shift, hover another item, then unpin. Check X and Escape.
5. Test a missing/custom item and confirm missing English is labelled rather than guessed.
6. Exercise Ctrl/Alt/Always, NPC/item toggles, combat visibility and native equipment comparison.
7. Test minimum/maximum sizes and narrow width, screen-edge clamping, fixed placement and movement lock.
8. Drag/lock/hide the minimap button, reopen with `/wl`, restore with `/wl minimap`, and `/reload` to verify saved options.

Minimap placement assumes the native circular Classic minimap. Custom square minimap addons may need an adapter. Loading both addons currently duplicates dictionary memory.

9. Set Always with each fade delay, read words during fading, leave/re-enter, and check Pin.
10. Switch Classic/Modern and use Above creature with visible friendly/enemy nameplates; move the creature/camera, hover words, switch between two identical creatures, and hide nameplates.
