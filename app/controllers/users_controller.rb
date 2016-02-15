class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index

    @users = []
    @filter_notice = ""

    if (params[:type].to_i == 1) && !(params[:nbr_users].blank?) && (params[:nbr_users].to_i > 0)
      @filter_notice = "Filtre : Affichage des utilisateurs ayant parraine plus de #{params[:nbr_users]} inscription(s) !"
      @users = User.all.reject { |user| user.godchildren.count < params[:nbr_users].to_i}
    elsif (params[:type].to_i == 2) && !(params[:nbr_godfathers].blank?) && (params[:nbr_godfathers].to_i >= 0)
      @filter_notice = "Filtre : Affichage du(des) #{params[:nbr_godfathers]} meilleur(s) parrain(s)!"
      @users = User.select('users.*, COUNT(users.id) as "godchildren_count"').joins(:godchildren).group("users.id").order('godchildren_count DESC').limit(params[:nbr_godfathers].to_i)
    elsif params[:type].to_i == 3
      @filter_notice = "Filtre : Affichage des utilisateurs n'ayant pas encore parraine d'inscriptions"
      @users = User.all.reject{|user| user.godchildren.count > 0}
    else
      @filter_notice = "Filtre : Aucun ou mal défini!"
      @users = User.all
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :lastname, :firstname, :godfather_username)
  end
end
