# frozen_string_literal: true

class MailingListPersonDecorator < SimpleDelegator
  GROUP_ONE_DIT_DOMAINS = %w[
    @trade.gov.uk
    @mobile.trade.gov.uk
    @digital.trade.gov.uk

    @fco.gov.uk
    @fcdo.gov.uk
    @traderemedies.gov.uk
    @ukexportfinance.gov.uk
  ].freeze

  def merge_fields
    {
      FNAME: given_name,
      LNAME: surname,
      PF_COUNTRY: country
    }
  end

  def tags
    ['pf_imported'] + building_tags + group_tags
  end

  private

  def building_tags
    building.select(&:present?).map { |building| "pf_building_#{building}" }
  end

  def group_tags
    [].tap do |ary|
      ary << 'group_onedit' if email.end_with?(*GROUP_ONE_DIT_DOMAINS)
    end
  end
end
