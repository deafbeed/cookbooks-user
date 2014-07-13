#
# Author:: Shamik <shamik@native5.com>
# Cookbook Name:: user
# Resource:: add
#
# Copyright:: 2014 Native5 Software Pvt. Ltd.
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
#

# Allowed actions
actions :add, :remove

# Default action
default_action :add

# Name attribute: username
attribute :username,
    :kind_of => String,
    :name_attribute => true, 
    :required => true,
    :regex => [ /^[a-zA-Z0-9_]*[a-zA-Z][a-zA-Z0-9_]*$/ ]

# Other attributes

# User home
attribute :home,
    :kind_of => String

# Primary group for the user
attribute :primary_group,
    :kind_of => String

# List of user groups / gids
attribute :groups,
    :kind_of => Array,
    :default => [ ]

# User comment
attribute :comment,
    :kind_of => String,
    :default => ""

# User shell
attribute :shell,
    :kind_of => String,
    :default => "/bin/bash"

# Whether the user is a system user ( uid < 500 ) ?
attribute :system,
    :kind_of => [ TrueClass, FalseClass ],
    :default => false

# Whether the user will have sudo permissions ?
attribute :sudo,
    :kind_of => [ TrueClass, FalseClass ],
    :default => false

# List of ssh keys to be added to user's authorized_keys
attribute :ssh_keys,
    :kind_of => Array,
    :default => [ ]

# Whether to preserve existing keys already in user's authorized_keys or to overwrite them using ssh_keys ?
attribute :preserve_existing_ssh_keys,
    :kind_of => [ TrueClass, FalseClass ],
    :default => false

# List of skeleton directories to create for the user
attribute :skel_dirs,
    :kind_of => Array,
    :default => [ ]

# Chmod permissions to use for creating the skeleton directories
attribute :skel_dirs_mode,
    :kind_of => Fixnum,
    :default => 00700

def initialize(*args)
  super
  @action = :add
end
