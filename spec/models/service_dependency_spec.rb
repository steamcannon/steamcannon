require 'spec_helper'

describe ServiceDependency do
  it { should belong_to :dependent_service }
  it { should belong_to :required_service }
end
