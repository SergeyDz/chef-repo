#
# Cookbook Name:: hadoop
# Recipe:: spark_historyserver
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

include_recipe 'hadoop::spark'
pkg = 'spark-history-server'

dfs = node['hadoop']['core_site']['fs.defaultFS']

execute 'hdfs-spark-userdir' do
  command "hdfs dfs -mkdir -p #{dfs}/user/spark && hdfs dfs -chown -R spark:spark #{dfs}/user/spark"
  user 'hdfs'
  group 'hdfs'
  timeout 300
  action :nothing
end

eventlog_dir =
  if node['spark']['spark_defaults'].key?('spark.eventLog.dir')
    node['spark']['spark_defaults']['spark.eventLog.dir']
  else
    'hdfs:///user/spark/applicationHistory'
  end

execute 'hdfs-spark-eventlog-dir' do
  command "hdfs dfs -mkdir -p #{eventlog_dir} && hdfs dfs -chown -R spark:spark #{eventlog_dir} && hdfs dfs -chmod 1777 #{eventlog_dir}"
  user 'hdfs'
  group 'hdfs'
  timeout 300
  action :nothing
end

spark_log_dir =
  if node['spark'].key?('spark_env') && node['spark']['spark_env'].key?('spark_log_dir')
    node['spark']['spark_env']['spark_log_dir']
  else
    '/var/log/spark'
  end

# Create /etc/default configuration
template "/etc/default/#{pkg}" do
  source 'generic-env.sh.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'spark_home' => "#{hadoop_lib_dir}/spark",
    'spark_pid_dir' => '/var/run/spark',
    'spark_log_dir' => spark_log_dir,
    'spark_ident_string' => 'spark',
    'spark_history_server_log_dir' => eventlog_dir,
    'spark_history_opts' => '$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=${SPARK_HISTORY_SERVER_LOG_DIR}',
    'spark_conf_dir' => '/etc/spark/conf'
  }
end

template "/etc/init.d/#{pkg}" do
  source 'hadoop-init.erb'
  mode '0755'
  owner 'root'
  group 'root'
  action :create
  variables :options => {
    'desc' => 'Spark History Server',
    'name' => pkg,
    'process' => 'java',
    'binary' => "#{hadoop_lib_dir}/spark/bin/spark-class",
    'args' => 'org.apache.spark.deploy.history.HistoryServer > ${LOG_FILE} 2>&1 < /dev/null &',
    'confdir' => '${SPARK_CONF_DIR}',
    'user' => 'spark',
    'home' => "#{hadoop_lib_dir}/spark",
    'pidfile' => "${SPARK_PID_DIR}/#{pkg}.pid",
    'logfile' => "${SPARK_LOG_DIR}/#{pkg}.log"
  }
end

service pkg do
  status_command "service #{pkg} status"
  supports [:restart => true, :reload => false, :status => true]
  action :nothing
end
