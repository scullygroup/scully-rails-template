class RolesController < ApplicationController
  layout 'comatose_admin'
  before_filter :require_user

  def index
    @roles = Role.list_all_but_reserved
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "Role was sucessfully saved!"
      redirect_to('/roles')
    else
      render :action => :new
    end
  end

  def edit
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = "Role updated!"
      redirect_to('/roles')
    else
      render :action => :edit
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to('/roles') }
    end
  end

end