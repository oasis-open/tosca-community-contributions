## Quick recap

The team discussed the geographical concentration of TOSCA and telecommunication standards activity in Europe, comparing it to different approaches in the U.S. and Israel. They explored the value of TOSCA in Kubernetes environments, focusing on its ability to model service topologies and microservice interactions, while discussing various challenges in service assurance and control loops. The team examined different modeling approaches for Kubernetes applications using TOSCA, including substitution mapping, inheritance, and capability types, with plans to experiment with these methods in future meetings.
## Next steps

- [Chris to update the GitHub page with Tal's suggestions about ongoing validation and the relationship between infrastructure and workload for Kubernetes.](https://us02tasks.zoom.us?meetingId=8J52bcDGRyS94gah6F0aVQ%3D%3D&stepId=abdd4101-a45d-11f0-afdc-52cf3d65279e)
- [Chris to model the example using a substitution mapping approach by next week.](https://us02tasks.zoom.us?meetingId=8J52bcDGRyS94gah6F0aVQ%3D%3D&stepId=abdd4777-a45d-11f0-a7cd-52cf3d65279e)
- [Chris to reach out to Jay at University of Westminster to invite him to participate in future meetings.](https://us02tasks.zoom.us?meetingId=8J52bcDGRyS94gah6F0aVQ%3D%3D&stepId=abdd4a7d-a45d-11f0-b6f3-52cf3d65279e)
- [Chris to reach out to the Stuttgart team to invite them to participate on a regular basis.](https://us02tasks.zoom.us?meetingId=8J52bcDGRyS94gah6F0aVQ%3D%3D&stepId=abdd4d16-a45d-11f0-a6b7-52cf3d65279e)
- [Chris to keep the notes up to date on the GitHub page.](https://us02tasks.zoom.us?meetingId=8J52bcDGRyS94gah6F0aVQ%3D%3D&stepId=abdd4f85-a45d-11f0-8537-52cf3d65279e)
## Summary

### European Standards Concentration in Telecom

Chris and Tal discussed the geographical concentration of TOSCA and telecommunication standards activity in Europe, attributing it to factors like the presence of companies like Nokia and Ericsson, academic research funding, and a cultural emphasis on standards. Chris noted a contrast with the U.S., where there's often a preference for implementing solutions without strict adherence to standards. Tal mentioned that Israeli startups, known for their fast-paced approach, might even exceed American pragmatism in prioritizing action over adherence to standards. Chris mentioned a potential participant, Jay from the University of Westminster, who is currently busy with teaching but hopes to join the discussion in the coming weeks.
### Tosca in Kubernetes: Benefits Overview

The team discussed the value of Tosca in Kubernetes environments, focusing on its ability to model service topologies and microservice interactions. Chris outlined several benefits, including visualization of complex applications, design-time validation, automatic microservice configuration, service mesh integration, network policy management, and dependency management in deployments. He invited team members to review and contribute to the GitHub page containing these points for further refinement.
### TOSCA for Kubernetes Deployment Simplification

Tal and Chris discussed the role of TOSCA in design-time and Day 2 validation, emphasizing that TOSCA policies apply not only at deployment but also during ongoing operations. They explored the potential of TOSCA to streamline Kubernetes deployments by enabling a unified language for infrastructure and workload management, which could simplify the deployment process and ensure proper interaction between infrastructure and workloads. Chris agreed to update the documentation and sought feedback on edits, while Tal highlighted the importance of managing the relationship between infrastructure and workloads to enhance deployment efficiency.
### Service Modeling and Control Challenges

The team discussed challenges in service assurance and control loops, particularly when dealing with unreliable software and hardware. They explored the potential of using Tosca to design services, focusing on extracting biology information from manifests and representing it using Tosca nodes and relationships. The main question addressed was whether to model microservices directly or align with Kubernetes resources, with Chris suggesting they need to determine the starting point and level of alignment with Kubernetes concepts.
### Microservices Modeling and Interaction Views

Angelo and Chris discussed modeling microservices and their interactions. They explored the possibility of creating abstract views that focus on topology, independent of specific implementations like service meshes or monitoring systems. Angelo suggested defining multiple views for different perspectives, such as device or admin views. Chris agreed and proposed using substitution mapping to model the internal details of microservices, decomposing them into Kubernetes resources. They discussed the benefits of abstracting away non-essential details to maintain a clear focus on microservice interactions.
### TOSCA Orchestration Design Strategy

The team discussed the design of an orchestrator and the balance between high-level abstractions and low-level building blocks in TOSCA. Tal suggested that they could create both types of definitions, allowing users to choose between top-down and bottom-up approaches. He emphasized the importance of maintaining the ability to express low-level Kubernetes types, as losing this functionality could create obstacles. The team agreed that users might need both approaches, depending on their workflow and company requirements.
### Top-Down Microservices Development Challenges

Tal and Chris discussed the challenges and benefits of using a top-down approach in software development, particularly in the context of microservices and Kubernetes. Tal emphasized the importance of seeing both high-level and low-level components simultaneously, while Chris suggested that substitution mapping could be a useful approach for standardizing service deployments. They agreed that tooling support would be necessary to effectively manage substitution mapping and other complex development processes.
### TOSCA Node Types for Service Deployment

Tal proposed using TOSCA node types with capability types for service deployment, suggesting a simple service node type with default configurations that could be inherited and modified for specific needs. He emphasized the elegance and straightforwardness of the capability-based approach, while noting some limitations with substitution mapping in TOSCA 1.3, though improvements might be available in later versions. Tal expressed interest in experimenting with different approaches to identify trade-offs and gather insights that could inform future TOSCA versions, such as TOSCA 2.1 or 3.
### Hybrid Modeling Approaches Discussion

The team discussed the merits of substitution mapping and inheritance approaches for modeling systems. Chris shared his experience using a hybrid approach that combines substitution mapping and inheritance based on John Strassner's policy continuum concept, which defines multiple levels of abstraction from business view to instance model. They agreed to experiment with both approaches without dismissing them prematurely, while Chris also noted his success with using substitution for translating functional architectures to specific technologies and inheritance for vendor implementations.
### Kubernetes TOSCA Modeling Approaches

The team discussed different approaches to modeling Kubernetes applications using TOSCA, with Chris proposing to explore both substitution and parameterization methods. Tal shared an example of using capability types in TOSCA, highlighting the hierarchical nature of both node and capability types. The group agreed to experiment with different modeling approaches, with Chris and Tal planning to make progress on their respective methods before the next meeting. They also discussed the importance of relationship types in TOSCA modeling, with Chris suggesting that exploring needed relationship types would be a valuable area for further investigation.
