execute 'docker_restart' do
    command 'sudo service docker restart'
    timeout 60
end

