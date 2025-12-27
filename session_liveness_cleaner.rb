module SessionLivenessCleaner
  PROBE_MARKER = "__msf_alive__".freeze

  def self.run(fm, logger = nil)
    fm.sessions.each do |sid, sess|
      next unless sess

      if session_active?(sess)
        log(logger, "Session #{sid} is active.")
        next
      end

      log(logger, "Session #{sid} appears inactive; terminating.")
      safely_kill(sess, logger, sid)
    end
  end

  def self.session_active?(sess)
    return false unless sess

    if sess.respond_to?(:alive?)
      return false unless sess.alive?
    end

    probe_session(sess)
  rescue StandardError
    false
  end

  def self.probe_session(sess)
    if sess.respond_to?(:shell_command_token)
      output = sess.shell_command_token("echo #{PROBE_MARKER} 2>/dev/null")
      return output.to_s.include?(PROBE_MARKER)
    end

    if sess.respond_to?(:sys) && sess.sys.respond_to?(:config)
      sess.sys.config.getuid
      return true
    end

    if sess.respond_to?(:info)
      sess.info
      return true
    end

    true
  end

  def self.safely_kill(sess, logger, sid)
    sess.kill
  rescue StandardError => e
    log(logger, "Failed to terminate session #{sid}: #{e.message}")
  end

  def self.log(logger, message)
    if logger&.respond_to?(:print_status)
      logger.print_status(message)
    else
      puts(message)
    end
  end
end
