# AWS IAM Setup for the Ubicity Orchestrator

This guide creates a dedicated IAM user for the Ubicity Orchestrator with
permissions to manage VPCs, subnets, security groups, Elastic IPs, EKS
clusters, and supporting resources.

## 1. Create the IAM User

1. Sign in to the AWS Console as the **root user** (or an admin)
2. Go to **IAM > Users > Create user**
3. Enter a user name (e.g., `ubicity-orchestrator`)
4. Do **not** enable console access — this user only needs programmatic access
5. Click **Next**

## 2. Attach Permissions

On the **Set permissions** page, select **Attach policies directly** and
attach the following AWS managed policies:

| Policy | Purpose |
|--------|---------|
| **AmazonEC2FullAccess** | Manage EC2 resources — key pairs (ImportKeyPair, CreateKeyPair), instances, AMIs, volumes, snapshots, plus VPCs, subnets, route tables, internet gateways, security groups, Elastic IPs, and network interfaces |
| **AmazonSSMReadOnlyAccess** | Look up public AMI IDs via AWS Systems Manager Parameter Store (e.g. `/aws/service/canonical/ubuntu/...`) |
| **IAMFullAccess** | Pass IAM roles to EKS (cluster role and node role), create service-linked roles, and manage access entries |

> **Note:** The `AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`,
> `AmazonEKS_CNI_Policy`, and `AmazonEC2ContainerRegistryReadOnly`
> policies are intended to be attached to the EKS *IAM roles* (see
> Section 5), not to the Orchestrator's user account.
> `AmazonVPCFullAccess` is a strict subset of `AmazonEC2FullAccess`
> and is therefore also not needed here.

Click **Next**, then **Create user**.

## 3. Create Access Keys

1. Click into the newly created user (`ubicity-orchestrator`)
2. Go to the **Security credentials** tab
3. Under **Access keys**, click **Create access key**
4. Select **Command Line Interface (CLI)** as the use case
5. Click **Next**, then **Create access key**
6. **Save the Access Key ID and Secret Access Key** — you will not be
   able to view the secret again

## 4. Configure the AWS Credentials File

Create (or update) the credentials file in `~/vault`:

```
mkdir -p ~/vault

cat > ~/vault/aws-credentials <<EOF
[ubicity]
aws_access_key_id = <your-access-key-id>
aws_secret_access_key = <your-secret-access-key>
EOF

chmod 600 ~/vault/aws-credentials
```

## 5. Create the EKS IAM Roles

EKS requires two IAM roles that the Orchestrator passes to the service.
These are created once and reused across clusters.

### 5a. EKS Cluster Role

1. Go to **IAM > Roles > Create role**
2. **Trusted entity type**: select **AWS service**
3. **Use case**: select **EKS**, then choose **EKS - Cluster**
4. Click **Next** — the `AmazonEKSClusterPolicy` is automatically attached
5. Name the role (e.g., `eksClusterRole`)
6. Click **Create role**
7. Note the **ARN** shown on the role details page
   (e.g., `arn:aws:iam::123456789012:role/eksClusterRole`)

### 5b. EKS Node Role

1. Go to **IAM > Roles > Create role**
2. **Trusted entity type**: select **AWS service**
3. **Use case**: select **EC2**
4. Click **Next**
5. Attach the following three policies:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEC2ContainerRegistryReadOnly`
6. Name the role (e.g., `eksNodeRole`)
7. Click **Create role**
8. Note the **ARN** shown on the role details page
   (e.g., `arn:aws:iam::123456789012:role/eksNodeRole`)

## 6. Add an EKS Inline Policy

AWS does not provide a managed `AmazonEKSFullAccess` policy, so the
Orchestrator needs an inline policy granting `eks:*` to create,
describe, and delete clusters and node groups:

1. Go to **IAM > Users > ubicity-orchestrator**
2. Click **Add permissions > Create inline policy**
3. Switch to **JSON** and enter:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "eks:*",
    "Resource": "*"
  }]
}
```

4. Name it (e.g., `EKSFullAccess`) and save

> **Note:** This is separate from Kubernetes RBAC. The IAM user that
> creates an EKS cluster automatically receives `system:masters`
> Kubernetes access. To grant other IAM users/roles access to the
> Kubernetes API, use [EKS access
> entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html).

## 7. Configure the Orchestrator

In your TOSCA service template, reference the credentials file and
profile, along with the role ARNs:

```yaml
account:
  type: Account
  properties:
    name: my-aws-account
    credentials_file: ~/vault/aws-credentials
    profile: ubicity

eks_cluster:
  type: Eks
  properties:
    name: my-cluster
    number_of_workers: 2
    cluster_role_arn: arn:aws:iam::123456789012:role/eksClusterRole
    node_role_arn: arn:aws:iam::123456789012:role/eksNodeRole
```

## 8. Clean Up the Old IAM User (Optional)

If you previously used a personal IAM user (e.g., `lauwers`) with the
Orchestrator:

1. Go to **IAM > Users > lauwers**
2. Remove any Orchestrator-specific inline policies you added
   (`PassRole`, `EksPassRole`, etc.)
3. Detach any managed policies that were added for the Orchestrator
