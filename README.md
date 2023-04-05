## This repository do below things
### * before you run this script,
### - do not run this script as root or sudo
### 1. install nvidia driver
### 2. install nvidia-container-toolkit
### 3. install docker
### 4. set up k8s control plane
### 5. install helm
### 6. install helmfile
### 7. install kustomize
### 8. install uyuni infra
### 9. install uyuni suite
-----------------------
## how to add worker nodes
### 1. run setup.sh up to specific lines
### 2. In master node, edit $HOME/kubespray/inventory/mycluster/host.yaml.
### 3. copy master's administrator's public key to worker node
### 4. add worker node into k8s using ansible command
### 5. In uyuni dashboard, add worker node.
-----------------------
## how to remove uyuni-infra and uyuni-suite completely
### 1. helmfile --environment test -l type=app destroy
### 2. helmfile --environment test -l type=base destroy
### 3. delete every pvcs, pvs and files, configmaps, secrets in nfs server
----------------------
## keycloak domain : http://???.???.???.???:30090
### default ID : Admin
### default PW : xiilabPassword3#
