# frozen_string_literal: true

class VersionPolicy < ApplicationPolicy
  def index?
    administrator?
  end

  def undo?
    administrator?
  end
end
