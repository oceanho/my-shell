# 文件说明

nginx.conf 是nginx主配置文件

docker-registry.oceanho.com.conf 是nginx http节点下的扩展站点项目,配置的是docker registry的反代理

由于出于安全考虑，需要对docker registry做请求安全认证(Basic Authorization,nginx本身就支持)、

我们需要用 `htpasswd -Bbn` 命令生成一个密码文件，然后在 nginx 的配置中用 auth_basic_user_file 指定密码文件。

说明：使用htpasswd -B生成的密码是加密了的,所以nginx必须要支持 crypt() 加解密,可以用 docker nginx:alpine镜像）
或者生成密码的时候 不使用  -b、

关于docker registry nginx做前端代理，更多信息参考：https://docs.docker.com/registry/recipes/nginx/#solution
