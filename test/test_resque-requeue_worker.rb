require 'helper'

class TestResqueRequeueWorker < Test::Unit::TestCase
  SIGNALS_TO_REQUEUE=%w(TERM INT KILL)

  def setup
    Resque.redis.flushall
    @worker = Resque::Plugins::RequeueWorker.new(:test_jobs)
  end

  should "be a valid plugin" do
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::RequeueWorker)
    end
  end

  SIGNALS_TO_REQUEUE.each do |sig|
    should "recreate job if #{sig} signal is received" do
      Resque.enqueue(TestJob, sig, 0)
      old_job = Resque.peek('test_jobs')
      @worker.register_signal_handlers
      child_pid = Process.fork {
        @worker.perform(Resque::Job.reserve('test_jobs'))
      }

      Process.kill(sig, child_pid)
      Process.waitpid(child_pid)
      assert Resque.redis.get(sig) != 'done', "job was completed"
      assert job = Resque.peek('test_jobs'), "There are no jobs in Resque"
      assert old_job == job, "Job #{old_job.inspect} is not #{job.inspect}"
    end
  end
end
