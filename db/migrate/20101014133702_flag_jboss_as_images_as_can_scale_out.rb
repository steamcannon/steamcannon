class Image < ActiveRecord::Base
  has_many :image_services
  has_many :services, :through => :image_services
end

class ImageService < ActiveRecord::Base
  belongs_to :image
  belongs_to :service
end

class Service < ActiveRecord::Base
end

class FlagJbossAsImagesAsCanScaleOut < ActiveRecord::Migration
  def self.up
    jboss_as = Service.find_by_name('jboss_as')
    if jboss_as
      Image.all.each do |image|
        if image.services.size == 1 && image.services.include?(jboss_as)
          image.can_scale_out = true
          image.save!
        end
      end
    end
  end

  def self.down
    Image.all.each do |image|
      image.can_scale_out = false
      image.save!
    end
  end
end
