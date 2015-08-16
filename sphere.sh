#!/bin/bash

VERSION=1.2
IMAGE=${IMAGE:-ninjasphere/ninjasphere}

SCRIPT_PATH=$(cd $(dirname $0); pwd)

die() {
    echo "$*" 1>&2
    exit 1
}

with() {
    alternate-cloud() {
        local domain=$1
        local host=$2
        test -n "$host" || die "usage: with alternate-cloud {domain} {host} start ..."
        shift 2

        WITH_ARGS="-v ${SCRIPT_PATH}/sphere-config/config:/opt/ninjablocks/config -e NINJA_SPHERE_CLIENT_OPTS=--docker --add-host api.${domain}:${host} --add-host mqtt.${domain}:${host}"
        test -n "$1" || die "usage: with alternate-cloud 192.168.99.100 start..."
        "$@"
    }
    "$@"
}

start() {

    if [[ $NINJA_SERIAL == "" ]]; then
        if [ -f volume-data/sphere-serial.conf ]; then
            NINJA_SERIAL=$(cat volume-data/sphere-serial.conf)
        fi
    fi

    if [[ $NINJA_SERIAL == "" ]]; then
        echo "Serial number must be specified the first time: $0 init <serial>"
        exit 1
    fi

    mkdir -p volume-data
    init "$NINJA_SERIAL"

    docker run -d -it \
        -v $(pwd)/volume-data:/data \
        --env NINJA_SERIAL=$NINJA_SERIAL \
        --name=ninjasphere \
        -p 1883:1883 -p 8000:8000 -p 80:9080 -p 9001:9001 \
        ${WITH_ARGS} \
        "$@" \
        ${IMAGE}

    echo 'Sphere service launched.'
}

stop() {
    docker kill ninjasphere
    docker rm ninjasphere
}

ps() {
    docker exec ninjasphere ps aux
}

interact() {
    docker exec -it ninjasphere bash
}

logs() {
    docker "$@" ninjasphere
}

run-driver() {
    export sphere_installDirectory=$SCRIPT_PATH
    export PATH=$PATH:$SCRIPT_PATH/driver-bin

    if [[ "$1" == "" ]]; then
        echo "You must specify the path to the driver"
        exit 1
    fi

    if test -z "$MQTT_HOST" && which boot2docker >/dev/null; then
        MQTT_HOST=$(boot2docker ip 2>/dev/null)
    else
        MQTT_HOST=${MQTT_HOST:-127.0.0.1}
    fi

    "$@" --mqtt.host=$MQTT_HOST --mqtt.port=1883
}

init() {
    serial=${1:-$(sphere-go-serial)}
    test -n "$serial" || die "init: must specify a serial number"
    mkdir -p volume-data
    echo -n "$serial" > volume-data/sphere-serial.conf
    echo "NINJA_SERIAL=$serial;" > volume-data/sphere-serial.env
}

serial() {
    test -f volume-data/sphere-serial.conf && echo $(cat volume-data/sphere-serial.conf) || die "not initialized"
}

case "$1" in
    start)
        shift 1
        start "$@"
        ;;
    stop)
        stop
        ;;
    init)
        shift 1
        init "$@"
        ;;
    ps)
        ps
        ;;
    shell)
        interact
        ;;
    logs)
        logs "$@"
        ;;
    run-driver)
        shift 1
        run-driver "$@"
        ;;
    serial)
        shift 1
        serial "$@"
        ;;
    with)
        shift 1
        with "$@"
    ;;
    version)
        echo "$VERSION"
        ;;
    *)
        echo "Usage: $0  start [arg...]  -- start the sphere stack, init must have been run first"
        echo "       $0 init [serial]   -- initialize the serial number for the docker-ised sphere"
        echo "       $0 stop            -- stop the sphere stack"
        echo "       $0 ps              -- 'ps aux' inside the container"
        echo "       $0 shell           -- 'bash' inside the container"
        echo "       $0 serial          -- the serial number of the docker-used sphere"
        echo "       $0 logs [-f]       -- show (or follow) the logs"
        echo "       $0 version         -- the version number of the sphere.sh script"
        echo ""
        echo "To connect to an alternate cloud, run: $0 [ with alternate-cloud {domain} {host} ] start, for example:"
        echo ""
        echo "       $0 with alternate-cloud example.com 192.168.99.100 start"

        exit 1
esac

