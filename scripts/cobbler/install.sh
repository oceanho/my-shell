#!/bin/bash
#
# Install Cobbler(Kickstart) Tools for CentOS-6/7
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-10-22

#
# 操作系统发型主版本
os_release_ver=`sed -r 's#[a-zA-Z ]+(5|6|7)\..*#\1#g' /etc/redhat-release`

#
# cobbler settings 文件中的server参数
# auto：表示自动 从 net_bind_device 指定的设备中获取
# 也可以手动指定
cobbler_server_ip="auto"
#
# cobbler settings 文件中的next-server参数
# auto：表示自动 从 net_bind_device 指定的设备中获取
# 也可以手动指定
cobbler_next_server_ip="auto"

#
# cobbler 安装系统可以使用的默认密码（盐 / 密码：123456）
password_salt="`openssl rand -base64 32`"
default_password_crypted=`openssl passwd -1 -salt "${password_salt}" '123456'`  # 123456

#
# 定义一个变量，用来表示cobbler涉及到网络参数自动获取网卡设备名称
# 比如：dhcpd,cobbler的settings文件中涉及到的IP地址等等
# 
net_auto_dev="eth1"
dhcpd_template_geturl="https://raw.githubusercontent.com/oceanho/my-shell/master/scripts/cobbler/dhcpd_172-16-1-0_24.template"

dhcpd_bind_net_prefix="172.16.1"
dhcpd_bind_net_subnet="172.16.1.0"
dhcpd_bind_net_netmask="255.255.255.0"

# 显示帮助
function help()
{
    echo -e `
    clear
cat <<EOF
    \n
    \033[36m
    \n
    功能\n
    一键实现Cobbler程序安装和部署\n\n

    参数\n
    cobbler-server-ip，指定cobbler settings的server-ip参数，默认从net-auto-dev网卡设备中自动获取\n
    cobbler-next-server-ip，指定cobbler settings的next-server-ip参数，默认从net-auto-dev网卡设备中自动获取\n
    net-auto-dev，指定自动获取cobbler网络参数相关的配置参数网卡设备，默认eth1
    \n
    \n
    \033[0m
EOF
    `
}

case "$1" in
    -h|--help|help|-help )
        help
        exit 0
    ;;
esac


#
# 处理参数
# 参数格式要求
# key=value，比如 net-auto-dev=eth1
until [ $# -eq 0 ]
do
    if egrep -q "[a-z-]+=.*"<<<"$1" 
    then
        k=$(sed -r 's#([a-z-]+)=.*#\1#g' <<<"$1")
        v=$(sed -r 's#[a-z-]+=(.*)#\1#g' <<<"$1")
        case "$k" in
            "cobbler-server-ip" )
                cobbler_server_ip=$v
            ;;
            "cobbler-next-server-ip" )
                cobbler_next_server_ip=$v
            ;;
            "net-auto-dev" )
                net_auto_dev=$v
            ;;
        esac
    fi
    shift
done


#
# 根据传入的参数，初始化一些必须的参数，比如绑定dhcpd服务的网段地址，cobbler settings配置文件中涉及到的server的ip地址等参数的初始化
function init_param()
{
    str=`ip addr show $net_auto_dev | awk -F"[ ]+" 'NR==3{print $3}'`
    if [ $? -ne 0 ]
    then
        echo -e "\033[31m 获取网卡配置信息失败. \033[0m"
        return 1
    fi

    str_ip="${str#%/*}"
    str_netmask="${str#*/}"

    #
    # 以下的写法只能支持 8/16/24 子网
    case $str_netmask in
        "8" )
            dhcpd_bind_net_prefix=`egrep -o "([0-9]+.){1}" <<<$str_ip`
            dhcpd_bind_net_subnet="${dhcpd_bind_net_prefix}0.0.0"
            dhcpd_bind_net_netmask="255.0.0.0"
        ;;
        "16" )
            dhcpd_bind_net_prefix=`egrep -o "([0-9]+.){2}" <<<$str_ip`
            dhcpd_bind_net_subnet="${dhcpd_bind_net_prefix}0.0"
            dhcpd_bind_net_netmask="255.255.0.0"
        ;;
        "24" )
            dhcpd_bind_net_prefix=`egrep -o "([0-9]+.){3}" <<<$str_ip`
            dhcpd_bind_net_subnet="${dhcpd_bind_net_prefix}0"
            dhcpd_bind_net_netmask="255.255.255.0"
        ;;
    esac

    if [ "$cobbler_server_ip" == "auto" ]
    then
        cobbler_server_ip=$str_ip
    fi
    if [ "$cobbler_next_server_ip" == "auto" ]
    then
        cobbler_next_server_ip=$str_ip
    fi
}

#
# YUM of epel 
# 自动现在cobbler先决条件项目，比如epel源等、
# 说明：如果已经有了epel源，该函数不执行安装epel源的操作，如果没有epel源，自动安装阿里云的epel源 
function install_pre_require()
{
    echo -e "\033[36m Installing requires \033[0m"
    if [ `yum --disablerepo=\* --enablerepo=epel repolist | grep -c epel` -eq 0 ]
    then
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${os_release_ver}.repo
    fi
    echo -e "\033[32m requires Completed. \033[0m"
}

function install_cobbler_softs()
{
    echo -e "\033[36m Installing cobbler-softs \033[0m"
    fix_missing_packages_for_centos7_epel
    yum -y install cobbler cobbler-web dhcp tftp-server pykickstart httpd
    if [ $? -ne 0 ]
    then
        echo -e "\033[31m Action failed. \033[0m"
        return 1
    fi
    echo -e "\033[32m cobbler-softs Completed. \033[0m"
}

function fix_missing_packages_for_centos7_epel()
{
    if [ $os_release_ver -eq 7 ]
    then
        # rpm -ql Django14 | wc -l || e
        echo -e "\033[33m May be miss Django14-1.4.21-1.el7.noarch. need you fixed. \033[0m"
        # yum -y localinstall        
    fi
}

#
# 配置DHCP服务
# 该函数会从远程主机下载，dhcpd.template 文件
# 说明：DHCP IP地址段是 100 - 254
function configure_dhcp_template()
{
    echo -e "\033[36m Configure dhcp.template \033[0m"
    cp /etc/cobbler/dhcp.template{,$(date +%s).ori}
    wget -O /etc/cobbler/dhcp.template ${dhcpd_template_geturl}
    sed -i "21s#.*#subnet $dhcpd_bind_net_subnet netmask $dhcpd_bind_net_netmask {#" /etc/cobbler/dhcp.template
    sed -i "22s#.*#     option subnet-mask        ${dhcpd_bind_net_netmask};#" /etc/cobbler/dhcp.template
    sed -i "23s#.*#     range dynamic-bootp        ${dhcpd_bind_net_prefix}.100 ${dhcpd_bind_net_prefix}.254;#" /etc/cobbler/dhcp.template
}


function configure_tftpd()
{
    echo -e "\033[36m Configure tftpd \033[0m"
    sed -i 's#yes#no#' /etc/xinetd.d/tftp
}

function configure_httpd()
{
    echo -e "\033[36m Configure httpd \033[0m"
}

function sync_configure()
{
    echo -e "\033[36m Sync cobbler settings \033[0m"
    cobbler sync
}

function restart_services()
{
    echo -e "\033[36m Restart cobbler's services \033[0m"
    if [ $os_release_ver -ne 7 ]
    then
        /etc/init.d/cobblerd restart
        /etc/init.d/httpd restart
        /etc/init.d/xinetd restart
    else
        systemctl restart cobblerd.service        
        systemctl restart httpd.service
        systemctl restart cobblerd.service
        systemctl restart xinetd.service
    fi
}

function configure_cobbler_services()
{
    configure_dhcp_template
    configure_tftpd
    configure_httpd

    cp /etc/cobbler/settings{,$(date +%s).ori}    # 备份

    # 修改配置文件
    sed -i "s/server: 127.0.0.1/server: ${cobbler_server_ip}/" /etc/cobbler/settings
    sed -i "s/next_server: 127.0.0.1/next_server: ${cobbler_next_server_ip}/" /etc/cobbler/settings
    sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
    sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings  # 限制客户端只能安装一次系统
    sed -ri "/default_password_crypted/s#(.*: ).*#\1\"`openssl passwd -1 -salt 'oceanhoasdhakdhakjs' '123456'`\"#" /etc/cobbler/settings
    #sed -i 's#yes#no#' /etc/xinetd.d/rsync
    sed -i 's#yes#no#' /etc/xinetd.d/tftp
}

# 程序入口
function main()
{

    # 初始化参数
    init_param

    install_pre_require
    install_cobbler_softs
    configure_cobbler_services
    sync_configure
    restart_services
    cobbler get-loaders
    sync_configure
    cobbler check
}

# 执行安装程序操作
main