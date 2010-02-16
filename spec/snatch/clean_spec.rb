require 'spec_helper'

describe Snatch::Clean do
  before(:each) do
    File.stub!(:open).and_return('stream')
    @clean = Snatch::Clean.new('file_name', 'public')
  end

  it 'should update CSS and HTML' do
    @clean.instance_variable_set(:@doc, 'nokogiri')
    Snatch::Clean::CSS.should_receive(:update).with('nokogiri', 'public')
    Snatch::Clean::HTML.should_receive(:update).with('nokogiri', 'public')
    @clean.process
  end
end
