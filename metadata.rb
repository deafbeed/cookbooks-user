name             'user'
maintainer       'Native5 Software Solutions Pvt. Ltd.'
maintainer_email 'Shamik Datta <shamik@native5.com>'
license          'All rights reserved'
description      'Recipes to create / modify users'
version          '0.1.0'

%w{
    debian
    ubuntu
    centos
    redhat
    scientific
    fedora
    amazon
}.each do |os|
  supports os
end

