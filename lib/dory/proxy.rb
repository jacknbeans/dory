require_relative 'docker_service'

module Dory
  class Proxy
    extend Dory::DockerService

    def self.dory_http_proxy_image_name
      setting = Dory::Config.settings[:dory][:nginx_proxy][:image]
      return setting if setting
      certs_dir && !certs_dir.empty? \
        ? 'codekitchen/dinghy-http-proxy:2.5.10' \
        : 'freedomben/dory-http-proxy:2.6.2.2'
    end

    def self.container_name
      Dory::Config.settings[:dory][:nginx_proxy][:container_name]
    end

    def self.certs_dir
      Dory::Config.settings[:dory][:nginx_proxy][:ssl_certs_dir]
    end

    def self.docker_sock_file
      Dory::Config.settings[:dory][:nginx_proxy][:docker_sock_file]
    end

    def self.certs_arg
      if certs_dir && !certs_dir.empty?
        "-v #{certs_dir}:/etc/nginx/certs"
      else
        ''
      end
    end

    def self.tls_arg
      if [:tls_enabled, :ssl_enabled, :https_enabled].any? { |s|
          Dory::Config.settings[:dory][:nginx_proxy][s]
         }
        "-p #{Dory::Config.settings[:dory][:nginx_proxy][:tls_port]}:443"
      else
        ''
      end
    end

    def self.docker_sock_arg
      if self.docker_sock_file && !File.exist?(self.docker_sock_file)
        "/var/run/docker.sock"
      else
        self.docker_sock_file
      end
    end

    def self.http_port
      Dory::Config.settings[:dory][:nginx_proxy][:port]
    end

    def self.run_command
      "docker run -d -p #{http_port}:80 #{self.tls_arg} #{self.certs_arg} "\
        "-v #{self.docker_sock_arg}:/tmp/docker.sock -e " \
        "'CONTAINER_NAME=#{Shellwords.escape(self.container_name)}' --name " \
        "'#{Shellwords.escape(self.container_name)}' " \
        "#{Shellwords.escape(dory_http_proxy_image_name)}"
    end

    def self.start_cmd
      "docker start #{Shellwords.escape(self.container_name)}"
    end
  end
end
