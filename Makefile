IMAGE=ninjasphere/ninjasphere
SPHERE_CLIENT_BIN=bin-linux-amd64/sphere-client
SPHERE_DIRECTOR_BIN=bin-linux-amd64/sphere-director
SPHERE_HOMECLOUD_BIN=bin-linux-amd64/sphere-go-homecloud
MQTT_BRIDGEIFY_BIN=bin-linux-amd64/mqtt-bridgeify
SPHERE_UI_BIN=bin-linux-amd64/sphere-ui
BINARIES=\
$(SPHERE_CLIENT_BIN) \
$(SPHERE_DIRECTOR_BIN) \
$(SPHERE_HOMECLOUD_BIN) \
$(SPHERE_BRIDGEIFY_BIN) \
$(SPHERE_UI_BIN)


all: build

build: sphere-config sphere-schemas $(BINARIES)
	docker build -t $(IMAGE) .

sphere-config:
	git clone https://github.com/ninjasphere/sphere-config.git

sphere-schemas:
	git clone https://github.com/ninjasphere/schemas.git sphere-schemas

$(SPHERE_CLIENT_BIN):
	bash build-binary.sh ninjasphere/sphere-client

$(SPHERE_DIRECTOR_BIN):
	bash build-binary.sh ninjasphere/sphere-director

$(SPHERE_HOMECLOUD_BIN):
	bash build-binary.sh ninjasphere/sphere-go-homecloud

$(MQTT_BRIDGEIFY_BIN):
	bash build-binary.sh ninjablocks/mqtt-bridgeify

$(SPHERE_UI_BIN):
	bash build-binary.sh ninjasphere/sphere-ui

clean:
	rm -rf sphere-config sphere-schemas $(BINARIES)

