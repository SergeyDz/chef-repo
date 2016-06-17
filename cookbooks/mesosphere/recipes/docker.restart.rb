execute 'docker_restart' do
    command 'service docker restart'
    timeout 60
end