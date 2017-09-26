proxy_env = ENV.select { |k, v| %w(http_proxy https_proxy no_proxy).include?(k) && !v.empty? }
proxy_args = proxy_env.map { |k,v| "--#{k.gsub('_','-')} '#{v}'" }.join(' ')
python_bin = node['cwlogs']['python_bin']
ca_bundle = node['cwlogs']['ca_bundle']
python_flag = if ! python_bin.nil? && ! python_bin.strip.empty?then "--python=#{python_bin}" else '' end 
environment = {
  'REQUESTS_CA_BUNDLE' => if ! ca_bundle.nil? && ! ca_bundle.strip.empty? then ca_bundle else '' end 
}

service 'awslogs' do
  # awslogs service is created, enabled, and started by the installer at the end of this recipe, but we need to declare
  # a chef resource for the template to notify
  action :nothing
end

template '/tmp/cwlogs.cfg' do
  source 'awslogs.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables ({
    :logfiles => node['cwlogs']['logfiles']
  })
  notifies :restart, 'service[awslogs]'
end

directory '/opt/aws/cloudwatch' do
  recursive true
end

remote_file '/opt/aws/cloudwatch/awslogs-agent-setup.py' do
  source node['cwlogs']['installation_file_source']
  mode '0755'
  action node['cwlogs']['attempt_upgrade'] ? :create : :create_if_missing
  notifies :run, 'execute[Install CloudWatch Logs agent]', :immediately
end

execute 'Install CloudWatch Logs agent' do
  command "/opt/aws/cloudwatch/awslogs-agent-setup.py -n #{python_flag} -r #{node['cwlogs']['region']} -c /tmp/cwlogs.cfg #{proxy_args}"
  environment environment
  guard_interpreter :bash
  not_if 'pgrep -f awslogs-agent-setup >/dev/null'
  action :nothing
end
