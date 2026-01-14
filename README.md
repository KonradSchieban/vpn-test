# HA VPN Test Project

This project provisions a High Availability (HA) Cloud VPN connection between two Google Cloud Virtual Private Clouds (VPCs), `vpc-a` and `vpc-b`, within the same region. It uses Terraform to manage the infrastructure and the Cloud Foundation Fabric `net-vpn-ha` module for the VPN components.

## Architecture

The Terraform configuration deploys the following resources:

-   **VPC Networks**:
    -   `vpc-a` (Automatic subnet creation disabled)
    -   `vpc-b` (Automatic subnet creation disabled)
-   **Subnets**:
    -   `vpc-a-subnet`: Located in `vpc-a`.
    -   `vpc-b-subnet`: Located in `vpc-b`.
-   **HA VPN Gateways & Tunnels**:
    -   Establishes an HA VPN connection between `vpc-a` and `vpc-b`.
    -   Uses BGP for dynamic routing.
    -   Configures two tunnels per VPN gateway for high availability.
-   **Firewall Rules**:
    -   `allow-internal-a`: Allows all traffic from `vpc-b` subnet to `vpc-a`.
    -   `allow-internal-b`: Allows all traffic from `vpc-a` subnet to `vpc-b`.
    -   `allow-iap-a` / `allow-iap-b`: Allows SSH access via Identity-Aware Proxy (IAP) to instances with the `allow-iap` tag.

## Prerequisites

-   [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated.
-   [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.0) installed.
-   A Google Cloud Project with billing enabled.

## Usage

1.  **Clone the repository:**

    ```sh
    git clone <repository-url>
    cd vpn-test
    ```

2.  **Configure Variables:**

    Create a `terraform.tfvars` file or set environment variables to define the required inputs.
    
    ```hcl
    # terraform.tfvars
    project_id = "your-project-id"
    region     = "europe-west3" # Optional, defaults to europe-west3
    ```

3.  **Initialize Terraform:**

    ```sh
    terraform init
    ```

4.  **Plan the Deployment:**

    ```sh
    terraform plan
    ```

5.  **Apply the Configuration:**

    ```sh
    terraform apply
    ```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `project_id` | The GCP project ID to deploy resources in. | `string` | **Required** |
| `region` | The GCP region for resources. | `string` | `europe-west3` |
| `vpc_a_name` | Name for VPC A. | `string` | `vpc-a` |
| `vpc_b_name` | Name for VPC B. | `string` | `vpc-b` |
| `vpc_a_subnet_cidr` | CIDR range for VPC A subnet. | `string` | `10.0.0.0/24` |
| `vpc_b_subnet_cidr` | CIDR range for VPC B subnet. | `string` | `10.1.0.0/24` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_a_name` | The name of the created VPC A. |
| `vpc_b_name` | The name of the created VPC B. |

## Clean Up

To destroy the created resources and avoid further charges:

```sh
terraform destroy
```
