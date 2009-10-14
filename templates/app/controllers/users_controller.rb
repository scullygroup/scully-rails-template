class UsersController < ApplicationController

  layout 'comatose_admin'
  before_filter :require_user
  
  # before_filter :except => [:show, :search] do |controller|
  #   controller.check_authorization({”required_user_level” => “administrator”})
  # end
  
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for signing up, we've delivered an email to you with instructions on how to complete your registration!"
      @user.deliver_verification_instructions! # this is new for email verification
      redirect_to('/users')
    else
      render :action => :new
    end
  end
  
  def show
    #@user = @current_user
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end

  def edit
    #@user = @current_user
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to('/users')
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
    end
  end
  
end