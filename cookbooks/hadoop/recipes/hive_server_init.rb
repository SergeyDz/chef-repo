include_recipe 'hadoop::default'
include_recipe 'hadoop::hive_server'

ruby_block 'initaction-start-hive-server-service' do
  block do
    resources('service[hive-server]').run_action(:start)
  end
end

