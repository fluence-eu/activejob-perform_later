# frozen_string_literal: true

module ActiveJob
  module PerformLater
    module Macro
      VALID_SCOPES = [nil, :class, :instance].freeze

      def perform_later_job(method_name = nil, on: nil, &block)
        unless VALID_SCOPES.include?(on)
          raise ArgumentError, "on: must be :class or :instance, got #{on.inspect}"
        end
        raise ArgumentError, "on: requires a method name" if on && method_name.nil?

        const_name = PerformLater.job_const_name(method_name, on: on)
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
