# resources/node.rb
#
# Copyright 2013, Simple Finance Technology Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

actions(:create, :delete, :create_if_missing)
default_action(:create)

attribute :path,        kind_of: String, name_attribute: true
attribute :connect_str, kind_of: String, required: true
attribute :data,        kind_of: String

attribute :auth_cert,   kind_of: String, default: nil
attribute :auth_scheme, kind_of: String, default: 'digest'

attribute :acl_digest,  kind_of: Hash
attribute :acl_ip,      kind_of: Hash
attribute :acl_sasl,    kind_of: Hash
attribute :acl_world,   kind_of: Fixnum, default: Zk::PERM_ALL

def initialize(name, run_context = nil)
  super

  # Initializes acl attributes default values
  # We can't use `default` dsl because it'll share the hash reference
  @acl_digest = {}
  @acl_sasl = {}
  @acl_ip = {}
end
