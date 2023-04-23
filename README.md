## Summary
### k8s : 1.24.6
### cni : calico
### cri : docker latest version
### os : ubuntu 22.04
### provisioner : ceph-filesystem
### kubespray : release-2.20
---------------------
## before you run this script
### - prepare nfs server which provides /data directory
### - do not run this script as root or sudo
### - you can create only one administrator account
---------------------
## This repository do below things
### 1. set up k8s control plane
### 2. install helm
### 3. install helmfile
### 4. install rook ceph
### 5. install uyuni infra
### 6. install uyuni suite
-----------------------
## how to add worker nodes
### 1. run add_node.sh up to specific lines
### 2. In master node, edit $HOME/kubespray/inventory/mycluster/host.yaml.
### 3. copy master's administrator's public key to worker node
### 4. add worker node into k8s using ansible command
### 5. In uyuni dashboard, add worker node.
### 6. After you join additional masters, copy /etc/kubernetes/admin.conf to administrator's $HOME/.kube.
-----------------------
## how to remove uyuni-infra and uyuni-suite completely
### 1. helmfile --environment test -l type=app destroy
### 2. helmfile --environment test -l type=base destroy
### 3. delete every pvcs, pvs and files, configmaps, secrets in nfs server
----------------------
## keycloak domain : http://???.???.???.???:30090
### default ID : Admin
### default PW : xiilabPassword3# or keycloak12345
----------------------
## 멀티 마스터환경에서 1대의 마스터 다운 시 조치
### 1. 시간이 지나면 디플로이먼트는 다른 노드에서 재생성됨
### 2. prometheus, alertmanager, keycloak, kafka 등이 statefulset에 속한 파드들만 강제 삭제. 
### 3. uyuni suite의 경우 core만 crashloop가 발생하므로 pvc는 삭제하지 않은 상태로 uyuni suite 전부 삭제 후 재배포
### 4. (선택) 다운된 마스터 노드가 복구 불가능한 경우, 해당 마스터를 클러스터에서 제외하고 OS 재설치 등의 작업을 거친 후에 같은 아이피로 클러스터에 합류
