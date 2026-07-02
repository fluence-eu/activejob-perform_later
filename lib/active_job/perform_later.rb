# frozen_string_literal: true

require "active_job/perform_later/version"
require "active_job/perform_later/job"
require "active_job/perform_later/proxy"
require "active_job/perform_later/mixin"
require "active_job/perform_later/macro"

module ActiveJob
  module PerformLater
    class << self
      attr_writer :base_job

      def base_job
        @base_job ||= "ActiveJob::Base"
      end

      def resolved_base_job
        base_job.is_a?(String) ? Object.const_get(base_job) : base_job
      end

      def target_ref(target)
        return target unless target.is_a?(Module)

        target.name || raise(ArgumentError, "cannot perform_later on an anonymous class or module")
      end

      def job_for(target, _method_name)
        klass = target.is_a?(Module) ? target : target.class
        lookup_const(klass, "PerformLaterJob") || Job
      end

      def lookup_const(mod, const_name)
        mod.ancestors.each do |ancestor|
          next if ancestor == Object
          return ancestor.const_get(const_name, false) if ancestor.const_defined?(const_name, false)
        end
        nil
      end
    end
  end
end

Object.include ActiveJob::PerformLater::Mixin
Module.include ActiveJob::PerformLater::Macro
