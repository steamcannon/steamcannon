class EventSubject < ActiveRecord::Base
  has_ancestry
  
  belongs_to :subject, :polymorphic => true
  belongs_to :owner, :polymorphic => true
  has_many :events, :dependent => :destroy
end
