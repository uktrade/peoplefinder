# frozen_string_literal: true

# Protect admin-restricted areas on the route layer level
# Used for mounted Rack apps that we can't authorise on the controller layer
class AdminRouteConstraint
  def matches?(request)
    current_user_id = request.session[ApplicationController::SESSION_KEY]
    return false if current_user_id.blank?

    current_user = Person.find(current_user_id)
    Admin::ManagementPolicy.new(current_user, :management).sidekiq?
  end
end
