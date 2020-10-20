# Infrastructure-as-a-Service Use Cases
This directory contains TOSCA service templates that deploy services on 
* Amazon Web Services
* Microsoft Azure
* Google Cloud Platform
## IaaS Platform Models
In order to orchestrate Compute, Storage, and Networking services on IaaS clouds, a TOSCA Orchestrator 
must have knowledge about the specific cloud platforms (and the associated regions and availability zones)
on which it can deploy these nodes. Our approach models the various IaaS platforms using TOSCA node types.

A Compute, Storage, or Network node must express that it must be deployed on a cloud platform. 
Our approach uses TOSCA *requirements* for expressing this.
## Credentials
A TOSCA Orchestrator must manage credentials to communicate with the IaaS platforms.
### Open Issues
* Do we define (as part of operation input definitions) the credentials that must be supplied, or is this done “under the hood”?
* If we define required inputs in TOSCA do we need to flag values as “secret” or “sensitive”? If so, how?
* Do we rely on the APIs to each platform to manage credentials themselves, or do we rely on a central credential “vault”? Does the orchestrator need to know how to retrieve values from that vault?
