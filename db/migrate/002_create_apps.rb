class CreateApps < ActiveRecord::Migration
	def up
		create_table :apps do |t|

		end
	end

	def down
		drop_table :apps
	end
end
