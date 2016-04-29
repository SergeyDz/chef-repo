#
# Cookbook Name:: windows-vagrant
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template 'c:\chef\vagrant.start.ps1' do
    source 'vagrant.command.erb'
    variables :commands => [
	'vagrant up'
    ]
end

template 'c:\chef\vagrant.stop.ps1' do
    source 'vagrant.command.erb'
    variables :commands => [
	'vagrant halt'
    ]
end

template 'c:\chef\vagrant.restart.ps1' do
    source 'vagrant.command.erb'
    variables :commands => [
	'vagrant halt',
	'vagrant up'
    ]
end

template 'c:\chef\vagrant.remove.ps1' do
    source 'vagrant.command.erb'
    variables :commands => [
	'vagrant halt',
	'Stop-Process -processname VBox*',
	'vagrant destroy --force'
    ]
end

template 'c:\chef\vagrant.credssp.ps1' do
    source 'credssp.erb'
end