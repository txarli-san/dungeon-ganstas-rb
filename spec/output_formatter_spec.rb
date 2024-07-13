require 'spec_helper'
require_relative '../core/output_formatter'

RSpec.describe OutputFormatter do
  let(:formatter) { OutputFormatter.new }

  describe '#format_description' do
    it 'formats the description correctly' do
      expect(formatter.format_description('Test description')).to eq("\nTest description\n")
    end
  end

  describe '#format_result' do
    it 'formats the result correctly' do
      expect(formatter.format_result('Test result')).to eq("\nTest result\n")
    end
  end
end
