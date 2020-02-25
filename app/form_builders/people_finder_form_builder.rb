# frozen_string_literal: true

class PeopleFinderFormBuilder < GOVUKDesignSystemFormBuilder::FormBuilder
  def team_browser_radio_button(method, tag_value, label_text, options = {})
    radio_button(method, tag_value, options) + label(method, label_text, value: tag_value)
  end
end
