# frozen_string_literal: true

require "test_helper"

class ProxyClassMethodTest < AJPLTestCase
  setup { TestService::RESULTS.clear }

  test "enqueues the generic job with target name, method, args and kwargs" do
    assert_enqueued_with(
      job: ActiveJob::PerformLater::Job,
      args: ["TestService", "build", ["report", 2], { upcase: true }]
    ) do
      TestService.perform_later.build("report", 2, upcase: true)
    end
  end

  test "performs the method with positional and keyword arguments" do
    perform_enqueued_jobs do
      TestService.perform_later.build("report", 2, upcase: true)
    end
    assert_equal [["REPORT", 2]], TestService::RESULTS
  end

  test "the original method stays synchronous" do
    TestService.build("direct")
    assert_equal [["direct", 1]], TestService::RESULTS
    assert_no_enqueued_jobs
  end
end
