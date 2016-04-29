Chef::Log.info("******Refresh vagrant environments.******")

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
    $stream = [System.IO.StreamWriter] "c:/chef/vagrant.ps1"
    $stream.WriteLine("vagrant halt")
    $stream.WriteLine("Stop-Process -processname VBox*")
    $stream.WriteLine("vagrant destroy --force")
    $stream.WriteLine("vagrant up")
    $stream.close()
  EOH
end

powershell "credssp" do
 code <<-EOH
    $stream = [System.IO.StreamWriter] "c:/chef/credssp.ps1"
    $stream.WriteLine("param([string]`$password)")
    $stream.WriteLine("`$pass = ConvertTo-SecureString -AsPlainText `$password -Force");
    $stream.WriteLine("`$cred = New-Object System.Management.Automation.PSCredential -ArgumentList '#{user}', `$pass")
    $stream.WriteLine("invoke-command -Credential `$cred -ComputerName . -ScriptBlock { Invoke-Expression 'C:/chef/vagrant.ps1' } -Authentication Credssp")
    $stream.close()
#
Invoke-Expression "C:/chef/credssp.ps1 #{password}"
#
  EOH

end



