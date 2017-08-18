module ProductsHelper
  def image_for(product, options = { size: 50 })
    size = options[:size]
    image_tag(asset_path('book.png'), class: 'image_tag')
  end		
end
