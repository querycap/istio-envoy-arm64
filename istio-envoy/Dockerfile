FROM querycapistio/istio-envoy-arm64-build-env:0.1.0 as builder

ARG VERSION=1.6.1

WORKDIR /go/src

RUN gn --version && ninja --version && clang++ --version

# clone istio/proxy
RUN git clone --depth 1 -b ${VERSION} https://github.com/istio/proxy /go/src/proxy

WORKDIR /go/src/proxy

ENV ENVOY_ORG=istio

RUN make build_envoy;

RUN mkdir -p /envoy && cp -r bazel-bin/src/envoy/envoy /envoy

RUN /envoy/envoy --version | grep version | sed -e 's/.*version\: //g' > /envoy/envoy-version

FROM busybox

COPY --from=builder /envoy/envoy /envoy/envoy
COPY --from=builder /envoy/envoy-version /envoy/envoy-version

ENTRYPOINT ["/envoy/envoy"]