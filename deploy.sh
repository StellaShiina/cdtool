#!/usr/bin/bash

set -e

echo 'Start to delpoy cdtool...'

SERVICE_PATH=/etc/systemd/system/cdtool.service
BIN_PATH=/opt/cdtool/cdtool

service_sha0=''
service_sha1=$(sha256sum cdtool.service | awk '{print $1}')

bin_sha0=''
bin_sha1=''

update_service() {
    echo 'Updating service...'
    cp cdtool.service $SERVICE_PATH
    systemctl daemon-reload
    echo 'Service updated successfully'
}

build_bin() {
    echo 'Building server...'
    go build -o cdtool
    echo 'Server built successfully'
}

deploy() {
    echo 'Starting service...'
    systemctl start cdtool
    echo 'Enable service...'
    systemctl enable cdtool
}

systemctl --now disable cdtool.service
mkdir -p /opt/cdtool/

if [[ -f $SERVICE_PATH ]]; then
    service_sha0=$(sha256sum "$SERVICE_PATH" | awk '{print $1}')
fi

if [[ $service_sha0 != $service_sha1 ]]; then
    update_service
else
    echo 'Service is up to date'
fi

if [[ -f $BIN_PATH ]]; then
    bin_sha0=$(sha256sum "$BIN_PATH" | awk '{print $1}')
fi

if [[ ! -f cdtool ]]; then
    build_bin
fi

bin_sha1=$(sha256sum cdtool | awk '{print $1}')

if [[ $bin_sha0 != $bin_sha1 ]]; then
    cp cdtool $BIN_PATH
else
    echo 'CD-server is up to date...'
fi

deploy

echo 'Finished'