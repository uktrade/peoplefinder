# frozen_string_literal: true

module VersionsHelper
  def view_template(version)
    version.membership? ? 'membership' : 'general'
  end

  def link_to_edited_item(version)
    link_to(version.item, version.item) if version.item && !version.item.is_a?(Membership)
  end
end
