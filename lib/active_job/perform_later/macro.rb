# frozen_string_literal: true

module ActiveJob
  module PerformLater
    # `perform_later_job` class macro, mixed into Module.
    module Macro
      # Accepted values for the `on:` scope option.
      #
      # @api private
      # @return [Array<Symbol, nil>] valid scopes
      VALID_SCOPES = [nil, :class, :instance].freeze

      # Defines a dedicated job class for `method_name` — or the
      # class-wide `PerformLaterJob` fallback when no name is given —
      # named after {PerformLater.job_const_name} and inheriting from the
      # nearest `PerformLaterJob` or {PerformLater.base_job}.
      #
      # @api public
      # @param method_name [Symbol, nil] method the job is dedicated to;
      #   nil declares the class-wide fallback job
      # @param on [Symbol, nil] restrict the job to `:class` or
      #   `:instance` calls of `method_name`
      # @yield optional block class_eval'ed inside the generated job
      #   (`queue_as`, `retry_on`, ...)
      # @return [Class] the generated job class
      # @raise [ArgumentError] on an invalid scope, a scope without a
      #   method name, or an already-defined job constant
      # @example Dedicated job with options
      #   class Report
      #     perform_later_job :generate, on: :instance do
      #       queue_as :reports
      #     end
      #   end
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
