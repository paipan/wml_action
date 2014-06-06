require 'logger'

module WmlAction

  module Log
    @@log ||= Logger.new(STDERR)
    @@log.sev_threshold = Logger::ERROR

    def log
      @@log
    end

    def level=(l)
      @@log.sev_threshold = l
    end

  end

end
