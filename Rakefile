require 'dotenv/load'
require 'open3'
require 'rake'
require_relative 'core/engine'
require_relative 'core/game_view'

namespace :deploy do
  desc 'Deploy to production'
  task :production do
    engine = Engine.new('./data/game_data.yml')
    def log_message(engine, message)
      response = "DEPLOYMENT: #{message}"
      puts GameView.format_response(engine, response)
    end

    begin
      log_message(engine, 'Starting deployment...')
      user = ENV['USER']
      host = ENV['HOST']
      remote_dir = ENV['REMOTE_DIR']
      nginx_dir = ENV['NGINX_DIR']

      log_message(engine, 'Pushing to GitHub...')
      system('git push origin dev') or raise 'Failed to push to GitHub'

      log_message(engine, 'Connecting to server...')
      ssh_commands = [
        "cd #{remote_dir}",
        'git pull origin dev',
        "sudo cp ui/index.html #{nginx_dir}/index.html",
        "sudo chmod 755 #{nginx_dir}/index.html",
        'sudo systemctl restart dungeon-gangstas'
      ]

      ssh_command = "ssh #{user}@#{host} '#{ssh_commands.join(' && ')}'"
      log_message(engine, "Executing: #{ssh_command}")

      stdout, stderr, status = Open3.capture3(ssh_command)

      raise "Deployment failed on server: #{stderr}" unless status.success?

      log_message(engine, 'Deployment completed successfully.')
      log_message(engine, "Output: #{stdout}")
    rescue StandardError => e
      log_message(engine, "Deployment failed: #{e.message}")
      exit 1
    end
  end
end
