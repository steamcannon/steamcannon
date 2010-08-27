require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  
  describe "content_for_superuser" do
    context "for a superuser" do
      before(:each) do
        @current_user = Factory.build(:superuser)
        stub!(:current_user).and_return(@current_user)
      end
      
      it "should concat the given text" do
        should_receive(:concat).with('some text')
        content_for_superuser("some text")
      end

      it "should concat the block results" do
        should_receive(:concat).with('SOME TEXT')
        content_for_superuser do
          'some text'.upcase
        end
      end
    end

    context "for a non superuser" do
      before(:each) do
        @current_user = Factory.build(:user)
        stub!(:current_user).and_return(@current_user)
      end
      
      it "should not concat the given text" do
        should_not_receive(:concat)
        content_for_superuser("some text")
      end

      it "should not concat the block results" do
        should_not_receive(:concat)
        content_for_superuser do
          'some text'.upcase
        end
      end
    end

    it "should raise an error if block and text both provided" do
      lambda {
        content_for_superuser('text') { }
      }.should raise_error(ArgumentError)
    end
  end

end

