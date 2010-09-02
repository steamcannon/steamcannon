# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'shoulda'
require 'ap'

  
# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner

  config.before(:each) do
    # AuthLogic test helpers
    def login(session_stubs = {}, user_stubs = {})
      login_with_user(mock_model(User, { :superuser? => false}.merge(user_stubs)),
                      session_stubs)
    end

    def login_with_user(user, session_stubs = {})
      @current_user = user
      session_stubs = {:record => @current_user}.merge(session_stubs)
      @current_user_session = mock_model(UserSession, session_stubs)
      UserSession.stub!(:find).and_return(@current_user_session)
      controller = mock(ActionController, :current_user => @current_user)
      AuditColumns::Base.stub!(:controller).and_return(controller)
    end
    
    def logout
      @current_user_session = nil
      UserSession.stub!(:find).and_return(nil)
      AuditColumns::Base.stub!(:controller).and_return(nil)
    end

  end
end
