# frozen_string_literal: true

require 'rails_helper'

describe UserUpdateMailer do
  shared_examples "common #{described_class} mail elements" do
    it 'includes the email of the person who instigated the change' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(instigator.email)
      end
    end
  end

  let(:instigator) { create(:person, email: 'instigator.user@digital.justice.gov.uk') }
  let(:person) { create(:person, email: 'test.user@digital.justice.gov.uk', profile_photo_id: 1) }

  describe '.updated_profile_email' do
    subject(:mail) do
      described_class.updated_profile_email(person, instigator.email).deliver_now
    end

    let!(:hr) { create(:group, name: 'Human Resources') }
    let!(:hr_membership) { create(:membership, person: person, group: hr, role: 'Administrative Officer') }
    let!(:ds) { create(:group, name: 'Digital Services') }
    let!(:csg) { create(:group, name: 'Corporate Services Group') }

    let(:mass_assignment_params) do
      {
        email: 'changed.user@digital.justice.gov.uk',
        works_monday: false,
        works_saturday: true,
        profile_photo_id: 2,
        memberships_attributes: {
          '0' => {
            role: 'Lead Developer',
            group_id: ds.id,
            leader: true
          },
          '1' => {
            role: 'Product Manager',
            group_id: csg.id,
            leader: false
          },
          '2' => {
            id: hr_membership.id,
            group_id: hr.id,
            role: 'Chief Executive Officer',
            leader: true
          },
          '3' => {
            id: person.memberships.find_by(group_id: Group.department).id,
            _destroy: '1'
          }
        }
      }
    end

    let(:team_reassignment) do
      {
        memberships_attributes: {
          '2' => {
            id: hr_membership.id,
            group_id: ds.id,
            role: 'Chief Executive Officer',
            leader: true
          }
        }
      }
    end

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the person show url' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person_url(person))
      end
    end

    context 'recipients' do
      it 'emails the changed person' do
        expect(mail.to).to include 'test.user@digital.justice.gov.uk'
      end
    end
  end

  describe '.deleted_profile_email' do
    subject(:mail) { described_class.deleted_profile_email(person.email, person.name, instigator.email).deliver_now }

    include_examples 'common mailer template elements'
    include_examples "common #{described_class} mail elements"

    it 'includes the persons name' do
      %w[plain html].each do |part_type|
        expect(get_message_part(mail, part_type)).to have_text(person.name)
      end
    end
  end
end
