# frozen_string_literal: true

class PersonPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    true
  end

  def update?
    true
  end

  def confirm?
    true
  end

  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    administrator? || people_editor?
  end

  def add_membership?
    true
  end

  def audit?
    administrator? || people_editor?
  end
end
