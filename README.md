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
