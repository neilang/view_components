# frozen_string_literal: true

require "components/test_helper"
require_relative "../../lib/primer/view_components/statuses"

class PrimerComponentTest < Minitest::Test
  include Primer::ComponentTestHelpers

  # Components with any arguments necessary to make them render
  COMPONENTS_WITH_ARGS = [
    [Primer::Alpha::SkeletonBox, {}],
    [Primer::Alpha::TreeView, {}],
    [Primer::Alpha::FileTreeView, {}],
    [Primer::Alpha::IncludeFragment, {}],
    [Primer::Alpha::ActionBar, {}, proc { |component|
      component.with_item_icon_button(icon: :search, label: "Search")
      component.with_item_icon_button(icon: :pencil, label: "Edit")
      component.with_item_icon_button(icon: :archive, label: "Archive")
    }],
    [Primer::Beta::RelativeTime, { datetime: Time.now.utc }],
    [Primer::Beta::IconButton, { icon: :star, "aria-label": "Star" }],
    [Primer::Beta::Button, {}],
    [Primer::Alpha::SegmentedControl, {
      "aria-label": "File view",
      full_width: false
    }, proc { |component|
      component.with_item(label: "Button", selected: true)
      component.with_item(label: "Button")
    }],
    [Primer::Alpha::SegmentedControl::Item, { label: "Button" }],
    [Primer::Alpha::Layout, {}, proc { |component|
      component.with_main(tag: :div) { "Foo" }
      component.with_sidebar(tag: :div) { "Bar" }
    }],
    [Primer::Alpha::HellipButton, { "aria-label": "No action" }],
    [Primer::Alpha::TabPanels, { label: "label" }],
    [Primer::Alpha::TabNav, { label: "label" }],
    [Primer::Alpha::UnderlinePanels, { label: "Panel label" }],
    [Primer::Alpha::Image, { src: "https://github.com/github.png", alt: "alt" }],
    [Primer::IconButton, { icon: :star, "aria-label": "Label" }],
    [Primer::Alpha::ActionList, { aria: { label: "Action List" } }, lambda do |component|
      component.with_item(label: "Foo")
    end],
    [Primer::Alpha::AutoComplete, { label_text: "Fruits", src: "Foo", list_id: "Bar", input_id: "input-id", input_name: "input-name" }],
    [Primer::Alpha::AutoComplete::Item, { value: "Foo" }],
    [Primer::Beta::AutoComplete::NoResultItem, { value: "Foo" }],
    [Primer::Beta::AutoComplete, { label_text: "Fruits", src: "Foo", list_id: "Bar", input_id: "input-id", input_name: "input-name" }],
    [Primer::Beta::AutoComplete::Item, { value: "Foo" }],
    [Primer::Beta::Avatar, { alt: "github", src: "https://github.com/github.png" }],
    [Primer::Beta::AvatarStack, {}, lambda do |component|
      component.with_avatar(alt: "github", src: "https://github.com/github.png")
    end],
    [Primer::Beta::BaseButton, {}],
    [Primer::BaseComponent, { tag: :div }],
    [Primer::Beta::Blankslate, {}, proc { |component|
      component.with_heading(tag: :h2) { "Foo" }
    }],
    [Primer::Beta::BorderBox, {}, proc { |component| component.with_header { "Foo" } }],
    [Primer::Beta::BorderBox::Header, {}],
    [Primer::BlankslateComponent, { title: "Foo" }],
    [Primer::Box, {}],
    [Primer::Beta::Breadcrumbs, {}, proc { |component| component.with_item(href: "/") { "Foo" } }],
    [Primer::ButtonComponent, {}, proc { "Button" }],
    [Primer::Beta::ButtonGroup, {}, proc { |component| component.with_button { "Button" } }],
    [Primer::Alpha::ButtonMarketing, {}],
    [Primer::Beta::ClipboardCopy, { "aria-label": "String that will be read to screenreaders", value: "String that will be copied" }],
    [Primer::Beta::ClipboardCopyButton, { "aria-label": "String that will be read to screenreaders", value: "String that will be copied" }],
    [Primer::ConditionalWrapper, { condition: true, tag: :div }],
    [Primer::Beta::CloseButton, {}],
    [Primer::Beta::Counter, { count: 1 }],
    [Primer::Beta::Details, {}, lambda do |component|
      component.with_summary { "Foo" }
      component.with_body { "Bar" }
    end],
    [Primer::Alpha::Dialog, { title: "Test" }, proc { |component|
      component.with_header { "Foo" }
      component.with_body { "Foo" }
      component.with_footer { "Foo" }
    }],
    [Primer::Alpha::Dialog::Header, { title: "Test", id: "test" }],
    [Primer::Alpha::Dialog::Body, {}],
    [Primer::Alpha::Dialog::Footer, {}],
    [Primer::Alpha::Dropdown, {}, lambda do |component|
      component.with_button { "Foo" }
      component.with_menu do |menu|
        menu.with_item { "Baz" }
      end
    end],
    [Primer::Alpha::Dropdown::Menu, {}],
    [Primer::Beta::Flash, {}],
    [Primer::Beta::Heading, { tag: :h1 }],
    [Primer::Alpha::HiddenTextExpander, { "aria-label": "No action" }],
    [Primer::Beta::Label, {}],
    [Primer::LayoutComponent, {}],
    [Primer::Beta::Link, { href: "https://www.google.com" }],
    [Primer::Beta::Markdown, {}],
    [Primer::Alpha::Menu, {}, proc { |component| component.with_item(href: "#url") { "Item" } }],
    [Primer::Alpha::Navigation::Tab, {}],
    [Primer::Beta::Octicon, { icon: :people }],
    [Primer::Beta::Popover, {}, proc { |component| component.with_body { "Foo" } }],
    [Primer::Beta::ProgressBar, {}, proc { |component| component.with_item }],
    [Primer::Beta::Spinner, {}],
    [Primer::Beta::State, { title: "Open" }],
    [Primer::Beta::Subhead, { heading: "Foo" }, proc { |component| component.with_heading { "Foo" } }],
    [Primer::Alpha::TabContainer, {}, proc { "Foo" }],
    [Primer::Alpha::ToggleSwitch, {}],
    [Primer::Alpha::CheckBoxGroup, { name: :foo, label: "Foo" }],
    [Primer::Alpha::CheckBox, { name: :foo, label: "Foo" }],
    [Primer::Alpha::FormButton, { name: :foo, label: "Foo" }],
    [Primer::Alpha::MultiInput, { name: :foo, label: "Foo" }],
    [Primer::Alpha::RadioButtonGroup, { name: :foo, label: "Foo" }],
    [Primer::Alpha::RadioButton, { name: :foo, label: "Foo", value: "foo" }],
    [Primer::Alpha::Select, { name: :foo, label: "Foo" }],
    [Primer::Alpha::SubmitButton, { name: :foo, label: "Foo" }],
    [Primer::Alpha::TextArea, { name: :foo, label: "Foo" }],
    [Primer::Alpha::TextField, { name: :foo, label: "Foo" }],
    [Primer::Alpha::Overlay, { title: "Test", role: :dialog }, proc { |component|
      component.with_header { "Foo" }
      component.with_body { "Foo" }
    }],
    [Primer::Alpha::Overlay::Header, { title: "Test", id: "test" }],
    [Primer::Alpha::Overlay::Body, {}],
    [Primer::Alpha::Overlay::Footer, {}],
    [Primer::Beta::Text, {}],
    [Primer::Truncate, {}],
    [Primer::Beta::Truncate, {}, proc { |component| component.with_item { "Foo" } }],
    [Primer::Beta::TimelineItem, {}, proc { |component| component.with_body { "Foo" } }],
    [Primer::Tooltip, { label: "More" }],
    [Primer::Alpha::UnderlineNav, { label: "aria label" }, proc { |component| component.with_tab(selected: true) { "Foo" } }],
    [Primer::Alpha::Tooltip, { type: :label, for_id: "some-button", text: "Foo" }],
    [Primer::Alpha::NavList, { aria: { label: "Nav list" } }],
    [Primer::Beta::NavList, { aria: { label: "Nav list" } }],
    [Primer::Alpha::Banner, {}],
    [Primer::Alpha::FormControl, { label: "Foo" }],
    [Primer::Alpha::ActionMenu, {}, proc { |component| component.with_item(label: "Do something", value: "") }],
    [Primer::Alpha::SelectPanel, {}],
    [Primer::Alpha::Stack, {}],
    [Primer::Alpha::StackItem, {}]
  ].freeze

  def test_registered_components
    ignored_components = [
      "Primer::Alpha::NavList::Divider",
      "Primer::Alpha::NavList::Item",
      "Primer::Alpha::NavList::Heading",
      "Primer::Alpha::NavList::Group",
      "Primer::Alpha::ActionBar::Divider",
      "Primer::Alpha::ActionBar::Item",
      "Primer::Alpha::ActionList::Heading",
      "Primer::Alpha::ActionList::Item",
      "Primer::Alpha::ActionList::Divider",
      "Primer::Alpha::ActionList::FormWrapper",
      "Primer::Alpha::ActionMenu::Heading",
      "Primer::Alpha::ActionMenu::List",
      "Primer::Alpha::ActionMenu::ListWrapper",
      "Primer::Alpha::ActionMenu::Group",
      "Primer::Beta::NavList::Item",
      "Primer::Beta::NavList::Group",
      "Primer::Beta::NavList::Divider",
      "Primer::Beta::NavList::Header",
      "Primer::Alpha::OcticonSymbols",
      "Primer::Component",
      "Primer::Content",
      "Primer::Navigation::TabComponent",
      "Primer::ResponsiveArg",
      "Primer::Alpha::TreeView::IconPair",
      "Primer::Alpha::TreeView::Icon",
      "Primer::Alpha::TreeView::LeadingAction",
      "Primer::Alpha::TreeView::LeafNode",
      "Primer::Alpha::TreeView::LoadingFailureMessage",
      "Primer::Alpha::TreeView::Node",
      "Primer::Alpha::TreeView::SkeletonLoader",
      "Primer::Alpha::TreeView::SpinnerLoader",
      "Primer::Alpha::TreeView::SubTreeContainer",
      "Primer::Alpha::TreeView::SubTreeNode",
      "Primer::Alpha::TreeView::SubTree",
      "Primer::Alpha::TreeView::Visual",
      "Primer::Alpha::FileTreeView::FileNode",
      "Primer::Alpha::FileTreeView::DirectoryNode",
    ]

    primer_component_files_count = Dir["app/components/**/*.rb"].count { |p| p.exclude?("/experimental/") }
    assert_equal primer_component_files_count, COMPONENTS_WITH_ARGS.length + ignored_components.count, "Primer component added. Please update this test with an entry for your new component <3"
  end

  def test_all_components_support_system_arguments
    default_args = { my: 4 }
    COMPONENTS_WITH_ARGS.each do |component, args, proc|
      render_component(component, default_args.merge(args), proc)
      assert_selector(".my-4", visible: :all, message: "#{component.name} does not support system arguments")
    end
  end

  def test_all_components_pass_through_classes
    default_args = { classes: "foo" }
    COMPONENTS_WITH_ARGS.each do |component, args, proc|
      render_component(component, default_args.merge(args), proc)
      assert_selector(".foo", visible: :all, message: "#{component.name} does not pass through classes")
    end
  end

  def test_all_components_support_inline_styles
    default_args = { style: "width: 100%;" }
    COMPONENTS_WITH_ARGS.each do |component, args, proc|
      render_component(component, default_args.merge(args), proc)
      assert_selector("[style='width: 100%;']", visible: :all, message: "#{component.name} does not support inline styles")
    end
  end

  def test_all_components_support_content_tag_arguments
    default_args = { hidden: true }
    COMPONENTS_WITH_ARGS.each do |component, args, proc|
      render_component(component, default_args.merge(args), proc)
      assert_selector("[hidden]", visible: false, message: "#{component.name} does not support content tag arguments")
    end
  end

  def test_all_components_support_data_tag_arguments
    default_args = { "data-ga-click": "Foo,bar" }
    COMPONENTS_WITH_ARGS.each do |component, args, proc|
      render_component(component, default_args.merge(args), proc)
      assert_selector("[data-ga-click='Foo,bar']", visible: false, message: "#{component.name} does not support data arguments")
    end
  end

  def test_status_has_a_default
    assert_component_state(Primer::Component, :alpha)
  end

  def render_component(component, args, proc)
    render_inline(component.new(**args)) do |c|
      proc.call(c) if proc.present?
    end
  end

  def test_deny_single_argument_does_not_raise_in_production
    with_raise_on_invalid_options(true) do
      assert_raises(ArgumentError) { Primer::DenyComponent.new(class: "foo") }

      Rails.stub(:env, "production".inquiry) do
        Primer::DenyComponent.new(class: "foo")
      end
      # rubocop:enable Rails/Inquiry
    end
  end

  def test_deny_aria_key_does_not_raise_in_production
    with_raise_on_invalid_aria(true) do
      assert_raises(ArgumentError) { Primer::DenyComponent.new(aria: { label: "foo" }) }

      # rubocop:disable Rails/Inquiry
      Rails.stub(:env, "production".inquiry) do
        Primer::DenyComponent.new(aria: { label: "foo" })
      end
      # rubocop:enable Rails/Inquiry
    end
  end
end
