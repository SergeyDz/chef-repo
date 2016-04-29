Chef::Log.info("******Start vagrant environments.******")
command = 'restart'

chef_gem 'chef-vault' do
  compile_time true if respond_to?(:compile_time)
end

require 'chef-vault'

item = ChefVault::Item.load("passwords", "chef")
user = item["username"]
password = item["password"]
Chef::Log.info("USERNAME=" + user)
Chef::Log.info("Inline username: #{user}")

powershell "vagrant" do
 code <<-EOH
#
Invoke-Expression "C:/chef/vagrant.credssp.ps1 #{user} #{password} #{command}"
#
  EOH

end



