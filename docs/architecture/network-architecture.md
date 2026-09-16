# Enterprise Network Architecture

## VPC

The lab uses a dedicated multi-AZ VPC in `us-east-1`.

| Component | CIDR | Availability Zone | Tier |
|---|---|---|---|
| VPC | 10.0.0.0/16 | Regional | Network boundary |
| Public subnet 1 | 10.0.1.0/24 | us-east-1a | Public |
| Public subnet 2 | 10.0.2.0/24 | us-east-1b | Public |
| Private subnet 1 | 10.0.11.0/24 | us-east-1a | Private |
| Private subnet 2 | 10.0.12.0/24 | us-east-1b | Private |

## Architecture

Public and private subnet tiers span two Availability Zones.

Public subnets provide the network tier for internet-facing infrastructure such as load balancers and NAT gateways.

Private subnets provide the network tier for application, compute, Kubernetes, and other workloads that should not receive direct internet exposure.

## Routing

Public subnet default routes will use an Internet Gateway.

Private subnet default routes will use controlled NAT egress.

Route tables and NAT infrastructure are implemented separately from the foundational VPC and subnet resources.

## DNS

VPC DNS support and DNS hostnames are enabled.

Route 53 and application DNS are implemented in a later networking phase.

## Security Boundaries

Workloads are placed in private subnets by default.

Internet-facing resources are placed in public subnets only when required.

Security groups provide workload-level traffic controls.

Network ACLs provide subnet-level controls where justified.

## Growth

The `/16` VPC provides address space for additional application, Kubernetes, database, endpoint, and infrastructure subnet tiers without changing the initial four-subnet topology.
