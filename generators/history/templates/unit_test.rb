require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  fixtures :<%= table_name %>

  def test_should_create_<%= file_name %>
    assert_difference '<%= class_name %>.count' do
      <%= file_name %> = create_<%= file_name %>
      assert !<%= file_name %>.new_record?, "#{<%= file_name %>.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_action_key
    assert_no_difference '<%= class_name %>.count' do
      u = create_<%= file_name %>(:action_key => nil)
      assert u.errors.on(:action_key)
    end
  end
  
  def test_should_hide_<%= file_name %>
    assert_false <%= table_name %>(:commented).hidden?
    <%= table_name %>(:commented).hide!
    assert <%= table_name %>(:commented).hidden?
  end
  protected
    def create_<%= file_name %>(options = {})
      <%= class_name %>.create({ :user_id => 1, :to_id =>1 , :to_type => "User", :linked_id => 1, :linked_type => "Comment", :description=> "Commented on...", :action_key => "new_comment", :public_action => 1, :hidden=>0}.merge(options))
    end
end
