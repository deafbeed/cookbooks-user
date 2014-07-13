#
# Author:: Shamik <shamik@native5.com>
# Cookbook Name:: user
# Provider:: add_user
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

# Support whyrun
def whyrun_supported?
    true
end

# Implement action create
action :add do
    converge_by("Performing add action for user '#{ @new_resource.name }'") do
        # Add user to the system
        create_user

        # Always set the primary group and then set the rest of the groups - will ensure idempotence
        set_user_primary_group

        # Add any defined unix groups for this user
        if @new_resource.groups and !@new_resource.groups.nil? and !@new_resource.groups.empty?
            add_user_groups
        end

        # Add ssh directory for the user
        add_ssh_dir

        # Add / Remove sudo support for the user
        if @new_resource.sudo and !@new_resource.sudo.nil?
            add_sudo_support
        else
            remove_sudo_support
        end

        # Add or set ssh keys depending on whether preserve_existing_ssh_keys is true or false, respectively
        if @new_resource.preserve_existing_ssh_keys
            # Add the additional ssh keys into user's authorized keys if defined
            add_ssh_keys
        else
            # Set provided ssh keys to user's authorized keys
            set_ssh_keys
        end

        # Add any listed skeleton directories
        if !@new_resource.skel_dirs.empty?
            create_skel_dirs
        end
    end
end

# Implement action remove
action :remove do
    converge_by("Performing delete action for user '#{ @new_resource.name }'") do
        remove_sudo_support
        remove_user
    end
end

def load_current_resource
    @current_resource = Chef::Resource::UserManage.new(@new_resource.name)
end

# Create the user using the chef user resource
def create_user
    Chef::Log.debug "Adding user '#{ new_resource.name }'"

    user "add_user" do
        username    new_resource.name
        comment     new_resource.comment
        #gid         new_resource.primary_group || new_resource.name
        home        new_resource.home || "/home/#{ new_resource.name }"
        shell       new_resource.shell
        system      new_resource.system
        supports    :manage_home => true
        action      :create
    end
end

# Delete the user using the chef user resource
def remove_user
    Chef::Log.debug "Deleting user '#{ new_resource.name }'"

    user "remove_user" do
        username    new_resource.name
        action      :remove
    end
end

# Set primary unix group for user
def set_user_primary_group
    userPrimaryGroup = new_resource.primary_group || new_resource.name

    # Ensure the group is added to the system before adding it to the user
    add_group(userPrimaryGroup)

    Chef::Log.debug "Setting primary group '#{ userPrimaryGroup }' for user '#{ new_resource.name }'"

    execute "add_user_primary_group" do
        command "usermod -g #{ userPrimaryGroup } #{ new_resource.name }"
        action  :run
    end
end

# Add additional groups for the user
def add_user_groups
    new_resource.groups.each do |userGroup|
        # Ensure the group is added to the system before adding it to the user
        add_group(userGroup)
    
        Chef::Log.debug "Adding unix group '#{ userGroup }' for user '#{ new_resource.name }'"

        execute "add_user_group_#{ userGroup }" do
            command "usermod -G #{ userGroup } #{ new_resource.name }"
            action  :run
        end
    end
end

def add_group(g)
    Chef::Log.debug "Adding unix group '#{ g }'"

    group g do
        action :create
    end
end

# Create file /etc/sudoers.d/<username>
def add_sudo_support
    Chef::Log.debug "Adding sudo support for user '#{ new_resource.name }'"

    template "add_sudoers_file" do
        path        "/etc/sudoers.d/#{ new_resource.name }"
        source      "sudoers/enable_user.erb"
        owner       "root"
        mode        00640
        cookbook    "user"
        action      :create_if_missing
        variables(
            :username => new_resource.name
        )
    end
end

# Remove file /etc/sudoers.d/<username>
def remove_sudo_support
    Chef::Log.debug "Removing sudo support for user '#{ new_resource.name }'"

    file "/etc/sudoers.d/#{ new_resource.name }" do
        action :delete
    end
end

# Create ~/.ssh dir if not present
def add_ssh_dir
    userHome = new_resource.home || "/home/#{ new_resource.name }"

    Chef::Log.debug "Adding user's .ssh directory '#{ userHome }/.ssh'"

    directory "create_user_ssh_dir" do
        owner       new_resource.name
        group       new_resource.primary_group || new_resource.name
        mode        0700
        recursive   true
        path        "#{ userHome }/.ssh"
        action      :create
    end
end

# Set ssh keys - overwrites user's ~/.ssh/authorized_keys
def set_ssh_keys
    userHome = new_resource.home || "/home/#{ new_resource.name }"

    Chef::Log.debug "Overwriting user's authorized ssh keys"

    # Overwrite the ~/.ssh/authorized_keys
    template "set_ssh_authorized_keys" do
        path        "#{ userHome }/.ssh/authorized_keys"
        source      "ssh/authorized_keys.erb"
        owner       new_resource.name
        group       new_resource.primary_group || new_resource.name
        mode        00600
        cookbook    "user"
        action      :create
        variables(
            :sshKeys => new_resource.ssh_keys
        )
    end
end

# Add additional ssh keys to ~/.ssh/authorized_keys
def add_ssh_keys
    userHome = new_resource.home || "/home/#{ new_resource.name }"

    Chef::Log.debug "Adding provided ssh keys to authorized ssh keys"

    # Do not overwrite the ~/.ssh/authorized_keys - append each ssh key to it
    new_resource.ssh_keys.each do |sshKey|
        execute "insert_new_ssh_keys" do
            command "grep -q \"#{ sshKey }\" \"#{ userHome }/.ssh/authorized_keys\" || \
                        echo \"#{ sshKey }\" >> \"#{ userHome }/.ssh/authorized_keys\""
            action  :run
        end
    end
end

# Create skeleton dirs for this user
def create_skel_dirs
    userHome = new_resource.home || "/home/#{ new_resource.name }"

    new_resource.skel_dirs.each do |skelDir|
        Chef::Log.debug "Adding user skel directory '#{userHome}/#{ skelDir }'"

        directory "#{ userHome }/#{ skelDir }" do
            owner       new_resource.name
            group       new_resource.primary_group || new_resource.name
            recursive   true
            path        "#{ userHome }/#{ skelDir }"
            mode        new_resource.skel_dirs_mode
            action      :create
        end
    end
end

