# frozen_string_literal: true

require "test_helper"

class ApplicationJobStub < ActiveJob::Base
  queue_as :app_default
end

class BaseJobTest < AJPLTestCase
  teardown { ActiveJob::PerformLater.base_job = "ActiveJob::Base" }

  test "default base job is ActiveJob::Base" do
    assert_equal ActiveJob::Base, ActiveJob::PerformLater.resolved_base_job
  end

  test "accepts a string resolved lazily" do
    ActiveJob::PerformLater.base_job = "ApplicationJobStub"
    assert_equal ApplicationJobStub, ActiveJob::PerformLater.resolved_base_job
  end

  test "accepts a class directly" do
    ActiveJob::PerformLater.base_job = ApplicationJobStub
    assert_equal ApplicationJobStub, ActiveJob::PerformLater.resolved_base_job
  end

  test "generated jobs inherit the configured base job" do
    ActiveJob::PerformLater.base_job = "ApplicationJobStub"
    Object.const_set(:BillingService, Class.new do
      perform_later_job { retry_on IOError }
      def self.charge; end
    end)

    assert_operator BillingService::PerformLaterJob, :<, ApplicationJobStub
    assert_equal "app_default", BillingService::PerformLaterJob.new.queue_name
  ensure
    Object.send(:remove_const, :BillingService) if Object.const_defined?(:BillingService)
  end
end
