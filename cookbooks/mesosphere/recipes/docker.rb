# install custom packages here

package 'docker' do
	package_name 'docker'
	action :install
end

file '/etc/default/docker' do
    content 'iptables=false'
    mode '777'
end

service 'docker' do
    action :start
end
