# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module Macro
      def perform_later_job(&block)
        const_name = "PerformLaterJob"
        if const_defined?(const_name, false)
          raise ArgumentError, "#{self}::#{const_name} is already defined"
        end

        job = const_set(const_name, Class.new(PerformLater.resolved_base_job))
        job.include(JobBehavior)
        job.class_eval(&block) if block
        job
      end
    end
  end
end
