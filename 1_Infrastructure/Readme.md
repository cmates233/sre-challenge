## Part 1 - Infrastructure

### Assumptions
- No strict SLAs have been indicated. Based on the given instructions, I'm assuming a **99.999%** of availability is required.
- Given that the maximum coverage of a GKE cluster is regional, 2 clusters will be used to fulfill the multi-region failover architecture.
- GCP Architectural Good Practices will be followed up to the maximum extent applicable.
- Security at it's core, without creating a lot of mess. (More on this on Part 3)


### Diagram

> -- TODO --

### Architecture reasoning:

Since there has been a requirement of implementing a multi-region failover, I believe this is best exercises by having a primary cluster (which we'll call primary-cluster) and a backup one, which is expected to be "warm" (this is, with a small node pool and the replicas for every deployment set to 0). This way, we can return to normal operations in a couple of minutes.

The clusters will be of "regional" kind, located within 3 zones. I've chosen europe-southwest1 as the main zone since I believe it's best for this company, as the main userbase is in spain. The backup one wouldn't make sense to reside in the same location, and as such I've chosen europe-west3, which is in Germany, within EU and compliant with data residency guidelines.

The golang application will be deployed through the pipeline, and will run within the 3 zones. A service of "LoadBalancer" kind will be applied in front of the application, to:

1. Manage the incoming connections and distribute the load evenly within the pods, and
2. Ensure that we have a single IP to access.

This will be applied in both clusters, and we'll make use of split DNS zones, which, using a healthcheck pointing to the primary cluster load balancer's, we'll decide whether to point traffic to the backup or not.

Regarding the cluster's configuration, although this will be explained further in section 3, I've configured the cluster to be private to reduce the attack's surface, which means that the nodes will not have an external IP nor internet connectivity. For the sake of simplicity and not knowing the allowed IP ranges, I've left intentionally public the access to the control plane, and a NAT gateway will ensure that the images can be reached, although the use of PGA would be advised.

In regards with the monitoring stack, I'll use grafana + prometheus, both installed directly with helm + terraform. I've reconfigured the repos to be able to access them without internet through a proxy repo in Artifact Registry, plus, enabling  vulnerability scanning, which adds another layer of security to the supply chain, specially for externally-sourced packages.

In regards of the kind of GKE cluster selected, I've chosen the standard type, as it allows a faster scale up on both the primary and the backup cluster, although, should it be cost-prohibitive, an autopilot cluster on the backup side would save some budget when scaled to 0, since it's pay per resources consumed.

### Autoscaling
The application, as is, is a very simple hello world application. If we were to autoscale based on metrics that are not CPU usage, I'd recommend one of the following ways:

- Analyze traffic / requests to see if they're a feasible metric: We could have an application that calculates 100M digits of pi. The traffic would be small, CPU usage would be extreme.
- If we want to autoscale based on external events (like, amount of unacked messages in a PubSub topic), then we would have to use [KEDA](https://keda.sh/).

As of now and in order to complete this task, I'd suggest scaling based on requests and/or active connections using the built-in HPA, which supports [custom metrics](https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/autoscaling-metrics).


### Useful links
- https://cloud.google.com/blog/products/containers-kubernetes/empower-your-teams-with-self-service-kubernetes-using-gke-fleets-and-argo-cd
- https://argo-cd.readthedocs.io/en/stable/#quick-start
- https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/autoscaling-metrics
- https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/modern-cicd-gke-user-guide#designing_modern_ci_cd_with_gke 
