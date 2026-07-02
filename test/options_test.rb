# frozen_string_literal: true

require "test_helper"

class OptionsTest < AJPLTestCase
  test "queue and priority are passed through to set" do
    assert_enqueued_with(job: ActiveJob::PerformLater::Job, queue: "low", priority: 5) do
      TestService.perform_later(queue: :low, priority: 5).build("x")
    end
  end

  test "wait schedules the job" do
    freeze_time do
      assert_enqueued_with(job: ActiveJob::PerformLater::Job, at: 10.minutes.from_now) do
        TestService.perform_later(wait: 10.minutes).build("x")
      end
    end
  end

  test "wait_until schedules the job" do
    freeze_time do
      assert_enqueued_with(job: ActiveJob::PerformLater::Job, at: 2.hours.from_now) do
        TestService.perform_later(wait_until: 2.hours.from_now).build("x")
      end
    end
  end

  test "the proxy call returns the enqueued job instance" do
    job = TestService.perform_later.build("x")
    assert_kind_of ActiveJob::PerformLater::Job, job
    assert_equal ["TestService", "build", ["x"], {}], job.arguments
  end
end
