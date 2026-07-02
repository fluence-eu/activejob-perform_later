# frozen_string_literal: true

require "test_helper"

class ExportService
  RESULTS = []

  perform_later_job do
    queue_as :exports
  end

  perform_later_job :heavy_export do
    queue_as :heavy
  end

  perform_later_job :purge! do
    queue_as :purge
  end

  def self.heavy_export(label)
    RESULTS << [:heavy, label]
  end

  def self.light_export(label)
    RESULTS << [:light, label]
  end

  def self.purge!
    RESULTS << :purged
  end
end

class StandaloneService
  perform_later_job :solo do
    queue_as :solo
  end

  def self.solo; end
end

class MacroMethodTest < AJPLTestCase
  setup { ExportService::RESULTS.clear }

  test "method job constant is named after the method" do
    assert ExportService.const_defined?(:HeavyExportPerformLaterJob, false)
    assert_equal "ExportService::HeavyExportPerformLaterJob",
                 ExportService::HeavyExportPerformLaterJob.name
  end

  test "punctuation is stripped from the constant name" do
    assert ExportService.const_defined?(:PurgePerformLaterJob, false)
  end

  test "method job inherits the class job so rules cumulate" do
    assert_operator ExportService::HeavyExportPerformLaterJob, :<, ExportService::PerformLaterJob
  end

  test "without a class job the method job inherits the base job" do
    assert_equal ActiveJob::Base, StandaloneService::SoloPerformLaterJob.superclass
  end

  test "resolution priority is method job, then class job, then generic" do
    assert_enqueued_with(job: ExportService::HeavyExportPerformLaterJob, queue: "heavy") do
      ExportService.perform_later.heavy_export("big")
    end
    assert_enqueued_with(job: ExportService::PerformLaterJob, queue: "exports") do
      ExportService.perform_later.light_export("small")
    end
    assert_enqueued_with(job: ActiveJob::PerformLater::Job) do
      TestService.perform_later.build("x")
    end
  end

  test "constant collision raises at load" do
    err = assert_raises(ArgumentError) do
      Class.new do
        def self.a; end
        def self.a!; end
        perform_later_job(:a) { queue_as :x }
        perform_later_job(:a!) { queue_as :y }
      end
    end
    assert_match(/already defined/, err.message)
  end

  test "method job performs end to end" do
    perform_enqueued_jobs { ExportService.perform_later.purge! }
    assert_equal [:purged], ExportService::RESULTS
  end
end
