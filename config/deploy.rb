set :application, "semanticjournal"

server "myserver", :app, :web, :db, :primary => true

set(:deploy_to) { File.join("", "home", user, application) }

default_run_options[:pty] = true
set :repository,  "git@github.com:Swirrl/semanticjournal.git"
set :scm, "git"
set :scm_passphrase, "passphrase"
set :user, "my_user"
set :runner, "my_user"
set :use_sudo, false

set :branch, "master"

ssh_options[:port] = 2224

namespace :deploy do
  
  desc <<-DESC
    overriding deploy:cold task to not migrate... 
  DESC
  task :cold do
    update
    start
  end
    
  desc <<-DESC
    overriding start to just call restart
  DESC
  task :start do
    restart
  end

  desc <<-DESC
    overriding stop to do nothing - you cant stop a passenger app!
  DESC
  task :stop do
  end

  desc <<-DESC
    overriding start to just touch the restart txt
  DESC
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end