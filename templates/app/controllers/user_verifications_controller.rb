class UserVerificationsController < ApplicationController
  
  before_filter :load_user_using_perishable_token

  def show
    if @user
      @user.confirmed
      @user.confirm!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end

    redirect_to '/login'
  end

  def confirm
    @user = User.find(params[:id])
    @user.confirmed #reference method in model to set recently_approved?
    @user.confirm!
    flash[:notice] = "User has been approved!"
    redirect_to('/users')
  end

  def deny
    @user = Story.find(params[:id])
    @user.deny!
    flash[:error] = "User has been denied!"
    redirect_to('/users')
  end
  
  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = "Unable to find your account." unless @user
  end

end