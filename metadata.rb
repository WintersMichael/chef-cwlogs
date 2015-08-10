name             'cloudwatch-logs'
maintainer       'Ben Bridts'
maintainer_email 'ben@cloudar.be'
license          'FreeBSD'
source_url       'https://github.com/WeAreCloudar/chef-cloudwatch-logs'
description      'Installs and configures AWS CloudWatch Logs'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.3'

%w{ ubuntu debian centos redhat fedora amazon}.each do |os|
  supports os
end
