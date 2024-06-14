# frozen_string_literal: true

# UsersController
class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  # GET /users
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    if @user.save
      redirect_to users_path, notice: 'Utilisateur created with success'
    else
      render :new
    end
  end

  # GET /users/:id/edit
  def edit; end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User updated'
    else
      render :edit
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User deleted'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :username, :password)
  end

  def new_user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation)
  end
end
