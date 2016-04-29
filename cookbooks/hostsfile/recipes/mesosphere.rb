
hostsfile_entry '10.1.0.178' do
  hostname  'sdzyuban-mesos-01'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.166' do
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

hostsfile_entry '10.1.1.49' do
  hostname  'sdzyuban-mesos-hp'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.200' do
  hostname  'sdzyuban-mesos-02'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.224' do
  hostname  'sdzyuban-vm-centos'
  action    :create_if_missing
end

hostsfile_entry '10.1.0.188' do
 hostname 'sdzyuban-mesos-04'
 action :create_if_missing
end
