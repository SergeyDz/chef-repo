#include_recipe 'hadoop_wrapper::default'
include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_hdfs_namenode'

ruby_block 'initaction-format-hdfs-namenode' do
  block do
    resources('execute[hdfs-namenode-format]').run_action(:run)
  end
end


ruby_block 'initaction-start-hdfs-namenode-service' do
  block do
    resources('service[hadoop-hdfs-namenode]').run_action(:start)
  end
end

