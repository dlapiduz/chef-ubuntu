#
# Cookbook Name:: application
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
application node[:app][:id] do
  path node[:app][:deploy_to]
  owner "www-data"
  group "www-data"

  repository "git@coquito.sinaistudio.com:sellarchy_new.git"

  rails do
    # Rails-specific configuration
  end

end
