require 'active_record'

class Use < ActiveRecord::Base

	#Relations
	belongs_to :user #foreign key
	belongs_to :app	#foreign key

	#Validators
	validates :user_id, :presence => true
	validates :app_id, :presence => true

	validates_uniqueness_of :app_id, :scope => :user_id
end
