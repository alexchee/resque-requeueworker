module Resque
  module Plugins
    class RequeueWorker < Resque::Worker
      include Resque::Helpers
      extend Resque::Helpers

      attr_accessor :current_job
      attr_accessor :has_finished

      # Processes a given job in the child.
      def perform(job)
        self.current_job = job
        self.has_finished = false
        begin
          run_hook :after_fork, job
          job.perform
          self.has_finished = true
        rescue Object => e
          log "#{job.inspect} failed: #{e.inspect}"
          begin
            job.fail(e)
          rescue Object => e
            log "Received exception when reporting failure: #{e.inspect}"
          end
          failed!
        else
          log "done: #{job.inspect}"
        ensure
          yield job if block_given?
        end
      end

      # 
      # Registers the various signal handlers a worker responds to.
      #
      # TERM: Recreates job, shutdown immediately, stop processing jobs.
      #  INT: Recreates job, shutdown immediately, stop processing jobs.
      # KILL: Recreates job, shutdown immediately, stop processing jobs.
      # QUIT: Shutdown after the current job has finished processing.
      # USR1: Kill the forked child immediately, continue processing jobs.
      # USR2: Don't process any new jobs
      # CONT: Start processing jobs again after a USR2
      # 
      def register_signal_handlers
        log! "Registering signals"
        super
        
        trap('TERM') { 
          log "received TERM, attempting to requeue"
          reinsert_into_queue
          shutdown!
          }
        trap('INT')  { 
          log "received INT, attempting to requeue"
          reinsert_into_queue
          shutdown!
        }
        trap ('KILL') {
          log "received KILL, attempting to requeue"
          reinsert_into_queue
          shutdown!
        }
        
        log! "Registered signals"
      end
  
      # 
      # Puts job back into resque
      # 
      def reinsert_into_queue
        log "Adding '#{self.current_job.inspect}' back to queue"
        self.current_job.recreate if self.current_job && !self.has_finished
      end
  
    end
  end
end