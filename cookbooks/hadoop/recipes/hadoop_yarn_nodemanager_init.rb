include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_yarn_nodemanager'

ruby_block 'initaction-start-yarn-nodemanager-service' do
  block do
    resources('service[hadoop-yarn-nodemanager]').run_action(:start)
  end
end

