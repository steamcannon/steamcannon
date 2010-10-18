require 'spec_helper'

describe AccountRequest do
  it { should validate_presence_of :email }

end
