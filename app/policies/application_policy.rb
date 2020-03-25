# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def people_editor?
    @user.is_a?(Person) && @user.role_people_editor?
  end

  def groups_editor?
    @user.is_a?(Person) && @user.role_groups_editor?
  end

  def administrator?
    @user.is_a?(Person) && @user.role_administrator?
  end
end
