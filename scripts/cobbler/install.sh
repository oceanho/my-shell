#!/bin/bash
#
# Install Cobbler(Kickstart) Tools for CentOS-6/7
# Created by OceanHo(gzhehai@foxmail.com) AT 2017-10-22

os_release_ver=`sed -r 's#[a-zA-Z ]+(5|6|7)\..*#\1#g' /etc/redhat-release`
http_dhcpd_template_url="https://raw.githubusercontent.com/oceanho/my-shell/master/scripts/cobbler/dhcpd_172-16-1-0_24.template"

# YUM of epel 
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

function configure_dhcp_template()
{
    cp /etc/cobbler/dhcp.template{,$(date +%s).ori}
    wget -O /etc/cobbler/dhcp.template ${http_dhcpd_template_url}
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
        systemctl restart cobblerd.service
        systemctl restart httpd.service
        systemctl restart xinetd.service
    fi
}

function configure_cobbler_services()
{
    configure_dhcp_template
    configure_tftpd
    configure_httpd
    
    #configure_dhcp_template && \
    #configure_tftpd && \
    #configure_httpd
    cp /etc/cobbler/settings{,$(date +%s).ori}    # 备份

    # 修改配置文件
    sed -i 's/server: 127.0.0.1/server: 172.16.1.200/' /etc/cobbler/settings
    sed -i 's/next_server: 127.0.0.1/next_server: 172.16.1.200/' /etc/cobbler/settings
    sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
    sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings  # 限制客户端只能安装一次系统
    sed -ri "/default_password_crypted/s#(.*: ).*#\1\"`openssl passwd -1 -salt 'oceanhoasdhakdhakjs' '123456'`\"#" /etc/cobbler/settings
    sed -i 's#yes#no#' /etc/xinetd.d/rsync
    sed -i 's#yes#no#' /etc/xinetd.d/tftp
}

function main()
{
    install_pre_require
    install_cobbler_softs
    configure_cobbler_services
    sync_configure
    restart_services
    sync_configure
    cobbler check
}

main