# Put the correct routes in place
module AuthenticatedSystem
  def self.add_routes
    Merb::BootLoader.after_app_loads do
      Merb::Router.prepend do |r|
        r.match("/login").to(:controller => "<%= controller_class_name %>", :action => "create").name(:login)
        r.match("/logout").to(:controller => "<%= controller_class_name %>", :action => "destroy").name(:logout)
        r.match("/<%= plural_name %>/activate/:activation_code").to(:controller => "<%= model_controller_class_name %>", :action => "activate").name(:<%= singular_name %>_activation)
        r.resources :users
      end
    end
  end
end