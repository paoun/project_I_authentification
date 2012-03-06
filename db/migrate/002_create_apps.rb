class CreateApps < ActiveRecord::Migration
	def up
		create_table :apps do |t|
			t.string :name
			t.string :url
		end
	end

	def down
		drop_table :apps
	end
end
