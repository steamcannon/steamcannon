class Instance < ActiveRecord::Base
  belongs_to :environment
  belongs_to :image

  DEPLOY_DIR = "/opt/jboss-as6/server/cluster-ec2/farm/"

  def running?
    status == 'running'
  end

  def deploy file
    # `scp -o StrictHostKeyChecking=no #{file} #{public_dns}:#{deploy_path}`
    remote = File.join(deploy_path, File.basename(file))
    ssh do |shell|
      shell.exec!("/opt/jboss-as6/bin/twiddle.sh -s $(hostname -i) invoke jboss.deployment:flavor=URL,type=DeploymentScanner stop")
      shell.scp.upload! file.to_s, remote
      shell.exec!("/opt/jboss-as6/bin/twiddle.sh -s $(hostname -i) invoke jboss.deployment:flavor=URL,type=DeploymentScanner start")
    end
    remote
  end

  def undeploy file
    remote = File.join(deploy_path, File.basename(file))
    ssh do |shell|
      shell.exec! "rm -f #{remote}"
    end
  end

  def list dir = deploy_path
    result = []
    ssh do |shell|
      shell.exec!("ls #{dir}") do |ch, stream, data|
        result = data.split("\n") if stream == :stdout
      end
    end
    result
  end

  def ssh
    options = APP_CONFIG['ssh_private_key_file'] ? {:keys => [APP_CONFIG['ssh_private_key_file']]} : {}
    Net::SSH.start(public_dns, APP_CONFIG['ssh_username'], options) do |shell|
      yield shell
    end
  end

  def deploy_path
    APP_CONFIG['deploy_dir'] || DEPLOY_DIR
  end

end
