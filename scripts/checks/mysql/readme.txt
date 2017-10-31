
文件：
1、check_mysql.sh，MySQL监测脚本文件
2、check_mysql_auth，MySQL监测使用的连接串参数（账号,密码,端口等等）


功能：
通过执行 select version(); 检查mysql的健康状态.


特点：
1、支持参数控制对不同主机的MySQL检查
2、支持从配置文件读取连接MySQL的连接串信息


使用帮助：
---------

1、简单
   sh ./check_mysql.sh

2、传递参数实现指定主机上MySQL的状态监测
   sh ./check_mysql.sh "用户" "密码" "MySQL主机/ip" "MySQL端口" "健康状态输出的值"
   比如：sh ./check_mysql.sh root 123456 10.0.0.200 3306 1
   说明：参数不能少，顺序不能错，必须按照上面传参.通过命令行传递参数,不安全

3、通过指定MySQL登录授权文件实现MySQL状态监测
   sh ./check_mysql.sh --security "/etc/checks/mysql_check_auth"
   说明：--security 表示使用安全的方式获取MySQL授权账号密码,
         --security 必须是第一个参数.第二个参数表示MySQL登录授权账号密码文件路径,最好用绝对路径.

   文件(/etc/checks/mysql_check_auth)内容：
   user=root
   pass=123456
   host=localhost
   port=3306
   healthly_output="\033[32m MySQL Service is Healthly. \033[0m"
------------------------------------------------------------------------------------------------
