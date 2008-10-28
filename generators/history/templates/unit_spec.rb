require File.dirname(__FILE__) + '/../spec_helper'

describe <%= class_name %> do
  fixtures :<%= table_name %>
  
  it 'creates <%= file_name %>' do
    lambda do
      <%= file_name %> = create_<%= file_name %>
      violated "#{<%= file_name %>.errors.full_messages.to_sentence}" if <%= file_name %>.new_record?
    end.should change(<%= class_name %>, :count).by(1)
  end

  it 'requires action_key' do
    lambda do
      u = create_<%= file_name %>(:action_key => nil)
      u.errors.on(:action_key).should_not be_nil
    end.should_not change(<%= class_name %>, :count)
  end

  it 'hides <%= file_name %>' do
    <%= table_name %>(:commented).hidden.should be_false
    <%= table_name %>(:commented).hide!
    <%= table_name %>(:commented).hidden.should_not be_false
    <%= table_name %>(:commented).should be_hidden
  end
  
  it "monthly logger should create only one entry per month"
  
  it "daily logger should create only one entry per month"
  
  protected
    def create_<%= file_name %>(options = {})
      <%= class_name %>.create({ :user_id => 1, :to_id =>1 , :to_type => "User", :linked_id => 1, :linked_type => "Comment", :description=> "Commented on...", :action_key => "new_comment", :public_action => 1, :hidden=>0}.merge(options))
    end
end

describe <%= class_name %>, "dynamic log methods" do
  fixtures :<%= table_name %>
  
  it "log_login should create a new entry with login as action_key"
  
  it "log_daily_login should create one entry per day with login as action_key"
  
  it "log_monthly_login should create one entry per month with login as action_key"
  
end