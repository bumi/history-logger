class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.column :user_id, :integer
      t.column :linked_type, :string
      t.column :linked_id, :integer
      t.column :to_type, :string
      t.column :to_id, :integer
      t.column :action_key, :string
      t.column :description, :text
      t.column :action_type, :string
      t.column :hidden, :boolean
      t.column :only_log, :boolean
      t.column :created_at, :datetime
    end
    add_index :<%= table_name %>, [:linked_id, :linked_type]
    add_index :<%= table_name %>, [:to_id, :to_type]
    add_index :<%= table_name %>, :action_key
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
