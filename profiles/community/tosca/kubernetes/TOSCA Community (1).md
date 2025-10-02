## Quick recap

The team discussed the development of a TOSCA profile for Kubernetes, including updates on TOSCA version support and plans to create profiles using example scenarios. They explored service meshes, particularly Istio, and their potential integration with Kubernetes environments, discussing how TOSCA could potentially automate service mesh configurations. The team also examined ways to model microservices in Kubernetes using TOSCA, considering different approaches to represent relationships and capabilities while acknowledging the challenges of translating Kubernetes resources to TOSCA types.
## Next steps

- [Chris to share the mermaid diagrams of Kubernetes abstractions with the team by moving them to the repository.](https://us02tasks.zoom.us?meetingId=ICIjRTGSTOmP4Ifh0R2LyA%3D%3D&stepId=3c11b6a8-995e-11f0-9d76-56503a5ae7df)
- [Chris to resend the email about the OpenAPI translator tool for converting Kubernetes resources to TOSCA types.](https://us02tasks.zoom.us?meetingId=ICIjRTGSTOmP4Ifh0R2LyA%3D%3D&stepId=3c11bb94-995e-11f0-9d76-56503a5ae7df)
- [Team to start modeling the Google microservices demo with appropriate relationships in TOSCA.](https://us02tasks.zoom.us?meetingId=ICIjRTGSTOmP4Ifh0R2LyA%3D%3D&stepId=3c11be50-995e-11f0-9d76-56503a5ae7df)
- [Team to study the Kubernetes manifests of the example applications .](https://us02tasks.zoom.us?meetingId=ICIjRTGSTOmP4Ifh0R2LyA%3D%3D&stepId=3c11c09e-995e-11f0-9d76-56503a5ae7df)
- [Team to explore how to model service mesh relationships in TOSCA.](https://us02tasks.zoom.us?meetingId=ICIjRTGSTOmP4Ifh0R2LyA%3D%3D&stepId=3c11c2ba-995e-11f0-9d76-56503a5ae7df)
## Summary

### TOSCA Profile for Kubernetes Development

The team discussed the development of a TOSCA profile for Kubernetes, with Tal updating on a pull request that added TOSCA 2.0 support to the previous generation of Puccini, making it the only parser supporting all TOSCA versions back to 1.0. They noted that Dario, who contributed the TOSCA 2.0 support, is using it for his dissertation as part of a larger university project focused on an orchestrator. The team planned to start creating the profile by examining example scenarios, such as a microservices demo for Google Kubernetes, and agreed to bring Angelo or Domenico up to speed if they arrived late to the meeting.
### Service Mesh Integration in Kubernetes

The team discussed service meshes, particularly Istio, and their potential use in Kubernetes environments. Tal explained that service meshes could be added to any microservices-based application and highlighted their ability to model complex network topologies. Chris and Marcel examined some microservices demos, noting that while they provided complete examples, they didn't fully utilize advanced Kubernetes features. The group agreed that TOSCA could potentially derive service mesh configurations from application topologies, offering a more automated approach than traditional Kubernetes manifests.
### Service Mesh Modeling with TOSCA

The team discussed the challenges of modeling service mesh connections in Kubernetes and the potential benefits of using TOSCA for automatic service mesh creation. Tal explained that while KRM only shows DNS names and connections, TOSCA could model higher-level application relationships and validate dependencies. Marcel noted that some connection information can be inferred from environment variables, though this is not always reliable. The group agreed to start by recreating KRM configurations in TOSCA before exploring more advanced features like automatic service mesh generation.
### TOSCA Microservices Modeling in Kubernetes

The team discussed modeling microservices in Kubernetes using TOSCA, focusing on how to represent relationships and capabilities. Tal suggested modeling microservices as node types with embedded capabilities, while Chris proposed a more granular approach using separate node and capability types. They agreed to start with a simple microservices example as a sanity check before tackling more complex scenarios. The group also touched on the challenges of translating Kubernetes resources to TOSCA types and the need for a TOSCA parser to convert profiles into Kubernetes manifests.
