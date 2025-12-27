require '/home/msf/msf-autorunscripts/session_liveness_cleaner'

fm = if defined?(framework)
  framework
elsif defined?(client) && client.respond_to?(:framework)
  client.framework
end

if fm.nil?
  puts("No framework context found. Run this from msfconsole IRB.")
else
  logger = defined?(client) ? client : nil
  SessionLivenessCleaner.run(fm, logger)
end
