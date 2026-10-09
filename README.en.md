# RE4 Map Teleport

An REFramework Lua mod for the Steam version of Resident Evil 4 Remake. **v0.2.0: experimental cross-region support.**

Install the RE4 build of [REFramework v1.5.9.1](https://github.com/praydog/REFramework/releases/tag/v1.5.9.1) separately, then merge this project's `reframework` directory into the directory containing `re4.exe`. Back up existing files before replacing them. No runtime binary or game files are bundled.

Open the map, choose the floor, move the central circular reticle onto a road, and press **F6** once. The map closes while the destination is checked. Keep the game foreground and allow up to approximately 20 seconds. **F7** returns to the most recent F6 departure point. Insert toggles REFramework's UI. Script Generated UI exposes the same Teleport / Return actions.

Teleportation requires loaded, ready scene geometry, a matching floor and a ground ray hit. Empty areas, water, incorrect floors and unavailable scenes are rejected. Return history contains one session-only point; script resets, game restarts or character-context changes can clear it.

Tested with Steam build 22377325 and REFramework v1.5.9.1, runtime v1.5.9+7, on a Chapter 6 Hardcore save. Nearby physical F6 teleportation was confirmed by the user. Automated ground-checked round trips reached the old village entrance and a Chapter 4 lakeside point. The abandoned factory room was reached and confirmed by the user. Valley teleportation failed the ground check; the user walked there instead. Cross-region tests mainly supplied world coordinates through temporary tooling into the map-target pipeline, not physical F6 at every destination. Those controls are excluded from this release.

Cross-region candidate loading is limited to village-region stages 40000–49999, using one nearest anchor on the chosen floor. These anchors are not exact spatial boundaries. Arbitrary destinations and castle/island cross-region loading are not verified. No achievement compatibility guarantee. The mod does not directly edit saves or reset chapter flags; normal game autosaves can still record the resulting state. The test installation had other mods, so compatibility cannot be generalized.

Early discarded experiments coincided with hangs and one full-machine restart; the root cause was not established. Successful limited testing does not guarantee stability across all systems or saves.

To uninstall, exit the game and remove only this mod's Lua and anchor JSON. For loaded-ground-only behavior, replace the Lua with `rollback/stable_loaded_only.lua`, renamed to `codex_map_teleport.lua`. Do not enable both variants together. Leave REFramework itself installed if other mods need it.

Build the mod-only ZIP with `python tools/build_release.py`. See the Chinese README, development notes and validation records for details. MIT license, with retained third-party notices. This project does not claim to be the first RE4 teleport mod.
