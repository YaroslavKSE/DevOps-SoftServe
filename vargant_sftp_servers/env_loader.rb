def load_env(file = ".env")
    return unless File.exist?(file)
    File.foreach(file) do |line|
      next if line.strip.empty? || line.start_with?('#')
      key, value = line.strip.split('=', 2)
      ENV[key] = value
    end
  end
  
  load_env
  
  SFTP_USERNAME = ENV['SFTP_USERNAME'] || 'sftpuser'
  SFTP_PASSWORD = ENV['SFTP_PASSWORD'] || 'password'
  
  VM_MEMORY = ENV['VM_MEMORY'] || '512'
  VM_CPUS = ENV['VM_CPUS'] || '1'