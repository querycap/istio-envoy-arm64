FROM querycapistio/istio-envoy-arm64-build-env:0.0.0 as builder

ARG VERSION=1.6.1

WORKDIR /go/src

RUN gn --version && bazel --version && ninja --version && clang++ --version

# clone istio/proxy
RUN git clone --depth 1 -b ${VERSION} https://github.com/istio/proxy /go/src/proxy

WORKDIR /go/src/proxy

RUN set -eux; \
    \
    export ENVOY_ORG=istio; \
    \
    export JAVA_HOME=$(dirname $(dirname $(realpath $(which javac)))); \
    export BAZEL_BUILD_ARGS="--sandbox_debug --verbose_failures --define=ABSOLUTE_JAVABASE=${JAVA_HOME} --javabase=@bazel_tools//tools/jdk:absolute_javabase --host_javabase=@bazel_tools//tools/jdk:absolute_javabase --java_toolchain=@bazel_tools//tools/jdk:toolchain_vanilla --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_vanilla"; \
    make build_envoy; \
    mkdir -p /envoy; \
    cp -r bazel-bin/src/envoy/envoy /envoy

RUN /envoy/envoy --version | grep version | sed -e 's/.*version\: //g' > /envoy/envoy-version

FROM busybox

COPY --from=builder /envoy/envoy /envoy/envoy
COPY --from=builder /envoy/envoy-version /envoy/envoy-version

ENTRYPOINT ["/envoy/envoy"]