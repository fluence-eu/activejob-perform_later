# frozen_string_literal: true

require "test_helper"

class ProxyTargetsTest < AJPLTestCase
  setup do
    TestModule::RESULTS.clear
    TestRecord::RESULTS.clear
    TestRecord::REGISTRY.clear
  end

  test "module methods enqueue and perform" do
    assert_enqueued_with(
      job: ActiveJob::PerformLater::Job,
      args: ["TestModule", "cleanup", ["tmp"], {}]
    ) do
      TestModule.perform_later.cleanup("tmp")
    end
    perform_enqueued_jobs
    assert_equal ["tmp"], TestModule::RESULTS
  end

  test "instances travel through GlobalID and are re-found at perform" do
    record = TestRecord.new(42)
    perform_enqueued_jobs do
      record.perform_later.touch("hello", force: true)
    end
    assert_equal [[42, "hello", true]], TestRecord::RESULTS
  end
end
