# frozen_string_literal: true

class ReportController < ApplicationController
  def create
    Zendesk.new.report_problem(reporter: current_user, params: params)

    flash[:notice] = 'Thank you for your submission. Your problem has been reported.'
    redirect_back(fallback_location: home_path)
  end
end
