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

describe Cloud::Ec2 do
  before(:each) do
    @user = Factory.build(:user,
                          :cloud_username => 'username',
                          :cloud_password => 'password')
    @ec2 = Cloud::Ec2.new(@user)
    @instance = Factory.build(:instance)
  end

  describe "multicast_config" do
    before(:each) do
      @ec2.stub!(:pre_signed_put_url).and_return('put_url')
      @ec2.stub!(:pre_signed_delete_url).and_return('delete_url')
    end

    it "should generate put_url" do
      @ec2.should_receive(:pre_signed_put_url).with(@instance)
      @ec2.multicast_config(@instance)
    end

    it "should generate delete_url" do
      @ec2.should_receive(:pre_signed_delete_url).with(@instance)
      @ec2.multicast_config(@instance)
    end

    it "should return put and delete urls" do
      expected = {
        :s3_ping => {
          :pre_signed_put_url => 'put_url',
          :pre_signed_delete_url => 'delete_url'
        }
      }
      @ec2.multicast_config(@instance).should == expected
    end
  end

  describe "launch_options" do
    before(:each) do
      @ec2.stub!(:base_security_group).and_return({:name => 'steamcannon_base'})
      @ec2.stub!(:service_security_groups).and_return([{:name => 'steamcannon_service'}])
      @ec2.stub!(:ensure_security_group)
    end

    it "should include base security group" do
      @ec2.should_receive(:base_security_group).and_return({})
      @ec2.launch_options(@instance)
    end

    it "should include service specific security groups" do
      @ec2.should_receive(:service_security_groups).with(@instance).and_return([])
      @ec2.launch_options(@instance)
    end

    it "should ensure security groups exist" do
      @ec2.should_receive(:ensure_security_group).with({:name => 'steamcannon_base'})
      @ec2.should_receive(:ensure_security_group).with({:name => 'steamcannon_service'})
      @ec2.launch_options(@instance)
    end

    it "should return security group names" do
      expected =  ['steamcannon_base', 'steamcannon_service']
      @ec2.launch_options(@instance)[:security_group].should == expected
    end

    it "should return the default realm" do
      @ec2.launch_options(@instance)[:realm_id].should == 'us-east-1d'
    end
  end

  describe "pre_signed_put_url" do
    it "should have :put method" do
      @ec2.should_receive(:pre_signed_url).with(@instance, hash_including(:method => :put))
      @ec2.send(:pre_signed_put_url, @instance)
    end

    it "should have public-read permissions" do
      @ec2.should_receive(:pre_signed_url).
        with(@instance, hash_including(:headers => {'x-amz-acl' => 'public-read'}))
      @ec2.send(:pre_signed_put_url, @instance)
    end
  end

  describe "pre_signed_delete_url" do
    it "should have :delete method" do
      @ec2.should_receive(:pre_signed_url).with(@instance, hash_including(:method => :delete))
      @ec2.send(:pre_signed_delete_url, @instance)
    end
  end

  describe "pre_signed_url" do
    before(:each) do
      @cloud = mock('cloud')
      @cloud.stub!(:cloud_username).and_return('username')
      @cloud.stub!(:cloud_password).and_return('password')
      @instance.stub!(:cloud).and_return(@cloud)
      @environment = Factory.build(:environment)
      @instance.stub!(:environment).and_return(@environment)
      @environment.stub!(:user).and_return(@user)
      @ec2.stub!(:multicast_bucket).and_return('bucket')
      @created_at = Time.now
      @instance.stub!(:created_at).and_return(@created_at)
      @sig = S3::Signature
      @sig.stub!(:generate_temporary_url)
    end

    it "should get access_key from user object" do
      @user.should_receive(:cloud_username).and_return('username')
      @sig.should_receive(:generate_temporary_url).
        with(hash_including(:access_key => 'username'))
      @ec2.send(:pre_signed_url, @instance, {})
    end

    it "should get secret_access_key from user object" do
      @user.should_receive(:cloud_password).and_return('password')
      @sig.should_receive(:generate_temporary_url).
        with(hash_including(:secret_access_key => 'password'))
      @ec2.send(:pre_signed_url, @instance, {})
    end

    it "should get multicast bucket" do
      @ec2.should_receive(:multicast_bucket).and_return('bucket')
      @sig.should_receive(:generate_temporary_url).
        with(hash_including(:bucket => 'bucket'))
      @ec2.send(:pre_signed_url, @instance, {})
    end

    it "should expire 1 year after instance creation" do
      expires_at = @created_at + 1.year
      @instance.should_receive(:created_at).and_return(@created_at)
      @sig.should_receive(:generate_temporary_url).
        with(hash_including(:expires_at => expires_at))
      @ec2.send(:pre_signed_url, @instance, {})
    end

    it "should return temporary url" do
      @sig.should_receive(:generate_temporary_url).and_return('url')
      @ec2.send(:pre_signed_url, @instance, {}).should == 'url'
    end
  end

  describe "multicast_bucket" do
    before(:each) do
      @s3 = Aws::S3
      @s3.stub!(:new)
      @s3::Bucket.stub(:create)
    end

    it "should generate suffix from cloud username" do
      Digest::SHA1.should_receive(:hexdigest).with('username')
      @ec2.send(:multicast_bucket)
    end

    it "should create a new s3 object" do
      @s3.should_receive(:new).with('username', 'password', anything)
      @ec2.send(:multicast_bucket)
    end

    it "should create s3 bucket with public read permissions" do
      @s3::Bucket.should_receive(:create).with(anything, anything, true, 'public-read')
      @ec2.send(:multicast_bucket)
    end

    it "should return bucket name" do
      Digest::SHA1.stub!(:hexdigest).and_return('suffix')
      @ec2.send(:multicast_bucket).should == "SteamCannonEnvironments_suffix"
    end
  end

  describe "base_security_group" do
    it "should be named steamcannon" do
      @ec2.send(:base_security_group)[:name].should == 'steamcannon'
    end

    it "should have permissions inside group" do
      permissions = @ec2.send(:base_security_group)[:permissions]
      permissions.should include(:self)
    end

    it "should have permissions for ssh" do
      permissions = @ec2.send(:base_security_group)[:permissions]
      permissions.find do |permission|
        permission.is_a?(Hash) and permission[:from_port] == '22'
      end.should_not be_nil
    end

    it "should have permissions for Agent" do
      permissions = @ec2.send(:base_security_group)[:permissions]
      permissions.find do |permission|
        permission.is_a?(Hash) and permission[:from_port] == '7575'
      end.should_not be_nil
    end
  end

  describe "service_security_groups" do
    it "should retrieve all agent services" do
      @ec2.should_receive(:agent_services).and_return([])
      @ec2.send(:service_security_groups, @instance)
    end

    it "should create security group from each service" do
      agent_service = mock('agent service')
      @ec2.stub!(:agent_services).and_return([agent_service])
      @ec2.should_receive(:security_group_from_service).with(agent_service).and_return('group')
      @ec2.send(:service_security_groups, @instance).should == ['group']
    end
  end

  describe "security_group_from_service" do
    before(:each) do
      @service = Factory.build(:service)
      @agent_service = mock('agent_service',
                            :service => @service,
                            :open_ports => [])
    end

    it "should belong to correct user" do
      @ec2.send(:security_group_from_service, @agent_service)[:user].should == @user
    end

    it "should create name from service's name" do
      @service.should_receive(:name).and_return('name')
      @ec2.send(:security_group_from_service, @agent_service)[:name].should match(/name/)
    end

    it "should create description from service's full name" do
      @service.should_receive(:full_name).and_return('full name')
      @ec2.send(:security_group_from_service, @agent_service)[:description].should match(/full name/)
    end

    it "should create permission for every open port" do
      @agent_service.should_receive(:open_ports).and_return([80])
      permissions = @ec2.send(:security_group_from_service, @agent_service)[:permissions]
      permissions.size.should be(1)
      permissions.first[:to_port].should be(80)
      permissions.first[:from_port].should be(80)
    end
  end

  describe "agent_services" do
    it "should do create instance for service" do
      service = Factory.build(:service)
      @instance.stub_chain(:image, :services).and_return([service])
      AgentServices::Base.should_receive(:instance_for_service).
        with(service, @instance.environment)
      @ec2.send(:agent_services, @instance)
    end
  end
end
