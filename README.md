# Description

Installs the CloudWatch Logs client and enables easy configuration of multiple
logs via attributes.

## Supported OS

Currently all linux OS's are supported.

On Amazon Linux the yum package will be used.

## Usage

Logs are configured by appending to the `['cwlogs']['logfiles']` attribute from
any recipe.  You can configure as many logs as needed.  Simply include the
default cwlogs recipe in your runlist after all recipes which define a log.

If you do not want each chef run to risk pulling in the latest cloudwatch
installer from AWS, then you can set the following attribute to `false`:

```ruby
['cwlogs']['attempt_upgrade'] = false
```

The CloudWatch agent no longer supports installs using Python 2.6. On systems with Python 2.6 set as default, you will need a newerv version of Python installed (2.7 minimum). You can then set the `default['cwlogs']['python_bin']` attribute to point to the >= 2.7 executable. 

```ruby
default['cwlogs']['python_bin'] = '/usr/bin/python2.7'
```

Some systems require a root SSL certificate in order for python/pip to access remote https endpoints. For that purpose, you can specify a location to your system's root cert bundle using the `default['cwlogs']['ca_bundle']` attribute.

```ruby
default['cwlogs']['ca_bundle'] = '/path/to/my/bundle.pem'
```

You may want to provide your own installation file instead of using the default location from Amazon. To do so, update the `default['cwlogs']['installation_file_source']` attribute.

```ruby
default['cwlogs']['installation_file_source'] = 'https://your.internal.domain.org/path/to/installer.py'
default['cwlogs']['installation_file_source'] = '/path/on/your/filesystem'
```

## Example

```ruby
default['cwlogs']['logfiles']['mysite-httpd_access'] = {
  :log_stream_name  => '{instance_id}-{hostname}',
  :log_group_name   => 'mysite-httpd_access-group',
  :file             => '/var/log/httpd/mysite.com/access_log',
  :datetime_format  => '%d/%b/%Y:%H:%M:%S %z',
  :initial_position => 'end_of_file'
}

default['cwlogs']['logfiles']['mysite-httpd_error'] = {
  :log_stream_name  => '{instance_id}-{hostname}',
  :log_group_name   => 'mysite-httpd_error-group',
  :file             => '/var/log/httpd/mysite.com/error_log',
  :datetime_format  => '%d/%b/%Y:%H:%M:%S %z',
  :initial_position => 'end_of_file'
}

default['cwlogs']['logfiles']['mysite-mod_security_log'] = {
  :log_stream_name          => '{instance_id}-{hostname}',
  :log_group_name           => 'mysite-mod_security_log',
  :file                     => '/var/log/modsec_audit.log',
  :datetime_format          => '[%d/%b/%Y:%H:%M:%S %z]',
  :multi_line_start_pattern => '^--([0-9a-fA-F]*){8}-[A]{1}--',
  :initial_position         => 'end_of_file'
}
```

From any attributes file will generate the following CloudWatch Logs config:

```ini
[mysite-httpd_access]
log_stream_name = {instance_id}-{hostname}
log_group_name = mysite-httpd_access-group
file = /var/log/httpd/mysite.com/access_log
datetime_format = %d/%b/%Y:%H:%M:%S %z
initial_position = end_of_file

[mysite-httpd_error]
log_stream_name = {instance_id}-{hostname}
log_group_name = mysite-httpd_error-group
file = /var/log/httpd/mysite.com/error_log
datetime_format = %d/%b/%Y:%H:%M:%S %z
initial_position = end_of_file

[mysite-mod_security_log]
log_stream_name = {instance_id}-{hostname}
log_group_name = mysite-mod_security_log
file = /var/log/modsec_audit.log
datetime_format = [%d/%b/%Y:%H:%M:%S %z]
multi_line_start_pattern = ^--([0-9a-fA-F]*){8}-[A]{1}--
initial_position = end_of_file
```

All hash elements will pass through to the config file, so for example you can
use `encoding` or any other supported config element.

> See the [AWS CloudWatch Logs configuration reference][1] for details.

[1]: http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/AgentReference.html
