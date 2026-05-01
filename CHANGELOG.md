# Changelog

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
