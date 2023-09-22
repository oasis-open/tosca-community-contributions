## Public Capability

### Scope
This type belongs to YAML type definitions derived from OASIS TOSCA normative and non normative types v.1.3.

More information can be found in the [OASIS Open TOSCA Community Contribution Page](https://github.com/oasis-open/tosca-community-contributions/tree/master/profiles/org.oasis-open).

### Description
This capability represents a public endpoint which is accessible to the general internet (and its public IP address ranges). This public endpoint capability also can be used to create a floating (IP) address that the underlying network assigns from a pool allocated from the application's underlying public network. This floating address is managed by the underlying network such that can be routed an application's private address and remains reliable to internet clients.


| Name | URI | Version | Derived From |
|:---- |:--- |:------- |:------------ |
| `Public` | `tosca.capabilities.Endpoint.Public` | `1.3.0` | `tosca.capabilities.Endpoint` |


### Licensing
Adaptation to Winery format has been done by [Engineering Ingegneria Informatica](https://www.eng.it) in September 2023 under the terms of [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0) (the "License").

This type is free for use in compliance with the License.

Unless required by applicable law or agreed to in writing, artifacts distributed under the License are distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.