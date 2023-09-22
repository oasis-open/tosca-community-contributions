# Table of Contents
- [Table of Contents](#table-of-contents)
- [Introduction](#introduction)
  - [Eclipse Winery](#eclipse-winery)
  - [What does this package contain?](#what-does-this-package-contain)
  - [How was this package realized?](#how-was-this-package-realized)
- [How to Use this package with Eclipse Winery](#how-to-use-this-package-with-eclipse-winery)
- [Contacts](#contacts)
- [Disclaimer](#disclaimer)
- [References](#references)

# Introduction
This work represents [Engineering Ingegneria Informatica's](https://www.eng.it/) contribution to the activities of the [Open Source OASIS TOSCA Repository](https://github.com/oasis-open/tosca-community-contributions). It provides data that can be used as building blocks for designing TOSCA service templates through Eclipse Winery.

## Eclipse Winery
[Eclipse Winery](https://winery.readthedocs.io/en/latest/) is an open source TOSCA Generator, specifically a Modeler, i.e. a tool that allows the user to design a TOSCA Service Template by means of a graphical editor, avoiding the burden to write YAML descriptors manually and to package them into a well formatted CSAR Archive.

Specifically, Winery consists of a web-based environment that includes a type and template management component to offer creation and modification of all elements defined in the TOSCA specification. All information is stored in a repository, which allows importing and exporting TOSCA CSAR Archives. CSAR packages produced through Winery can be imported by a TOSCA Orchestrator to be deployed on a cloud infrastructure.

Winery organizes all definitions, types and templates into a folder in the local filesystem. Upon the first installation, this folder is empty, i.e. the first time Winery is launched, it starts without any predefined type. There are several projects available on the web that provide some Winery repositories ready to use (see e.g. the [RADON project](https://radon-h2020.eu/), which provides the following [Winery Repository](https://github.com/radon-h2020/radon-particles)).


## What does this package contain?
This package contains a repository which can be directly imported by Eclipse Winery to provide standard types in the graphical editor. Specifically, the directory contains:

- artifact_types
- capability_types
- data_types
- group_types
- interface_types
- node_types
- policy_types
- relationship_types

defined by OASIS as TOSCA Normative types (aligned with TOSCA Simple Profile in YAML Version 1.3) and ETSI NFV SOL001 types (VNFD, PNFD and NSD description compliant with TOSCA Specification).

## How was this package realized?
This package has been obtained through an open source tool command line tool for Linux (*importToscaDescWinery*), realized by Engineering Ingegneria Informatica and available [here](https://github.com/Engineering-Research-and-Development/importToscaDescWinery).

# How to Use this package with Eclipse Winery
According to instructions detailed [here](https://winery.readthedocs.io/en/latest/user/getting-started.html), Eclipse Winery can be launched through Docker using the following command:

> docker run -it -p 8080:8080 \
>  -e PUBLIC_HOSTNAME=localhost \
>  -e WINERY_FEATURE_RADON=false \
>  -e WINERY_REPOSITORY_PROVIDER=yaml \
>  -v <some_dir>/toscaModels:/var/repository \
>  -u 'id -u' \
>  opentosca/winery

This launches the application within a container hosted on the local machine. The host TCP port 8080 is mapped to container's internal port 8080, so that access to the Winery GUI is simply obtained by opening a web browser on the host machine and navigating to the following URL:

> [http://localhost:8080/](http://localhost:8080/)

In the previous command, container's directory */var/repository* is mapped to the host's directory *<some_dir>/toscaModels*, where *<some_dir>* represents a given directory chosen by the user. In order to use our data as building blocks of Eclipse Winery GUI, they shall be simply placed within this directory. This is obtained through the following commands:

> cd *<some_dir>*
> 
> git clone https://github.com/oasis-open/tosca-community-contributions.git
>
> cp -R tosca-community-contributions/tools/winery-canvas/tosca1.3_etsinfv4.4.1 ./toscaModels

Once done, just launch Winery with the *docker* command above (or refresh the interface if already running) to see the new types in the available catalog.

# Contacts
In case of issues, clarifications, inconsistencies, questions or proposals, please feel free to contact us at the following e-mail: [opensource-notify@eng.it](mailto:opensource-notify@eng.it).


# Disclaimer
This work has been realized by [Engineering Ingegneria Informatica](https://www.eng.it/) and is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. For further details please refer to the licensing terms available [here](./LICENSE.txt).


# References
Here follows some useful references:

- [Engineering Ingegneria Informatica home page](https://www.eng.it/)
- [OASIS Topology and Orchestration Specification for Cloud Applications (TOSCA) TC](https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=tosca)
- [TOSCA Normative Types on the OASIS Open Github Repository](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/org.oasis-open/simple)
- [NFV SOL001 - YAML type definitions for ETSI NFV descriptors from ETSI forge](https://forge.etsi.org/rep/nfv/SOL001)
- [Eclipse Winery Home Page](https://projects.eclipse.org/projects/soa.winery)
- [Eclipse Winery Project on Github](https://github.com/eclipse/winery)
- [Brief Video Introduction to Eclipse Winery](https://youtu.be/hj7iBadt7D8)
- [Eclipse Winery Documentation on readthedocs.io](https://winery.readthedocs.io/en/latest/)
- [TOSCA definitions repository for the RADON project](https://github.com/radon-h2020/radon-particles)
- [RADON Project](http://radon-h2020.eu/)
- [importToscaDescWinery tool on Github](https://github.com/Engineering-Research-and-Development/importToscaDescWinery)
