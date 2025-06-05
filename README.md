Prerequisites
- Linux machine (can be VM)
- kubectl command-line tool
- terraform tool
- helm tool

Setup instructions
1. Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

2. Start minikube
minikube start

3. Verify minikube status
minikube status
kubectl get nodes

4. Install argocd using helm:

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo-cd/argo-cd --namespace argocd --version 8.0.14

ArgoCD usage
The easiest way to connect to argoCD is to use port-forwarding:
kubectl port-forward svc/argocd-server -n argocd 8443:443
(password can be found using command: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d )

There are two applications defined and theis manifests are attached to this repository: nginx-stg.yaml and nginx-prod.yaml
Those two applications can be installed or updated using:
kubectl apply -f nginx-stg.yaml
kubectl apply -f nginx-prod.yaml

On each commit to this repo github actions pipeline is triggered and based on branch it updates values file for staging or production (staging branch is for staging and master is for productsion)
First do the deployment on staging - update staging branch, than if everything works fine merge changes to master, which should trigger production deployment.

If you want to do a rollback just update image tag in values file and commit changes with "[skip ci]" or "[ci skip]" keywords in commit message.

It is also possible to change docker image tag directly in Argocd application and promote application this way between staging and production.
In such a situation you should click on an application you want to update, then click on deployment and use EDIT button. You can change image tag there.
However currently in application manifests it is set to autosync configuration with github repository so you should disable it first in application definition
and apply changes.
