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
    administrator? || groups_editor?
  end

  def update?
    administrator? || groups_editor?
  end

  def new?
    administrator? || groups_editor?
  end

  def create?
    administrator? || groups_editor?
  end

  def destroy?
    administrator? || groups_editor?
  end
end
