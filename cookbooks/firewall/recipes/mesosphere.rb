# all defaults
firewall 'default'

# enable platform default firewall
firewall 'default' do
  action :install
end

firewall_rule 'marathon' do
	port 8080
	source '0.0.0.0/0'
	command :allow
end

firewall_rule 'zk' do
	port [2181, 2888, 3888]
	source '0.0.0.0/0'
	command :allow
end

firewall_rule 'mesos' do
	port [5050, 5051]
	source '0.0.0.0/0'
	command :allow
end

firewall_rule 'ssh' do
    port 22 
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'kafka' do
    port 7007
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'rabbbit_mq' do
    port [5672, 15672]
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'consul' do
    port [4000, 8500]
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'elk' do
    port [5000, 5061, 9200, 9300]
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'hadoop' do 
    port [8020,8030,8031,8032,8033]
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'hadoop2' do
    port [8088,8090,8040,8042]
    source '0.0.0.0/0'
    command :allow
end

firewall_rule 'hadoop3' do
    port [8188,8190]
    source '0.0.0.0/0'
    command :allow
end



firewall 'default' do
    action [:save, :restart]
end

