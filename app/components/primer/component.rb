# frozen_string_literal: true

require "view_component/version"

module Primer
  # @private
  # :nocov:
  class Component < ViewComponent::Base
    if Module.const_defined?("ViewComponent::SlotableV2") &&
       !(ViewComponent::Base < ViewComponent::SlotableV2)
      include ViewComponent::SlotableV2
    end

    if Module.const_defined?("ViewComponent::PolymorphicSlots") &&
       !(ViewComponent::Base < ViewComponent::PolymorphicSlots)
      include ViewComponent::PolymorphicSlots
    end

    include ExperimentalRenderHelpers
    include ExperimentalSlotHelpers

    include AttributesHelper
    include ClassNameHelper
    include FetchOrFallbackHelper
    include TestSelectorHelper
    include JoinStyleArgumentsHelper
    include ViewHelper
    include Status::Dsl
    include Audited::Dsl

    INVALID_ARIA_LABEL_TAGS = [:div, :span, :p].freeze

    def self.deprecated?
      status == :deprecated
    end

    def self.generate_id(base_name: name.demodulize.underscore.dasherize)
      "#{base_name}-#{SecureRandom.uuid}"
    end

    private

    def raise_on_invalid_options?
      Rails.application.config.primer_view_components.raise_on_invalid_options
    end

    def raise_on_invalid_aria?
      Rails.application.config.primer_view_components.raise_on_invalid_aria
    end

    def deprecated_component_warning(new_class: nil, version: nil)
      return if Rails.env.production? || silence_deprecations?

      message = "#{self.class.name} is deprecated"
      message += " and will be removed in v#{version}." if version
      message += " Use #{new_class.name} instead." if new_class

      ::Primer::ViewComponents.deprecation.warn(message)
    end

    def validate_aria_label
      aria_label = aria("label", @system_arguments)
      aria_labelledby = aria("labelledby", @system_arguments)
      raise ArgumentError, "`aria-label` or `aria-labelledby` is required." if aria_label.nil? && aria_labelledby.nil? && !Rails.env.production?
    end

    def silence_deprecations?
      Rails.application.config.primer_view_components.silence_deprecations
    end

    def check_denylist(denylist = [], **arguments)
      if should_raise_error?

        # Convert denylist from:
        # { [:p, :pt] => "message" } to:
        # { p: "message", pt: "message" }
        unpacked_denylist =
          denylist.each_with_object({}) do |(keys, value), memo|
            keys.each { |key| memo[key] = value }
          end

        violations = unpacked_denylist.keys & arguments.keys

        if violations.any?
          message = "Found #{violations.count} #{'violation'.pluralize(violations)}:"
          violations.each do |violation|
            message += "\n The #{violation} argument is not allowed here. #{unpacked_denylist[violation]}"
          end

          raise(ArgumentError, message)
        end
      end

      arguments
    end

    def validate_arguments(tag:, denylist_name: :system_arguments_denylist, **arguments)
      deny_single_argument(:class, "Use `classes` instead.", **arguments)

      if (denylist = arguments[denylist_name])
        check_denylist(denylist, **arguments)

        # Remove :system_arguments_denylist key and any denied keys from system arguments
        arguments.except!(denylist_name)
        arguments.except!(*denylist.keys.flatten)
      end

      deny_aria_label(tag: tag, arguments: arguments)

      arguments
    end

    def deny_single_argument(key, help_text, **arguments)
      raise ArgumentError, "`#{key}` is an invalid argument. #{help_text}" \
        if should_raise_error? && arguments.key?(key)

      arguments.except!(key)
    end

    def deny_aria_label(tag:, arguments:)
      return arguments.except!(:skip_aria_label_check) if arguments[:skip_aria_label_check]
      return if arguments[:role]
      return unless INVALID_ARIA_LABEL_TAGS.include?(tag)

      deny_aria_key(
        :label,
        "Don't use `aria-label` on `#{tag}` elements. See https://www.tpgi.com/short-note-on-aria-label-aria-labelledby-and-aria-describedby/",
        **arguments
      )
    end

    def deny_aria_key(key, help_text, **arguments)
      raise ArgumentError, help_text if should_raise_aria_error? && aria(key, arguments)
    end

    def deny_tag_argument(**arguments)
      deny_single_argument(:tag, "This component has a fixed tag.", **arguments)
    end

    def should_raise_error?
      !Rails.env.production? && raise_on_invalid_options? && !ENV["PRIMER_WARNINGS_DISABLED"]
    end

    def shouldnt_raise_error?
      !should_raise_error?
    end

    def should_raise_aria_error?
      !Rails.env.production? && raise_on_invalid_aria? && !ENV["PRIMER_WARNINGS_DISABLED"]
    end

    def trimmed_content
      return content unless content.present?

      # strip unsets `html_safe`, so we have to set it back again to guarantee that HTML blocks won't break
      content.html_safe? ? content.strip.html_safe : content.strip # rubocop:disable Rails/OutputSafety
    end
  end
end
