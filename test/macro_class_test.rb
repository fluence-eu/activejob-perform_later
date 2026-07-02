# frozen_string_literal: true

require "test_helper"

class ReportService
  RESULTS = []

  perform_later_job do
    queue_as :reports
    retry_on Timeout::Error, attempts: 5
  end

  def self.generate(month)
    RESULTS << month
  end
end

class DiscardingService
  perform_later_job do
    discard_on ArgumentError
  end

  def self.boom
    raise ArgumentError, "boom"
  end
end

class ChildReportService < ReportService
  def self.summarize
    RESULTS << :summary
  end
end

class MacroClassTest < AJPLTestCase
  setup { ReportService::RESULTS.clear }

  test "creates a named job subclass of the base job" do
    assert ReportService.const_defined?(:PerformLaterJob, false)
    assert_equal "ReportService::PerformLaterJob", ReportService::PerformLaterJob.name
    assert_operator ReportService::PerformLaterJob, :<, ActiveJob::Base
  end

  test "proxy enqueues through the class job with its DSL applied" do
    assert_enqueued_with(job: ReportService::PerformLaterJob, queue: "reports",
                         args: ["ReportService", "generate", ["2026-06"], {}]) do
      ReportService.perform_later.generate("2026-06")
    end
  end

  test "block DSL registers retry_on handlers" do
    assert_includes ReportService::PerformLaterJob.rescue_handlers.map(&:first), "Timeout::Error"
  end

  test "discard_on from the block is effective at perform" do
    perform_enqueued_jobs { DiscardingService.perform_later.boom }
    assert_performed_jobs 1
  end

  test "subclasses inherit the parent's job" do
    assert_enqueued_with(job: ReportService::PerformLaterJob) do
      ChildReportService.perform_later.summarize
    end
  end

  test "classes without macro keep the generic job" do
    assert_enqueued_with(job: ActiveJob::PerformLater::Job) do
      TestService.perform_later.build("x")
    end
  end

  test "redeclaring the class job raises" do
    assert_raises(ArgumentError) do
      ReportService.perform_later_job { queue_as :other }
    end
  end

  test "performs end to end through the class job" do
    perform_enqueued_jobs { ReportService.perform_later.generate("2026-05") }
    assert_equal ["2026-05"], ReportService::RESULTS
  end
end
