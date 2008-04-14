module AuthenticatedSystem
  module OrmMap
    
    def find_active_with_conditions(conditions)
      if <%= class_name %>.instance_methods.include?("activated_at")
        <%= class_name %>.with_scope(:find => {:conditions => "activated_at IS NOT NULL"}) do
          <%= class_name %>.find(:first, :conditions => conditions)
        end
      else
        <%= class_name %>.find(:first, :conditions => conditions)
      end
    end  
    
    def find_with_conditions(conditions)
      <%= class_name %>.find(:first, :conditions => conditions)
    end
    
    def find_all_with_nick_like(nick)
      <%= class_name %>.with_scope(:find => {:order => "nickname DESC", :limit => 1}) do
        <%= class_name %>.find(:all, :conditions => ["nickname LIKE ?", nick])
      end
    end
    
    # A method to assist with specs
    def clear_database_table
      <%= class_name %>.delete_all
    end
  end
  
end