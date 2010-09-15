require 'spec_helper'

describe InstanceService do
  it { should belong_to :instance }
  it { should belong_to :service }
end
