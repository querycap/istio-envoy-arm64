VERSION=$(shell cat istio-envoy/Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*://g" )
HUB=querycapistio
TAG=$(VERSION)

build:
	docker buildx build \
		--push \
		--build-arg VERSION=$(VERSION) \
		--tag $(HUB)/istio-envoy-arm64:$(TAG) \
		--platform linux/arm64 \
		--file istio-envoy/Dockerfile .

drop-bin:
	docker cp $(shell docker create $(HUB)/istio-envoy-arm64:$(VERSION)):/envoy/ ${PWD}
	$(MAKE) set-output

set-output:
	echo "::set-output name=version::$(VERSION)"
	echo "::set-output name=envoy_expect_version::$(shell docker run --entrypoint=/usr/local/bin/envoy istio/proxyv2:$(VERSION) --version | grep version | sed -e 's/.*version\: //g')"
	echo "::set-output name=envoy_actual_version::$(shell cat ./envoy/envoy-version)"

build-build-env:
	docker buildx build \
		--push \
		--build-arg VERSION=$(VERSION) \
		--tag $(HUB)/istio-envoy-arm64-build-env:${TAG} \
		--platform linux/arm64 \
		--file build-env/Dockerfile .
