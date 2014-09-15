class Post < ActiveRecord::Base
  # attr_accessible :picture_base64
  attr_accessor :picture_base64

  has_attached_file :picture,:styles => { :thumb => "100x100#" }
  validates_attachment_content_type :picture, :content_type => /\Aimage\/.*\Z/
end
