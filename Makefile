VERSION=$(shell cat istio-envoy/.version)
HUB=querycapistio
TAG=devel

build:
	docker buildx build \
		--push \
		--build-arg VERSION=${VERSION} \
		--tag ${HUB}/istio-enovy-arm64:${VERSION} \
		--platform linux/arm64 \
		--file istio-envoy/Dockerfile .

build-build-env:
	docker buildx build \
		--push \
		--build-arg VERSION=${VERSION} \
		--tag ${HUB}/istio-envoy-arm64-build-env:${TAG} \
		--platform linux/arm64 \
		--file build-env/Dockerfile .

drop-bin:
	docker cp $(shell docker run -dit --rm ${HUB}/istio-enovy-arm64:${VERSION}):/envoy ${PWD}/envoy

version:
	docker run -it --entrypoint=/usr/local/bin/envoy istio/proxyv2:${VERSION} --version | grep version | sed -e 's/.*version\: //g' > istio-envoy/.envoy-version

