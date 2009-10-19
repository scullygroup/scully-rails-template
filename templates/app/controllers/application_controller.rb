class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery

  include HoptoadNotifier::Catcher

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :role_call, :cms_admin
  
  before_filter :start_session
  
  def start_session
    unless session[:user_random]
  		session[:user_random] = rand(99999999)
  	end
  end
  
  private
  
  # def check_authorization(vars)
  #   puts "Required User Level is " + vars["required_user_level"]
  #   unless User.find_by_id(session[:user_id])
  #   flash[:notice] = “Please log in”
  #   redirect_to(:controller => “login”, :action => “login”)
  # end
      
  # determine the role of the current user
  def role_call
    @role = Role.find(current_user.role_id)
    return "#{@role.name}"
  end
  
  # determine if the user has full privileges to the cms
  def cms_admin
    @role = Role.find(current_user.role_id)
    case @role.name
      when "admin"      : return true
      when "publisher"  : return true
    else
      return false
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:error] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  # def require_no_user
  #   if current_user
  #     store_location
  #     flash[:error] = "You must be logged out to access this page"
  #     redirect_to account_url
  #     return false
  #   end
  # end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end