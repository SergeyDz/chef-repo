hostsfile_entry '10.1.1.231' do
  hostname  'sdzyuban-mesos-01'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.135' do
  hostname  'sdzyuban-pc'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.77' do
  hostname  'sdzyuban-dell'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.77' do
  hostname  'sdzyuban-ubuntu'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.77' do
 hostname 'sdzyuban-mesos-dell'
 action :create_if_missing
end

hostsfile_entry '10.1.1.233' do
  hostname  'sdzyuban-mesos-hp'
  action    :create_if_missing
end

hostsfile_entry '10.1.1.232' do
  hostname  'sdzyuban-mesos-02'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.224' do
  hostname  'sdzyuban-vm-centos'
  action    :create_if_missing
end

hostsfile_entry '10.1.1.234' do
 hostname 'sdzyuban-mesos-04'
 action :create_if_missing
end
