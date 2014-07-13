Description
===========
Chef LWRP(s) to create / delete / manage user accounts. This is a personal exercise towards writing a chef cookbook which confirms to best practices. It already includes or intends to include complete documentation, unit tests, Berkshelf compatibility, etc. It makes use of the built-in user resource and needs a \*NIX system.

The LWRP(s) presented here are similar to the ones made available by https://github.com/fnichol/chef-user. However, they have been designed as per my own needs.

Requirements
============

Tested on Chef 0.11.6 but newer and older version should work just fine. File an [issue](https://github.com/deafbeed/cookbooks-user/issues) if this isn't the case.

Cookbooks
---------

None

Resources and Providers
===

user\_manage
-------------
**Note**: Always creates user's home directory. 

###Actions

|Action      | Description                       | Default              |
|------------|-----------------------------------|----------------------|
|add       | Add a user                        | Yes                  |
|remove    | Remove a user                     |                      |

###Attributes

|Attribute   | Type      | Description     | Default  |  Mandatory  | Name Attribute  |
|------------|-----------|-----------------|-------|----------------|------|
| username | String      | Username of the user. Follows rules for \*NIX usernames. |  NULL  | Yes | Yes |
| home   | String    | User home directory | /home/{{username}} | |  |
| primary\_group | String | User Primary Group | {{username}} | | |
| groups | Array | List of secondary groups for the user | [ ] | | |
| comment | String | One (or more) comments about the user | NULL | | |
| shell | String | User login shell | /bin/bash | | |
| system | Boolean | Set to create a system user | false | | |
| sudo | Boolean | Set to give user passwordless permissions to user sudo | false | | |
| ssh\_keys | Array | List of ssh keys to add to user's authorized keys | [ ] | | |
| preserve\_existing\_ssh\_keys | Boolean | Set to preserve user's existing ssh keys. Valid only if the user already exists and you are trying to create it again | false | | |
| skel\_dirs | Array | list of directories to create in the user's home directory | [ ] | | |
| skel\_dirs\_mode | Octal | Chmod permissions to give to the created skel\_dirs | 00700 | | |


