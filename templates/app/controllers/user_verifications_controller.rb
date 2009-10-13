class UserVerificationsController < ApplicationController
  
  before_filter :load_user_using_perishable_token

  def show
    if @user
      @user.verify!
      flash[:notice] = "Thank you for verifying your account. You may now login."
    end

    redirect_to '/login'
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = "Unable to find your account." unless @user
  end

end