require 'spec_helper'

describe App do

  it "should require a name attribute" do
    app = App.new
    app.save
    app.should have(1).error_on(:name)
  end
end
