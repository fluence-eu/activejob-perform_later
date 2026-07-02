# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module Macro
      def perform_later_job(method_name = nil, &block)
        const_name = PerformLater.job_const_name(method_name)
        if const_defined?(const_name, false)
          raise ArgumentError, "#{self}::#{const_name} is already defined"
        end

        parent =
          if method_name
            PerformLater.lookup_const(self, "PerformLaterJob") || PerformLater.resolved_base_job
          else
            PerformLater.resolved_base_job
          end

        job = const_set(const_name, Class.new(parent))
        job.include(JobBehavior)
        job.class_eval(&block) if block
        job
      end
    end
  end
end
