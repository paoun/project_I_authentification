class AddNameUrl < ActiveRecord::Migration
	def up
    	add_column :apps, :name, :string
    	add_column :apps, :url, :string
	end

	def down
		remove_column :apps, :name
		remove_column :apps, :url
	end

end
