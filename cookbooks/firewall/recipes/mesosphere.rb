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


firewall 'default' do
    action [:save, :restart]
end
