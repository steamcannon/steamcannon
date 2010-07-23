require 'open-uri'

class App < ActiveRecord::Base
  has_attached_file(:archive,
                    :url => "/uploads/:id/:filename",
                    :path => ":rails_root/public/uploads/:id/:filename")
  validates_attachment_presence :archive
  validates_presence_of :name
end
