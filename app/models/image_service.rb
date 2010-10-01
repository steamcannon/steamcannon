class ImageService < ActiveRecord::Base
  belongs_to :image
  belongs_to :service
end
