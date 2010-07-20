require 'spec_helper'

describe App do

  it "should be a new record if initialized with no attributes" do
    app = App.new
    app.should be_new_record
  end

  it "should assign id from archive name" do
    app = App.new(:archive => "my_app.war")
    app.id.should == "my_app"
  end

  it "should use id for to_s" do
    app = App.new(:archive => "my_app.war")
    app.to_s.should == app.id
  end

  it "should use id for to_param" do
    app = App.new(:archive => "my_app.war")
    app.to_param.should == app.id
  end

  it "should not have any errors" do
    app = App.new
    app.errors.should be_empty
  end

  it "should == another app with the same id" do
    app1 = App.new(:archive => "my_app.war")
    app2 = App.new(:archive => "my_app.war")
    app1.should == app2
  end

  it "should eql another app with the same id" do
    app1 = App.new(:archive => "my_app.war")
    app2 = App.new(:archive => "my_app.war")
    app1.should be_eql(app2)
  end

  it "should hash off of id" do
    app = App.new(:archive => "my_app.war")
    app.hash.should == app.id.hash
  end
end
