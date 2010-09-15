require 'spec_helper'

describe Service do
  before(:each) do
    @service = Factory(:service)
  end

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
end
