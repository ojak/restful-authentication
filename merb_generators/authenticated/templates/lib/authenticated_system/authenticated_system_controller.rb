module AuthenticatedSystem
  module Controller
    protected
      # Returns true or false if the <%= singular_name %> is logged in.
      # Preloads @current_<%= singular_name %> with the <%= singular_name %> model if they're logged in.
      def logged_in?
        !!current_<%= singular_name %>
      end
    
      # Accesses the current <%= singular_name %> from the session.  Set it to :false if login fails
      # so that future calls do not hit the database.
      def current_<%= singular_name %>
        @current_<%= singular_name %> ||= (login_from_session || login_from_basic_auth || login_from_cookie || false)
      end
    
      # Store the given <%= singular_name %> in the session.
      def current_<%= singular_name %>=(new_<%= singular_name %>)
        session[:<%= singular_name %>] = (!new_<%= singular_name %> || !new_<%= singular_name %>.kind_of?(<%= class_name %>)) ? nil : new_<%= singular_name %>.id
        @current_<%= singular_name %> = new_<%= singular_name %>
      end
    
      # Check if the <%= singular_name %> is authorized
      #
      # Override this method in your controllers if you want to restrict access
      # to only a few actions or if you want to check if the <%= singular_name %>
      # has the correct rights.
      #
      # Example:
      #
      #  # only allow nonbobs
      #  def authorized?
      #    current_<%= singular_name %>.login != "bob"
      #  end
      def authorized?
        logged_in?
      end

      # Filter method to enforce a login requirement.
      #
      # To require logins for all actions, use this in your controllers:
      #
      #   before_filter :login_required
      #
      # To require logins for specific actions, use this in your controllers:
      #
      #   before_filter :login_required, :only => [ :edit, :update ]
      #
      # To skip this in a subclassed controller:
      #
      #   skip_before_filter :login_required
      #
      def login_required
        authorized? || throw(:halt, :access_denied)
      end

      # Redirect as appropriate when an access request fails.
      #
      # The default action is to redirect to the login screen.
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the <%= singular_name %> is not authorized
      # to access the requested action.  For example, a popup window might
      # simply close itself.
      def access_denied
        case content_type
        when :html
          store_location
          redirect url(:login)
        when :xml
          basic_authentication.request
        end
      end
    
      # Store the URI of the current request in the session.
      #
      # We can return to this location by calling #redirect_back_or_default.
      def store_location
        session[:return_to] = request.uri
      end
    
      # Redirect to the URI stored by the most recent store_location call or
      # to the passed default.
      def redirect_back_or_default(default)
        loc = session[:return_to] || default
        session[:return_to] = nil
        redirect loc
      end
    
      # Inclusion hook to make #current_<%= singular_name %> and #logged_in?
      # available as ActionView helper methods.
      # def self.included(base)
      #   base.send :helper_method, :current_<%= singular_name %>, :logged_in?
      # end

      # Called from #current_<%= singular_name %>.  First attempt to login by the <%= singular_name %> id stored in the session.
      def login_from_session
        self.current_<%= singular_name %> = <%= class_name %>.find_with_conditions(:id => session[:<%= singular_name %>]) if session[:<%= singular_name %>]
      end

      # Called from #current_<%= singular_name %>.  Now, attempt to login by basic authentication information.
      def login_from_basic_auth
        basic_authentication.authenticate do |email, password|
          self.current_<%= singular_name %> = <%= class_name %>.authenticate(email, password)
        end
      end

      # Called from #current_<%= singular_name %>.  Finaly, attempt to login by an expiring token in the cookie.
      def login_from_cookie     
        <%= singular_name %> = cookies[:auth_token] && <%= class_name %>.find_with_conditions(:remember_token => cookies[:auth_token])
        if <%= singular_name %> && <%= singular_name %>.remember_token?
          <%= singular_name %>.remember_me
          cookies[:auth_token] = { :value => <%= singular_name %>.remember_token, :expires => <%= singular_name %>.remember_token_expires_at }
          self.current_<%= singular_name %> = <%= singular_name %>
        end
      end
  end
end

Merb::BootLoader.after_app_loads do
  Application.send(:include, AuthenticatedSystem::Controller)
end