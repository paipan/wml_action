require 'logger'

module WMLAction

  module Log
    @@log ||= Logger.new(STDERR)
    @@log.sev_threshold = Logger::DEBUG

    def log
      @@log
    end

    def level=(l)
      @@log.sev_threshold = l
    end

  end

end
