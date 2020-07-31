# istio envoy arm64


## setup self-hosted

* https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service
* install buildx v0.4.1
* create builder 
    * `docker buildx create --use --name=builder --node=arm64 --platform=linux/arm64 --driver-opt="image=moby/buildkit:master,network=host"`
