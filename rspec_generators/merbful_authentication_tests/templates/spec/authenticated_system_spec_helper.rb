Merb::Config.use do |c|
  c[:session_store] = "memory"
end

<% if include_activation -%>
class Merb::Mailer
  self.delivery_method = :test_send
end
<% end -%>

class Hash
  
  def with( opts )
    self.merge(opts)
  end
  
  def without(*args)
    self.dup.delete_if{ |k,v| args.include?(k)}
  end
  
end

# Checks that a route is made to the correct controller etc
#
# === Example
# with_route("/pages/1", "PUT") do |params|
#   params[:controller].should == "pages"
#   params[:action].should == "update"
#   params[:id].should == "1"
# end
def with_route(the_path, _method = "GET")
  _fake_request = Merb::Test::FakeRequest.new(:request_uri => the_path, :request_method => _method)
  result = Merb::Router.match(_fake_request)
  yield result[1] if block_given?
  result
end