firewall_rule 'marathon' do
	port 8080
	protocol :tcp
	command :allow
end

firewall_rule 'zk' do
	port [2181, 2888, 3888]
	protocol :tcp
	command :allow
end

firewall_rule 'mesos' do
	port [5050, 5051]
	protocol :tcp
	command :allow
end


firewall_rule 'ssh' do
    port 22 
    protocol :tcp
    command :allow
end


