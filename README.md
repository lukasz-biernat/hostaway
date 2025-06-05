Prerequisites
- Linux machine (can be VM)
- kubectl command-line tool
- terraform tool
- helm tool

###
Setup instructions
1. Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

2. Start minikube
minikube start

(Verify minikube status using commands: minikube status ;;; kubectl get nodes)

3. Install argocd using helm:

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update
kubectl create namespace argocd
helm install argocd argo-cd/argo-cd --namespace argocd --version 8.0.14

###
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

###
Defined monitors and thresholds (for k8s cluster in general - in case of minukube some of these metrics do not make too much sense)

1. Container Metrics: CPU, memory, network usage of individual containers (it helps to identify bottlenecks and ensure efficient resource allocation)
alert above cpu and memory usage over 70%, observe network usage and alert if it reaches the maximum throughput (depending on available network throughput)

2. Pod Metrics: Track status of pods (Ready, Running, Failed), restart counts, and overall resource utilization within pods
alert if monitored pods are not in Running state or if restart count is not acceptable (it depends on what we accept - in general pods should not restart, but depending on cluster setup they may do so, sometimes application can cause restart as well)

3. Service Metrics: Monitor request rates, response times, and error rates for individual services to determine application performance and identify potential problems
observe request rates, alert when response time is not acceptable, for example above 2s, alert also when error rate is above for example 1 per hour (it depends on a traffic and on an application itself)

4. Deployment Metrics: Monitor the status of deployments, including desired vs. actual number of pods, to ensure successful deployments and scaling
alert when when actual number of pods is not equal to desired one

5. Cluster Metrics: Monitor overall cluster resource utilization, node health, and the number of running pods to ensure the cluster is operating effectively
alert when some node is not in a healthy state, alert when cpu or memory utilisation of nodes is above 70%

(6. Log Collection and Analysis: Centralize (ELK or Opensearch) and analyze logs from various components (containers, pods, nodes) to troubleshoot issues and gain insights into application behavior)
