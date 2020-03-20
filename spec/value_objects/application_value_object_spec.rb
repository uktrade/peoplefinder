# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationValueObject do
  subject { described_class.new(value) }

  let(:foo_class) { stub_const('FooValue', Class.new(described_class)) }
  let(:bar_class) { stub_const('BarValue', Class.new(described_class)) }

  let(:value) { 'Hello!' }

  let(:foo_one)      { foo_class.new('one') }
  let(:also_foo_one) { foo_class.new('one') }
  let(:foo_two)      { bar_class.new('two') }
  let(:bar_one)      { bar_class.new('one') }

  it 'is immutable' do
    expect(subject).to be_frozen
  end

  describe '#==' do
    it 'considers same class/same value equal' do
      expect(foo_one).to eq(also_foo_one)
    end

    it 'considers same class/different value not equal' do
      expect(foo_one).not_to eq(foo_two)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one).not_to eq(bar_one)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two).not_to eq(bar_one)
    end
  end

  describe '#hash' do
    it 'considers same class/same value equal' do
      expect(foo_one.hash).to eq(also_foo_one.hash)
    end

    it 'considers same class/different value not equal' do
      expect(foo_one.hash).not_to eq(foo_two.hash)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one.hash).not_to eq(bar_one.hash)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two.hash).not_to eq(bar_one.hash)
    end
  end
end
