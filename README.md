新增了对交换芯片RTL8367S的支持，相关的机型为以MTK7620A/DA为主控外接交换芯片实现千兆有线的水星D12G，Tplink C5 v4等等  
源码来自于https://gitlab.com/dm38/padavan-ng  
相关提交为https://gitlab.com/dm38/padavan-ng/-/commit/4ec2acb96dccc268ec23aa71b8f5fcb283b9e122  
  
新增了对xtls的支持，源码来自于xumng123  
https://github.com/xumng123/rt-n56u  
感谢vb1980持续对代码做出的测试和改进，他在原本的基础上新增了对xray的编译，而我之前就直接替换了v2ray的bin，所以是殊途同归啦  
https://github.com/vb1980/Padavan-KVR  
  
# Padavan
基于hanwckf,chongshengB以及padavanonly的源码整合而来，支持kvr  
编译方法同其他Padavan源码，主要特点如下：  
1.采用padavanonly源码的5.0.4.0无线驱动，支持kvr  
2.添加了chongshengB源码的所有插件  
3.其他部分等同于hanwckf的源码，有少量优化来自immortalwrt的padavan源码  
4.添加了MSG1500的7615版本config  
  
以下附上他们四位的源码地址供参考  
https://github.com/hanwckf/rt-n56u  
https://github.com/chongshengB/rt-n56u  
https://github.com/padavanonly/rt-n56u  
https://github.com/immortalwrt/padavan  

已测试的机型为MSG1500-7615，JCG-Q20，CR660x  
  
固件默认wifi名称PDCN及PDCN_5G  
wifi密码1234567890  
管理地址192.168.123.1  
管理账号密码都是admin  
