include_recipe 'hadoop::default'
include_recipe 'hadoop::hadoop_mapreduce_historyserver'
include_recipe 'hadoop::hadoop_mapreduce_jobtracker'
include_recipe 'hadoop::hadoop_mapreduce_tasktracker'


ruby_block 'initaction-start-mapreduce-historyserver-service' do
  block do
    resources('service[hadoop-mapreduce-historyserver]').run_action(:start)
  end
end


#ruby_block 'initaction-start-mapreduce-jobtracker-service' do
#  block do
#    resources('service[hadoop-yarn-resourcemanager]').run_action(:start)
#  end
#end

#ruby_block 'initaction-start-mapreduce-tasktracker-service' do
#  block do
#    resources('service[hadoop-yarn-resourcemanager]').run_action(:start)
#  end
#end



