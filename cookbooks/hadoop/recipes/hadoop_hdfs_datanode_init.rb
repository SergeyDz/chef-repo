#include_recipe 'hadoop_wrapper::default'
include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_hdfs_datanode'


ruby_block 'initaction-start-hdfs-datanode-service' do
  block do
    resources('service[hadoop-hdfs-datanode]').run_action(:start)
  end
end

