require 'spec_helper'
require_relative '../utils/output_formatter'

RSpec.describe OutputFormatter do
  let(:formatter) { OutputFormatter.new }

  describe '#format_description' do
    it 'formats the description correctly' do
      expect(formatter.format_description('Test description')).to eq("Test description\n")
    end
  end

  describe '#format_result' do
    it 'formats the result correctly' do
      expect(formatter.format_result('Test result')).to eq("Test result\n")
    end
  end
end
