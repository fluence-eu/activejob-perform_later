# frozen_string_literal: true

module ActiveJob
  module PerformLater
    class Proxy < BasicObject
      def initialize(target, options)
        @target = target
        @options = options
      end

      def method_missing(method_name, *args, **kwargs)
        unless @target.respond_to?(method_name)
          ::Kernel.raise ::NoMethodError,
                         "undefined method '#{method_name}' for #{@target.inspect} (via perform_later)"
        end

        PerformLater.job_for(@target, method_name)
                    .set(**@options)
                    .perform_later(PerformLater.target_ref(@target), method_name.to_s, args, kwargs)
      end

      def inspect
        "#<ActiveJob::PerformLater::Proxy target=#{@target.inspect} options=#{@options.inspect}>"
      end
    end
  end
end
