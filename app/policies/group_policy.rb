# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def show?
    true
  end

  def all_people?
    true
  end

  def people_outside_subteams?
    true
  end

  def tree?
    true
  end

  def edit?
    admin_user?
  end

  def update?
    admin_user?
  end

  def new?
    admin_user?
  end

  def create?
    admin_user?
  end

  def destroy?
    admin_user?
  end
end
