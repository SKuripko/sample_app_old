class ProductsController < ApplicationController
	before_action :signed_in_user, only: %i[index edit update destroy]
	helper_method :products

  def index
  	@products ||= Product.all
  end

  def show
  	@product = Product.find(params[:id])
  end
  	
  def search
    @products = Product.search(params[:search])
    render :index
  end  	

  def new
  	@product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = 'New item add!'
      redirect_to @product
    else
      render 'new'
    end
  end	
  
  def edit
  	puts 11111
  	@product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(product_params)
      flash[:success] = 'Item info updated!'
      redirect_to @product
    else
      render 'edit'
    end
  end

  def destroy
  	@product = Product.find(params[:id]).destroy
  	flash[:success] = 'Item deleted'
    redirect_to products_url
  end	

  private	

  def product_params
  	params.require(:product).permit(:title, :description, :image_url, :price)
  end	
end
