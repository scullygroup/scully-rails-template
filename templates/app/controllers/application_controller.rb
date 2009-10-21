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
  
  # simple role authorization
  def check_authorization(vars)
    unless role_call == vars["required_user_level"]
      flash[:error] = "You are not authorized to access this!"
      redirect_to("/account/#{current_user.id}")
    end
  end
  
  private
  
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
  
  # make sure a user cannot access records that belong to another user unless they are an admin
  def check_role
    if params[:id] && params[:id].to_i != current_user.id && role_call != "admin" 
      flash[:error] = "You cannot access records outside of your account!"
      redirect_to("/account/#{current_user.id}")
    end
  end
    
  # redirect to the target if user is an admin, otherwise redirect to their profile
  def redirect_based_on_role(target)
    if role_call == "admin"
      return redirect_to("#{target}")
    else
      return redirect_to("/account/#{current_user.id}")
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

  # rescue from record not found
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