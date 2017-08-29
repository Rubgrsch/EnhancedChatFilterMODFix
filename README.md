# EnhancedChatFilterMODFix
EnhancedChatFilter, a WoW chat addon, modded for CN users

Description
-----------

This is a WoW chat filter addon mainly for CN servers.  
It is now supporting Legion(7.3.0).  
这是一个主要适用于国服魔兽世界的聊天屏蔽插件。  
现已更新至军团再临(7.3.0)。  

NGA Link: <http://bbs.nga.cn/read.php?tid=9277315>  
Curse Link: <http://mods.curse.com/addons/wow/ecfmodfix>

[Github Wiki](https://github.com/Rubgrsch/EnhancedChatFilterMODFix/wiki/%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E)

Main Features
-------------

|名字|效果|
|:---:|:---:|
|关键词过滤|根据关键词过滤聊天信息|
|'忙碌'玩家过滤|过滤'忙碌'状态的玩家以及其自动回复|
|重复信息过滤|过滤内容相同的聊天信息|
|成就刷屏过滤|合并显示多人获取同一成就|
|任务进度刷屏过滤|过滤组队中的任务进度通告|
|团队警报刷屏过滤|过滤团队中的技能通告、打断喊话等信息|
|天赋技能过滤|过滤满级玩家及其宠物学习天赋、技能时的通告|
|怪物说话|用一个重复过滤器过滤NPC的说话|
|额外过滤器|一些没名字的过滤器(合集)，大大提高广告过滤效果|
|拾取过滤|根据物品的品质/id进行过滤|

FAQ
---

1. 如何共享不同账号下的关键词列表和开关设置
  - 同一账户(如wow1)下的不同角色共享设置，不同账户的无法直接共享。
  - 你可以用字符串导入导出的方法复制关键词列表，然后人工进行设置。或者手动复制设置/设置硬链接。

2. 为何我添加关键词时总是会有"包含会被自动过滤的字符，将忽略该关键词！"这一错误？
  - 不要加入标点符号，这些字符会被自动忽略，只需要添加那些汉字。

3. 正则是什么？
  - 不知道的请不要用。不知道的请不要用。不知道的请不要用。
  - 如果你想学习请自行百度/谷歌。 Lua的正则符号是%

Issues
------

如有问题请在测试后提交Issues。

Licenses
--------

Original project and this one are under Public Domain.  
Original project, written by eucalyptisch, can be found here: <https://wow.curseforge.com/projects/chat-filter>.  
First Chinese version, modded by szpunk, can be found here: <http://bbs.nga.cn/read.php?tid=7527032>.  
