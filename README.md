# terraform-eks

**!! NOT FOR PRODUCTION USE !!**

This is just a challenge to study and practice EKS deployment using Terraform.

# Goals
- Create an EKS cluster using at least two Availability Zones for worker nodes
- Deploy a Prometheus instance running on EKS
- Deploy a network monitoring solution for Kubernetes
- Validate communication between nodes
- Extract node latency communication metrics from Prometheus

# Prerequisites
- Terraform v0.14.7
- [Configured AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) v1.19.8
- `wget` (required for the eks module)

_Recommendation: Use [`asdf`](https://github.com/asdf-vm/asdf) and [`.tools-versions`](.tools-versions) file for version control._

# Structure

- `vpc.tf` provisions a VPC, subnets and availability zones using the AWS VPC Module.
- `security-groups.tf` provisions the security groups used by the EKS cluster.
- `eks-cluster.tf` Use EKS module to provision all the resources required to set up the cluster.
- `outputs.tf` defines the output configuration.
- `versions.tf` sets the Terraform version to at least 0.14.
- `kubernetes.tf` includes kubernetes module to manage `kubernetes_config_map.aws_auth`
- `metrics-server.tf` deploy metrics-server on EKS cluster.
- `kube-prommetheus.tf` use Helm provider to deploy kube-prometheus-stack.
- `values-kube-prometheus.yaml` custom helm values for running kube-prometheus-stack on EKS.

# Inspecting the Cluster

After the `terraform apply`, the EKS should be available with two nodes and the monitoring stack deployed.

A kubeconfig file is generated by the EKS module after the install.  
The `KUBECONFIG` env var should be set to configure the `kubectl` CLI with the EKS context:

```
export KUBECONFIG=$(terraform output -raw kubectl_config)
```

Then, `kubectl` can be used to check that the nodes are _Ready_ and using two different zones:
```
# kubectl get nodes
NAME                         STATUS   ROLES    AGE    VERSION
ip-10-0-1-94.ec2.internal    Ready    <none>   10m   v1.19.6-eks-49a6c0
ip-10-0-2-204.ec2.internal   Ready    <none>   10m   v1.19.6-eks-49a6c0
```

The metrics-server is deployed on the `kube-system` namespace. The the kube-prometheu-stack release is deploy on the `monitoring` namespace:
```
$ kubectl get po --all-namespaces
NAMESPACE     NAME                                                     READY   STATUS    RESTARTS   AGE
kube-system   aws-node-2p7b4                                           1/1     Running   0          3h19m
kube-system   aws-node-kpqfc                                           1/1     Running   0          3h19m
kube-system   coredns-7d74b564bd-8r8l8                                 1/1     Running   0          3h23m
kube-system   coredns-7d74b564bd-t9kvr                                 1/1     Running   0          3h23m
kube-system   kube-proxy-5ms7q                                         1/1     Running   0          3h19m
kube-system   kube-proxy-q6hdc                                         1/1     Running   0          3h19m
kube-system   metrics-server-7cc47dc976-xdmsb                          1/1     Running   0          3h21m
monitoring    alertmanager-kube-prometheus-kube-prome-alertmanager-0   2/2     Running   0          3h17m
monitoring    kube-prometheus-grafana-5cd7cdd777-jf97t                 2/2     Running   0          3h18m
monitoring    kube-prometheus-kube-prome-operator-7c7cd8f485-h7fbg     1/1     Running   0          3h18m
monitoring    kube-prometheus-kube-state-metrics-5f575558c7-pd74r      1/1     Running   0          3h18m
monitoring    kube-prometheus-prometheus-node-exporter-lcrwb           1/1     Running   0          3h18m
monitoring    kube-prometheus-prometheus-node-exporter-z29hb           1/1     Running   0          3h18m
monitoring    prometheus-kube-prometheus-kube-prome-prometheus-0       2/2     Running   1          3h17m
```
# kube-prometheus-stack
The [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) chart was deployed using the Terraform Helm provider.

The [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) is a stack that is meant for cluster monitoring, so it is pre-configured to collect metrics from all Kubernetes components.

Components included in this package are:

* The [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
* [Prometheus](https://prometheus.io/)
* [Alertmanager](https://github.com/prometheus/alertmanager)
* [Prometheus node-exporter](https://github.com/prometheus/node_exporter)
* [Prometheus Adapter for Kubernetes Metrics APIs](https://github.com/DirectXMan12/k8s-prometheus-adapter)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
* [Grafana](https://grafana.com/)

In addition to that, the package delivers a default set of dashboards and alerting rules. Many of the useful dashboards and alerts come from the [kubernetes-mixin](https://github.com/kubernetes-monitoring/kubernetes-mixin) project.

Prometheus can be accessed with `kubectl port-forward`:

```
$ kubectl --namespace=monitoring port-forward svc/kube-prometheus-kube-prome-prometheus 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Then, go to http://localhost:9090/alerts/ :

![Prometheus Alerts](/img/prometheus_alerts.png)

All alerts are inactive (except the *Watchdog* alert, which is intended to be an "always firing" event).

The dashboards can be accessed by proxying on the Grafana deployment:
```
$ kubectl --namespace=monitoring port-forward deploy/kube-prometheus-grafana 3000:3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
```
Go to http://localhost:3000/ and login with the following default credentials:
```
admin
prom-operator
```
*Note: The [values-kube-prometheus.yaml](values-kube-prometheus.yaml) file can be used to change the [default password](https://github.com/prometheus-community/helm-charts/blob/b0ebaff7c3dc5e9038e0dc5a4931b8b7ba18fad2/charts/kube-prometheus-stack/values.yaml#L608) before installation.*

The default dashboards bundled with kube-prometheus already provides insightful data about the cluster compute resources, workload and network metrics.

## Examples:

**API Server Work Queue Latency and resources usage:**

![API Server Dashboard](/img/api_server_dashboard.png)

**Kubelet request duration and resources usage:**

![Kubelet Dashboard](/img/kubelet_dashboard.png)
