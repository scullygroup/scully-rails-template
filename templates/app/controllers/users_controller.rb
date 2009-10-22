class UsersController < ApplicationController

  before_filter :require_user, :check_role
  
  layout 'comatose_admin'
  
  before_filter :except => [:show, :edit, :update, :no_role] do |controller|
    controller.check_authorization(["admin"])
  end
  
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
      # Send email verification to user
      @user.deliver_verification_instructions!
      redirect_to('/users')
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end

  def edit
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_based_on_role("/users")
    else
      render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      flash[:notice] = "Account has been deleted"
      format.html { redirect_to('/users') }
    end
  end
  
end