# Memcached服务状态检测脚本

## 文件
```
1、check_memcached.sh，Memcached监测脚本文件
2、check_memcached_auth，安全模式执行Memcached监测使用的ip/端口参数配置文件
```

## 功能
```
通过对指定Memcached服务进行写/读,比较.判断Memcached服务的健康状态.
```

## 特点
```
1、支持参数控制对不同实例的Memcached检查
2、支持从配置文件读取连接Memcached的IP/端口信息
```

## 使用帮助
### 1、简单
`sh ./check_memcached.sh`

### 2、传递参数实现指定主机上MySQL的状态监测
```
  sh ./check_memcached.sh "IP" "端口" "Memcached状态是健康时输出的返回值"
  比如：sh ./check_memcached.sh  10.0.0.200 11211 "ok"
  说明：参数不能少，顺序不能错，必须按照上面传参.通过命令行传递参数,不安全
```

### 3、通过指定Memcached连接IP/端口配置文件实现Memcached的状态监测
```
   sh ./check_memcached.sh --security "/etc/checks/memcached_check_conf"
   说明：--security 表示使用安全的方式获取MySQL授权账号密码,
         --security 必须是第一个参数.第二个参数表示Memcached连接IP/端口信息文件路径,最好用绝对路径.

   文件(/etc/checks/memcached_check_conf)内容：
   host=10.0.0.200
   port=11211
   healthly_output="\033[32m Memcached Service is Healthly. \033[0m"
```
