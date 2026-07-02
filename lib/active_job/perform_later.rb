# frozen_string_literal: true

require "active_job/perform_later/version"
require "active_job/perform_later/job"
require "active_job/perform_later/proxy"
require "active_job/perform_later/mixin"

module ActiveJob
  module PerformLater
    class << self
      def target_ref(target)
        return target unless target.is_a?(Module)

        target.name || raise(ArgumentError, "cannot perform_later on an anonymous class or module")
      end

      def job_for(_target, _method_name)
        Job
      end
    end
  end
end

Object.include ActiveJob::PerformLater::Mixin
