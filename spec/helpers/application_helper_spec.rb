# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:stubbed_time) { Time.new(2012, 10, 31, 2, 2, 2, '+01:00') }
  let(:originator) { Version.public_user }

  describe '#markdown' do
    it 'renders Markdown starting from h3' do
      source = "# Header\n\nPara para"
      fragment = Capybara::Node::Simple.new(markdown(source))

      expect(fragment).to have_selector('h3', text: 'Header')
    end
  end

  describe '#markdown_without_hyperlinks' do
    it 'renders Markdown with <a> tags replaced by their content' do
      source = "# Header\n\nPara para\n\n[link to](nowhere)"
      fragment = Capybara::Node::Simple.new(markdown_without_hyperlinks(source))

      expect(fragment).to have_selector('h3', text: 'Header')
      expect(fragment).not_to have_selector('a')
      expect(fragment.text).to have_text('link to')
      expect(fragment).not_to have_text('nowhere')
    end
  end

  describe '#call_to' do
    it 'returns an a with a tel: href' do
      generated = call_to('07700900123')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]', text: '07700900123')
    end

    it 'strips extraneous characters from href' do
      generated = call_to('07700 900 123')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:07700900123"]')
    end

    it 'preserves significant non-numeric characters in href' do
      generated = call_to('+447700900123,,1234#*')
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="tel:+447700900123,,1234#*"]')
    end

    it 'returns nil if telephone number is nil' do
      expect(call_to(nil)).to be_nil
    end
  end
end
