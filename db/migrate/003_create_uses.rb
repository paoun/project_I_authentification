class CreateUses < ActiveRecord::Migration
	def up
		create_table :uses do |t|
			t.integer :user_id
			t.integer :app_id
		end
	end

	def down
		destroy_table :uses 
	end
end
