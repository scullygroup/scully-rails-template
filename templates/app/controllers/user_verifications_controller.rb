class UserVerificationsController < ApplicationController
  
  before_filter :require_user, :except => :show
  before_filter :load_user_using_perishable_token, :except => [:confirm, :deny]
  
  # Action for user clicking the verificaton link in the email that was sent when registering
  def show
    if @user
      @user.confirm!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end

    redirect_to '/login'
  end

  # Action when confirming a user
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

  # Action when denying a user
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

  # Finds the token set for the user in the verification email
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = "Unable to find your account." unless @user
  end

end