## Quick recap

The team explored various approaches for modeling Kubernetes node types and capabilities using TOSCA, including substitution mapping, abstract node types, and inheritance features. They discussed the importance of TOSCA as a unifying tool while acknowledging that different domains may require different approaches, and agreed on the value of consistent design patterns across applications and platforms. The group examined practical examples of using TOSCA's features to create reusable profiles and demonstrated how to model Kubernetes capabilities, with Tal showcasing a Kubernetes profile generator that leverages the API for complex resource configurations.
## Next steps

- [Tal: Post a pointer to the examples or contribute them to the community repository](https://us02tasks.zoom.us?meetingId=QOxL0DegTMC%2BJOhO8lbygw%3D%3D&stepId=5c885243-b4e9-11f0-8113-4ec65935a09c)
- [Tal: Create a demo showing the deployment of the boutique example on a real running Kubernetes cluster](https://us02tasks.zoom.us?meetingId=QOxL0DegTMC%2BJOhO8lbygw%3D%3D&stepId=5c885a53-b4e9-11f0-91a0-4ec65935a09c)
- [Chris: Continue working on getting the online boutique example with substitution mapping fully working in the next couple days](https://us02tasks.zoom.us?meetingId=QOxL0DegTMC%2BJOhO8lbygw%3D%3D&stepId=5c885e3d-b4e9-11f0-848a-4ec65935a09c)
## Summary

### TOSCA Kubernetes Modeling Approaches

The team discussed approaches for modeling Kubernetes-related node types and capabilities using TOSCA, focusing on substitution mapping and abstract node types. Roberto presented a high-level approach using abstract platform and application node types, which Chris and Tal found interesting but noted might be too abstract for practical use. Tal emphasized the importance of TOSCA as a unifying tool, suggesting that different domains can use TOSCA in various ways that best suit their specific needs. The group agreed on the value of having consistent design patterns across different applications and platforms, while acknowledging that the best approach may vary depending on the domain and use case.
### TOSCA Profile Reusability Strategies

The team discussed leveraging TOSCA's substitution mapping and inheritance features to create reusable profiles at different levels of abstraction. Chris emphasized the importance of using substitution mapping to go from high-level abstractions to lower levels, while Tal suggested focusing on inheritance instead. They explored organizing profiles into abstract ones on the left, domain-specific ones on the right, and a common "core" profile in the middle to promote reusability. Chris shared an example of using substitution mapping in a microservices profile, demonstrating how it can create reusable building blocks.
### Kubernetes TOSCA Modeling Approach

Tal presented his approach to modeling Kubernetes capabilities in TOSCA, focusing on building blocks and node types. He emphasized the importance of labels in defining microservices and explained how he maps Kubernetes resources to capability types rather than node types. Tal also demonstrated how he can override default settings and assemble different components to create custom topologies.
### Kubernetes Microservices and Data Management

Tal discussed the use of Kubernetes for microservices and explained the concept of node types and their organization into microservices. He highlighted the importance of labels and selectors in Kubernetes and how they can be used to manage resources effectively. Tal also touched on the challenges of using functions in data types within TOSCA, particularly the ambiguity of the "self" context when functions are applied to different data types.
### TOSCA Node Validation Challenges

Tal and Chris discussed the challenges of validating node types in TOSCA, particularly regarding the containment hierarchy and the ability to access containing nodes. Tal suggested using custom functions to handle internal wiring and manage assemblage, emphasizing that TOSCA provides tools for this purpose, even if they are not built-in. They also discussed the limitations and complexities of substitution mapping across different platforms like Kubernetes and Nomad, concluding that while substitution mapping could be useful in certain cases, it adds unnecessary complexity for simple designs. Tal highlighted the simplicity and portability of using capability types to assemble features, which aligns well with how services are structured in Kubernetes and other platforms.
### TOSCA for Microservice Design Simplification

Tal discussed the benefits of TOSCA, highlighting its ability to set defaults and requirements for microservices, which simplifies the design process for architects. He explained how TOSCA allows for the creation of custom functions to address specific needs, such as avoiding duplicate labels for multiple instances of a service. Tal also mentioned the possibility of using different platforms like Nomad, while maintaining a similar approach.
### Kubernetes Orchestration Logic Challenges

Tal and Chris discussed the challenges of modeling Kubernetes orchestration logic within a template system. Chris expressed concerns about the reuse capabilities and the lack of orchestration logic in the current model, emphasizing the need for a more comprehensive example that includes complex Kubernetes features like custom controllers and status updates. Tal suggested creating a Kubernetes node type that could inherit orchestration logic, but Chris pointed out the need for more detailed logic, such as creating service accounts and deployments. Tal acknowledged these limitations and mentioned ongoing work to implement the discussed model in Puccini, with plans for a demo to showcase its functionality.
### Kubernetes Resource Management Demo

Tal demonstrated a Kubernetes profile generator that uses the Kubernetes API to create complex resource configurations, explaining that while Kubernetes supports both declarative and imperative management, TOSCA should not restrict users from using Kubernetes' full feature set. Calin inquired about Kubernetes' handling of resource creation and deletion, to which Tal explained that resources can be automatically recreated based on instance counts and described how Kubernetes Operators can provide complete ownership and control over resources through RBAC permissions. The conversation ended with Chris requesting Tal to contribute the example code to the Community Contributions Repo for further study.
