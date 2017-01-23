include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_yarn_resourcemanager'

ruby_block 'initaction-start-yarn-resourcemanager-service' do
  block do
    resources('service[hadoop-yarn-resourcemanager]').run_action(:start)
  end
end

