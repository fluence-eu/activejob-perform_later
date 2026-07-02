# frozen_string_literal: true

require "test_helper"

class GuardsTest < AJPLTestCase
  test "typo raises NoMethodError at enqueue and enqueues nothing" do
    assert_no_enqueued_jobs do
      assert_raises(NoMethodError) { TestService.perform_later.buidl("x") }
    end
  end

  test "private method raises NoMethodError at enqueue" do
    assert_no_enqueued_jobs do
      assert_raises(NoMethodError) { TestService.perform_later.internal_cleanup }
    end
  end

  test "non-serializable instance raises SerializationError at enqueue" do
    assert_raises(ActiveJob::SerializationError) { Object.new.perform_later.dup }
  end

  test "anonymous class raises ArgumentError at enqueue" do
    klass = Class.new { def self.go; end }
    assert_raises(ArgumentError) { klass.perform_later.go }
  end

  test "vanished class raises NameError at perform" do
    Object.const_set(:EphemeralService, Class.new { def self.run; end })
    EphemeralService.perform_later.run
    Object.send(:remove_const, :EphemeralService)
    assert_raises(NameError) { perform_enqueued_jobs }
  ensure
    Object.send(:remove_const, :EphemeralService) if Object.const_defined?(:EphemeralService)
  end

  test "inspecting the proxy does not enqueue a job" do
    assert_no_enqueued_jobs do
      assert_match(/ActiveJob::PerformLater::Proxy/, TestService.perform_later.inspect)
    end
  end

  test "string targets raise ArgumentError at enqueue" do
    assert_no_enqueued_jobs do
      assert_raises(ArgumentError) { "TestService".perform_later.upcase }
    end
  end

  test "passing a block raises ArgumentError at enqueue" do
    assert_no_enqueued_jobs do
      assert_raises(ArgumentError) { TestService.perform_later.build("x") { :nope } }
    end
  end
end
