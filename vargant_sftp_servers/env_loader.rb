def load_env(file = ".env")
  return unless File.exist?(file)
  File.foreach(file) do |line|
    next if line.strip.empty? || line.start_with?('#')
    key, value = line.strip.split('=', 2)
    ENV[key] = value
  end
end

load_env