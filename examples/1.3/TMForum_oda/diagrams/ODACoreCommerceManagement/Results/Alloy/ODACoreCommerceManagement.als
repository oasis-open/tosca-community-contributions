// --------------------------------------------------
// TOSCA Topology Metadata
// --------------------------------------------------

// tosca_definitions_version: tosca_simple_yaml_1_3
// description: Abstract template (no deployable nodes) used to reproduce diagram in https://projects.tmforum.org/wiki/display/TAC/Components+Interactions+in+Core+Commerce+Management

open cloudnet/LocationGraphs
open cloudnet/TOSCA
open cloudnet/tosca_simple_yaml_1_3

// --------------------------------------------------
// Imports
// --------------------------------------------------

open org_tmforum_1

// --------------------------------------------------
// Node Types
// --------------------------------------------------

//
// Adds the optional capabilities of TMF622 and TMF663 to the mandatory capabilities defined in the tmforum profile
//
sig TMFC002_c648_c663_r679 extends tmforum_TMFC002
{
  // --------------------------------------------------
  // Capabilities
  // --------------------------------------------------

  // YAML TMF648_capability: {'type': 'tmforum:TMF648'}
  capability_TMF648_capability: some tmforum_TMF648,

  // YAML TMF663_capability: {'type': 'tmforum:TMF663'}
  capability_TMF663_capability: some tmforum_TMF663,

  // --------------------------------------------------
  // Requirements
  // --------------------------------------------------

  // YAML TMF679_requirement: {'capability': 'tmforum:TMF679', 'relationship': {'type': 'tmforum:oda_component_depends_on_TMF_API'}}
  requirement_TMF679_requirement: one TOSCA/Requirement,

} {
  // --------------------------------------------------
  // Capabilities
  // --------------------------------------------------

  // YAML TMF648_capability: {'type': 'tmforum:TMF648'}
  capability_TMF648_capability.name["TMF648_capability"]
  capability[capability_TMF648_capability]

  // YAML TMF663_capability: {'type': 'tmforum:TMF663'}
  capability_TMF663_capability.name["TMF663_capability"]
  capability[capability_TMF663_capability]

  // --------------------------------------------------
  // Requirements
  // --------------------------------------------------

  // YAML TMF679_requirement: {'capability': 'tmforum:TMF679', 'relationship': {'type': 'tmforum:oda_component_depends_on_TMF_API'}}
  requirement["TMF679_requirement", requirement_TMF679_requirement]
  requirement_TMF679_requirement.capability[tmforum_TMF679]
  requirement_TMF679_requirement.relationship[tmforum_oda_component_depends_on_TMF_API]

}

/** There exists some TMFC002_c648_c663_r679 */
run Show_TMFC002_c648_c663_r679 {
  TMFC002_c648_c663_r679.no_name[]
} for 5 but
  8 Int,
  5 seq,
  // NOTE: Setting following scopes strongly reduces the research space.
  exactly 0 LocationGraphs/LocationGraph,
  exactly 4 LocationGraphs/Location,
  exactly 35 LocationGraphs/Value,
  exactly 4 LocationGraphs/Name,
  exactly 1 LocationGraphs/Sort,
  exactly 1 LocationGraphs/Process,
  exactly 0 TOSCA/Group,
  exactly 0 TOSCA/Policy,
  exactly 1 TMFC002_c648_c663_r679
  expect 1

//
// Add the optional requirement on TMF622
//
sig TMFC027_r622 extends tmforum_TMFC027
{
  // --------------------------------------------------
  // Requirements
  // --------------------------------------------------

  // YAML TMF622_requirement: {'capability': 'tmforum:TMF622', 'relationship': {'type': 'tmforum:oda_component_depends_on_TMF_API'}}
  requirement_TMF622_requirement: one TOSCA/Requirement,

} {
  // --------------------------------------------------
  // Requirements
  // --------------------------------------------------

  // YAML TMF622_requirement: {'capability': 'tmforum:TMF622', 'relationship': {'type': 'tmforum:oda_component_depends_on_TMF_API'}}
  requirement["TMF622_requirement", requirement_TMF622_requirement]
  requirement_TMF622_requirement.capability[tmforum_TMF622]
  requirement_TMF622_requirement.relationship[tmforum_oda_component_depends_on_TMF_API]

}

/** There exists some TMFC027_r622 */
run Show_TMFC027_r622 {
  TMFC027_r622.no_name[]
} for 5 but
  8 Int,
  5 seq,
  // NOTE: Setting following scopes strongly reduces the research space.
  exactly 0 LocationGraphs/LocationGraph,
  exactly 7 LocationGraphs/Location,
  exactly 35 LocationGraphs/Value,
  exactly 7 LocationGraphs/Name,
  exactly 1 LocationGraphs/Sort,
  exactly 1 LocationGraphs/Process,
  exactly 0 TOSCA/Group,
  exactly 0 TOSCA/Policy,
  exactly 1 TMFC027_r622
  expect 1

// --------------------------------------------------
// Topology Template
// --------------------------------------------------

sig ODACoreCommerceManagement_topology_template extends TOSCA/TopologyTemplate
{
  // --------------------------------------------------
  // YAML node_templates:
  // --------------------------------------------------

  // YAML PrdCtgMgmt: {'type': 'tmforum:TMFC001', 'properties': {'node_instance_name': 'PrdCtgMgmt', 'definition_file': '/dev/null'}}
  // YAML type: tmforum:TMFC001
  PrdCtgMgmt: one tmforum_TMFC001,

  // YAML PrdOrdCptVd: {'type': 'TMFC002_c648_c663_r679', 'properties': {'node_instance_name': 'PrdOrdCptVd', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF637_requirement': {'node': 'PI'}}, {'TMF679_requirement': {'node': 'Cpq'}}]}
  // YAML type: TMFC002_c648_c663_r679
  PrdOrdCptVd: one TMFC002_c648_c663_r679,

  // YAML Poom: {'type': 'tmforum:TMFC003', 'properties': {'node_instance_name': 'Poom', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF622_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF637_requirement': {'node': 'PI'}}]}
  // YAML type: tmforum:TMFC003
  Poom: one tmforum_TMFC003,

  // YAML PI: {'type': 'tmforum:TMFC005', 'properties': {'node_instance_name': 'PI', 'definition_file': '/dev/null'}}
  // YAML type: tmforum:TMFC005
  PI: one tmforum_TMFC005,

  // YAML Cpq: {'type': 'TMFC027_r622', 'properties': {'node_instance_name': 'Cpq', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF637_requirement': {'node': 'PI'}}, {'TMF645_requirement': {'node': 'Dummy'}}, {'TMF648_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF663_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF622_requirement': 'PrdOrdCptVd'}]}
  // YAML type: TMFC027_r622
  Cpq: one TMFC027_r622,

  // YAML Dummy: {'type': 'tmforum:TMFC999', 'properties': {'node_instance_name': 'Dummy', 'definition_file': '/dev/null'}, 'description': 'Dummy node to terminate Mandatory API TMF645 which is not shown on the diagram'}
  // YAML type: tmforum:TMFC999
  Dummy: one tmforum_TMFC999,

  // --------------------------------------------------
  // YAML relationship_templates:
  // --------------------------------------------------

  // --------------------------------------------------
  // YAML groups:
  // --------------------------------------------------

  // --------------------------------------------------
  // YAML policies:
  // --------------------------------------------------

  // --------------------------------------------------
  // YAML outputs:
  // --------------------------------------------------

} {
  // YAML description: None
  no description

  // --------------------------------------------------
  // YAML inputs:
  // --------------------------------------------------

  no inputs

  // --------------------------------------------------
  // YAML node_templates:
  // --------------------------------------------------

  #nodes = 6
  // YAML PrdCtgMgmt: {'type': 'tmforum:TMFC001', 'properties': {'node_instance_name': 'PrdCtgMgmt', 'definition_file': '/dev/null'}}
  node[PrdCtgMgmt]
  PrdCtgMgmt.name["PrdCtgMgmt"]
  PrdCtgMgmt.node_type_name = "tmforum:TMFC001"
  // YAML properties:
  // YAML component_class_ID: TMFC001
  PrdCtgMgmt.property_component_class_ID = "TMFC001"
  // YAML component_class_name: TMFC001
  PrdCtgMgmt.property_component_class_name = "TMFC001"
  // YAML component_class_short_name: TMFC001
  PrdCtgMgmt.property_component_class_short_name = "TMFC001"
  // YAML node_instance_name: PrdCtgMgmt
  PrdCtgMgmt.property_node_instance_name = "PrdCtgMgmt"
  // YAML definition_file: /dev/null
  PrdCtgMgmt.property_definition_file = "/dev/null"
  // YAML interfaces:
  #PrdCtgMgmt.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no PrdCtgMgmt.interface_Standard.operation_create.implementation
  no PrdCtgMgmt.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no PrdCtgMgmt.interface_Standard.operation_configure.implementation
  no PrdCtgMgmt.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no PrdCtgMgmt.interface_Standard.operation_start.implementation
  no PrdCtgMgmt.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no PrdCtgMgmt.interface_Standard.operation_stop.implementation
  no PrdCtgMgmt.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no PrdCtgMgmt.interface_Standard.operation_delete.implementation
  no PrdCtgMgmt.interface_Standard.operation_delete.inputs
  #PrdCtgMgmt.interface_Standard.operations = 5
  // YAML artifacts:
  no PrdCtgMgmt.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF620_capability: None
  // YAML id: TMF620
  PrdCtgMgmt.capability_TMF620_capability.property_id = "TMF620"
  // YAML name: Product Catalog Mgmt
  PrdCtgMgmt.capability_TMF620_capability.property_name = "Product Catalog Mgmt"
  // NOTE: The property 'swagger_file' is not required.
  no   PrdCtgMgmt.capability_TMF620_capability.property_swagger_file

  // YAML PrdOrdCptVd: {'type': 'TMFC002_c648_c663_r679', 'properties': {'node_instance_name': 'PrdOrdCptVd', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF637_requirement': {'node': 'PI'}}, {'TMF679_requirement': {'node': 'Cpq'}}]}
  node[PrdOrdCptVd]
  PrdOrdCptVd.name["PrdOrdCptVd"]
  PrdOrdCptVd.node_type_name = "TMFC002_c648_c663_r679"
  // YAML properties:
  // YAML component_class_ID: TMFC002
  PrdOrdCptVd.property_component_class_ID = "TMFC002"
  // YAML component_class_name: Product Order Capture & Validation
  PrdOrdCptVd.property_component_class_name = "Product Order Capture & Validation"
  // YAML component_class_short_name: PrdOrdCptVd
  PrdOrdCptVd.property_component_class_short_name = "PrdOrdCptVd"
  // YAML node_instance_name: PrdOrdCptVd
  PrdOrdCptVd.property_node_instance_name = "PrdOrdCptVd"
  // YAML definition_file: /dev/null
  PrdOrdCptVd.property_definition_file = "/dev/null"
  // YAML interfaces:
  #PrdOrdCptVd.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no PrdOrdCptVd.interface_Standard.operation_create.implementation
  no PrdOrdCptVd.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no PrdOrdCptVd.interface_Standard.operation_configure.implementation
  no PrdOrdCptVd.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no PrdOrdCptVd.interface_Standard.operation_start.implementation
  no PrdOrdCptVd.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no PrdOrdCptVd.interface_Standard.operation_stop.implementation
  no PrdOrdCptVd.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no PrdOrdCptVd.interface_Standard.operation_delete.implementation
  no PrdOrdCptVd.interface_Standard.operation_delete.inputs
  #PrdOrdCptVd.interface_Standard.operations = 5
  // YAML artifacts:
  no PrdOrdCptVd.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF622_capability: None
  // YAML id: TMF622
  PrdOrdCptVd.capability_TMF622_capability.property_id = "TMF622"
  // YAML name: Product Ordering
  PrdOrdCptVd.capability_TMF622_capability.property_name = "Product Ordering"
  // NOTE: The property 'swagger_file' is not required.
  no   PrdOrdCptVd.capability_TMF622_capability.property_swagger_file
  // YAML   TMF648_capability: None
  // YAML id: TMF648
  PrdOrdCptVd.capability_TMF648_capability.property_id = "TMF648"
  // YAML name: Quote
  PrdOrdCptVd.capability_TMF648_capability.property_name = "Quote"
  // NOTE: The property 'swagger_file' is not required.
  no   PrdOrdCptVd.capability_TMF648_capability.property_swagger_file
  // YAML   TMF663_capability: None
  // YAML id: TMF648
  PrdOrdCptVd.capability_TMF663_capability.property_id = "TMF648"
  // YAML name: Shopping Cart
  PrdOrdCptVd.capability_TMF663_capability.property_name = "Shopping Cart"
  // NOTE: The property 'swagger_file' is not required.
  no   PrdOrdCptVd.capability_TMF663_capability.property_swagger_file
  // YAML TMF620_requirement: {'node': 'PrdCtgMgmt'}
  connect[PrdOrdCptVd.requirement_TMF620_requirement, PrdCtgMgmt.capability_TMF620_capability]
  PrdOrdCptVd.requirement_TMF620_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #PrdOrdCptVd.requirement_TMF620_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #PrdOrdCptVd.requirement_TMF620_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF637_requirement: {'node': 'PI'}
  connect[PrdOrdCptVd.requirement_TMF637_requirement, PI.capability_TMF637_capability]
  PrdOrdCptVd.requirement_TMF637_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #PrdOrdCptVd.requirement_TMF637_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #PrdOrdCptVd.requirement_TMF637_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF679_requirement: {'node': 'Cpq'}
  connect[PrdOrdCptVd.requirement_TMF679_requirement, Cpq.capability_TMF679_capability]
  PrdOrdCptVd.requirement_TMF679_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #PrdOrdCptVd.requirement_TMF679_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_add_target.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_add_source.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #PrdOrdCptVd.requirement_TMF679_requirement.relationship.interface_Configure.operations = 8

  // YAML Poom: {'type': 'tmforum:TMFC003', 'properties': {'node_instance_name': 'Poom', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF622_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF637_requirement': {'node': 'PI'}}]}
  node[Poom]
  Poom.name["Poom"]
  Poom.node_type_name = "tmforum:TMFC003"
  // YAML properties:
  // YAML component_class_ID: TMFC003
  Poom.property_component_class_ID = "TMFC003"
  // YAML component_class_name: product_order_delivery_orchestration_&_management
  Poom.property_component_class_name = "product_order_delivery_orchestration_&_management"
  // YAML component_class_short_name: Poom
  Poom.property_component_class_short_name = "Poom"
  // YAML node_instance_name: Poom
  Poom.property_node_instance_name = "Poom"
  // YAML definition_file: /dev/null
  Poom.property_definition_file = "/dev/null"
  // YAML interfaces:
  #Poom.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no Poom.interface_Standard.operation_create.implementation
  no Poom.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no Poom.interface_Standard.operation_configure.implementation
  no Poom.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no Poom.interface_Standard.operation_start.implementation
  no Poom.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no Poom.interface_Standard.operation_stop.implementation
  no Poom.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no Poom.interface_Standard.operation_delete.implementation
  no Poom.interface_Standard.operation_delete.inputs
  #Poom.interface_Standard.operations = 5
  // YAML artifacts:
  no Poom.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF637_capability: None
  // YAML id: TMF637
  Poom.capability_TMF637_capability.property_id = "TMF637"
  // YAML name: Product Inventory Management
  Poom.capability_TMF637_capability.property_name = "Product Inventory Management"
  // NOTE: The property 'swagger_file' is not required.
  no   Poom.capability_TMF637_capability.property_swagger_file
  // YAML TMF620_requirement: {'node': 'PrdCtgMgmt'}
  connect[Poom.requirement_TMF620_requirement, PrdCtgMgmt.capability_TMF620_capability]
  Poom.requirement_TMF620_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Poom.requirement_TMF620_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Poom.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Poom.requirement_TMF620_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF622_requirement: {'node': 'PrdOrdCptVd'}
  connect[Poom.requirement_TMF622_requirement, PrdOrdCptVd.capability_TMF622_capability]
  Poom.requirement_TMF622_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Poom.requirement_TMF622_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Poom.requirement_TMF622_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Poom.requirement_TMF622_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF637_requirement: {'node': 'PI'}
  connect[Poom.requirement_TMF637_requirement, PI.capability_TMF637_capability]
  Poom.requirement_TMF637_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Poom.requirement_TMF637_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Poom.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Poom.requirement_TMF637_requirement.relationship.interface_Configure.operations = 8

  // YAML PI: {'type': 'tmforum:TMFC005', 'properties': {'node_instance_name': 'PI', 'definition_file': '/dev/null'}}
  node[PI]
  PI.name["PI"]
  PI.node_type_name = "tmforum:TMFC005"
  // YAML properties:
  // YAML component_class_ID: TMFC005
  PI.property_component_class_ID = "TMFC005"
  // YAML component_class_name: product_inventory
  PI.property_component_class_name = "product_inventory"
  // YAML component_class_short_name: PI
  PI.property_component_class_short_name = "PI"
  // YAML node_instance_name: PI
  PI.property_node_instance_name = "PI"
  // YAML definition_file: /dev/null
  PI.property_definition_file = "/dev/null"
  // YAML interfaces:
  #PI.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no PI.interface_Standard.operation_create.implementation
  no PI.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no PI.interface_Standard.operation_configure.implementation
  no PI.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no PI.interface_Standard.operation_start.implementation
  no PI.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no PI.interface_Standard.operation_stop.implementation
  no PI.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no PI.interface_Standard.operation_delete.implementation
  no PI.interface_Standard.operation_delete.inputs
  #PI.interface_Standard.operations = 5
  // YAML artifacts:
  no PI.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF637_capability: None
  // YAML id: TMF637
  PI.capability_TMF637_capability.property_id = "TMF637"
  // YAML name: Product Inventory Management
  PI.capability_TMF637_capability.property_name = "Product Inventory Management"
  // NOTE: The property 'swagger_file' is not required.
  no   PI.capability_TMF637_capability.property_swagger_file

  // YAML Cpq: {'type': 'TMFC027_r622', 'properties': {'node_instance_name': 'Cpq', 'definition_file': '/dev/null'}, 'requirements': [{'TMF620_requirement': {'node': 'PrdCtgMgmt'}}, {'TMF637_requirement': {'node': 'PI'}}, {'TMF645_requirement': {'node': 'Dummy'}}, {'TMF648_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF663_requirement': {'node': 'PrdOrdCptVd'}}, {'TMF622_requirement': 'PrdOrdCptVd'}]}
  node[Cpq]
  Cpq.name["Cpq"]
  Cpq.node_type_name = "TMFC027_r622"
  // YAML properties:
  // YAML component_class_ID: TMFC027
  Cpq.property_component_class_ID = "TMFC027"
  // YAML component_class_name: Configure Price and Quote
  Cpq.property_component_class_name = "Configure Price and Quote"
  // YAML component_class_short_name: Cpq
  Cpq.property_component_class_short_name = "Cpq"
  // YAML node_instance_name: Cpq
  Cpq.property_node_instance_name = "Cpq"
  // YAML definition_file: /dev/null
  Cpq.property_definition_file = "/dev/null"
  // YAML interfaces:
  #Cpq.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no Cpq.interface_Standard.operation_create.implementation
  no Cpq.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no Cpq.interface_Standard.operation_configure.implementation
  no Cpq.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no Cpq.interface_Standard.operation_start.implementation
  no Cpq.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no Cpq.interface_Standard.operation_stop.implementation
  no Cpq.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no Cpq.interface_Standard.operation_delete.implementation
  no Cpq.interface_Standard.operation_delete.inputs
  #Cpq.interface_Standard.operations = 5
  // YAML artifacts:
  no Cpq.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF679_capability: None
  // YAML id: TMF679
  Cpq.capability_TMF679_capability.property_id = "TMF679"
  // YAML name: Product Offering Qualification
  Cpq.capability_TMF679_capability.property_name = "Product Offering Qualification"
  // NOTE: The property 'swagger_file' is not required.
  no   Cpq.capability_TMF679_capability.property_swagger_file
  // YAML TMF620_requirement: {'node': 'PrdCtgMgmt'}
  connect[Cpq.requirement_TMF620_requirement, PrdCtgMgmt.capability_TMF620_capability]
  Cpq.requirement_TMF620_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF620_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF620_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF637_requirement: {'node': 'PI'}
  connect[Cpq.requirement_TMF637_requirement, PI.capability_TMF637_capability]
  Cpq.requirement_TMF637_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF637_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF637_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF645_requirement: {'node': 'Dummy'}
  connect[Cpq.requirement_TMF645_requirement, Dummy.capability_TMF645_capability]
  Cpq.requirement_TMF645_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF645_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF645_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF648_requirement: {'node': 'PrdOrdCptVd'}
  connect[Cpq.requirement_TMF648_requirement, PrdOrdCptVd.capability_TMF648_capability]
  Cpq.requirement_TMF648_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF648_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF648_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF663_requirement: {'node': 'PrdOrdCptVd'}
  connect[Cpq.requirement_TMF663_requirement, PrdOrdCptVd.capability_TMF663_capability]
  Cpq.requirement_TMF663_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF663_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF663_requirement.relationship.interface_Configure.operations = 8
  // YAML TMF622_requirement: PrdOrdCptVd
  connect[Cpq.requirement_TMF622_requirement, PrdOrdCptVd.capability_TMF622_capability]
  Cpq.requirement_TMF622_requirement.relationship._name_ = "(anonymous)"
  // YAML interfaces:
  #Cpq.requirement_TMF622_requirement.relationship.interfaces = 1
  // YAML Configure:
  // YAML pre_configure_source: {'description': 'Operation to pre-configure the source endpoint.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_source.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_source.inputs
  // YAML pre_configure_target: {'description': 'Operation to pre-configure the target endpoint.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_target.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_pre_configure_target.inputs
  // YAML post_configure_source: {'description': 'Operation to post-configure the source endpoint.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_source.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_source.inputs
  // YAML post_configure_target: {'description': 'Operation to post-configure the target endpoint.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_target.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_post_configure_target.inputs
  // YAML add_target: {'description': 'Operation to notify the source node of a target node being added via a relationship.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_target.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_target.inputs
  // YAML add_source: {'description': 'Operation to notify the target node of a source node which is now available via a relationship.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_source.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_add_source.inputs
  // YAML target_changed: {'description': 'Operation to notify source some property or attribute of the target changed'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_target_changed.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_target_changed.inputs
  // YAML remove_target: {'description': 'Operation to remove a target node.'}
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_remove_target.implementation
  no Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operation_remove_target.inputs
  #Cpq.requirement_TMF622_requirement.relationship.interface_Configure.operations = 8

  // YAML Dummy: {'type': 'tmforum:TMFC999', 'properties': {'node_instance_name': 'Dummy', 'definition_file': '/dev/null'}, 'description': 'Dummy node to terminate Mandatory API TMF645 which is not shown on the diagram'}
  node[Dummy]
  Dummy.name["Dummy"]
  Dummy.node_type_name = "tmforum:TMFC999"
  // YAML properties:
  // YAML component_class_ID: TMFC999
  Dummy.property_component_class_ID = "TMFC999"
  // YAML component_class_name: Dummy
  Dummy.property_component_class_name = "Dummy"
  // YAML component_class_short_name: dummy
  Dummy.property_component_class_short_name = "dummy"
  // YAML node_instance_name: Dummy
  Dummy.property_node_instance_name = "Dummy"
  // YAML definition_file: /dev/null
  Dummy.property_definition_file = "/dev/null"
  // YAML interfaces:
  #Dummy.interfaces = 1
  // YAML Standard:
  // YAML create: {'description': 'Standard lifecycle create operation.'}
  no Dummy.interface_Standard.operation_create.implementation
  no Dummy.interface_Standard.operation_create.inputs
  // YAML configure: {'description': 'Standard lifecycle configure operation.'}
  no Dummy.interface_Standard.operation_configure.implementation
  no Dummy.interface_Standard.operation_configure.inputs
  // YAML start: {'description': 'Standard lifecycle start operation.'}
  no Dummy.interface_Standard.operation_start.implementation
  no Dummy.interface_Standard.operation_start.inputs
  // YAML stop: {'description': 'Standard lifecycle stop operation.'}
  no Dummy.interface_Standard.operation_stop.implementation
  no Dummy.interface_Standard.operation_stop.inputs
  // YAML delete: {'description': 'Standard lifecycle delete operation.'}
  no Dummy.interface_Standard.operation_delete.implementation
  no Dummy.interface_Standard.operation_delete.inputs
  #Dummy.interface_Standard.operations = 5
  // YAML artifacts:
  no Dummy.artifacts
  // YAML capabilities:
  // YAML   feature: None
  // YAML   TMF645_capability: None
  // YAML id: TMF645
  Dummy.capability_TMF645_capability.property_id = "TMF645"
  // YAML name: Service Qualification
  Dummy.capability_TMF645_capability.property_name = "Service Qualification"
  // YAML swagger_file: https://github.com/tmforum-rand/Open_API_And_Data_Model/blob/v4.0-Sprint-2020-03/apis/TMF645_Service_Qualification/swaggers/TMF645-ServiceQualification-v4.0.1.swagger.json
  Dummy.capability_TMF645_capability.property_swagger_file = "https://github.com/tmforum-rand/Open_API_And_Data_Model/blob/v4.0-Sprint-2020-03/apis/TMF645_Service_Qualification/swaggers/TMF645-ServiceQualification-v4.0.1.swagger.json"
  // YAML   TMF648_capability: None
  // YAML id: TMF648
  Dummy.capability_TMF648_capability.property_id = "TMF648"
  // YAML name: Quote
  Dummy.capability_TMF648_capability.property_name = "Quote"
  // NOTE: The property 'swagger_file' is not required.
  no   Dummy.capability_TMF648_capability.property_swagger_file
  // YAML   TMF663_capability: None
  // YAML id: TMF648
  Dummy.capability_TMF663_capability.property_id = "TMF648"
  // YAML name: Shopping Cart
  Dummy.capability_TMF663_capability.property_name = "Shopping Cart"
  // NOTE: The property 'swagger_file' is not required.
  no   Dummy.capability_TMF663_capability.property_swagger_file


  // --------------------------------------------------
  // YAML relationship_templates:
  // --------------------------------------------------

  no relationships

  // --------------------------------------------------
  // YAML groups:
  // --------------------------------------------------

  no groups

  // --------------------------------------------------
  // YAML policies:
  // --------------------------------------------------

  no policies
  // --------------------------------------------------
  // YAML outputs:
  // --------------------------------------------------

  no outputs

  // --------------------------------------------------
  // Substitution Mappings
  // --------------------------------------------------

  // YAML substitution_mappings: None
  no substitution_mapping
}

/** There exists some ODACoreCommerceManagement_topology_template */
run Show_ODACoreCommerceManagement_topology_template {
} for 0 but
  // NOTE: Setting following scopes strongly reduces the research space.
  exactly 1 LocationGraphs/LocationGraph,
  exactly 18 LocationGraphs/Location,
  exactly 75 LocationGraphs/Value,
  exactly 18 LocationGraphs/Name,
  exactly 1 LocationGraphs/Process,
  exactly 1 LocationGraphs/Sort,
  exactly 40 LocationGraphs/Role,
  exactly 0 TOSCA/Scalar,
  exactly 0 TOSCA/scalar_unit_size,
  exactly 0 TOSCA/scalar_unit_frequency,
  exactly 0 TOSCA/scalar_unit_time,
  exactly 0 TOSCA/map_integer/Map,
  exactly 0 TOSCA/map_string/Map,
  exactly 0 TOSCA/map_data/Map,
  exactly 0 TOSCA/map_map_data/Map,
  exactly 18 TOSCA/ToscaComponent,
  exactly 40 TOSCA/ToscaRole,
  exactly 15 TOSCA/ToscaValue,
  exactly 1 TOSCA/TopologyTemplate,
  exactly 6 TOSCA/Node,
  exactly 12 TOSCA/Requirement,
  exactly 28 TOSCA/Capability,
  exactly 12 TOSCA/Relationship,
  exactly 0 TOSCA/Group,
  exactly 0 TOSCA/Policy,
  exactly 2 TOSCA/Interface,
  exactly 13 TOSCA/Operation,
  exactly 0 TOSCA/Attribute,
  exactly 0 TOSCA/Artifact,
  exactly 0 TOSCA/Data,
  exactly 0 TOSCA/AbstractProperty,
  exactly 0 TOSCA/Property,
  exactly 0 TOSCA/Parameter,
  exactly 0 tosca_artifacts_Root,
  exactly 0 tosca_artifacts_File,
  exactly 0 tosca_artifacts_Deployment,
  exactly 0 tosca_artifacts_Deployment_Image,
  exactly 0 tosca_artifacts_Deployment_Image_VM,
  exactly 0 tosca_artifacts_Implementation,
  exactly 0 tosca_artifacts_Implementation_Bash,
  exactly 0 tosca_artifacts_Implementation_Python,
  exactly 0 tosca_artifacts_template,
  exactly 0 tosca_datatypes_Root,
  exactly 0 tosca_datatypes_Credential,
  exactly 0 tosca_datatypes_TimeInterval,
  exactly 0 tosca_datatypes_network_NetworkInfo,
  exactly 0 tosca_datatypes_network_PortInfo,
  exactly 0 tosca_datatypes_network_PortSpec,
  exactly 28 tosca_capabilities_Root,
  exactly 28 tosca_capabilities_Node,
  exactly 0 tosca_capabilities_Container,
  exactly 0 tosca_capabilities_Compute,
  exactly 0 tosca_capabilities_Network,
  exactly 0 tosca_capabilities_Storage,
  exactly 0 tosca_capabilities_Endpoint,
  exactly 0 tosca_capabilities_Endpoint_Public,
  exactly 0 tosca_capabilities_Endpoint_Admin,
  exactly 0 tosca_capabilities_Endpoint_Database,
  exactly 0 tosca_capabilities_Attachment,
  exactly 0 tosca_capabilities_OperatingSystem,
  exactly 0 tosca_capabilities_Scalable,
  exactly 0 tosca_capabilities_network_Bindable,
  exactly 0 tosca_capabilities_network_Linkable,
  exactly 22 tmforum_TMFAPI,
  exactly 0 tmforum_TMF401,
  exactly 4 tmforum_TMF620,
  exactly 3 tmforum_TMF622,
  exactly 0 tmforum_TMF632,
  exactly 5 tmforum_TMF637,
  exactly 2 tmforum_TMF645,
  exactly 3 tmforum_TMF648,
  exactly 3 tmforum_TMF663,
  exactly 2 tmforum_TMF679,
  exactly 0 tmforum_TMF688,
  exactly 0 tmforum_run_oda_component,
  exactly 0 tmforum_run_oda_component_on_sailcloth,
  exactly 2 tosca_interfaces_Root,
  exactly 1 tosca_interfaces_node_lifecycle_Standard,
  exactly 1 tosca_interfaces_relationship_Configure,
  exactly 12 tosca_relationships_Root,
  exactly 0 tosca_relationships_DependsOn,
  exactly 0 tosca_relationships_HostedOn,
  exactly 0 tosca_relationships_ConnectsTo,
  exactly 0 tosca_relationships_AttachesTo,
  exactly 0 tosca_relationships_RoutesTo,
  exactly 0 tosca_relationships_network_LinksTo,
  exactly 0 tosca_relationships_network_BindsTo,
  exactly 12 tmforum_oda_component_depends_on_TMF_API,
  exactly 0 tmforum_running_on_sailcloth,
  exactly 6 tosca_nodes_Root,
  exactly 0 tosca_nodes_Abstract_Compute,
  exactly 0 tosca_nodes_Compute,
  exactly 0 tosca_nodes_SoftwareComponent,
  exactly 0 tosca_nodes_WebServer,
  exactly 0 tosca_nodes_WebApplication,
  exactly 0 tosca_nodes_DBMS,
  exactly 0 tosca_nodes_Database,
  exactly 0 tosca_nodes_Abstract_Storage,
  exactly 0 tosca_nodes_Storage_ObjectStorage,
  exactly 0 tosca_nodes_Storage_BlockStorage,
  exactly 0 tosca_nodes_Container_Runtime,
  exactly 0 tosca_nodes_Container_Application,
  exactly 0 tosca_nodes_LoadBalancer,
  exactly 0 tosca_nodes_network_Network,
  exactly 0 tosca_nodes_network_Port,
  exactly 0 tmforum_oda_platform,
  exactly 0 tmforum_oda_platform_canvas,
  exactly 0 tmforum_oda_sailcloth,
  exactly 6 tmforum_oda_component,
  exactly 1 tmforum_TMFC001,
  exactly 1 tmforum_TMFC002,
  exactly 1 tmforum_TMFC003,
  exactly 1 tmforum_TMFC005,
  exactly 1 tmforum_TMFC027,
  exactly 1 tmforum_TMFC999,
  exactly 0 tmforum_ocs,
  exactly 0 tmforum_linuxfile,
  exactly 1 TMFC002_c648_c663_r679,
  exactly 1 TMFC027_r622,
  exactly 0 tosca_groups_Root,
  exactly 0 tosca_policies_Root,
  exactly 0 tosca_policies_Placement,
  exactly 0 tosca_policies_Scaling,
  exactly 0 tosca_policies_Update,
  exactly 0 tosca_policies_Performance,
  exactly 1 ODACoreCommerceManagement_topology_template,
  8 Int,
  0 seq
  expect 1


