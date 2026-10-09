# 实现与维护

F6 捕获 `MapManager.get_MapGuiPos()` 的反向平移，经 `revertRotation` 和 `ConvertGuiPosToGamePos` 换算到地图中央准星的世界坐标，同时读取楼层。地图窗口使用 `HighwayGuiManager.closeCsItemWindowGui` 关闭，随后等待物理恢复。

查询使用 `via.physics.CastRayQuery`，静态地面层 2、mask 2。碰撞对象名称 `stXX_YYY_*` 解析为 stage；法线 Y 必须大于 0.65，并通过所选楼层的 section/group 范围检查。F7 同样检查返回场景状态及附近地面。

CharacterManager.requestWarp 携带 ContextID、Nullable vec3、Nullable Quaternion 和 StageIdentifier。位置确认同时检查 XZ 距离、高度差和 stage。角色上下文变化清空操作状态与返回点。

预加载：PrefectureID = floor(stage / 10000) * 10000；LocID = floor(stage / 1000) * 1000。使用 `ValueType.new` 构造真正的 `System.Nullable`1<chainsaw.EnvSceneStatus>`，明确设置 `_HasValue=true`、`_Value=3`，本机实测大小 8 字节、字节排列 `[1,0,0,0,3,0,0,0]`。不能用 `sdk.create_int32(3)` 冒充这个结构；旧实验曾读回异常状态 639。

只发起一次候选预加载，并要求 target Run(3)、request complete、ingameable、非 Wait、load rate 1，以及真实地面。取消、异常、确认后会清除 ScriptControl(1) 请求。该清理作用于引擎管理器的相同优先级，而非只作用于本脚本；不要同时运行另一个使用该优先级的场景加载/传送修改器。

已知问题：锚点最近邻无法准确覆盖场景边界；溪谷在本轮测试中保持 target Ready(2)、ingameable true，但目标射线没有地面。没有为了绕过检查而硬跳，也没有更改剧情章节。暂停/切换窗口可能让等待时间与物理准备不同步，使用时保持前台。

维护建议：优先完善区域边界与候选选择、阶段化暂停计时，以及在干净环境验证。修改任何状态/优先级/物理层前，先用独立只读记录确认，再做有返回点的单区域测试。不要恢复开发中绕过地面检查的固定坐标入口。

发布脚本包含常规运行状态 JSON 输出，但不含命令文件监听、自动往返、反射扫描或临时返回点恢复入口。没有保存开发时的用户路径、内存地址或个人信息。
