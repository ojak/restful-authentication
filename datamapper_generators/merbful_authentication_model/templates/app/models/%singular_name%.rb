require 'digest/sha1'
begin
  require File.join(File.dirname(__FILE__), '..', '..', "lib", "authenticated_system", "authenticated_dependencies")
rescue 
  nil
end
class <%= class_name %>
  include DataMapper::Resource
  include AuthenticatedSystem::Model
  
  attr_accessor :password, :password_confirmation

  property :id,                         Integer,    :serial => true
  property :login,                      String
  property :email,                      String
  property :crypted_password,           String
  property :salt,                       String
<% if include_activation -%>
  property :activation_code,            String
  property :activated_at,               DateTime
<% end -%>
  property :remember_token_expires_at,  DateTime
  property :remember_token,             String
  property :created_at,                 DateTime
  property :updated_at,                 DateTime

  validates_length            :login,                   :in => 3..40
  validates_is_unique         :login
  validates_present           :email
  # validates_format            :email,                   :as => :email_address
  validates_length            :email,                   :in => 3..100
  validates_is_unique         :email
  validates_present           :password,                :if => proc {password_required?}
  validates_present           :password_confirmation,   :if => proc {password_required?}
  validates_length            :password,                :in => 4..40, :if => proc {password_required?}
  validates_is_confirmed      :password,                :groups => :create

  before :save, :encrypt_password
<% if include_activation -%>
  before :create :make_activation_code
  after :create :send_signup_notification
<% end -%>
  
  def login=(value)
    @login = value.downcase unless value.nil?
  end
    
<% if include_activation -%>  
  EMAIL_FROM = "info@mysite.com"
  SIGNUP_MAIL_SUBJECT = "Welcome to MYSITE.  Please activate your account."
  ACTIVATE_MAIL_SUBJECT = "Welcome to MYSITE"
  
  # Activates the <%= singular_name %> in the database
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save

    # send mail for activation
    <%= class_name %>Mailer.dispatch_and_deliver(  :activation_notification,
                                  {   :from => <%= class_name %>::EMAIL_FROM,
                                      :to   => self.email,
                                      :subject => <%= class_name %>::ACTIVATE_MAIL_SUBJECT },

                                      :<%= singular_name %> => self )

  end
  
  def send_signup_notification
    <%= class_name %>Mailer.dispatch_and_deliver(
        :signup_notification,
      { :from => <%= class_name %>::EMAIL_FROM,
        :to  => self.email,
        :subject => <%= class_name %>::SIGNUP_MAIL_SUBJECT },
        :<%= singular_name %> => self        
    )
  end
  
<% end -%>


  
end
