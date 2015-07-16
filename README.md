# ninjasphere-docker

Runs a small, self-contained and definitely subtly-different-to-a-real-sphere copy of the Ninja Sphere client services.

Currently only runs on x86_64 Docker, and natively supports boot2docker.

## Getting Started

Before you run the docker-ised sphere for the first time you need initialize it with a unique serial number of your own choosing.

```
./sphere.sh init <serial number>
```

This will save the serial number in the volume-data directory where it will be referenced by later uses of the sphere.sh command.

You'll need docker set up and ready to go. Start by running:
```
./sphere.sh start [args...]
```

The first time you start the docker-ised Ninja Sphere you will need to pair it with the Ninja Sphere cloud. Pair the Sphere here: http://api.sphere.ninja/.

Notes:

* the pairing step is only required the first time the container is started.
* the IP shown after pairing and the link won't work, but you can verify from the logs that it's paired.
* if you have previously paired another sphere (of any type), the docker-ised sphere will start as a slave and homecloud will not start. Consider using a separate Ninja Sphere userid for each docker-ised sphere.
* a previous version of sphere.sh accepted the serial number as an optional first argument to the start command. This version of the command passes any additional arguments after the start keyword to the docker run command used to create the container.

To get a list of supported commands (they are just simple convenience wrappers around docker):
```
./sphere.sh
```

Most usefully:
```
./sphere.sh logs -f
```

And the convenient wrapper to run a Go driver pointing at the docker instance:
```
..../ninjasphere-docker/sphere.sh run-driver ./driver-awesome [extra driver arguments]
```

## Complete Driver Example

A more complete example of getting an entire Go driver into your local Go sources and running it:
```
go get github.com/ninjasphere/driver-go-chromecast
cd $GOPATH/src/github.com/ninjasphere/driver-go-chromecast
go build
..../ninjasphere-docker/sphere.sh run-driver ./driver-go-chromecast
```

## Data Persistence

All "user data" will be stored in ```volume-data``` in the current directory - to start fresh, delete this directory. The serial number will be cached across multiple runs, but it's also stored in this directory to make complete resets easier.

## Exposed Services

Ports 1883 (MQTT) and 8000 (HomeCloud REST) are exposed from the container (and the sphere.sh script publishes them for you too).

REST services can be accessed at for example:
```
http://your_docker_host_ip:8000/rest/v1/things
```

MQTT can be sniffed using the mosquitto client tools (available as part of homebrew's mosquitto install and ```mosquitto-clients``` on Ubuntu):
```
mosquitto_sub -t '#' -v -h your_docker_host_ip
```

Ports 80 and 9001 of the sphere-ui process are exposed to allow use of the sphere configuration UI.

## Components included

The following components are included:

* mqtt - provides the messaging bus
* redis - provides the local sphere data store
* sphere director - manages driver state
* homecloud - manages local data model
* sphere-client - manages connection to sphere cloud
* sphere-ui - provides rendering of the configurtion UI
* schemas - provides the JSON schema repository
* sphere-config - provides configuration defaults

## Missing Services & Errata

 * Drivers are not included, and homecloud will mutter a bit about them being restarted

## Revisions

###1.1
* Change to 'start' command.
* Introduce 'init', 'version' and 'serial' commands.
* Added support for sphere-ui.

###1.0
* Initial version cloned from http://github.com/theojulienne/ninjasphere-docker
