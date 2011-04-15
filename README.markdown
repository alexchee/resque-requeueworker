resque-requeueworker
====================

Resque::Plugins::RequeueWorker is an alternative to the standard Worker class. 

This class works by storing the current job and overriding hooks to TERM, INT, 
and KILL signals. If any of the monitored signals are received, the worker will 
recreate the job and shutdown the worker. The original worker only shutdowns 
the worker and the job is lost if the worker does not complete it.

This is original designed for EC2 spot instances where 
machines could suddenly terminate and sends these signals to the workers.

To use RequeueWorker, run this: 
    require 'resque/plugins/requeue_worker'
    Resque::Plugins::RequeueWorker.new(*queues)
  
Here is a sample rake task:

    require 'resque/tasks'
    require 'resque/plugins/requeue_worker'
    
    namespace :resque do
      desc "Start a Resque worker"
      task :requeue_work => :setup do
        require 'resque'
    
        queues = (ENV['QUEUES'] || ENV['QUEUE']).to_s.split(',')
    
        begin
          worker = Resque::Plugins::RequeueWorker.new(*queues)
          worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
          worker.very_verbose = ENV['VVERBOSE']
        rescue Resque::NoQueueError
          abort "set QUEUE env var, e.g. $ QUEUE=critical,high rake resque:work"
        end
    
        if ENV['PIDFILE']
          File.open(ENV['PIDFILE'], 'w') { |f| f << worker.pid }
        end
    
        worker.log "Starting worker #{worker}"
    
        worker.work(ENV['INTERVAL'] || 5) # interval, will block
      end
    end


Thanks to the Resque community for keeping great documentation and clean code.

Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2011 Alex Chee. See LICENSE for details.