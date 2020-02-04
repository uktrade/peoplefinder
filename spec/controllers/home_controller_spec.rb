# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  before do
    mock_logged_in_user
  end

  describe 'GET show' do
    context 'when there is no top-level group' do
      before do
        Group.destroy_all
        get :show
      end

      it 'redirects to the new group page' do
        expect(response).to redirect_to(new_group_path)
      end

      it 'tells the user to create a top-level group' do
        expect(flash[:notice]).to have_text('create a top-level group')
      end
    end

    context 'when there is a top-level group' do
      before do
        create(:department)
        get :show
      end

      it 'redirects to the top-level group' do
        expect(response).to redirect_to('/teams/department-for-international-trade')
      end
    end

    context 'when the HOME_PAGE_URL environment variable is defined' do
      it 'redirects to the HOME_PAGE_URL' do
        ENV['HOME_PAGE_URL'] = 'http://dev/null'
        create(:department)
        get :show
        ENV['HOME_PAGE_URL'] = nil
      end
    end
  end
end
