$LOAD_PATH.unshift 'lib'
require 'resque/plugins/requeue_worker_version'

Gem::Specification.new do |s|
  s.name              = "resque-requeue_worker"
  s.version           = Resque::Plugins::RequeueWorker::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Resque plugin for requeueing jobs when worker is killed."
  s.homepage          = "http://github.com:alexchee/resque-requeueworker"
  s.email             = "alex@alex-chee.com"
  s.authors           = [ "Alex Chee" ]

  s.files             = %w( README.markdown Rakefile VERSION LICENSE)
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")
  s.files            += Dir.glob("resque-requeue_worker.gemspec")

  s.extra_rdoc_files  = [ "LICENSE", "README.markdown" ]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.test_files = Dir.glob("test/**/*")

  s.description = <<description
A plugin for Resque that hooks on to signals and recreates current job if it receives TERM, INT, KILL Signals.
description
end

