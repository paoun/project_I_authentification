class AddLoginPass < ActiveRecord::Migration
	def up
    	add_column :users, :login, :string
    	add_column :users, :password, :string
	end

	def down
		remove_column :users, :login
		remove_column :users, :password
	end

end
