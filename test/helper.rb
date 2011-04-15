require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'active_support'
require 'resque'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'resque-requeue_worker'

class TestJob
  @queue = :test_jobs
  
  def self.perform(name, time = 0)
    Process.setpriority(Process::PRIO_PROCESS, 0 , -1)
    Resque.redis.set("#{name}",nil)
    sleep(time)
    Resque.redis.set("#{name}",'done')
  end
end