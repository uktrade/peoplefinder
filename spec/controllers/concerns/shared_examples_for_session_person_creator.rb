shared_examples_for "session_person_creatable" do

  it { is_expected.to respond_to :person_from_oauth }

  let(:valid_auth_hash) do
    {
      'info' => {
        'email' => 'example.user@digital.justice.gov.uk',
        'first_name' => 'John',
        'last_name' => 'Doe',
        'name' => 'John Doe'
      },
      'uid' => 'beef'
    }
  end

  shared_examples 'existing person returned' do
    it 'returns the matching person' do
      is_expected.to eql(person)
    end
  end

  shared_examples 'new person created' do
    it 'returns a person model' do
      is_expected.to be_a(Person)
    end

    describe 'the person' do
      it 'has correct e-mail address' do
        expect(subject.email).to eql(expected_email)
      end

      it 'has correct name' do
        expect(subject.name).to eql(expected_name)
      end

      it 'has correct SSO UUID' do
        expect(subject.ditsso_user_id).to eql(expected_user_id)
      end
    end
  end

  describe '.person_from_oauth' do
    subject do
      view = described_class.new
      view.person_from_oauth(auth_hash)
    end

    context 'for an existing person' do
      let!(:person) { create(:person_with_multiple_logins, email: valid_auth_hash['info']['email'], surname: 'Bob') }
      let(:auth_hash) { valid_auth_hash }

      it_behaves_like 'existing person returned'

      it 'extracts email from auth hash' do
        email_address = double('EmailAddress')
        expect(EmailAddress).to receive(:new).with(valid_auth_hash['info']['email']).and_return email_address
        subject
      end

      it 'updates the SSO UUID' do
        expect(subject.ditsso_user_id).to eql('beef')
      end
    end

    context 'for a new person' do
      let(:auth_hash) { valid_auth_hash }

      it_behaves_like 'new person created' do
        let(:expected_email) { 'example.user@digital.justice.gov.uk' }
        let(:expected_name) { 'John Doe' }
        let(:expected_user_id) { 'beef' }
      end
    end
  end
end
