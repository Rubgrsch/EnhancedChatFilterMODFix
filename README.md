# EnhancedChatFilterMODFix
EnhancedChatFilter, a WoW chat addon, modded for CN users

This is a WoW chat filter addon mainly for CN servers.  
It is now supporting Shadowlands(9.0).  
这是一个主要适用于国服魔兽世界的聊天屏蔽插件。  
现已更新至暗影国度(9.0)。  

Curse Link: <https://www.curseforge.com/wow/addons/ecfmodfix>

[Manual/使用说明](https://github.com/Rubgrsch/EnhancedChatFilterMODFix/wiki/Manual)

[ChangeLog/更新日志](https://github.com/Rubgrsch/EnhancedChatFilterMODFix/blob/master/EnhancedChatFilter/changelog.txt)

This addon will not officially support Classic WoW.  
本插件将不会正式支持怀旧服。  

Main Features
-------------

|名字|效果|
|:---:|:---:|
|关键词|根据设定关键词过滤信息|
|'忙碌'玩家|过滤'忙碌'状态的玩家|
|重复信息|过滤内容相似的聊天信息|
|屏蔽黑名单|将屏蔽过的玩家加入黑名单|
|成就刷屏|合并多人获取同一成就|
|NPC重复说话|过滤NPC的重复说话|
|任务组队通告|过滤组队、任务进度通告|
|团队技能通告|过滤技能通告、打断等信息|
|!额外过滤器|过滤各种广告垃圾信息，易误伤|
|系统信息|过滤部分无用的系统信息|
|拾取过滤|根据物品的品质/ID进行过滤|

FAQ
---

1. 如何共享不同账号下的关键词列表和开关设置
  - 同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
  - 你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
  - 不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
  - 不知道的请不要用。不知道的请不要用。如果你想学习请自行百度/谷歌。
  - Lua的正则符号是%

Licenses
--------

Original project and this one are under Public Domain.  
Original project, written by eucalyptisch, can be found here: <https://wow.curseforge.com/projects/chat-filter>.  
First Chinese version, modded by szpunk, can be found here: <http://bbs.nga.cn/read.php?tid=7527032>.  
