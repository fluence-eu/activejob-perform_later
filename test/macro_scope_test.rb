# frozen_string_literal: true

require "test_helper"

class DualRecord
  include GlobalID::Identification

  attr_reader :id

  def self.find(id)
    new(id)
  end

  def initialize(id)
    @id = id
  end

  perform_later_job :sync, on: :class do
    queue_as :class_sync
  end

  perform_later_job :sync, on: :instance do
    queue_as :instance_sync
  end

  perform_later_job :report, on: :class do
    queue_as :class_report
  end

  perform_later_job :audit, on: :instance do
    queue_as :instance_audit
  end

  def self.sync; end
  def sync; end
  def self.report; end
  def report; end
  def self.audit; end
  def audit; end
end

class MacroScopeTest < AJPLTestCase
  test "scoped constants coexist without collision" do
    assert DualRecord.const_defined?(:ClassSyncPerformLaterJob, false)
    assert DualRecord.const_defined?(:InstanceSyncPerformLaterJob, false)
  end

  test "class call uses the class-scoped job" do
    assert_enqueued_with(job: DualRecord::ClassSyncPerformLaterJob, queue: "class_sync") do
      DualRecord.perform_later.sync
    end
  end

  test "instance call uses the instance-scoped job" do
    record = DualRecord.new(1)
    assert_enqueued_with(job: DualRecord::InstanceSyncPerformLaterJob, queue: "instance_sync") do
      record.perform_later.sync
    end
  end

  test "instance call ignores a class-scoped job and falls back to the generic job" do
    record = DualRecord.new(2)
    assert_enqueued_with(job: ActiveJob::PerformLater::Job) do
      record.perform_later.report
    end
  end

  test "class call ignores an instance-scoped job and falls back to the generic job" do
    assert_enqueued_with(job: ActiveJob::PerformLater::Job) do
      DualRecord.perform_later.audit
    end
  end

  test "invalid scope raises" do
    assert_raises(ArgumentError) do
      Class.new do
        def self.x; end
        perform_later_job(:x, on: :bidule) { queue_as :nope }
      end
    end
  end

  test "scope without a method name raises" do
    assert_raises(ArgumentError) do
      Class.new { perform_later_job(on: :class) { queue_as :nope } }
    end
  end
end
