#!/bin/bash
#
# Created By OceanHo(gzhehai@foxmail.com) at 2018-01-21
#

#
#主机，IP/HostName规划
#
#主机名	IP	部署服务	数据盘挂载
#host1	192.168.1.101	PD1 & TiDB	/data
#host2	192.168.1.102	PD2	/data
#host3	192.168.1.103	PD3	/data
#host4	192.168.1.104	TiKV1	/data
#host5	192.168.1.105	TiKV2	/data
#host6	192.168.1.106	TiKV3	/data
#

Network_Prefix="192.168.1"
Network_Name="192-168-1_24"

# Create Docker Network
if [ `docker network ls --filter NAME=${Network_Name} | wc -l` -eq 1 ]
then
	docker network create --driver bridge --subnet ${Network_Prefix}.0/24 ${Network_Name}
else
	echo -e "\033[33m Exists $Network_Name \033[0m"
fi
[ $? -ne 0 ] && {
	echo -e "\033[35m It's seem to has problem. make sure please. \033[0m"
	exit 127;
}

#
# Docker Virtual Machines
#
# -----------------------

docker rm tidb tikv1 tikv2 tikv3 pd1 pd2 pd3 -f 2>/dev/null

# host1
docker create --name pd1 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/PD1/data:/data \
--network=${Network_Name} \
--ip ${Network_Prefix}.101 \
pingcap/pd:latest --name="pd1" \
--data-dir="/data/pd1" \
--client-urls="http://0.0.0.0:2379" \
--advertise-client-urls="http://${Network_Prefix}.101:2379" \
--peer-urls="http://0.0.0.0:2380" \
--advertise-peer-urls="http://${Network_Prefix}.101:2380" \
--initial-cluster="pd1=http://${Network_Prefix}.101:2380,pd2=http://${Network_Prefix}.102:2380,pd3=http://${Network_Prefix}.103:2380"

# host2
docker create --name pd2 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/PD2/data:/data \
--network=${Network_Name} \
--ip ${Network_Prefix}.102 \
pingcap/pd:latest --name="pd2" \
--data-dir="/data/pd2" \
--client-urls="http://0.0.0.0:2379" \
--advertise-client-urls="http://${Network_Prefix}.102:2379" \
--peer-urls="http://0.0.0.0:2380" \
--advertise-peer-urls="http://${Network_Prefix}.102:2380" \
--initial-cluster="pd1=http://${Network_Prefix}.101:2380,pd2=http://${Network_Prefix}.102:2380,pd3=http://${Network_Prefix}.103:2380"

# host3
docker create --name pd3 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/PD3/data:/data \
--network=${Network_Name} \
--ip ${Network_Prefix}.103 \
pingcap/pd:latest --name="pd3" \
--data-dir="/data/pd3" \
--client-urls="http://0.0.0.0:2379" \
--advertise-client-urls="http://${Network_Prefix}.103:2379" \
--peer-urls="http://0.0.0.0:2380" \
--advertise-peer-urls="http://${Network_Prefix}.103:2380" \
--initial-cluster="pd1=http://${Network_Prefix}.101:2380,pd2=http://${Network_Prefix}.102:2380,pd3=http://${Network_Prefix}.103:2380"


# TiKV1, host4
docker create --name tikv1 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/TiKV1/data:/data \
--ulimit nofile=1000000:1000000 \
--network=${Network_Name} \
--ip ${Network_Prefix}.104 \
pingcap/tikv:latest --addr="0.0.0.0:20160" \
--advertise-addr="${Network_Prefix}.104:20160" \
--data-dir="/data/tikv1" \
--pd="${Network_Prefix}.101:2379,${Network_Prefix}.102:2379,${Network_Prefix}.103:2379"


# TiKV2, host5
docker create --name tikv2 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/TiKV2/data:/data \
--ulimit nofile=1000000:1000000 \
--network=${Network_Name} \
--ip ${Network_Prefix}.105 \
pingcap/tikv:latest --addr="0.0.0.0:20160" \
--advertise-addr="${Network_Prefix}.105:20160" \
--data-dir="/data/tikv2" \
--pd="${Network_Prefix}.101:2379,${Network_Prefix}.102:2379,${Network_Prefix}.103:2379"

# TiKV3, host6
docker create --name tikv3 \
--add-host host1:${Network_Prefix}.101 \
--add-host host2:${Network_Prefix}.102 \
--add-host host3:${Network_Prefix}.103 \
--add-host host4:${Network_Prefix}.104 \
--add-host host5:${Network_Prefix}.105 \
--add-host host6:${Network_Prefix}.106 \
-v /etc/localtime:/etc/localtime:ro \
-v /data/tidb/TiKV3/data:/data \
--ulimit nofile=1000000:1000000 \
--network=${Network_Name} \
--ip ${Network_Prefix}.106 \
pingcap/tikv:latest --addr="0.0.0.0:20160" \
--advertise-addr="${Network_Prefix}.106:20160" \
--data-dir="/data/tikv3" \
--pd="${Network_Prefix}.101:2379,${Network_Prefix}.102:2379,${Network_Prefix}.103:2379"


#
# Start TiKV servers & TiPD servers
docker start pd1 pd2 pd3 tikv1 tikv2 tikv3


#
# Run tidb server
docker run -d --name tidb \
-p 4000:4000 \
-p 10080:10080 \
-v /etc/localtime:/etc/localtime:ro \
--network=${Network_Name} \
--ip ${Network_Prefix}.107 \
pingcap/tidb:latest \
--store=tikv \
--path="${Network_Prefix}.101:2379,${Network_Prefix}.102:2379,${Network_Prefix}.103:2379"

sleep 8000

#
# Run a mysql cli tools to test tidb
docker run -it --rm \
-v /etc/localtime:/etc/localtime:ro \
--network=${Network_Name} \
--ip ${Network_Prefix}.108 \
mysql:5.7 mysql -h ${Network_Prefix}.107 -u root -P 40000



