IMAGE = meg4r0m/alpine-haproxy
VERSIONS = 1.6_1.6.13_782947642c0c7983f73624d8d45e2321 1.7_1.7.9_a2bbbdd45ffe18d99cdcf26aa992f92d 1.8_1.8.1_e42892d4b6ee33200fccaa1d81837e49

.PHONY: all $(VERSIONS)

all: $(VERSIONS) lua tag-latest

$(VERSIONS): MAJOR = $(firstword $(subst _, ,$@))
$(VERSIONS): MINOR = $(word 2,$(subst _, ,$@))
$(VERSIONS): MD5SUM = $(lastword $(subst _, ,$@))
$(VERSIONS):
	@echo "=> building $(IMAGE):$(MAJOR)"
	@docker build \
		--build-arg HAPROXY_VERSION=$(MINOR) \
		--build-arg HAPROXY_MAJOR=$(MAJOR) \
		--build-arg HAPROXY_MD5=$(MD5SUM) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-t $(IMAGE):$(MAJOR) -f Dockerfile .
	@docker tag $(IMAGE):$(MAJOR) $(IMAGE):$(MINOR)
	@echo "=> pushing $(IMAGE):$(MAJOR)"
	@docker push $(IMAGE):$(MAJOR)
	@docker push $(IMAGE):$(MINOR)

lua: LATEST = $(word $(words $(VERSIONS)),$(VERSIONS))
lua: MAJOR = $(firstword $(subst _, ,$(LATEST)))
lua: MINOR = $(word 2,$(subst _, ,$(LATEST)))
lua: MD5SUM = $(lastword $(subst _, ,$(LATEST)))
lua:
	@echo "=> building $(IMAGE):$(MAJOR)-lua"
	@docker build \
		--build-arg HAPROXY_VERSION=$(MINOR) \
		--build-arg HAPROXY_MAJOR=$(MAJOR) \
		--build-arg HAPROXY_MD5=$(MD5SUM) \
		--build-arg WITH_LUA=1 \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		-t $(IMAGE):$(MAJOR)-lua -f Dockerfile .
	@docker tag $(IMAGE):$(MAJOR)-lua $(IMAGE):$(MINOR)-lua
	@echo "=> pushing $(IMAGE):$(MAJOR)-lua"
	@docker push $(IMAGE):$(MAJOR)-lua
	@docker push $(IMAGE):$(MINOR)-lua


tag-latest: MAJOR = $(firstword $(subst _, ,$(word $(words $(VERSIONS)),$(VERSIONS))))
tag-latest:
	@echo "=> pushing $(IMAGE):latest"
	@docker tag $(IMAGE):$(MAJOR) $(IMAGE):latest
@docker push $(IMAGE):latest