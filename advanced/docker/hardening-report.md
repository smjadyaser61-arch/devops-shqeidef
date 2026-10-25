# Image hardening report

Date of scans: 2026-10-25
Tool versions: Trivy [YOUR VERSION], Syft [YOUR VERSION], Cosign v3.1.4

## Comparison

| Measurement | Alpine (Milestone 2) | Distroless |
| --- | --- | --- |
| Image size | 172 MB | 149 MB |
| Packages listed by Syft | 302 | 80 |
| CRITICAL findings (Trivy) | 5 | 1 |
| HIGH findings (Trivy) | 58 | 7 |
| Shell available | Yes | No |
| HEALTHCHECK possible | Yes (wget-based) | No (existing wget-based check) |

## What the numbers show

The Distroless image is 23 MB smaller and contains 80 packages compared with 302 in the Alpine image. Trivy identified 63 HIGH/CRITICAL vulnerabilities in Alpine and 8 in Distroless, indicating a reduction in known security findings. The images also contain different runtime package versions, so the difference is not necessarily caused only by removing unnecessary tools.

## Trade-off

Distroless reduces the number of unnecessary tools and packages but removes the shell and package manager, making interactive debugging more difficult. If the container crashes, I would inspect the container using docker logs and docker inspect, then reproduce the problem using a development image containing debugging tools. The original wget-based HEALTHCHECK cannot run because wget is absent; a Node.js-based check would be possible, but was not added for this assignment.

## Signing

Image signed: ghcr.io/smjadyaser61-arch/shipfast-app@sha256:74c560f36f32a228e28f3898e13304cf3c4bc5e8937bbee143850522074e5953

Why a digest and not a tag: A digest identifies an exact image manifest, while a tag such as latest can be changed to reference another image.

Verify result: SUCCESS. Cosign validated the claims, verified the transparency log entry offline, and verified the signature against cosign.pub.
