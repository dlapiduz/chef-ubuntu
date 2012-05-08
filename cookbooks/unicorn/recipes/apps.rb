app_root = node[:app][:deploy_to]
defaults = Mash.new({
  :pid_path => "#{app_root}/shared/pids/unicorn.pid",
  :worker_count => node[:unicorn][:worker_count],
  :timeout => node[:unicorn][:timeout],
  :socket_path => "/tmp/unicorn/#{node[:app][:id]}.sock",
  :backlog_limit => 1,
  :master_bind_address => '0.0.0.0',
  :master_bind_port => "8080",
  :worker_listeners => true,
  :worker_bind_address => '127.0.0.1',
  :worker_bind_base_port => "8081",
  :debug => false,
  :env => 'production',
  :app_root => app_root,
  :enable => true,
  :config_path => "#{app_root}/current/config/unicorn.conf.rb",
  :use_bundler => true
})

runit_service "unicorn-#{node[:app][:id]}" do
  template_name "unicorn"
  cookbook "unicorn"
  options config
end
  
service "unicorn-#{node[:app][:id]}" do
  action config[:enable] ? [:enable, :start] : [:disable, :stop]
end