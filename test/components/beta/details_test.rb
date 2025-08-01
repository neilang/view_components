# frozen_string_literal: true

require "components/test_helper"

class PrimerBetaDetailsTest < Minitest::Test
  include Primer::ComponentTestHelpers

  def test_overlay_default_renders_details_overlay
    render_inline(Primer::Beta::Details.new(overlay: :default)) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("details.details-overlay")
  end

  def test_overlay_dark_renders_details_overlay_dark
    render_inline(Primer::Beta::Details.new(overlay: :dark)) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("details.details-overlay.details-overlay-dark")
  end

  def test_renders_details_reset_when_resetting_the_button_style
    render_inline(Primer::Beta::Details.new(reset: true)) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("details.details-reset")
  end

  def test_default_component_renders_btn_summary
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("summary.btn")
  end

  def test_does_not_render_btn_if_button_false
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary(button: false) do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("summary")
    refute_selector(".btn")
  end

  def test_falls_back_to_defaults_when_invalid_overlay_is_passed
    without_fetch_or_fallback_raises do
      render_inline(Primer::Beta::Details.new(overlay: :bar)) do |component|
        component.with_summary { "Summary" }
        component.with_body { "Body" }
      end
    end

    assert_selector("details")
    assert_selector(".btn")
  end

  def test_falls_back_to_default_body_tag_when_invalid_body_tag_is_passed
    without_fetch_or_fallback_raises do
      render_inline(Primer::Beta::Details.new) do |component|
        component.with_summary { "Summary" }
        component.with_body(tag: :img) { "Body" }
      end
    end

    assert_selector("div", text: "Body", visible: false)
    refute_selector("img", text: "Body", visible: false)
  end

  def test_passes_props_to_summary_button
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary(size: :small, scheme: :primary) do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("summary.btn.btn-sm.btn-primary")
  end

  def test_accepts_custom_values_for_summary_aria_label
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary(aria_label_closed: "Open me", aria_label_open: "Close me") do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("summary")
    assert_selector("summary[aria-label='Open me']")
    assert_selector("summary[data-aria-label-open='Close me']")
    assert_selector("summary[data-aria-label-closed='Open me']")
  end

  def test_accepts_partial_aria_label_values
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary(aria_label_closed: "Open me") do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("summary")
    assert_selector("summary[aria-label='Open me']")
    assert_selector("summary[data-aria-label-closed='Open me']")
    assert_selector("summary[data-aria-label-open='Collapse']")  # Uses default when only one is provided
  end

  def test_prevents_rendering_without_slots
    render_inline(Primer::Beta::Details.new)

    refute_selector("details")
    refute_selector("summary")

    render_inline(Primer::Beta::Details.new) do |component|
      component.with_body { "Body" }
    end

    refute_selector("details")
    refute_selector("summary")

    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary { "Summary" }
    end

    refute_selector("details")
    refute_selector("summary")
  end

  def test_disabled
    render_inline(Primer::Beta::Details.new(disabled: true)) do |component|
      component.with_summary { "Summary" }
      component.with_body { "Body" }
    end

    refute_selector("details")
    assert_selector("button[disabled]", text: "Summary")
  end

  def test_status
    assert_component_state(Primer::Beta::Details, :beta)
  end

  def test_renders_no_aria_labels_when_not_provided
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    # Should not have aria-label attribute
    refute_selector("summary[aria-label]")
    # Should not have data-aria-label attributes 
    refute_selector("summary[data-aria-label-closed]")
    refute_selector("summary[data-aria-label-open]")
    # Should still have aria-expanded
    assert_selector("summary[aria-expanded=false]")
  end

  def test_renders_no_aria_labels_when_not_provided_and_open
    render_inline(Primer::Beta::Details.new(open: true)) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    # Should not have aria-label attribute
    refute_selector("summary[aria-label]")
    # Should not have data-aria-label attributes 
    refute_selector("summary[data-aria-label-closed]")
    refute_selector("summary[data-aria-label-open]")
    # Should still have aria-expanded
    assert_selector("summary[aria-expanded=true]")
  end

  def test_renders_details_catalyst_element_and_data_attributes
    render_inline(Primer::Beta::Details.new) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("details-toggle")
    assert_selector("details[data-target='details-toggle.detailsTarget']")
    refute_selector("summary[aria-label]")  # No aria-label when not explicitly provided
    assert_selector("summary[aria-expanded=false]")
    assert_selector("summary[data-action='click:details-toggle#toggle']")
    refute_selector("summary[data-aria-label-closed]")  # No data attributes when not explicitly provided
    refute_selector("summary[data-aria-label-open]")  # No data attributes when not explicitly provided
    assert_selector("summary[data-target='details-toggle.summaryTarget']")
  end

  def test_renders_correct_aria_attributes_when_details_open_true
    render_inline(Primer::Beta::Details.new(open: true)) do |component|
      component.with_summary do
        "Summary"
      end
      component.with_body do
        "Body"
      end
    end

    assert_selector("details[open]")
    refute_selector("summary[aria-label]")  # No aria-label when not explicitly provided
    assert_selector("summary[aria-expanded=true]")
  end
end
