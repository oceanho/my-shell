FROM mysql:5.6

# install MHA dependences packages
# more about MHA info, redirect to https://yq.aliyun.com/articles/57845
RUN set -x \
&& apt-get update \
&& apt-get -y install libdbd-mysql-perl make sudo openssh-server openssl vim \
&& rm -rf /var/lib/apt/lists/*

# SSH comunication capability
# more info: https://docs.docker.com/engine/examples/running_ssh_service/
RUN mkdir /var/run/sshd
ENV SSH_ROOT_PASSWORD passW0rd
RUN echo "root:${SSH_ROOT_PASSWORD}" | chpasswd
RUN sed -i 's#PermitRootLogin .*#PermitRootLogin yes#g' /etc/ssh/sshd_config

COPY mha4mysql-node-0.57.tar.gz /mha4mysql-node-0.57.tar.gz

RUN tar -xf /mha4mysql-node-0.57.tar.gz \
&& cd /mha4mysql-node-0.57 \
&& perl Makefile.PL \
&& make \
&& make install \
&& rm -rf /mha4mysql-node-0.57*

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 22

CMD ["mysqld"]