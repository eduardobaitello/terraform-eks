# terraform-eks

**!! NOT FOR PRODUCTION USE !!**

This is just a challenge for the study of Terraform and EKS.

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

_Recommendation: Use [`asdf`](https://github.com/asdf-vm/asdf) and [`.tools-versions`](./.tools-versions) file for version control._

