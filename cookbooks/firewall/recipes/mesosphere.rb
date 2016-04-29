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

firewall_rule 'cassandra' do
    port [31000-32000,7000-7001,7199-7199,9042-9042,9160-9160] 
    source '0.0.0.0/0'
    command :allow 
end

firewall_rule 'kafka' do
    port 7007
    source '0.0.0.0/0'
    comand :allow
end

firewall 'default' do
    action [:save, :restart]
end
