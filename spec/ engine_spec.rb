require 'spec_helper'
require_relative '../core/engine'

RSpec.describe Engine do
  let(:data_file) { 'spec/fixtures/test_data.yml' }
  let(:engine) { Engine.new(data_file) }

  describe '#start' do
    it 'returns the initial room description' do
      expect(engine.start).to include('You are in a dark room')
    end
  end

  describe '#handle_input' do
    it 'handles movement commands' do
      expect(engine.handle_input('go north')).to include('You are in a long hallway')
    end

    it 'handles taking items' do
      expect(engine.handle_input('take iron sword')).to include('You take the Iron Sword')
    end

    it 'handles invalid commands' do
      expect(engine.handle_input('dance')).to include("I don't understand that command")
    end
  end
end
