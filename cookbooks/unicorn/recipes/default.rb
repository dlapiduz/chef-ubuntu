#
# Author:: Adam Jacob <adam@opscode.com>
# Cookbook Name:: unicorn
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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

gem_package "unicorn"

node.default[:unicorn][:worker_timeout] = 60
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
node.default[:unicorn][:preload_app] = false
node.default[:unicorn][:before_fork] = 'sleep 1' 
node.default[:unicorn][:port] = '8080'
node.set[:unicorn][:options] = { :tcp_nodelay => true, :backlog => 100 }

unicorn_config "/etc/unicorn/#{node[:app]['id']}.rb" do
  app_id node[:app][:id]
  listen({ node[:unicorn][:port] => node[:unicorn][:options] })
  working_directory ::File.join(node[:app]['deploy_to'], 'current')
  worker_timeout node[:unicorn][:worker_timeout] 
  preload_app node[:unicorn][:preload_app] 
  worker_processes node[:unicorn][:worker_processes]
  before_fork node[:unicorn][:before_fork] 
end

template "/etc/init.d/unicorn_init" do
  source "unicorn_init.erb"
  mode 0751

  variables(
    :deploy_to => node[:app][:deploy_to],
    :app_id => node[:app][:id]
  )
end

directory "/tmp/unicorn" do
  owner "deploy"
  mode "0755"
  action :create
end
