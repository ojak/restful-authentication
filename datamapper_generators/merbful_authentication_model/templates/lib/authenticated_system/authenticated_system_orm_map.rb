module AuthenticatedSystem
  module OrmMap
    
    def find_active_with_conditions(conditions)
      if <%= class_name %>.instance_methods.include?("activated_at")
        <%= class_name %>.first(conditions.merge(:activated_at.not => nil))
      else
        <%= class_name %>.first(conditions)
      end
    end  
    
    def find_with_conditions(conditions)
      <%= class_name %>.first(conditions)
    end
    
    def find_all_with_nick_like(condition, options = {} )
      <%= class_name %>.all({ :nickname.like => condition }.merge(options))
    end
    
    # A method to assist with specs
    def clear_database_table
      <%= class_name %>.auto_migrate!
    end
  end
  
end