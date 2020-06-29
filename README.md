# istio envoy arm64


## setup self-hosted

* install buildx v0.4.1
* create builder 
    * `docker buildx create --use --name=builder --node=arm64 --platform=linux/arm64 --driver-opt="image=moby/buildkit:master,network=host"`