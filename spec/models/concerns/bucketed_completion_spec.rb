# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Concerns::BucketedCompletion do
  xcontext '.bucketed_completion' do
    def create_bucketed_people
      create(:person)
      create_list(:person, 2, :with_details, city: nil, building: nil)
      create(:person, :with_details, :with_photo)
    end

    before do
      create_bucketed_people
    end

    it 'counts the people in each bucket outputs specific format' do
      expect(Person.bucketed_completion).to eq(
        '[0,19]' => 0,
        '[20,49]' => 0,
        '[50,79]' => 2,
        '[80,100]' => 1
      )
    end
  end
end
