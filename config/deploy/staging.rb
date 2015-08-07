set :deploy_to, deploysecret(:deploy_to)
set :branch, :master
set :ssh_options, port: deploysecret(:ssh_port)

set :passenger_restart_with_sudo, false

server deploysecret(:server), user: deploysecret(:user), roles: %w(web app db importer)
