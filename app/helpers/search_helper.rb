# frozen_string_literal: true

module SearchHelper
  def highlighted(record, hit, field)
    return record.send(field) if hit.try(:highlight).blank? || !hit.highlight.key?(field)

    raw_highlight = hit.highlight[field].join
    sanitize(raw_highlight, tags: %w[strong], attributes: %w[class])
  end
end
