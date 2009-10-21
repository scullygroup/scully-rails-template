class UserVerificationsController < ApplicationController
  
  before_filter :require_user, :except => :show
  before_filter :load_user_using_perishable_token, :except => [:confirm, :deny]
  
  def show
    if @user
      @user.confirm!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end

    redirect_to '/login'
  end

  def confirm
    @user = User.find(params[:id])
    # you cannot confirm yourself
    if @user.id == current_user.id
      flash[:error] = "You cannot confirm your own account!"
    else
      @user.confirm!
      flash[:notice] = "User has been approved!"
    end
    redirect_to('/users')
  end

  def deny
    @user = User.find(params[:id])
    # you cannot deny yourself
    if @user.id == current_user.id
      flash[:error] = "You cannot deny your own account!"
    else
      @user.deny!
      flash[:error] = "User has been denied!"
    end
    redirect_to('/users')
  end
  
  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = "Unable to find your account." unless @user
  end

end