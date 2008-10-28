class <%= class_name %> < ActiveRecord::Base
  include ActionController::UrlWriter #so we can access named routes
  
  set_table_name "<%= table_name %>"
  
  belongs_to :user
  
  # "linked" is the object linked with this action / created in this action
  # example: commenting on a Post => to: Post - linked: Comment
  belongs_to :linked, :polymorphic => true  
  
  # "to" is the object that is involved with this action
  belongs_to :to, :polymorphic => true

  # This method holds the description for actions that don't have a description but an action_key 
  # I've used this also to easily translate the descriptions with GetText
  def actions 
    {
      :new_comment => '<a href="%{user_url}">%{user}</a> has posted a new comment on <a href="%{to_url}">%{to}</a>: <a href="%{linked_url}"> <span>%{linked}</span></a>' 
    }
  end

  validates_presence_of :action_key
#  validates_length_of :description, :maximum => 320, :allow_blank => true
  

  named_scope :public_accessible, :conditions => "<%= table_name %>.only_log IS NULL AND <%= table_name %>.hidden IS NULL", :order => "<%= table_name %>.created_at DESC"
  
  
  # uses '%' (see sprintf) to fromat the description text. passes {:user.to_s, :user_url, :to.to_s, :to_url, :linked.to_s, :linked_url} to your description.
  # use for example %{user} to insert the linked user.to_s
  def to_s
    (self.description.blank? ? actions[self.action_key.to_sym] : self.description) % {:user => user.to_s, :user_url => (user.respond_to?("url") ? user.url : ""), :linked => (linked.to_s || "").strip_tags, :linked_url => (linked.respond_to?("url") ? linked.url : ""), :to => to.to_s, :to_url => (to.respond_to?("url") ? to.url : "")}
  end
  
  def validate
    errors.add_to_base("duplicate entry") if duplicate?
  end
  
  def duplicate?
    false # add your fancy code to mark an entry as duplicate. 
  end
  
  def has_valid_associations?
    !self.linked.blank? || !self.to.blank?
  end
  
  def self.daily(args={}) 
     user_id = args[:user].kind_of?(User) ? args[:user].id : args[:user]
     args.delete(:user)
     if user_id.blank? then return end
     return false if self.find(:first, :conditions=>["action_key = ? AND user_id = ? AND DATE(created_at) = ?",args[:action_key], user_id, (Time.now.to_date.to_s(:db))])
     create(args.merge(:user_id=>user_id))
  end

  def self.monthly(args={})
     user_id = args[:user].kind_of?(User) ? args[:user].id : args[:user]
     args.delete(:user)
     if user_id.blank? then return end
     return false if self.find(:first, :conditions=>["action_key = ? AND user_id = ? AND DATE(created_at) BETWEEN ? AND ?",args[:action_key], user_id, Time.now.beginning_of_month.to_date.to_s(:db), Time.now.end_of_month.to_date.to_s(:db) ])
     create(args.merge(:user_id=>user_id))
  end
  
  def self.find_public(what=:all, args={})
    find(what,args.merge({:conditions => "<%= table_name %>.only_log != 1 AND <%= table_name %>.hidden != 1"}))
  end
  
  def hide!
    self.update_attribute(:hidden, true)
  end
  
  private

   def self.method_missing(method,*args)
     method_key = method.to_s
     return super(method,args) unless method_key.starts_with?("log_")
     method_key.gsub!(/^log_/,"")
     args = args[0] || {}
     if match = method_key.match(/daily_|monthly_/)
       call = match[0]
       method_key.gsub!(call,"")
       call.gsub!("_","")
       return self.send(call.to_sym,args.merge({:action_key=>method_key}))
     end
     self.create(args.merge({:action_key=>method_key}))
   end

end
