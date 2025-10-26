## How to protect the Louvre

### Intro

Now that we have our stack built in and working, it would be interesting to have it secured. In section 1, I specified that the GKE nodes would be private, for a reason of exposure. I'll go through the relevant components discussing how would I introduce security layers where applicable, with the objective of having Zero trust implemented.

### The network

In order to secure the network, I'd suggest:

- Enabling [Private Google Access](https://docs.cloud.google.com/vpc/docs/private-google-access). Access to Google's APIs should not need to leave GCP (which, in turn, reduces egress costs).
- If desired, ensure that the VPC's traffic is either analyzed (with a special VM and [Packet Mirroring](https://cloud.google.com/vpc/docs/packet-mirroring) or filtered (through routing the outgoing traffic with it, like with a [Fortinet](https://cloud.google.com/fortinet?hl=en) multiNIC VM)).

### The cluster
In order to protect the cluster, I'd suggest the following actions:

- [Remove the clusters' public endpoints](https://cloud.google.com/kubernetes-engine/docs/how-to/latest/network-isolation): Having our GKE clusters' endpoints publicly available, without restriction, is a bad idea. The management API should only be accessible from inside the network, and even then, from certain parts of the network.
- Set an authorized network which is reserved for the Infra team, and use a bastion host to perform management actions.
- Use private nodes, as this will reduce the exposure by removing external IPs.
- Use [Workload Identity](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/workload-identity): This way, direct access to the metadata server will be disabled, and applications will need to be identified before being granted an auth token.
- If the applications will run untrusted code (like a PHP Code checker app), [GKE Sandbox](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/sandbox-pods) should be enabled to ensure nobody can escape the box.

### The workloads

- In order to protect the workloads (and us!), it would be interesting to ensure that only images that have been produced following a certain process can run. In order to do so, we have [Binary Authorization](https://docs.cloud.google.com/binary-authorization/docs/overview). This comes with multiple steps:
  - **[Attestation](https://docs.cloud.google.com/binary-authorization/docs/attestations)**: We create and configure attestors, which are signatures that certify that an action has been done in the image (for example, built in a certain way). We let the GKE clusters know which Attestors should be accepted, and images will not run without a proper (or multiple) attestation/s.
  - **[Continuous validation](https://docs.cloud.google.com/binary-authorization/docs/overview-cv)**: Everything can change, and an image that was previously was deemed suitable isn't anymore. For this reason, we should configure a CV policy with the adequate parameters to ensure that only images that keep being trusted are running in our cluster.

### The pods

In general terms, a pod should do whatever is required of it: live, and execute the containers that are needed. To ensure that we don't have unwanted risks, permissions on what they can do should be at the minimal level. Using [Pod Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) we achieve that. 

A sample would be:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-go-app
  labels:
    # Enforce the most restrictive "restricted" policy
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest


apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-go-app
  namespace: my-go-app
  labels:
    app: my-go-app
spec:
  ...      
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      fsGroup: 1000
      seccompProfile:
          type: RuntimeDefault
          readOnlyRootFilesystem: true
          capabilities:
          drop:
          - ALL
```

Additionally, we can further reduce the surface with [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) (by restricting any traffic that should not be expected).

Sample:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-go-app-netpol
  namespace: my-go-app
spec:
  podSelector:
    matchLabels:
      app: my-go-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
  egress:
  - ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
```

### The applications

For the externally available applications (like the go app), it would be needed some sort of protection, like a WAF. In GCP, the WAF of excellence is [Cloud Armor](https://cloud.google.com/armor/docs/security-policy-overview), which acts as an all-in-one protection mechanism for webapps.

Depending on the Cloud Armor tier we are going to apply (assuming the Enterprise one) we'll have access to different protections, but I'd go for:

- Enabling DDoS protection + rate limiting. An user accessing our website 10 times per second seems too much.
- By default, enabling [pre-configured WAF rules](https://cloud.google.com/armor/docs/waf-rules) is a good choice.
- Enable [bot management](https://cloud.google.com/armor/docs/bot-management) with Re-captcha to avoid being spammed by bot farms.
- Apply blocks to known threads (through [Threats intelligence](https://cloud.google.com/armor/docs/threat-intelligence)). As much as we love onions, using tor nodes makes the activity suspicious (among other threats)

Additionally, we could make use of [IAP](https://cloud.google.com/iap/docs/managing-access) to:
- Securely access our bastion hosts (among any other compute resource), and
- Protect certain web-apps that should only be accessed by certain individuals (like a tool for a particular team). 

Used in conjunction with [Chrome Enterprise](https://docs.cloud.google.com/chrome-enterprise-premium/docs/security-gateway-private-web-apps) and [Access Context Manager](https://cloud.google.com/access-context-manager/docs/overview), we can allow access conditioned to fulfillment of pre-requisites, like connecting from a certain IP range, being of a particular OU, or having the computer up to date.


### The project / organization

Among other security features, it would be interesting to have:

- [Security Command Center](https://cloud.google.com/security-command-center/docs/how-to-use-security-command-center): Detects other kind of threads, and also can simulate attack paths.
- [VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/overview): Prevents data exfiltration by ensuring that only allowed projects and identities can execute certain actions (think of a firewall, but for Google APIs).

### The logs
I wanted to leave this part for the end since it is not only the most transversal part (everything generate logs), but the key piece of knowledge.

GCP automatically generates audit logs for certain administrative actions, and more can be configured with [Data access logs](https://docs.cloud.google.com/logging/docs/audit/configure-data-access). What's more interesting is what do we do with them. 

- We could create [log-based metrics](https://docs.cloud.google.com/logging/docs/logs-based-metrics) based on certain filters, and create alerting policies that trigger if the metrics show any value (for example, a new service account key has been generated). With this, not only we have the records that something happens, we also make people aware of it.
- We could ingest the audit logs in a SIEM like Chronicle (now called [Google Security Operations SIEM](https://cloud.google.com/chronicle/docs/overview)) in order to make a more detailed analysis.

### The secrets
Last, but not least, we have to talk about where to store the secrets, and an excel file is not a valid choice.

There are 2 relevant products that I'd like to highlight:

- For generic secrets (user and password, tokens...): [Secret Manager](https://cloud.google.com/secret-manager/docs/overview). It allows to rotate them, manage IAM per secret, and everything we could expect from a secret manager.
- For keys: [KMS](https://docs.cloud.google.com/kms/docs/key-management-service) / [EKM](https://cloud.google.com/kms/docs/ekm). Keys in KMS are kept by the KMS service itself and never released, which allows certain grade of confidence on the security it provides. This is also useful if the company uses CMEK to protect their data, instead of relying on GMEK keys.