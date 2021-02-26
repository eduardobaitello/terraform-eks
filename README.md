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
- `kubernetes.tf` includes kubernetes module to create `kubernetes_config_map.aws_auth`
- `metrics-server.tf` deploy metrics-server on EKS cluster.
