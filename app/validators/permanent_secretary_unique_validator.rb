# frozen_string_literal: true

class PermanentSecretaryUniqueValidator < ActiveModel::Validator
  def validate(record)
    @record = record
    record.errors[:leader] << perm_sec_unique_message if perm_sec? && perm_sec_exists?
  end

  private

  def scope_t
    %i[errors validators permanent_secretary_unique_validator leader]
  end

  def perm_sec_unique_message
    I18n.t(
      :unique,
      scope: scope_t,
      name: Group.department.name,
      role: current_perm_sec.role || 'Permanent Secretary',
      person_name: current_perm_sec.person.name
    )
  end

  def perm_sec?
    @record.leader && @record.group_id == Group.department.id
  end

  def perm_sec_exists?
    current_perm_sec.present? &&
      current_perm_sec.id != @record.id
  end

  def current_perm_sec
    Membership.where(group_id: Group.department.id).where(leader: true).limit(1).first
  end
end
