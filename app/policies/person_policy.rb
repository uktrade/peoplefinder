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

  def destroy?
    administrator? || people_editor?
  end

  def audit?
    administrator? || people_editor?
  end
end
