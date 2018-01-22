#!/bin/bash
#

pushd ./mha-node/5.6/ >/dev/null 2>&1
docker build --tag oceanho/mysql-mha-node:5.6 .
popd >/dev/null 2>&1


pushd ./mha-manager/ubuntu/14.04/ >/dev/null 2>&1
docker build --tag oceanho/mysql-mha-manager:ubuntu1404 .
popd >/dev/null 2>&1

pushd ./mha-manager/ubuntu/16.04/ >/dev/null 2>&1
docker build --tag oceanho/mysql-mha-manager:ubuntu1604 .
popd >/dev/null 2>&1