# install custom packages here

package 'docker' do
	package_name 'docker'
	action :install
end

service 'docker' do
    action :start
end
