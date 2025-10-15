## Quick recap

The meeting focused on updates and discussions related to the TOSCA specification, its adoption, and community contributions, including recent developments and ongoing projects. The team explored various approaches for modeling microservices in TOSCA, particularly for Kubernetes deployments, discussing different methods and their potential advantages and challenges. They also addressed the management of cluster-wide resources and service modeling in TOSCA, emphasizing the need for flexible modeling approaches and further investigation of specific implementation details.
## Next steps

- [Chris to document approaches for managing cluster-wide resources that need to be accessed by Kubernetes services consisting of microservices.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d7958f-a9dd-11f0-acb8-fafb23a18df5)
- [Chris to continue developing real TOSCA definitions based on high-level type definitions for microservices and Kubernetes resources.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d79e42-a9dd-11f0-a327-fafb23a18df5)
- [Chris to contact Tal to discuss progress on the capability approach for Kubernetes modeling.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d7a1fe-a9dd-11f0-937f-fafb23a18df5)
- [Chris to explore Roberto's idea of using different technologies  to deploy the same application.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d7a555-a9dd-11f0-ba38-fafb23a18df5)
- [Chris to ensure Tal is available for next week's meeting to discuss his approach.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d7a843-a9dd-11f0-acd5-fafb23a18df5)
- [All participants to review and provide comments on the "arguments for why TOSCA" document.](https://us02tasks.zoom.us?meetingId=mrg3cuIqT2aaIN4%2BN0dAAg%3D%3D&stepId=62d7ab1c-a9dd-11f0-895c-fafb23a18df5)
## Summary

### TOSCA Specification and Community Updates

The meeting focused on updates and discussions related to the TOSCA specification, its adoption, and community contributions. Chris provided an overview of recent developments, including the completion of TOSCA version 2 and the decision to prioritize adoption activities over new functionality. The group discussed efforts to define TOSCA type definitions organized in profiles for Kubernetes deployments, with contributions from various community members. Jay and Prachi from the University of Westminster shared their project, "Swarmchestrate," which aims to orchestrate across cloud, edge, and fog environments using TOSCA and Kubernetes. Participants also mentioned ongoing work by Marcel and Roberto, highlighting the interconnected nature of these projects and their alignment with broader TOSCA initiatives.
### Kubernetes Deployment Modeling with Tosca

The team discussed the use of Tosca for Kubernetes deployments, focusing on defining type definitions that support microservices topology and Kubernetes-specific concepts. They are working to balance the needs of service designers and Kubernetes experts by incorporating both topology modeling and direct Kubernetes resource specification. The team is using examples like the Online Boutique application to test and refine their approach, with plans to review additional examples like VetStar Bench in future discussions.
### Exploring TOSCA Microservices Modeling Approaches

The team discussed two approaches for modeling microservices in TOSCA: using substitution mapping to decompose abstract service templates into Kubernetes abstractions, or using TEL's method where high-level node types group capabilities representing Kubernetes resources. Roberto highlighted that the first approach offers maximum flexibility for deployment across different technologies like Nomad, Docker Compose, and serverless, while Chris noted that TOSCA might be superior for modeling high-level functional architecture due to its ability to support various deployment mechanisms. The team agreed to explore both approaches using different examples to identify potential issues or advantages, with Chris working on fleshing out the substitution mapping approach and Tal tasked with working through the capability types example.
### Kubernetes Resource Template Development

Chris explained the development of a substituting template for Kubernetes resources, which aligns with a consistent pattern across microservices. He detailed the use of cluster IP resources, deployments, and service accounts, and discussed the potential for modeling these using Tosca-like abstractions. Marcel inquired about modeling shared cluster-wide resources, and Chris suggested using a "create if not exist" pattern in Tosca to handle shared resources like cluster roles.
### Tosca Directives and Kubernetes Modeling

Chris explained the functionality of directives in Tosca, discussing how to select, create, or substitute nodes based on existing templates. He emphasized the importance of resolving these scenarios in the context of their discussions, as they are common in modeling. Marcel suggested modeling the Kubernetes cluster itself as a different type and substituting its resources, but Chris preferred to focus on the application level for now. They discussed the challenge of how applications can instruct Kubernetes clusters to add roles, an approach they should pursue but need further exploration.
### Microservices Resource Management Strategies

The team discussed approaches for managing cluster-wide resources in a microservices architecture, with Roberto suggesting a mapping system similar to a hosted-on relationship. Chris proposed two potential methods: a creative-not-exist approach and modifying a cluster service with service updates. Marcel noted that the user's modeling needs should influence the approach chosen. Chris agreed and mentioned that Tosca is unopinionated, allowing for flexible modeling of applications, infrastructure, and everything in between.
### Kubernetes Service Modeling with Tosca

The team discussed Kubernetes service modeling using Tosca, focusing on challenges with capability-based approaches and orchestration logic. Chris proposed exploring multi-technology deployment options, building on previous work by DesLauriers who demonstrated similar template-based implementations for Kubernetes and Docker. The group also discussed the need to improve Tosca's support for overlaying implementation details onto node types for specific platforms, with Chris planning to document these requirements and continue developing real Tosca examples for further investigation.
