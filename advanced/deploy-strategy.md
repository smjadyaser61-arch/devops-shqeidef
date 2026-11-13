
# ShipFast Deployment Strategy

## 1. Deployment Strategy Comparison

| Strategy | Traffic Movement | Rollback Speed | Extra Infrastructure Cost | Blast Radius | Operational Effort |
|---|---|---|---|---|---|
| Recreate | Stop old instances, then start new ones | Slow; requires restarting the old version | Low | High; all users affected | Low |
| Rolling | Gradually replace old replicas with new ones | Moderate; requires reverting the rollout | Low | Medium; some users may reach faulty replicas | Low–Medium |
| Blue-Green | Switch traffic between two complete environments | Fast; switch traffic back | High; requires duplicate capacity | High after full switch | Medium |
| Canary | Gradually increase traffic to a new version | Fast; route traffic back to the stable version | Medium | Low initially; limited users exposed | High |

## 2. ShipFast Application Facts

ShipFast is a Node.js application with /health and /metrics endpoints.
In Week 6, the application will run with two replicas.
ArgoCD is planned for Week 7, and Prometheus metrics for Week 9.
The application has no database, simplifying deployment and rollback.

## 3. Recommended Strategy

For ShipFast today, I recommend Rolling Deployment.

Rolling deployment allows us to update the application gradually
without requiring a complete duplicate environment. With two replicas,
one replica can be updated while the other continues serving traffic.

The main advantage is low infrastructure cost and relatively simple
operation. The trade-off is that some users may temporarily receive
traffic from a faulty version during the rollout.

If ShipFast usage increases tenfold, I would move toward Canary
Deployment.

Canary deployment allows a small percentage of users to receive the
new version first. We can monitor errors and performance before
increasing traffic to the new release.

The downside is greater operational complexity and the need for
reliable monitoring and traffic management.

## 4. Main Risk and Detection

The biggest risk of Rolling Deployment is allowing a faulty new
version to receive production traffic during the rollout.

We can detect this by monitoring application health checks,
HTTP error rates, and response times.

If health checks fail or error rates increase, we should stop
the rollout and restore the previously working image.

## 5. Deployment Principles

We should build the Docker image once and promote the same
immutable image through environments.

CI should remain responsible for building and testing.
Deployment tools such as ArgoCD should manage Kubernetes
deployments without storing cluster credentials in the CI pipeline.
