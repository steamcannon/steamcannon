require 'spec_helper'

describe "/layouts/application" do
  describe "when logged in" do
    before(:each) { login }

    it "should display the navigation tabs" do
      render 'layouts/application'
      response.should have_tag('div[class=?]', 'navigation_menu')
    end
  end

  describe "when logged out" do
    before(:each) { logout }

    it "should not display the navigation tabs" do
      render 'layouts/application'
      response.should_not have_tag('div[class=?]', 'navigation_menu')
    end
  end
end
