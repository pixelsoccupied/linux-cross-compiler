# linux-cross-compiler
This docker container can used to cross-compile Go binary (e.g for K8s and ocp/k8s components) from macOS or Windows. Heplful when overriding`GOOS` and `GOARCH` is not enough.

This should help with error like for components that require CGO 

```
make WHAT="vendor/k8s.io/apiextensions-apiserver" KUBE_BUILD_PLATFORMS=linux/amd64 
+++ [1007 14:04:54] Building go targets for linux/amd64:
    vendor/k8s.io/apiextensions-apiserver
# runtime/cgo
cgo: C compiler "x86_64-linux-gnu-gcc" not found: exec: "x86_64-linux-gnu-gcc": executable file not found in $PATH
!!! [1007 14:04:54] Call tree:
!!! [1007 14:04:54]  1: /Users/kubernetes/hack/lib/golang.sh:732 kube::golang::build_some_binaries(...)
!!! [1007 14:04:54]  2: /Users/kubernetes/hack/lib/golang.sh:876 kube::golang::build_binaries_for_platform(...)
!!! [1007 14:04:54]  3: hack/make-rules/build.sh:27 kube::golang::build_binaries(...)
!!! [1007 14:04:54] Call tree:
!!! [1007 14:04:54]  1: hack/make-rules/build.sh:27 kube::golang::build_binaries(...)
!!! [1007 14:04:54] Call tree:
!!! [1007 14:04:54]  1: hack/make-rules/build.sh:27 kube::golang::build_binaries(...)
make: *** [all] Error 1

```

or when building hyperkube image for ocp/k8s which requires `_output/bin/deepcopy-gen` linux

```
 => ERROR [builder 4/4] RUN make WHAT='cmd/kube-apiserver cmd/kube-controller-manager cmd/kube-scheduler cmd/kubelet cmd/watch-termination  52.7s
------
 > [builder 4/4] RUN make WHAT='cmd/kube-apiserver cmd/kube-controller-manager cmd/kube-scheduler cmd/kubelet cmd/watch-termination' &&     mkdir -p /tmp/build &&     cp openshift-hack/images/hyperkube/hyperkube /tmp/build &&     cp /go/src/k8s.io/kubernetes/_output/local/bin/linux/$(go env GOARCH)/{kube-apiserver,kube-controller-manager,kube-scheduler,kubelet,watch-termination}     /tmp/build:
#13 15.06 +++ [1007 21:44:11] Building go targets for linux/amd64:
#13 15.06     ./vendor/k8s.io/code-generator/cmd/prerelease-lifecycle-gen
#13 48.71 Generating prerelease lifecycle code for 27 targets
#13 52.58 Generating deepcopy code for 246 targets
#13 52.65 ./hack/run-in-gopath.sh: line 34: _output/bin/deepcopy-gen: cannot execute binary file: Exec format error
#13 52.66 make[1]: *** [Makefile.generated_files:252: gen_deepcopy] Error 1
#13 52.67 make: *** [Makefile:552: generated_files] Error 2
------
executor failed running [/bin/sh -c make WHAT='cmd/kube-apiserver cmd/kube-controller-manager cmd/kube-scheduler cmd/kubelet cmd/watch-termination' &&     mkdir -p /tmp/build &&     cp openshift-hack/images/hyperkube/hyperkube /tmp/build &&     cp /go/src/k8s.io/kubernetes/_output/local/bin/linux/$(go env GOARCH)/{kube-apiserver,kube-controller-manager,kube-scheduler,kubelet,watch-termination}     /tmp/build]: exit code: 2

```
## Build the image
```
cd /linux-cross-compiler
docker build -t lin-comp:1 .
```
or
```docker pull quay.io/npathan/linux-cross-compiler```

## Run
```
cd /dir/where/code/lives 
docker run -it --mount type=bind,source=$(pwd),target=/mnt quay.io/npathan/linux-cross-compiler /bin/sh -c "cd /mnt && bash"
# once mounted do a clean up and then compile
make clean && make
```
