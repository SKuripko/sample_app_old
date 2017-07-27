class MicropostsController < ApplicationController
  before_action :signed_in_user, only: %i[create destroy]
  before_action :correct_user,   only: :destroy

  def index; 
  end

  def create
  	@micropost = current_user.microposts.build(micropost_params)
  	if @micropost.save
  	  flash[:success] = "Micropost created!"
  	  redirect_to root_url
  	else
  	  @feed_items = []
  	  render 'static_pages/home'
  	end    
  end

  def destroy
  	@micropost = current_user.microposts.find_by(params[:id]).destroy
  	flash[:success] = 'Micropost delete'
  	redirect_to root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end  

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
    rescue
      redirect_to root_url it @micropost.nil?
    end  
end
