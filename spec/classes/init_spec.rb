require 'spec_helper'
describe 'netuitiveagent' do
  context 'with default values for all parameters' do
    it { should contain_class('netuitiveagent') }
  end
end
