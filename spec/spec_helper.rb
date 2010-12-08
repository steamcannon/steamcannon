#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'email_spec'
require 'shoulda'
require 'ap'
require 'authlogic/test_case'


# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

module HasEventsMacro
  def it_should_have_events
    it { should have_one :event_subject }
    it { should have_many :events }
  end
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.extend(HasEventsMacro, :type => :models)

  config.before(:each) do
    activate_authlogic

    # AuthLogic test helpers
    def login(session_stubs = {}, user_stubs = {})
      login_with_user(mock_model(User, { :superuser? => false, :profile_complete? => true }.merge(user_stubs)),
                      session_stubs)
    end

    def login_with_user(user, session_stubs = {})
      @current_user = user
      session_stubs = {:record => @current_user}.merge(session_stubs)
      @current_user_session = mock_model(UserSession, session_stubs)
      UserSession.stub!(:find).and_return(@current_user_session)
      controller = mock(ActionController, :current_user => @current_user)
      AuditColumns::Base.stub!(:controller).and_return(controller)
      user
    end

    def logout
      @current_user_session = nil
      UserSession.stub!(:find).and_return(nil)
      AuditColumns::Base.stub!(:controller).and_return(nil)
    end

    ModelTask.stub!(:async)
     # force signup_mode here to override whatever is set in config/steamcannon.yml
    APP_CONFIG[:signup_mode] = 'open_signup'
    APP_CONFIG.delete(:certificate_password)
    # Don't require SSL for anything
    APP_CONFIG[:require_ssl_for_web] = false

    #turn off state transition logging by default
    HasEvents.log_event_on_state_transition = false
  end

end
