FROM envoyproxy/envoy-build-ubuntu:e7ea4e81bbd5028abb9d3a2f2c0afe063d9b62c0 as builder

ENV PATH="/opt/llvm/bin:${PATH}"

RUN gn --version && ninja --version && clang++ --version

ARG VERSION=1.7.2
RUN git clone --depth 1 -b ${VERSION} https://github.com/istio/proxy /go/src/proxy

WORKDIR /go/src/proxy

RUN set -eux; \
    \
    case $(cat .bazelversion) in \
    *"3.1"*) \
        wget -O /usr/local/bin/bazel https://github.com/Tick-Tocker/bazelisk-arm64/releases/download/arm64/bazelisk-linux-arm64; \
        chmod +x /usr/local/bin/bazel; \
        ;; \
    esac

ENV ENVOY_ORG=istio

RUN make build_envoy;
RUN mkdir -p /envoy && cp -r bazel-bin/src/envoy/envoy /envoy
RUN /envoy/envoy --version | grep version | sed -e 's/.*version\: //g' > /envoy/envoy-version

FROM busybox

COPY --from=builder /envoy/envoy /envoy/envoy
COPY --from=builder /envoy/envoy-version /envoy/envoy-version

ENTRYPOINT ["/envoy/envoy"]