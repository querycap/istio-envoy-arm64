VERSION=$(shell cat Dockerfile.version | grep "^FROM " | sed -e "s/FROM.*:v\{0,\}//g" )

NAME ?= istio-envoy-arm64
TAG ?= $(VERSION)

prepare:
	@echo ::set-output name=image::$(NAME):$(TAG)
	@echo ::set-output name=build_args::VERSION=$(VERSION)

release:
	docker cp $(shell docker create ghcr.io/querycap/istio/istio-envoy-arm64:$(VERSION)):/envoy/ ${PWD}
	$(MAKE) prepare-release

prepare-release:
	@echo "::set-output name=version::$(VERSION)"
	@echo "::set-output name=envoy_expect_version::$(shell docker run --entrypoint=/usr/local/bin/envoy istio/proxyv2:$(VERSION) --version | grep version | sed -e 's/.*version\: //g')"
	@echo "::set-output name=envoy_actual_version::$(shell cat ./envoy/envoy-version)"
