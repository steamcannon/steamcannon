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

require 'spec_helper'

describe AgentClient do
  before(:each) do
    @instance = Factory.build(:instance)
    @instance.stub!(:public_dns).and_return('1.2.3.4')
    @client = AgentClient.new(@instance, :mock)
  end

  
  describe "agent_url" do
    it "should create the proper url for the agent" do
      @client.send(:agent_url).should == "https://#{@instance.public_dns}:#{AgentClient::AGENT_PORT}"
    end

  end

  describe "connection" do
    before(:each) do
      cert = mock(Certificate,
                  :to_x509_certificate => 'x509',
                  :to_rsa_keypair => 'rsa',
                  :to_public_pem_file => 'pem')
      Certificate.stub!(:client_certificate).and_return(cert)
      Certificate.stub!(:ca_certificate).and_return(cert)
      @client.stub!(:verify_ssl?).and_return(false)
    end

    after(:each) do
      APP_CONFIG[:use_ssl_with_agents] = true
    end
    
    it "should include the ssl options if ssl enabled" do
      @client.stub!(:agent_url).and_return('url')
      RestClient::Resource.should_receive(:new).with('url',
                                                     {
                                                       :ssl_client_cert => 'x509',
                                                       :ssl_client_key => 'rsa',
                                                       :ssl_ca_file => 'pem',
                                                       :verify_ssl => false
                                                     })
      @client.send(:connection)
    end


    it "should not include the ssl options if ssl disabled" do
      APP_CONFIG[:use_ssl_with_agents] = false      
      @client.stub!(:agent_url).and_return('url')
      RestClient::Resource.should_receive(:new).with('url', {})
      @client.send(:connection)
    end

  end

  describe "agent_status" do
    it "should attempt to configure the agent if successful" do
      @client.stub!(:get).and_return({ "status" => "ok" })
      @client.stub!(:agent_configured?).and_return(false)
      @client.should_receive(:configure_agent)
      @client.agent_status
    end

  end


  describe "execute_request" do
    context "when the returned status != 'ok'" do
      before(:all) do
        @failing_response = { "status" => "failure", "message" => "blah" }
        @failing_proc = lambda { @failing_response.to_json }
  
      end
      
      it "should raise an exception" do
        lambda do
          @client.send(:execute_request, &@failing_proc)
        end.should raise_error(AgentClient::RequestFailedError)
      end 
        
      it "should include the response in the exception" do
        begin
          @client.send(:execute_request, &@failing_proc)
        rescue AgentClient::RequestFailedError => ex
          ex.response.should == @failing_response
        end
      end
    end
    
    context "when the request raises an exception" do
      before(:all) do
        @raising_proc = lambda { raise Errno::ECONNREFUSED }
      end
      
      it "should raise an exception" do
        lambda do
          @client.send(:execute_request, &@raising_proc)
        end.should raise_error(AgentClient::RequestFailedError)
      end
      
      it "should include the original exception in the new exception" do
        begin
          @client.send(:execute_request, &@raising_proc)
        rescue AgentClient::RequestFailedError => ex
          ex.wrapped_exception.class.should == Errno::ECONNREFUSED
        end
      end
    end
  end

  describe "service actions" do
    before(:each) do
      @connection = mock("connection")
      @resource = mock("resource")
      @client.stub!(:connection).and_return(@connection)
    end

    %w{ status start stop restart artifacts }.each do |action|
      it "the local #{action} action should :get the remote #{action} action" do
        @resource.should_receive(:get).with({}).and_return('{"status" : "ok"}')
        @connection.should_receive(:[]).with("/services/mock/#{action}").and_return(@resource)
        @client.send(action)
      end
    end

    it "the local artifact action should :get the remote artifact action" do
      @resource.should_receive(:get).with({}).and_return('{"status" : "ok"}')
      @connection.should_receive(:[]).with("/services/mock/artifacts/1").and_return(@resource)
      @client.artifact(1)
    end

    it "the local deploy_artifact action should :post to the remote deploy_artifact action" do
      @resource.should_receive(:post).with({:artifact => 'the_file'}, {}).and_return('{"status" : "ok"}')
      @connection.should_receive(:[]).with("/services/mock/artifacts").and_return(@resource)
      artifact = mock('artifact')
      artifact.stub_chain(:archive, :path).and_return("path")
      File.should_receive(:new).with("path", "r").and_return('the_file')
      @client.deploy_artifact(artifact)
    end

    it "the local undeploy_artifact action should :delete to the remote undeploy_artifact action" do
      @resource.should_receive(:delete).with({}).and_return('{"status" : "ok"}')
      @connection.should_receive(:[]).with("/services/mock/artifacts/1").and_return(@resource)
      @client.undeploy_artifact(1)
    end
    
    it "the local configure action should :post to the remote configure action" do
      @resource.should_receive(:post).with({:config => {}}, {}).and_return('{"status" : "ok"}')
      @connection.should_receive(:[]).with("/services/mock/configure").and_return(@resource)
      @client.configure({})
    end
    
  end
end
