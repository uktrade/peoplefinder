# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    regular_user?
  end

  def update?
    regular_user?
  end

  def update_email?
    true
  end

  def new?
    regular_user?
  end

  def create?
    regular_user?
  end

  def destroy?
    admin_user?
  end

  def add_membership?
    regular_user?
  end
end
