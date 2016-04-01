#
# Cookbook Name:: maven
# Attributes:: default
#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
#
# Copyright:: Copyright (c) 2010-2015, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['maven']['m2_home'] = '/usr/local/maven'
default['maven']['mavenrc']['opts'] = '-Dmaven.repo.local=$HOME/.m2/repository -Xmx384m'
default['maven']['version'] = '3.3.9'
default['maven']['url'] = "http://apache.mirrors.tds.net/maven/maven-#{node['maven']['version'].split('.')[0]}/#{node['maven']['version']}/binaries/apache-maven-#{node['maven']['version']}-bin.tar.gz"
default['maven']['checksum'] = '6e3e9c949ab4695a204f74038717aa7b2689b1be94875899ac1b3fe42800ff82'
default['maven']['plugin_version'] = '2.10'
default['maven']['repositories'] = ['http://repo1.maven.apache.org/maven']
default['maven']['setup_bin'] = false
