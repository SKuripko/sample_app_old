class Product < ApplicationRecord
  validates :title, :description, :image_url, presence: true, length: { maximum: 80 }
  validates :price, numericality: {greater_than_orequal_to: 0.01}
  validates :title, uniqueness: true
  validates :image_url, allow_blank: true, format: {
  	with: %r{\.(gif|jpg|png)\Z}i, 
  	message: 'URL должен указывать на изображение GIF,JPG и PNG'
  }

  def self.search(search)
    if search
      self.where("title like ?", "%#{search}%")
    else
  	  self.all
    end
  end
end    	  
