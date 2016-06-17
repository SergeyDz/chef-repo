#
# Cookbook Name:: hadoop
# Recipe:: hive_server
#
# Copyright © 2013-2015 Cask Data, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'hadoop::hive'
include_recipe 'hadoop::_hive_checkconfig'
include_recipe 'hadoop::_system_tuning'
include_recipe 'hadoop::zookeeper'
pkg = 'hive-server2'

hive_conf_dir = "/etc/hive/#{node['hive']['conf_dir']}"

# Setup jaas.conf
if node['hive'].key?('jaas')
  my_vars = {
    # Only use client, for connecting to secure ZooKeeper
    :client => node['hive']['jaas']['client']
  }

  template "#{hive_conf_dir}/jaas.conf" do
    source 'jaas.conf.erb'
    mode '0644'
    owner 'hive'
    group 'hive'
    action :create
    variables my_vars
  end
end # End jaas.conf

hive_log_dir =
  if node['hive'].key?('hive_env') && node['hive']['hive_env'].key?('hive_log_dir')
    node['hive']['hive_env']['hive_log_dir']
  else
    '/var/log/hive'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'hive_home' => "#{hadoop_lib_dir}/hive",
    'hive_pid_dir' => '/var/run/hive',
    'hive_log_dir' => hive_log_dir,
    'hive_ident_string' => 'hive',
    'hive_conf_dir' => hive_conf_dir
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'desc' => 'Hive Server2',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/hive/bin/hive",
    'args' => '--config ${CONF_DIR} --service hiveserver2 > ${LOG_FILE} 2>&1 < /dev/null &',
    'confdir' => '${HIVE_CONF_DIR}',
    'user' => 'hive',
    'home' => "#{hadoop_lib_dir}/hive",
    'pidfile' => "${HIVE_PID_DIR}/#{pkg}.pid",
    'logfile' => "${HIVE_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end
