class ApplicationController < ActionController::Base

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  helper :all

  protect_from_forgery

  include HoptoadNotifier::Catcher

  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :role_call, :cms_admin, :redirect_based_on_role
  
  before_filter :start_session
  
  
  def start_session
    unless session[:user_random]
  		session[:user_random] = rand(99999999)
  	end
  end
  
  # Determine the role of the current user based on the current user's role_id 
  def role_call
    @role = Role.find(current_user.role_id)
    return "#{@role.name}"
  end
  
  # Determine if the user has full privileges to the cms
  def cms_admin
    @role = Role.find(current_user.role_id)
    case @role.name
      when "admin"      : return true
      when "publisher"  : return true
    else
      return false
    end
  end
  
  # Make sure a user cannot access records that belong to another user unless they are an admin
  def check_role
    if params[:id] && params[:id].to_i != current_user.id && role_call != "admin" 
      flash[:error] = "You cannot access records outside of your account!"
      redirect_to("/account/#{current_user.id}")
    end
  end
    
  # Redirect for controller actions that redirects to the target if user is an admin, otherwise redirect to their profile.
  # For example, if the use is an admin, this will redirect them to the "/users" url:
  #
  # redirect_based_on_role("/users")
  #
  def redirect_based_on_role(target)
    if role_call == "admin"
      return redirect_to("#{target}")
    else
      return redirect_to("/account/#{current_user.id}")
    end
  end
  
  private
  
  # Simple role authorization, checks to see if current user's role in present in the vars array
  # For example, this before_filter is placed at the top of the controller.
  # Actions can be specified, as well as an array of roles.
  #
  # before_filter :except => [:show, :edit, :update, :no_role] do |controller|
  #   controller.check_authorization(["admin", "writer"])
  # end
  # 
  def check_authorization(vars)
    unless "#{vars}".include?(role_call)
      flash[:error] = "You are not authorized to access this!"
      redirect_to("/account/#{current_user.id}")
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  # Helper method to determine the current logged-in user based on the user session
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

  # Rescue from record not found
  def record_not_found
    flash[:error] = "The requested record was not found under your account!"
    redirect_to("/account/#{current_user.id}")
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
