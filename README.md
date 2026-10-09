# RE4 Map Teleport — 地图传送修改器

用于 Steam《生化危机4 重制版》的 REFramework Lua 修改器。打开地图，把**中央圆形准星**移到目标道路，按 **F6**；按 **F7** 返回最近一次 F6 传送前的位置。版本：**0.2.0，跨区域功能为实验性功能**。

## 安装

1. 退出游戏。备份重要存档及已有同名修改器文件。
2. 安装官方 [REFramework](https://github.com/praydog/REFramework/releases/tag/v1.5.9.1) 的 **RE4** 版本，把其中 `dinput8.dll` 放在 `re4.exe` 同目录。已有其他版本时请先备份，避免直接覆盖。该版本是本项目实测版本，并非声称它是最新版本。
3. 把本项目的 `reframework` 文件夹合并到游戏根目录，得到：

```text
游戏根目录/
  re4.exe
  dinput8.dll                  ← 单独安装的 REFramework
  reframework/
    autorun/codex_map_teleport.lua
    data/codex_map_stage_points.json
```

源码包中的 `rollback`、`docs`、`third_party` 和开发工具不需要复制进游戏。

## 使用

- 加载存档，打开地图，选择正确楼层，把中央准星放在道路或室内地面上，按 F6 一次。
- 地图会关闭。保持游戏在前台，等待加载和位置确认；不要连续按键或马上切换窗口。慢速区域可能等待约 20 秒。
- F7 返回最近一次 F6 的出发点。下一次 F6 会替换返回点；F7 不是完整的传送历史。
- Insert 显示/隐藏 REFramework 面板。Script Generated UI → Map teleport - F6 / F7 也提供 Teleport / Return 按钮。
- 没有可用地面、楼层不匹配或加载失败时，取消传送。不要把准星放在水面、山壁或地图空白处。
- 返回点只在当前脚本会话内有效。重启游戏、重载脚本、读取存档导致角色上下文变化时，返回点可能清空。

## 验证范围与限制

实测环境：Windows、Steam 游戏 build **22377325**、REFramework **v1.5.9.1**；运行时显示 `v1.5.9+7`，提交 `5bae4701396248a776c1de19f5be9552022295d5`；第六章硬核模式存档。测试环境还装有其他修改器，不能据此保证所有组合兼容。

| 场景 | 验证结果 |
| --- | --- |
| 第六章附近道路 | 用户已确认实体 F6 传送可用；附近往返有位置记录 |
| 第六章 → 旧村庄入口 → 返回 | 正确加载参数后，自动往返成功；完整地图目标流程也有成功记录 |
| 第六章 → 第四章湖区岸边 → 返回 | 有一次地面检查后自动往返成功记录；未覆盖整个湖区 |
| 第六章 → 废弃工厂房间 | 地图目标流程成功，用户确认到达并完成找抽屉的目的 |
| 溪谷 | 自动传送没有通过地面检查，已取消；用户自行步行到达 |

跨区域预加载仅为村庄大区域（stage 40000–49999）选择最近的一个候选场景。锚点是定位线索，不是准确区域边界，因此部分目的地会失败。城堡、岛屿及任意其他章节的跨区域加载未验证。

跨区域测试主要用临时工具输入世界坐标，走与 F6 相同的地面检查和传送流程；不等于每个地点都做过实体 F6 的地图准星测试。临时工具已从发布版本移除。

本修改器不直接编辑存档文件，也不重置章节、剧情旗标或宝物领取状态。但游戏本身的自动保存可能记录传送后的游戏状态。Steam 成就兼容性未验证，不作保证。

早期开发中的错误加载参数和未经地面验证的实验曾伴随游戏卡死及一次整机重启，根因没有确定。这些实验入口不包含在发布包中。已验证成功的路径仍不能保证所有硬件、存档和修改器组合都稳定。

## 卸载与回退

退出游戏后，移走 `reframework/autorun/codex_map_teleport.lua` 和 `reframework/data/codex_map_stage_points.json` 即可卸载本修改器；无需移除其他 REFramework 修改器。

若只想保留附近传送：备份当前 Lua 文件，再把 `rollback/stable_loaded_only.lua` 复制到 `reframework/autorun/`，重命名为 `codex_map_teleport.lua` 并替换本修改器。该版本只寻找已加载地面，不请求旧区域预加载。不要同时启用两个版本。

REFramework 本体是否移除应按其他修改器的需要决定，不要因为卸载本脚本就直接删除它。

## 开发与发布

脚本无需编译。打包命令：`python tools/build_release.py`，生成 `dist/` 下的修改器安装包。开源时上传本源码目录，不要上传自己的游戏日志、存档、屏幕截图或 REFramework 二进制。

技术说明见 [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)，验证记录见 [docs/VALIDATION.md](docs/VALIDATION.md)，英文说明见 [README.en.md](README.en.md)。采用 MIT License；第三方署名见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
