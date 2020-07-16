# frozen_string_literal: true

class PeopleFinderFormBuilder < GOVUKDesignSystemFormBuilder::FormBuilder
  delegate :concat, :tag, to: :@template

  def team_browser_radio_button(method, tag_value, label_text, options = {})
    # radio_button(method, tag_value, options.merge('aria-role': 'option')) + label(method, label_text, value: tag_value)
    govuk_radio_button(method, tag_value, label: { text: label_text })
  end

  def additional_fields_details(summary, &block)
    tag.div(class: 'govuk-details', data: { module: 'govuk-details' }) do
      tag.summary(class: 'govuk-details__summary') do
        tag.span(summary, class: 'govuk-details__summary-text')
      end + tag.div(class: 'govuk-details__text', &block)
    end
  end

  # The GOV.UK DS Form Builder has a very eccentric way of handling check boxes that
  # does not match the behaviour of Rails's check_box form helper (does not provide
  # a default false hidden field, can't be set to be checked, doesn't do I18n),
  # so we use this alternative implementation instead for boolean model fields.
  def model_govuk_check_box(method, label_text: I18n.translate("helpers.label.person.#{method}"))
    tag.div(class: 'govuk-checkboxes__item') do
      check_box(method, class: 'govuk-checkboxes__input') +
        label(method, label_text, class: 'govuk-label govuk-checkboxes__label')
    end
  end

  def array_govuk_collection_select(method, values, legend: I18n.t("helpers.label.person.#{method}"))
    legend_proc = -> { tag.legend(class: 'govuk-fieldset__legend govuk-fieldset__legend--xs') { legend } }
    govuk_check_boxes_fieldset(
      method,
      legend: legend_proc,
      small: true
    ) do
      array_govuk_collection_check_boxes(method, values, :first, :last, checked: @object.try(method))
    end
  end

  def array_govuk_collection_check_boxes(attribute_name, collection, value_method, text_method, options = {})
    collection_check_boxes(attribute_name, collection, value_method, text_method, options) do |item|
      tag.div(class: 'govuk-checkboxes__item') do
        item.check_box(class: 'govuk-checkboxes__input') +
          item.label(class: 'govuk-label govuk-checkboxes__label')
      end
    end
  end
end
