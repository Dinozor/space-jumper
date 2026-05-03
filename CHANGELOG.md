# Changelog

## [1.2.0](https://github.com/Dinozor/space-jumper/compare/v1.1.0...v1.2.0) (2026-05-03)


### Features

* **abilities:** dynamic injectable ability system with 6 abilities ([726bad9](https://github.com/Dinozor/space-jumper/commit/726bad9a26ca383989d40af33b79ac52f61865b8))
* **characters:** CharacterData system with stat profiles and upgrades ([e7c5f8d](https://github.com/Dinozor/space-jumper/commit/e7c5f8dd8a662dc0c2d1d074c819686b4cf6332d))
* **corridor:** add wave/formation spawning to corridor spawner ([ddc736f](https://github.com/Dinozor/space-jumper/commit/ddc736f276e00455b3b9f289d5b9eb1bbe578ad1))
* **debris:** add tag/type system with shootable, sticky, icy constants ([23146ff](https://github.com/Dinozor/space-jumper/commit/23146ff4426d7258fbb41fc4a7c93391333f1fec))
* **economy:** add currency, level rewards, and purchased abilities tracking ([2993ba6](https://github.com/Dinozor/space-jumper/commit/2993ba65a9e2741cfec81e974d8ceb7b53eebed8))
* **gameplay:** cable ending cinematic when player reaches station proximity ([7de3cbd](https://github.com/Dinozor/space-jumper/commit/7de3cbd0236757abd1478450d5265d5e37d4c0e1))
* **level:** use distance-to-station for win/lose thresholds and progress bar ([f9ee5cf](https://github.com/Dinozor/space-jumper/commit/f9ee5cf6c6fcb2e016e58b6549a7b81e3186a4d3))
* **menu:** add shop menu for purchasing abilities ([c266bde](https://github.com/Dinozor/space-jumper/commit/c266bde9a08e398ff6b1c362429ff88fe14d14a2))
* **menu:** add story subtitle to main menu ([01f8469](https://github.com/Dinozor/space-jumper/commit/01f84698d19718d2f43177d6754d8b8c090254cc))
* **menu:** redesign shop with TabContainer — Upgrades grid and Characters tab ([5bc4dc5](https://github.com/Dinozor/space-jumper/commit/5bc4dc56b4c8621e927b5507cee44680edd9d885))
* **menu:** show locked levels grayed out with unlock tooltip in level select ([af703ba](https://github.com/Dinozor/space-jumper/commit/af703ba59d04e3d8c913cb37471e07239b5459a3))
* **persistence:** add Delete Save and Reset Scoreboard buttons to settings (main menu only) ([c857762](https://github.com/Dinozor/space-jumper/commit/c8577627aea23afcd6900f55cb6d22ce1ad47f7b))
* **persistence:** add SaveManager static helper for progression and scores I/O ([d7cf848](https://github.com/Dinozor/space-jumper/commit/d7cf84898f68190cd8b2c4597365f88527f4aadc))
* **persistence:** pause menu sets settings_from_main_menu=false before opening settings ([b37cd5e](https://github.com/Dinozor/space-jumper/commit/b37cd5ee32f002807d76c7f29b516f9adc0143da))
* **persistence:** record attempts on game end and persist progression on awards ([421907d](https://github.com/Dinozor/space-jumper/commit/421907dd159796748bf5a7446e244d4b7cc35ae0))
* **persistence:** wire SaveManager into GameState — load on startup, save on mutations ([01992fe](https://github.com/Dinozor/space-jumper/commit/01992fefcbdbf0f5c6ae15282a634f9f555f0f89))
* **player,level:** directional bounce control + Training Grounds level ([01d366b](https://github.com/Dinozor/space-jumper/commit/01d366ba92850fe662e40b1327054de1c73a8996))
* **player:** add per-level drag coefficient slowing upward bounce velocity ([aa472f0](https://github.com/Dinozor/space-jumper/commit/aa472f00194d104b3a505f4015138407417ecbe6))
* **player:** replace hardcoded GRAVITY with station_escape_speed from LevelData ([9a2bf5a](https://github.com/Dinozor/space-jumper/commit/9a2bf5a79383a8ed447ff12e567578643ef6287d))
* **scoreboard:** add Scoreboard button to main menu; set settings_from_main_menu flag ([859a37c](https://github.com/Dinozor/space-jumper/commit/859a37c9589b1e44448993233655371dc6f04956))
* **scoreboard:** add Scoreboard scene with level dropdown, last 3 attempts, and all attempts ([000bbb4](https://github.com/Dinozor/space-jumper/commit/000bbb4ad9aff7f6b5eebeb78e1a6b2790dd66fd))
* **scoreboard:** add Scores button per level in level select ([cd0bbea](https://github.com/Dinozor/space-jumper/commit/cd0bbea0810ec98a541557b82df80e738fc16a05))
* **scoreboard:** add View Scores button to win screen ([ced5f34](https://github.com/Dinozor/space-jumper/commit/ced5f34add17ffca371a4a1d7ed10fc244b8d0f6))
* **ui:** add attempt_count and last_attempt_level_id to GameState ([440a595](https://github.com/Dinozor/space-jumper/commit/440a595e198b7bca1621deea2f802f472a1c2986))
* **ui:** add LoseScreen scene ([7d7e3c0](https://github.com/Dinozor/space-jumper/commit/7d7e3c0f1d1e2e242ffc0927d35392993fd116ef))
* **ui:** add LoseScreen script with contextual retry label ([6ef0339](https://github.com/Dinozor/space-jumper/commit/6ef0339ad3964790fd491feb991892adefcf53e0))
* **ui:** add pause menu with Esc key, settings, and exit to menu ([883d09d](https://github.com/Dinozor/space-jumper/commit/883d09dc9162b2db52ef2b02c93a6c73f181cf05))
* **ui:** add WinScreen scene ([1a9488c](https://github.com/Dinozor/space-jumper/commit/1a9488c71099c3b7524330ab20a99a76f9f75eb6))
* **ui:** add WinScreen script with coins display and Next Level gating ([5dfb0fb](https://github.com/Dinozor/space-jumper/commit/5dfb0fb05231c01fd28d49a1458e9250a7d99435))
* **ui:** replace GameOver node with WinScreen and LoseScreen in game.tscn ([c70777c](https://github.com/Dinozor/space-jumper/commit/c70777cd16afda329389bcb11e0b65b460f3ba0b))
* **ui:** replace level select list with orbital map ([6311ea1](https://github.com/Dinozor/space-jumper/commit/6311ea17d9da472699dbac19054fea16e3f24b9d))
* **ui:** wire WinScreen and LoseScreen into game.gd ([f0252e9](https://github.com/Dinozor/space-jumper/commit/f0252e9a059cdb75ed092d74ba29d490345f9b5c))


### Bug Fixes

* **debris:** only hazard objects deal damage on contact ([de62100](https://github.com/Dinozor/space-jumper/commit/de62100312ead16c2b822fc21a3991068e9a0a17))
* **gameplay:** reduce spawn density and strengthen wall-bounce lateral impulse ([3eac03b](https://github.com/Dinozor/space-jumper/commit/3eac03b98e641be412f4c634511b6ee1073a9f9e))
* **hud:** boost bar updates during intro and shows only with jetpack ability ([c520ec2](https://github.com/Dinozor/space-jumper/commit/c520ec2ef413ff081677777ef67e0d527ff6b1ed))
* **levels:** update default level ID from 0 to 1 for new level numbering ([a0df981](https://github.com/Dinozor/space-jumper/commit/a0df98118ba5bea2a45aa401b2e784aad5878d14))
* **menu:** unlock next level on win so level select shows all levels ([b3149ea](https://github.com/Dinozor/space-jumper/commit/b3149ea007ef4d3dc4c214347ef9b80d1612d1b0))
* **persistence:** reset settings_from_main_menu flag on settings back navigation ([5bc710f](https://github.com/Dinozor/space-jumper/commit/5bc710f16fdb9b2724d37cf6573eaecc8588b0d4))
* **persistence:** SaveManager quality fixes — public MAX_SCORES_PER_LEVEL, null guard, error reporting, doc comments ([c513ba6](https://github.com/Dinozor/space-jumper/commit/c513ba69b5274dac4b4add7323ffc5c8fb7adc68))
* **player:** swap character mesh on game start ([d874456](https://github.com/Dinozor/space-jumper/commit/d874456ba8dd8e38abb9f0913217a9a85092b3df))
* **scoreboard:** use entry reference as rank map key to avoid ts collision ([bf5002f](https://github.com/Dinozor/space-jumper/commit/bf5002f5f5b77b2b1f7409362508a32b2ee5c71e))
* **spawner:** disable gravity on debris so fall speed stays constant ([5bb042d](https://github.com/Dinozor/space-jumper/commit/5bb042de5381c1952e4e40c6d6ad18704f31b388))
* **ui:** replace event.is_action_just_pressed with Input.is_action_just_pressed ([c962967](https://github.com/Dinozor/space-jumper/commit/c962967c18689dff1a27f7569afc194d5dffbfc1))


### Levels

* replace test levels with exploded-station arc (6 levels) ([2507e43](https://github.com/Dinozor/space-jumper/commit/2507e43bc98420c3f24e7a55550943072070e91d))
* tune test_level physics and add Orbital Decay second level ([e5bebd6](https://github.com/Dinozor/space-jumper/commit/e5bebd61b947021acd0bd06c234b0d1025b8e4c9))

## [1.1.0](https://github.com/Dinozor/space-jumper/compare/v1.0.0...v1.1.0) (2026-05-01)


### Features

* **gameplay:** intro boost sequence with 3-2-1 countdown ([1d692cc](https://github.com/Dinozor/space-jumper/commit/1d692ccff1c5fe95cea692b0a2a8c3ad30419434))
* **gameplay:** load LevelData from GameState at runtime in game.gd ([7cb3d97](https://github.com/Dinozor/space-jumper/commit/7cb3d978bef5fa12e77a0f971a79d7dffded3454))
* **level:** scripted sections and checkpoint platform ([2e169dc](https://github.com/Dinozor/space-jumper/commit/2e169dc3a9ca54cb66eae449de0b3a1fd4a0b313))
* **menu:** add settings screen with audio toggles and control remapping ([c8b7ea5](https://github.com/Dinozor/space-jumper/commit/c8b7ea5d5da4436bb6e7d7c1e242f5dafd06ba3f))
* **menu:** level select reads LevelData from GameState, adds Back button ([733a700](https://github.com/Dinozor/space-jumper/commit/733a700e1ac95ae2c7520ff8cd652794f58a006e))
* **player:** directional bounce off contact surface normal ([4cb1a7e](https://github.com/Dinozor/space-jumper/commit/4cb1a7ecba042629c30da0101d164fe41620d755))
* **spawner:** spawn table resource replaces hardcoded corridor ratios ([e65a39d](https://github.com/Dinozor/space-jumper/commit/e65a39dc7f145bd15306adac286a1a8ee8451098))


### Bug Fixes

* **debris:** use player-side slide collision for reliable single-fire bounce detection ([ea1b1fe](https://github.com/Dinozor/space-jumper/commit/ea1b1fe59aa09d7f72b25b7050b0fa863c05e376))
* **player:** player is invincible during intro boost sequence ([3a33a95](https://github.com/Dinozor/space-jumper/commit/3a33a95377b1b74e7ede7cf431a76274791b3e21))

## 1.0.0 (2026-04-30)


### Features

* **claude:** changed everything ([d3d351a](https://github.com/Dinozor/space-jumper/commit/d3d351a044f44a1f6c468b74d59901b55c15f53f))
* **corridor:** randomise debris fall speed per spawn ([e6dc1ad](https://github.com/Dinozor/space-jumper/commit/e6dc1ad45f0086af1dea25b74576b5f0891c6f63))
* create all scenes and wire up full gameplay loop ([ed3f23e](https://github.com/Dinozor/space-jumper/commit/ed3f23e2b7b2eadf8ce62a93d9f37f0b6904bc31))
* **debris:** add doorway chunk obstacle with randomised gap position ([ea5eb2e](https://github.com/Dinozor/space-jumper/commit/ea5eb2ee28d3e941c64052dcbe0b5e44a871b329))
* **debris:** add wall-type obstacle that blocks half the corridor ([abc4d41](https://github.com/Dinozor/space-jumper/commit/abc4d41a36c005c873170a7f8a40031b42b42089))
* **gameplay:** add space station visual at corridor top (y=80) ([d7f9eb8](https://github.com/Dinozor/space-jumper/commit/d7f9eb8e9ed697e92bd6f20001adcc28cce31f19))
* **gameplay:** pre-fill corridor and add press-to-start gate ([9618a0a](https://github.com/Dinozor/space-jumper/commit/9618a0a62f1d2c9a41d20edd1dadc0241991a8c5))
* **hud:** add health bar and station progress bar ([9d97d85](https://github.com/Dinozor/space-jumper/commit/9d97d85b2adbfda164b809b6f2159a5613dd6f33))
* **levels:** auto-load level resources from folder at startup ([ccc4088](https://github.com/Dinozor/space-jumper/commit/ccc408855dd915bbe76ec8e39fdfc3817d05e6d5))
* **pickups:** add boost pickup for sparse-debris escapes ([47418e5](https://github.com/Dinozor/space-jumper/commit/47418e5f64fd0fbc30f765811321405713db71b1))
* **pickups:** add health pickup with timer-based spawner ([9ba300d](https://github.com/Dinozor/space-jumper/commit/9ba300d8556ef2aa8c9041d823e79dd40c582237))
* **player:** add jetpack boost intro sequence ([d3811c5](https://github.com/Dinozor/space-jumper/commit/d3811c56805caec701c282e897b66d6feaea076b))
* **player:** cap max fall speed so player can always catch the station ([cf905a0](https://github.com/Dinozor/space-jumper/commit/cf905a0f641b90e2a43f6752453d825d19e17706))
* **player:** rotate mesh to face movement direction and tilt on bounce ([08a7b33](https://github.com/Dinozor/space-jumper/commit/08a7b33d7c7765d25e80dbf99cdc8c21920dbcc9))


### Bug Fixes

* **ci:** butler binary is inside linux-amd64/ subdirectory in zip ([e1404c7](https://github.com/Dinozor/space-jumper/commit/e1404c7d01f5a6c56fad1ddeea7a4bf2b684d6f6))
* **ci:** download butler from GitHub releases instead of defunct broth.itch.ovh ([0d616cb](https://github.com/Dinozor/space-jumper/commit/0d616cbb3f89e3896d172b6a364ea9f8d5b8e26d))
* **gameplay:** fix press-to-start by removing tree pause ([8be3898](https://github.com/Dinozor/space-jumper/commit/8be3898a224b066e9c489c055b3108a4302c7982))


### Assets

* add Kenney UI, fonts, and SFX; add space sky environment ([2777e2a](https://github.com/Dinozor/space-jumper/commit/2777e2a354069f152dbed141ebe51fb102a87fa8))
* **player,debris:** replace placeholder meshes with Kenney GLB models ([e846d68](https://github.com/Dinozor/space-jumper/commit/e846d68ad3edb13e2c8bee504c3e61c330094d5b))
