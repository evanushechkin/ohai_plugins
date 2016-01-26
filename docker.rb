Ohai.plugin(:DockerContainers) do

  provides "docker_containers"

  collect_data(:linux) do
    if find_docker
      docker_containers Mash.new
      docker_containers[:version]             = get_version
      docker_containers[:containers]          = get_containers
      docker_containers[:images]              = get_images
      docker_containers[:container_config]    = get_config
    end
  end

  def find_docker
    so = shell_out("/bin/bash -c 'command -v docker'")
    docker_bin = so.stdout.strip
    return docker_bin unless docker_bin.empty?
  end

  def get_version
    so = shell_out('docker -v 2>&1')
    so.stdout.lines.each do |line|
      case line
      when /^Docker version \/(\d+\.\d+\.\d+)/
        return $1
      end
    end
  end
  def get_containers
    containers = {}
    so = shell_out('docker ps -a')
    containers = so.stdout.lines
    return containers
  end

  def get_config
    configs = {}
    so = shell_out('docker ps -a | awk {'print $1'}')
    so.stdout.lines.each do |line|
      configs = shell_out('docker inspect #{line}')
    end
  end


end
