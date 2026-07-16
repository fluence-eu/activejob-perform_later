# frozen_string_literal: true

require "active_job/perform_later/version"
require "active_job/perform_later/job"
require "active_job/perform_later/proxy"
require "active_job/perform_later/mixin"
require "active_job/perform_later/macro"

module ActiveJob
  # Runs any method of any class or instance in the background, either
  # through ad-hoc {Mixin#perform_later} proxies or through dedicated
  # jobs declared with the {Macro#perform_later_job} macro.
  #
  # @example Enqueue a method call on a model
  #   user.perform_later(wait: 5.minutes).send_welcome_email
  module PerformLater
    class << self
      # Sets the job class every generated job inherits from.
      #
      # Accepts a Class, or a String resolved lazily so the constant can
      # be defined after configuration runs (e.g. an autoloaded
      # `ApplicationJob`).
      #
      # @api public
      # @return [Class, String] the new base job
      attr_writer :base_job

      # The job class (or class name) generated jobs inherit from.
      #
      # @api public
      # @return [Class, String] defaults to `"ActiveJob::Base"`
      def base_job
        @base_job ||= "ActiveJob::Base"
      end

      # Resolves {base_job} to a Class, constantizing it when configured
      # as a String.
      #
      # @api private
      # @return [Class] the job class generated jobs inherit from
      def resolved_base_job
        base_job.is_a?(String) ? Object.const_get(base_job) : base_job
      end

      # Converts a proxy target into an Active Job serializable reference.
      #
      # Classes and modules are passed by name; any other object is
      # passed as-is and relies on GlobalID (or primitive) serialization.
      #
      # @api private
      # @param target [Object] receiver captured by the proxy
      # @return [Object] the reference given to `perform_later`
      # @raise [ArgumentError] when target is a String or an anonymous
      #   class or module
      def target_ref(target)
        if target.is_a?(String)
          raise ArgumentError, "String targets are not supported by perform_later"
        end
        return target unless target.is_a?(Module)

        target.name || raise(ArgumentError, "cannot perform_later on an anonymous class or module")
      end

      # Picks the job class used to enqueue `method_name` on `target`.
      #
      # Looks up, in order: the scope-prefixed constant
      # (`Class…`/`Instance…`), the method-named constant, the class-wide
      # `PerformLaterJob`, then falls back to the generic {Job}.
      #
      # @api private
      # @param target [Object] receiver captured by the proxy
      # @param method_name [Symbol] method being enqueued
      # @return [Class] the Active Job class to enqueue with
      def job_for(target, method_name)
        klass = target.is_a?(Module) ? target : target.class
        scope = target.is_a?(Module) ? :class : :instance

        [job_const_name(method_name, on: scope),
         job_const_name(method_name),
         "PerformLaterJob"].each do |const_name|
          job = lookup_const(klass, const_name)
          return job if job
        end

        Job
      end

      # Builds the conventional job constant name for a method.
      #
      # @api private
      # @param method_name [Symbol, String, nil] method the job wraps
      # @param on [Symbol, nil] optional `:class` / `:instance` scope prefix
      # @return [String] e.g. `"SyncPerformLaterJob"`,
      #   `"ClassSyncPerformLaterJob"`
      def job_const_name(method_name, on: nil)
        return "PerformLaterJob" if method_name.nil?

        prefix = on ? ActiveSupport::Inflector.camelize(on.to_s) : ""
        base = ActiveSupport::Inflector.camelize(method_name.to_s.sub(/[?!=]\z/, ""))
        "#{prefix}#{base}PerformLaterJob"
      end

      # Finds `const_name` defined directly on `mod` or one of its
      # ancestors, skipping Object so a top-level constant does not leak
      # into every class.
      #
      # @api private
      # @param mod [Module] starting point of the ancestry lookup
      # @param const_name [String] constant name to look up
      # @return [Class, nil] the matching job class, or nil when undefined
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
